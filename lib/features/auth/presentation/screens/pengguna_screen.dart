import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

class UserModelItem {
  final String id;
  String namaLengkap;
  String username;
  String email;
  String noTelepon;
  String role; // 'penyewa', 'admin_ormawa'
  String npmOrOrganisasi;
  String status; // 'aktif', 'nonaktif'
  DateTime createdAt;

  UserModelItem({
    required this.id,
    required this.namaLengkap,
    required this.username,
    required this.email,
    required this.noTelepon,
    required this.role,
    required this.npmOrOrganisasi,
    required this.status,
    required this.createdAt,
  });
}

class PenggunaScreen extends ConsumerStatefulWidget {
  const PenggunaScreen({super.key});

  @override
  ConsumerState<PenggunaScreen> createState() => _PenggunaScreenState();
}

class _PenggunaScreenState extends ConsumerState<PenggunaScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'Semua';

  late List<UserModelItem> _userList;

  @override
  void initState() {
    super.initState();
    _userList = [
      UserModelItem(
        id: '1',
        namaLengkap: 'Fajar Ramadhan',
        username: 'fajar.ramadhan',
        email: 'fajar.ramadhan@student.ac.id',
        noTelepon: '081234567890',
        role: 'penyewa',
        npmOrOrganisasi: '2110631170012 • Teknik Informatika',
        status: 'aktif',
        createdAt: DateTime(2026, 2, 10),
      ),
      UserModelItem(
        id: '2',
        namaLengkap: 'Annisa Rahmawati',
        username: 'annisa.rahma',
        email: 'annisa.rahma@student.ac.id',
        noTelepon: '085712349876',
        role: 'penyewa',
        npmOrOrganisasi: '2210631170045 • Sistem Informasi',
        status: 'aktif',
        createdAt: DateTime(2026, 3, 14),
      ),
      UserModelItem(
        id: '3',
        namaLengkap: 'Admin BEM FT',
        username: 'bemft.admin',
        email: 'bem.teknik@univ.ac.id',
        noTelepon: '081399887766',
        role: 'admin_ormawa',
        npmOrOrganisasi: 'BEM Fakultas Teknik',
        status: 'aktif',
        createdAt: DateTime(2026, 1, 5),
      ),
      UserModelItem(
        id: '4',
        namaLengkap: 'Dewi Anggraini',
        username: 'dewi.ang',
        email: 'dewi.ang@student.ac.id',
        noTelepon: '081399887766',
        role: 'penyewa',
        npmOrOrganisasi: '2110631170088 • Ilmu Komunikasi',
        status: 'aktif',
        createdAt: DateTime(2026, 4, 1),
      ),
      UserModelItem(
        id: '5',
        namaLengkap: 'Admin HMTI',
        username: 'hmti.admin',
        email: 'hmti@univ.ac.id',
        noTelepon: '082211445566',
        role: 'admin_ormawa',
        npmOrOrganisasi: 'Himpunan Mahasiswa TI',
        status: 'aktif',
        createdAt: DateTime(2026, 1, 15),
      ),
      UserModelItem(
        id: '6',
        namaLengkap: 'Rian Pratama',
        username: 'rian.pratama',
        email: 'rian.pratama@student.ac.id',
        noTelepon: '082155443322',
        role: 'penyewa',
        npmOrOrganisasi: '2010631170034 • Teknik Mesin',
        status: 'aktif',
        createdAt: DateTime(2026, 5, 20),
      ),
      UserModelItem(
        id: '7',
        namaLengkap: 'Budi Santoso',
        username: 'budi.santoso',
        email: 'budi.santoso@student.ac.id',
        noTelepon: '087811223344',
        role: 'penyewa',
        npmOrOrganisasi: '2210631170090 • Manajemen',
        status: 'nonaktif',
        createdAt: DateTime(2026, 6, 8),
      ),
    ];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<UserModelItem> get _filteredUsers {
    final query = _searchCtrl.text.toLowerCase().trim();
    return _userList.where((u) {
      final matchQuery = query.isEmpty ||
          u.namaLengkap.toLowerCase().contains(query) ||
          u.username.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          u.npmOrOrganisasi.toLowerCase().contains(query);

      final matchFilter = _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Mahasiswa Penyewa' && u.role == 'penyewa') ||
          (_selectedFilter == 'Admin Ormawa' && u.role == 'admin_ormawa') ||
          (_selectedFilter == 'Aktif' && u.status == 'aktif') ||
          (_selectedFilter == 'Nonaktif' && u.status == 'nonaktif');

      return matchQuery && matchFilter;
    }).toList();
  }

  void _openCreateUserDialog() {
    final namaCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final noTelpCtrl = TextEditingController();
    final identitasCtrl = TextEditingController();
    String role = 'penyewa';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text('Tambah Pengguna Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        decoration: const InputDecoration(labelText: 'Peran Akun / Role', prefixIcon: Icon(Icons.badge_outlined)),
                        items: const [
                          DropdownMenuItem(value: 'penyewa', child: Text('Mahasiswa Penyewa')),
                          DropdownMenuItem(value: 'admin_ormawa', child: Text('Admin Ormawa')),
                        ],
                        onChanged: (v) => setDialogState(() => role = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: namaCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: usernameCtrl,
                              decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email_rounded)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: identitasCtrl,
                              decoration: InputDecoration(
                                labelText: role == 'penyewa' ? 'NPM & Prodi' : 'Nama Organisasi',
                                prefixIcon: const Icon(Icons.numbers_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Alamat Email', prefixIcon: Icon(Icons.email_outlined)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noTelpCtrl,
                        decoration: const InputDecoration(labelText: 'No. WhatsApp / Telepon', prefixIcon: Icon(Icons.phone_outlined)),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    if (namaCtrl.text.trim().isEmpty || usernameCtrl.text.trim().isEmpty) return;

                    final newUser = UserModelItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      namaLengkap: namaCtrl.text.trim(),
                      username: usernameCtrl.text.trim().toLowerCase(),
                      email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : '${usernameCtrl.text.trim()}@univ.ac.id',
                      noTelepon: noTelpCtrl.text.trim().isNotEmpty ? noTelpCtrl.text.trim() : '081234567890',
                      role: role,
                      npmOrOrganisasi: identitasCtrl.text.trim().isNotEmpty
                          ? identitasCtrl.text.trim()
                          : (role == 'penyewa' ? '2210631170099' : 'Unit Ormawa'),
                      status: 'aktif',
                      createdAt: DateTime.now(),
                    );

                    setState(() {
                      _userList.insert(0, newUser);
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pengguna ${newUser.namaLengkap} berhasil ditambahkan!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Simpan Pengguna'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openEditUserDialog(UserModelItem user) {
    final namaCtrl = TextEditingController(text: user.namaLengkap);
    final emailCtrl = TextEditingController(text: user.email);
    final noTelpCtrl = TextEditingController(text: user.noTelepon);
    final identitasCtrl = TextEditingController(text: user.npmOrOrganisasi);
    String status = user.status;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('Edit Akun: ${user.username}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: namaCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: identitasCtrl,
                        decoration: InputDecoration(
                          labelText: user.role == 'penyewa' ? 'NPM & Prodi' : 'Organisasi',
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Alamat Email', prefixIcon: Icon(Icons.email_outlined)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noTelpCtrl,
                        decoration: const InputDecoration(labelText: 'No. WhatsApp', prefixIcon: Icon(Icons.phone_outlined)),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'Status Akun', prefixIcon: Icon(Icons.toggle_on_outlined)),
                        items: const [
                          DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                          DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif (Dibekukan)')),
                        ],
                        onChanged: (v) => setDialogState(() => status = v!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    setState(() {
                      user.namaLengkap = namaCtrl.text.trim();
                      user.email = emailCtrl.text.trim();
                      user.noTelepon = noTelpCtrl.text.trim();
                      user.npmOrOrganisasi = identitasCtrl.text.trim();
                      user.status = status;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data pengguna berhasil diperbarui!'), backgroundColor: AppColors.success),
                    );
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteUser(UserModelItem user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengguna?'),
        content: Text('Yakin ingin menghapus akun ${user.namaLengkap} (@${user.username})? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() => _userList.remove(user));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengguna berhasil dihapus'), backgroundColor: AppColors.error),
              );
            },
            child: const Text('Hapus Akun'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMini(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;
    final totalPenyewa = _userList.where((u) => u.role == 'penyewa').length;
    final totalOrmawa = _userList.where((u) => u.role == 'admin_ormawa').length;
    final totalAktif = _userList.where((u) => u.status == 'aktif').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER & TAMBAH BUTTON =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Pengguna',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.6),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola data akun mahasiswa penyewa dan admin ormawa dalam sistem SISEWA.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _openCreateUserDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Pengguna'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== STATS CARDS =====
          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 560 ? 2 : 1);
              return GridView.count(
                crossAxisCount: cross,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 95,
                children: [
                  _buildStatMini('Total Pengguna', '${_userList.length} Akun', Icons.people_outline, AppColors.primary),
                  _buildStatMini('Mahasiswa Penyewa', '$totalPenyewa Akun', Icons.school_outlined, AppColors.info),
                  _buildStatMini('Admin Ormawa', '$totalOrmawa Akun', Icons.admin_panel_settings_outlined, AppColors.warning),
                  _buildStatMini('Akun Aktif', '$totalAktif Akun', Icons.verified_user_outlined, AppColors.success),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // ===== SEARCH & FILTER PILLS =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Cari nama lengkap, username, NPM, atau email...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua'),
                      _buildFilterChip('Mahasiswa Penyewa'),
                      _buildFilterChip('Admin Ormawa'),
                      _buildFilterChip('Aktif'),
                      _buildFilterChip('Nonaktif'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ===== LIST PENGGUNA =====
          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.person_off_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('Tidak ada pengguna ditemukan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text('Coba ubah kata kunci pencarian atau filter status.', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = filtered[index];
                return _buildUserCard(user);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: const Color(0xFFF3F4F6),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
        onSelected: (selected) {
          if (selected) setState(() => _selectedFilter = label);
        },
      ),
    );
  }

  Widget _buildUserCard(UserModelItem user) {
    final isPenyewa = user.role == 'penyewa';
    final isAktif = user.status == 'aktif';

    final initials = user.namaLengkap.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar Initial
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPenyewa ? AppColors.primarySurface : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isPenyewa ? AppColors.primary : const Color(0xFFB45309),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.namaLengkap,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPenyewa ? AppColors.primarySurface : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPenyewa ? 'Penyewa' : 'Admin Ormawa',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isPenyewa ? AppColors.primary : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAktif ? AppColors.successBg : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAktif ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isAktif ? AppColors.success : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username} • ${user.npmOrOrganisasi}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 13, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(user.email, style: const TextStyle(fontSize: 11.5, color: AppColors.textHint)),
                    const SizedBox(width: 14),
                    const Icon(Icons.phone_outlined, size: 13, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(user.noTelepon, style: const TextStyle(fontSize: 11.5, color: AppColors.textHint)),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              IconButton(
                tooltip: 'Edit Akun',
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                onPressed: () => _openEditUserDialog(user),
              ),
              IconButton(
                tooltip: isAktif ? 'Nonaktifkan Akun' : 'Aktifkan Akun',
                icon: Icon(
                  isAktif ? Icons.toggle_on : Icons.toggle_off_outlined,
                  size: 26,
                  color: isAktif ? AppColors.success : AppColors.textHint,
                ),
                onPressed: () {
                  setState(() {
                    user.status = isAktif ? 'nonaktif' : 'aktif';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status @${user.username} diubah menjadi ${user.status}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Hapus Pengguna',
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                onPressed: () => _confirmDeleteUser(user),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
