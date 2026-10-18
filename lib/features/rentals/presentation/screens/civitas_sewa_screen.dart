import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CivitasSewaScreen extends ConsumerStatefulWidget {
  const CivitasSewaScreen({super.key});

  @override
  ConsumerState<CivitasSewaScreen> createState() => _CivitasSewaScreenState();
}

class _CivitasSewaScreenState extends ConsumerState<CivitasSewaScreen> {
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
      case 'menunggu':
        bg = AppColors.infoBg;
        fg = AppColors.info;
        label = 'Menunggu Persetujuan Ormawa';
        break;
      case 'disetujui':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        label = 'Disetujui / Aktif Dipinjam';
        break;
      case 'selesai':
        bg = AppColors.successBg;
        fg = AppColors.success;
        label = 'Selesai (Sudah Dikembalikan)';
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

  void _showDetailSewa(SyncPenyewaan item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.kodeSewa, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      Text('Penyedia: ${item.ormawaTujuan}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  _buildStatusBadge(item.status),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow('Nama Barang', item.namaBarang),
              _buildDetailRow('Keperluan Acara', item.keperluan),
              _buildDetailRow('Durasi Pinjam', '${item.tglMulai.day}/${item.tglMulai.month}/${item.tglMulai.year} s/d ${item.tglKembali.day}/${item.tglKembali.month}/${item.tglKembali.year}'),
              _buildDetailRow('Total Biaya Sewa', '${_formatCurrency(item.totalHarga)} • ${item.statusBayar}'),
              _buildDetailRow('Ketentuan Pembayaran', 'Tanpa DP. Pembayaran dilakukan setelah pengembalian barang ke sekretariat ormawa.'),
              const SizedBox(height: 20),
              if (item.status == 'selesai' && item.statusBayar != 'Lunas')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                        label: const Text('Bayar Tagihan (QRIS)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openQrisPayDialog(item);
                        },
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openQrisPayDialog(SyncPenyewaan item) {
    final catatanCtrl = TextEditingController();
    bool hasUploadedFile = true;
    final ormawaName = item.ormawaTujuan;
    final nmidCode = 'ID1024${(item.kodeSewa.hashCode.abs() % 900000 + 100000)}92';

    final syncState = ref.read(sisewaSyncProvider);
    final bayarItem = syncState.bayarList.firstWhere(
      (b) => b.kodeSewa == item.kodeSewa,
      orElse: () => SyncPembayaran(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        kodePembayaran: 'PAY-2026-00${syncState.bayarList.length + 1}',
        kodeSewa: item.kodeSewa,
        namaPenyewa: item.namaPenyewa,
        usernamePenyewa: item.usernamePenyewa,
        npm: item.npm,
        nominal: item.totalHarga,
        jenisPembayaran: 'Pelunasan Sewa',
        metodePembayaran: 'QRIS Ormawa ($ormawaName)',
        tanggalBayar: DateTime.now(),
        status: 'menunggu_pembayaran',
        nomorRef: 'INV-${item.kodeSewa}',
      ),
    );

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
                                Text(bayarItem.jenisPembayaran, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              ],
                            ),
                            Text(_formatCurrency(bayarItem.nominal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

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
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ormawaName.toUpperCase(),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NMID : $nmidCode',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

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

                      TextFormField(
                        controller: catatanCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Pelunasan (Opsional)',
                          hintText: 'Cth: Sudah lunas via QRIS Livin Mandiri',
                          prefixIcon: Icon(Icons.notes_rounded),
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
                    final existing = ref.read(sisewaSyncProvider).bayarList.any((b) => b.id == bayarItem.id);
                    if (existing) {
                      ref.read(sisewaSyncProvider.notifier).submitBuktiPembayaran(
                            bayarId: bayarItem.id,
                            metode: 'QRIS Ormawa ($ormawaName)',
                            nomorRef: refNo,
                            catatan: catatanCtrl.text.trim().isNotEmpty ? catatanCtrl.text.trim() : null,
                          );
                    } else {
                      ref.read(sisewaSyncProvider.notifier).kirimBuktiPembayaran(
                            sewa: item,
                            nominal: bayarItem.nominal,
                            metode: 'QRIS Ormawa ($ormawaName)',
                            nomorRef: refNo,
                            catatan: catatanCtrl.text.trim().isNotEmpty ? catatanCtrl.text.trim() : null,
                          );
                    }
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textHint, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(sisewaSyncProvider);
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    final query = _searchCtrl.text.toLowerCase().trim();

    final myUser = (user?.username ?? '').toLowerCase().trim();
    final myName = (user?.namaLengkap ?? '').toLowerCase().trim();

    // Tampilkan daftar sewa milik civitas
    final mySewaList = syncState.sewaList.where((item) {
      final itemUser = item.usernamePenyewa.toLowerCase().trim();
      final itemName = item.namaPenyewa.toLowerCase().trim();
      final isMine = myUser.isEmpty ||
          itemUser == myUser ||
          itemName == myName ||
          (myUser == 'civitas' && (itemUser == 'civitas' || itemUser == 'fajar.ramadhan'));

      final matchQuery = query.isEmpty ||
          item.kodeSewa.toLowerCase().contains(query) ||
          item.namaBarang.toLowerCase().contains(query) ||
          item.ormawaTujuan.toLowerCase().contains(query);

      final matchFilter = _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Menunggu' && item.status == 'menunggu') ||
          (_selectedFilter == 'Disetujui' && item.status == 'disetujui') ||
          (_selectedFilter == 'Selesai' && item.status == 'selesai') ||
          (_selectedFilter == 'Ditolak' && item.status == 'ditolak');

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
                'Sewa Saya',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.6),
              ),
              SizedBox(height: 4),
              Text(
                'Daftar permohonan peminjaman aset Anda ke organisasi mahasiswa kampus.',
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
                    hintText: 'Cari Kode Sewa, Nama Barang, atau Ormawa Tujuan...',
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
                      'Menunggu',
                      'Disetujui',
                      'Selesai',
                      'Ditolak',
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

          // ===== LIST SEWA =====
          if (mySewaList.isEmpty)
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
                  Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('Belum ada riwayat permohonan sewa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Silakan pilih barang di Katalog untuk mengajukan peminjaman.', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mySewaList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final item = mySewaList[idx];
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(item.kodeSewa, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                const SizedBox(width: 8),
                                _buildStatusBadge(item.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.namaBarang,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ormawa: ${item.ormawaTujuan} • Acara: ${item.keperluan}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Periode: ${item.tglMulai.day}/${item.tglMulai.month} - ${item.tglKembali.day}/${item.tglKembali.month}/${item.tglKembali.year} • Total: ${_formatCurrency(item.totalHarga)} (${item.statusBayar})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (item.status == 'selesai' && item.statusBayar != 'Lunas') ...[
                            ElevatedButton.icon(
                              onPressed: () => _openQrisPayDialog(item),
                              icon: const Icon(Icons.qr_code_scanner_rounded, size: 13),
                              label: const Text('Bayar QRIS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          OutlinedButton(
                            onPressed: () => _showDetailSewa(item),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            child: const Text('Detail'),
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
