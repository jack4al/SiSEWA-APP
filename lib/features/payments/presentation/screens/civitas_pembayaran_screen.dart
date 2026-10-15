import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CivitasPembayaranScreen extends ConsumerStatefulWidget {
  const CivitasPembayaranScreen({super.key});

  @override
  ConsumerState<CivitasPembayaranScreen> createState() =>
      _CivitasPembayaranScreenState();
}

class _CivitasPembayaranScreenState
    extends ConsumerState<CivitasPembayaranScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'lunas':
        bg = AppColors.successBg;
        fg = AppColors.success;
        label = 'Lunas';
        break;
      case 'menunggu_verifikasi':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        label = 'Menunggu Verifikasi Ormawa';
        break;
      case 'menunggu_pembayaran':
      case 'belum_bayar':
        bg = AppColors.infoBg;
        fg = AppColors.info;
        label = 'Menunggu Pembayaran';
        break;
      case 'ditolak':
        bg = AppColors.errorBg;
        fg = AppColors.error;
        label = 'Ditolak Ormawa';
        break;
      default:
        bg = AppColors.surfaceMuted;
        fg = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  void _openUploadBuktiDialog(SyncPembayaran item) {
    final catatanCtrl = TextEditingController();
    bool hasUploadedFile = true;

    // Cari ormawa tujuan dari sewa
    final syncState = ref.read(sisewaSyncProvider);
    final sewa = syncState.sewaList.firstWhere(
      (s) => s.kodeSewa == item.kodeSewa,
      orElse: () => syncState.sewaList.first,
    );
    final ormawaName = sewa.ormawaTujuan;
    final nmidCode = 'ID1024${(item.kodeSewa.hashCode.abs() % 900000 + 100000)}92';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Pembayaran QRIS Ormawa', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text('Scan & upload bukti pelunasan sewa', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rincian Tagihan
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tagihan: ${item.kodeSewa}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                                const SizedBox(height: 2),
                                Text(item.jenisPembayaran, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              ],
                            ),
                            Text(_formatCurrency(item.nominal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // STANDAR QRIS RESMI ORMAWA
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header QRIS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'QRIS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'PEMBAYARAN RESMI ORMAWA',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textHint,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // QR Box Visual
                            Container(
                              width: 150,
                              height: 150,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 130,
                                    color: Color(0xFF1E293B),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary, width: 1.5),
                                    ),
                                    child: const Icon(Icons.school, size: 18, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Merchant Details
                            Text(
                              ormawaName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NMID: $nmidCode',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${_formatCurrency(item.nominal)} (Otomatis Masuk Kas $ormawaName)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Box Unggah Bukti QRIS (Interactive)
                      InkWell(
                        onTap: () {
                          setDialogState(() {
                            hasUploadedFile = !hasUploadedFile;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: hasUploadedFile ? AppColors.successBg : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasUploadedFile ? AppColors.success : AppColors.border,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasUploadedFile ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                                color: hasUploadedFile ? AppColors.success : AppColors.textSecondary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasUploadedFile ? 'Screenshot_QRIS_${item.kodeSewa}.png' : 'Unggah Tangkapan Layar QRIS',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: hasUploadedFile ? AppColors.success : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      hasUploadedFile ? 'Ukuran: 284 KB • Siap diverifikasi' : 'Format JPG/PNG dari m-Banking / e-Wallet',
                                      style: const TextStyle(fontSize: 10.5, color: AppColors.textHint),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                hasUploadedFile ? 'Ganti' : 'Pilih File',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: hasUploadedFile ? AppColors.success : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Catatan Tambahan (Opsional)
                      TextFormField(
                        controller: catatanCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Pelunasan (Opsional)',
                          hintText: 'Cth: Sudah lunas via QRIS Livin Mandiri',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pembayaran otomatis diverifikasi langsung oleh bendahara $ormawaName.',
                                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
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
                    final refNo = 'QRIS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                    ref.read(sisewaSyncProvider.notifier).submitBuktiPembayaran(
                          bayarId: item.id,
                          metode: 'QRIS Ormawa ($ormawaName)',
                          nomorRef: refNo,
                          catatan: catatanCtrl.text.trim().isNotEmpty
                              ? catatanCtrl.text.trim()
                              : null,
                        );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bukti QRIS berhasil dikirim! Menunggu konfirmasi bendahara $ormawaName.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Kirim Bukti Pembayaran'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(sisewaSyncProvider);
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    // 1. Kumpulkan semua pembayaran dari syncState.bayarList
    final List<SyncPembayaran> allMyBayar = [...syncState.bayarList];
    final existingKodeSewa = allMyBayar.map((b) => b.kodeSewa).toSet();

    final myUsername = (user?.username ?? '').toLowerCase().trim();
    final myFullName = (user?.namaLengkap ?? '').toLowerCase().trim();

    // 2. Backfill otomatis jika civitas memiliki transaksi sewa yang belum terbit tagihannya di bayarList
    for (final s in syncState.sewaList) {
      final sUser = s.usernamePenyewa.toLowerCase().trim();
      final sName = s.namaPenyewa.toLowerCase().trim();
      final isMine = myUsername.isEmpty ||
          sUser == myUsername ||
          sName == myFullName ||
          (myUsername == 'civitas' && (sUser == 'civitas' || sUser == 'fajar.ramadhan'));

      if (isMine && !existingKodeSewa.contains(s.kodeSewa)) {
        allMyBayar.add(
          SyncPembayaran(
            id: 'pay_${s.id}',
            kodePembayaran: 'PAY-${s.kodeSewa}',
            kodeSewa: s.kodeSewa,
            namaPenyewa: s.namaPenyewa,
            usernamePenyewa: s.usernamePenyewa,
            npm: s.npm,
            nominal: s.totalHarga,
            jenisPembayaran: 'Pelunasan Sewa',
            metodePembayaran: 'QRIS Ormawa (${s.ormawaTujuan})',
            tanggalBayar: s.tglMulai,
            status: s.statusBayar == 'Lunas'
                ? 'lunas'
                : (s.statusBayar == 'Menunggu Verifikasi'
                    ? 'menunggu_verifikasi'
                    : 'menunggu_pembayaran'),
            nomorRef: 'INV-${s.kodeSewa}',
            catatan: 'Tagihan sewa ${s.namaBarang} ke ${s.ormawaTujuan}',
          ),
        );
        existingKodeSewa.add(s.kodeSewa);
      }
    }

    final query = _searchCtrl.text.toLowerCase().trim();

    final myBayarList = allMyBayar.where((item) {
      final itemUser = item.usernamePenyewa.toLowerCase().trim();
      final itemName = item.namaPenyewa.toLowerCase().trim();
      final isMine = myUsername.isEmpty ||
          itemUser == myUsername ||
          itemName == myFullName ||
          (myUsername == 'civitas' && (itemUser == 'civitas' || itemUser == 'fajar.ramadhan'));

      final matchQuery = query.isEmpty ||
          item.kodePembayaran.toLowerCase().contains(query) ||
          item.kodeSewa.toLowerCase().contains(query) ||
          item.nomorRef.toLowerCase().contains(query);

      final matchFilter = _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Menunggu Pembayaran' &&
              (item.status == 'menunggu_pembayaran' || item.status == 'belum_bayar')) ||
          (_selectedFilter == 'Menunggu Verifikasi' && item.status == 'menunggu_verifikasi') ||
          (_selectedFilter == 'Lunas' && item.status == 'lunas');

      return isMine && matchQuery && matchFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Pembayaran Saya',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.6),
              ),
              SizedBox(height: 4),
              Text(
                'Pelunasan biaya sewa setelah barang dikembalikan ke ormawa (Tanpa DP).',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== PENCARIAN & FILTER =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari No. Kuitansi atau Kode Sewa...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Semua',
                      'Menunggu Pembayaran',
                      'Menunggu Verifikasi',
                      'Lunas',
                    ].map((f) {
                      final isSelected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
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
                            if (selected) setState(() => _selectedFilter = f);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ===== LIST PEMBAYARAN =====
          if (myBayarList.isEmpty)
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
                  Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('Tidak ada tagihan atau transaksi pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Tagihan sewa akan terbit otomatis setelah barang selesai digunakan & dikembalikan.', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myBayarList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final item = myBayarList[idx];
                final isLunas = item.status == 'lunas';

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(item.kodePembayaran, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                              ),
                              const SizedBox(width: 8),
                              Text('No. Sewa: ${item.kodeSewa}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            ],
                          ),
                          _buildStatusBadge(item.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.jenisPembayaran, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Metode: ${item.metodePembayaran}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                          Text(_formatCurrency(item.nominal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                      const Divider(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Waktu: ${item.tanggalBayar.day}/${item.tanggalBayar.month}/${item.tanggalBayar.year}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                          ),
                          if (!isLunas)
                            ElevatedButton.icon(
                              onPressed: () => _openUploadBuktiDialog(item),
                              icon: Icon(
                                item.status == 'menunggu_verifikasi'
                                    ? Icons.edit_note_rounded
                                    : Icons.qr_code_scanner_rounded,
                                size: 15,
                              ),
                              label: Text(
                                item.status == 'menunggu_verifikasi'
                                    ? 'Perbarui Bukti QRIS'
                                    : 'Bayar via QRIS',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Tervalidasi Kas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
