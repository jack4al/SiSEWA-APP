import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialOrmawa;

  const ChatScreen({super.key, this.initialOrmawa});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  String? _selectedContact;

  @override
  void initState() {
    super.initState();
    _selectedContact = widget.initialOrmawa;
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  bool _isMatchOrmawa(String targetOrg, String queryOrg) {
    final t = targetOrg.toLowerCase().trim();
    final q = queryOrg.toLowerCase().trim();

    if (t == q || t.contains(q) || q.contains(t)) return true;

    final isTargetBem = t.contains('bem') || t.contains('badan eksekutif');
    final isQueryBem = q.contains('bem') || q.contains('badan eksekutif');
    if (isTargetBem && isQueryBem) return true;

    final isTargetHmti = t.contains('hmti') || t.contains('ti') || t.contains('informatika');
    final isQueryHmti = q.contains('hmti') || q.contains('ti') || q.contains('informatika');
    if (isTargetHmti && isQueryHmti) return true;

    final isTargetMm = t.contains('multimedia');
    final isQueryMm = q.contains('multimedia');
    if (isTargetMm && isQueryMm) return true;

    return false;
  }

  void _sendMessage({
    required bool isPenyewa,
    required String senderName,
    required String senderUsername,
    required String contactName,
  }) {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    final profile = ref.read(profileProvider).asData?.value;
    final adminOrg = profile?.namaOrganisasi?.trim() ?? '';
    final ormawaName = isPenyewa
        ? contactName
        : (adminOrg.isNotEmpty ? adminOrg : 'BEM Fakultas Teknik');

    String receiverUsername;
    final syncState = ref.read(sisewaSyncProvider);

    if (isPenyewa) {
      final existingChat = syncState.chatList
          .where((c) =>
              _isMatchOrmawa(c.ormawaName, contactName) &&
              c.senderRole == 'admin_ormawa')
          .firstOrNull;
      if (existingChat != null) {
        receiverUsername = existingChat.senderUsername;
      } else if (contactName.toLowerCase().contains('bem') ||
          contactName.toLowerCase().contains('badan eksekutif')) {
        receiverUsername = 'bem_ft';
      } else if (contactName.toLowerCase().contains('hmti') ||
          contactName.toLowerCase().contains('ti') ||
          contactName.toLowerCase().contains('informatika')) {
        receiverUsername = 'hmti';
      } else if (contactName.toLowerCase().contains('multimedia')) {
        receiverUsername = 'ukm_multimedia';
      } else {
        receiverUsername = contactName.toLowerCase().replaceAll(' ', '_');
      }
    } else {
      final contactClean = contactName.toLowerCase().trim();
      final contactDot = contactClean.replaceAll(' ', '.');
      final contactUnder = contactClean.replaceAll(' ', '_');

      final existingChat = syncState.chatList
          .where((c) =>
              c.senderName.toLowerCase().trim() == contactClean ||
              c.senderUsername.toLowerCase().trim() == contactDot ||
              c.senderUsername.toLowerCase().trim() == contactUnder ||
              c.receiverUsername.toLowerCase().trim() == contactDot ||
              c.receiverUsername.toLowerCase().trim() == contactUnder)
          .firstOrNull;

      if (existingChat != null) {
        receiverUsername = existingChat.senderRole == 'penyewa'
            ? existingChat.senderUsername
            : existingChat.receiverUsername;
      } else {
        final existingSewa = syncState.sewaList
            .where((s) => s.namaPenyewa.toLowerCase().trim() == contactClean)
            .firstOrNull;
        receiverUsername =
            existingSewa?.usernamePenyewa ?? contactDot;
      }
    }

    ref.read(sisewaSyncProvider.notifier).kirimPesan(
          senderRole: isPenyewa ? 'penyewa' : 'admin_ormawa',
          senderName: senderName,
          senderUsername: senderUsername,
          receiverUsername: receiverUsername,
          ormawaName: ormawaName,
          message: text,
        );

    _messageCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(sisewaSyncProvider);
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final profile = ref.watch(profileProvider).asData?.value;
    final adminOrg = profile?.namaOrganisasi?.trim() ?? '';
    final isPenyewa = user?.isPenyewa ?? false;

    // Daftar kontak percakapan yang tersinkronisasi dinamis
    final Set<String> contactSet = {};
    if (isPenyewa) {
      // Civitas dapat chat ke seluruh ormawa penyedia aset
      for (final b in syncState.barangList) {
        if (b.unitOrmawa.isNotEmpty) contactSet.add(b.unitOrmawa);
      }
      for (final s in syncState.sewaList) {
        if (s.ormawaTujuan.isNotEmpty) contactSet.add(s.ormawaTujuan);
      }
      for (final c in syncState.chatList) {
        if (c.ormawaName.isNotEmpty) contactSet.add(c.ormawaName);
      }
      if (contactSet.isEmpty) {
        contactSet.addAll([
          'BEM Fakultas Teknik',
          'Himpunan Mahasiswa TI',
          'UKM Multimedia',
          'Pramuka Racana',
        ]);
      }
    } else {
      // Ormawa dapat chat ke mahasiswa yang mengajukan sewa / mengirim pesan
      for (final s in syncState.sewaList) {
        if (s.namaPenyewa.isNotEmpty) {
          if (adminOrg.isEmpty || _isMatchOrmawa(s.ormawaTujuan, adminOrg)) {
            contactSet.add(s.namaPenyewa);
          }
        }
      }
      for (final c in syncState.chatList) {
        if (c.senderName.isNotEmpty && c.senderRole == 'penyewa') {
          if (adminOrg.isEmpty || _isMatchOrmawa(c.ormawaName, adminOrg)) {
            contactSet.add(c.senderName);
          }
        }
      }
      if (contactSet.isEmpty) {
        contactSet.addAll([
          'Fajar Ramadhan',
          'Annisa Rahmawati',
          'Dewi Anggraini',
          'Rian Pratama',
        ]);
      }
    }

    final contacts = contactSet.toList();

    if ((_selectedContact == null || !contacts.contains(_selectedContact)) &&
        contacts.isNotEmpty) {
      _selectedContact = contacts.first;
    }

    final query = _searchCtrl.text.toLowerCase().trim();
    final filteredContacts = contacts.where((c) {
      return query.isEmpty || c.toLowerCase().contains(query);
    }).toList();

    // Pesan-pesan pada thread yang sedang aktif
    final activeMessages = syncState.chatList.where((m) {
      if (isPenyewa) {
        final matchesOrmawa =
            _isMatchOrmawa(m.ormawaName, _selectedContact ?? '');
        final myUser = user?.username.toLowerCase() ?? '';
        final myName = user?.namaLengkap.toLowerCase() ?? '';
        final isMyChat = myUser.isEmpty ||
            m.senderUsername.toLowerCase() == myUser ||
            m.receiverUsername.toLowerCase() == myUser ||
            m.senderName.toLowerCase() == myName ||
            (myUser != 'annisa.rahma' &&
                myUser != 'dewi.ang' &&
                (m.senderUsername == 'fajar.ramadhan' ||
                    m.receiverUsername == 'fajar.ramadhan'));
        return matchesOrmawa && isMyChat;
      } else {
        final contactLower = _selectedContact?.toLowerCase().trim() ?? '';
        final contactDot = contactLower.replaceAll(' ', '.');
        final contactUnder = contactLower.replaceAll(' ', '_');

        String contactUsername = '';
        final matchChat = syncState.chatList
            .where((c) =>
                c.senderName.toLowerCase().trim() == contactLower ||
                c.senderUsername.toLowerCase().trim() == contactDot ||
                c.senderUsername.toLowerCase().trim() == contactUnder)
            .firstOrNull;
        if (matchChat != null) {
          contactUsername = matchChat.senderRole == 'penyewa'
              ? matchChat.senderUsername.toLowerCase().trim()
              : matchChat.receiverUsername.toLowerCase().trim();
        }
        final matchSewa = syncState.sewaList
            .where((s) => s.namaPenyewa.toLowerCase().trim() == contactLower)
            .firstOrNull;
        if (matchSewa != null) {
          contactUsername = matchSewa.usernamePenyewa.toLowerCase().trim();
        }

        final senderLower = m.senderName.toLowerCase().trim();
        final recvLower = m.receiverUsername.toLowerCase().trim();
        final senderUserLower = m.senderUsername.toLowerCase().trim();

        final matchesContact = senderLower == contactLower ||
            (contactUsername.isNotEmpty &&
                (senderUserLower == contactUsername || recvLower == contactUsername)) ||
            recvLower == contactDot ||
            recvLower == contactUnder ||
            senderUserLower == contactDot ||
            senderUserLower == contactUnder ||
            (contactLower.isNotEmpty && senderLower.contains(contactLower)) ||
            (contactLower.isNotEmpty && contactLower.contains(senderLower));

        return matchesContact;
      }
    }).toList();

    return Container(
      color: AppColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;

          if (isWide) {
            return Row(
              children: [
                // KOLOM KIRI: DAFTAR KONTAK / PERCAKAPAN
                SizedBox(
                  width: 320,
                  child: _buildContactList(
                    filteredContacts,
                    syncState.chatList,
                    isPenyewa,
                  ),
                ),
                const VerticalDivider(width: 1, color: AppColors.border),

                // KOLOM KANAN: RUANG OBROLAN AKTIF
                Expanded(
                  child: _buildChatArea(
                    isPenyewa: isPenyewa,
                    userName: user?.namaLengkap ?? (isPenyewa ? 'Mahasiswa' : 'Admin Ormawa'),
                    userUsername: user?.username ?? (isPenyewa ? 'civitas' : 'admin_ormawa'),
                    activeMessages: activeMessages,
                  ),
                ),
              ],
            );
          } else {
            // Mode layar sempit / mobile
            return _selectedContact == null
                ? _buildContactList(
                    filteredContacts,
                    syncState.chatList,
                    isPenyewa,
                  )
                : _buildChatArea(
                    isPenyewa: isPenyewa,
                    userName: user?.namaLengkap ?? (isPenyewa ? 'Mahasiswa' : 'Admin Ormawa'),
                    userUsername: user?.username ?? (isPenyewa ? 'civitas' : 'admin_ormawa'),
                    activeMessages: activeMessages,
                    onBackToList: () => setState(() => _selectedContact = null),
                  );
          }
        },
      ),
    );
  }

  // ============================================================
  // 1. DAFTAR KONTAK PERCAKAPAN
  // ============================================================
  Widget _buildContactList(
    List<String> contacts,
    List<SyncChatMessage> allMessages,
    bool isPenyewa,
  ) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kontak
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isPenyewa ? 'Chat Ormawa' : 'Pesan Penyewa',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${contacts.length} Kontak',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: AppColors.textHint),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Cari nama ormawa/penyewa...',
                            hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textHint),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // List Kontak
          Expanded(
            child: ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border, indent: 64),
              itemBuilder: (context, idx) {
                final contact = contacts[idx];
                final isSelected = _selectedContact == contact;

                // Ambil pesan terakhir untuk preview
                final contactMsgs = allMessages.where((m) {
                  if (isPenyewa) {
                    return m.ormawaName == contact;
                  } else {
                    return m.senderName == contact ||
                        m.receiverUsername.contains(contact.toLowerCase().replaceAll(' ', '.'));
                  }
                }).toList();

                final lastMsg = contactMsgs.isNotEmpty ? contactMsgs.last : null;

                return InkWell(
                  onTap: () => setState(() => _selectedContact = contact),
                  child: Container(
                    color: isSelected ? AppColors.primarySurface.withValues(alpha: 0.5) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isPenyewa
                              ? AppColors.primary
                              : const Color(0xFF3B82F6),
                          child: Text(
                            contact.isNotEmpty ? contact[0].toUpperCase() : 'C',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      contact,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (lastMsg != null)
                                    Text(
                                      '${lastMsg.timestamp.hour.toString().padLeft(2, '0')}:${lastMsg.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 10.5, color: AppColors.textHint),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                lastMsg?.message ?? 'Belum ada percakapan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2. RUANG OBROLAN AKTIF
  // ============================================================
  Widget _buildChatArea({
    required bool isPenyewa,
    required String userName,
    required String userUsername,
    required List<SyncChatMessage> activeMessages,
    VoidCallback? onBackToList,
  }) {
    final contact = _selectedContact ?? 'Pilih Percakapan';

    return Column(
      children: [
        // Topbar Chat
        Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            children: [
              if (onBackToList != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBackToList,
                ),
              CircleAvatar(
                radius: 19,
                backgroundColor: isPenyewa ? AppColors.primary : const Color(0xFF3B82F6),
                child: Text(
                  contact.isNotEmpty ? contact[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isPenyewa ? 'Sekretariat Ormawa • Online' : 'Penyewa Kampus • Aktif',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Terkoneksi SISEWA',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List Bubble Chat
        Expanded(
          child: activeMessages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: AppColors.primary),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Mulai obrolan dengan $contact',
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tanyakan ketersediaan barang, jadwal serah terima, atau verifikasi sewa.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: activeMessages.length,
                  itemBuilder: (context, idx) {
                    final msg = activeMessages[idx];
                    final isMe = isPenyewa
                        ? msg.senderRole == 'penyewa'
                        : msg.senderRole == 'admin_ormawa';

                    return _buildMessageBubble(msg, isMe);
                  },
                ),
        ),

        // Suggested Quick Replies Chips
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: (isPenyewa
                      ? [
                          'Halo admin, apakah alat siap diambil?',
                          'Kuitansi QRIS sudah saya bayar ya',
                          'Barang sudah dikembalikan di sekre',
                        ]
                      : [
                          'Halo, barang sudah kami siapkan di sekre ya.',
                          'Pembayaran QRIS Anda sudah kami verifikasi.',
                          'Mohon bawa KTM asli saat serah terima barang.',
                        ])
                  .map((chip) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(chip),
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
                    onPressed: () {
                      _messageCtrl.text = chip;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Bottom Input Bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _messageCtrl,
                    onSubmitted: (_) => _sendMessage(
                      isPenyewa: isPenyewa,
                      senderName: userName,
                      senderUsername: userUsername,
                      contactName: contact,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan untuk $contact...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: () => _sendMessage(
                    isPenyewa: isPenyewa,
                    senderName: userName,
                    senderUsername: userUsername,
                    contactName: contact,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(SyncChatMessage msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFE5E7EB),
              child: Text(
                msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: isMe ? null : Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Text(
                      msg.senderName,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    msg.message,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')} WIB',
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.textHint,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.done_all_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
