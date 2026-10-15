import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';

class PenyewaanScreen extends ConsumerStatefulWidget {
  const PenyewaanScreen({super.key});

  @override
  ConsumerState<PenyewaanScreen> createState() => _PenyewaanScreenState();
}

class _PenyewaanScreenState extends ConsumerState<PenyewaanScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showDetailSewa(SyncPenyewaan item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                      Text(
                        item.kodeSewa,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        item.keperluan,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(item.status),
                ],
              ),
              const Divider(height: 28),
              _buildDetailRow('Penyewa', '${item.namaPenyewa} (NPM: ${item.npm})'),
              _buildDetailRow('Kontak WhatsApp', item.noTelepon),
              _buildDetailRow('Unit Ormawa', item.ormawaTujuan),
              _buildDetailRow('Barang Disewa', item.namaBarang),
              _buildDetailRow(
                'Durasi Sewa',
                '${item.tglMulai.day}/${item.tglMulai.month} - ${item.tglKembali.day}/${item.tglKembali.month}/${item.tglKembali.year}',
              ),
              _buildDetailRow(
                'Biaya Sewa',
                'Rp ${item.totalHarga.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} • ${item.statusBayar}',
              ),
              _buildDetailRow(
                'Ketentuan Pembayaran',
                'Tanpa DP. Pembayaran dilakukan setelah pengembalian barang ke sekretariat.',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (item.status == 'menunggu') ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          ref.read(sisewaSyncProvider.notifier).rejectSewa(item.id);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengajuan sewa telah ditolak'),
                            ),
                          );
                        },
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          ref.read(sisewaSyncProvider.notifier).approveSewa(item.id);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pengajuan sewa disetujui! Stok inventaris otomatis berkurang.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Setujui Pengajuan'),
                      ),
                    ),
                  ] else if (item.status == 'disetujui') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 18,
                        ),
                        label: const Text('Tandai Selesai (Kembali)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(sisewaSyncProvider.notifier)
                              .selesaikanPengembalian(
                                kodeSewa: item.kodeSewa,
                                kondisiFisik: 'baik',
                                denda: 0,
                                biayaKerusakan: 0,
                                catatan: 'Barang kembali dalam kondisi baik & lengkap.',
                              );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Penyewaan selesai dan stok barang telah dipulihkan!',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'menunggu':
        bg = AppColors.infoBg;
        fg = AppColors.info;
        label = 'Menunggu';
        break;
      case 'disetujui':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        label = 'Disetujui / Aktif';
        break;
      case 'selesai':
        bg = AppColors.successBg;
        fg = AppColors.success;
        label = 'Selesai';
        break;
      case 'ditolak':
        bg = AppColors.errorBg;
        fg = AppColors.error;
        label = 'Ditolak';
        break;
      default:
        bg = AppColors.surfaceMuted;
        fg = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(sisewaSyncProvider);
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final profile = ref.watch(profileProvider).asData?.value;
    final adminOrg = profile?.namaOrganisasi?.trim() ?? '';
    final adminSingkatan = profile?.singkatanOrganisasi?.trim() ?? '';
    final isAdminOrmawa = user?.role == AppConstants.roleAdminOrmawa;

    bool isMatchOrmawa(String targetOrg) {
      if (!isAdminOrmawa) return true;
      if (adminOrg.isEmpty && adminSingkatan.isEmpty) return true;

      final t = targetOrg.toLowerCase().trim();
      final o = adminOrg.toLowerCase().trim();
      final s = adminSingkatan.toLowerCase().trim();

      if (o.isNotEmpty && (t.contains(o) || o.contains(t))) return true;
      if (s.isNotEmpty && (t.contains(s) || s.contains(t))) return true;

      final isBemTarget = t.contains('bem') || t.contains('badan eksekutif');
      final isBemAdmin = o.contains('bem') || o.contains('badan eksekutif') || s.contains('bem');
      if (isBemTarget && isBemAdmin) return true;

      final isHmtiTarget = t.contains('hmti') || t.contains('ti') || t.contains('informatika');
      final isHmtiAdmin = o.contains('hmti') || o.contains('ti') || o.contains('informatika') || s.contains('hmti');
      if (isHmtiTarget && isHmtiAdmin) return true;

      final isMmTarget = t.contains('multimedia');
      final isMmAdmin = o.contains('multimedia') || s.contains('multimedia');
      if (isMmTarget && isMmAdmin) return true;

      return false;
    }

    var sewaList = syncState.sewaList.where((item) {
      return isMatchOrmawa(item.ormawaTujuan);
    }).toList();

    if (sewaList.isEmpty && syncState.sewaList.isNotEmpty) {
      sewaList = syncState.sewaList;
    }

    final query = _searchCtrl.text.toLowerCase().trim();
    final filtered = sewaList.where((item) {
      final matchQuery = query.isEmpty ||
          item.kodeSewa.toLowerCase().contains(query) ||
          item.namaPenyewa.toLowerCase().contains(query) ||
          item.npm.contains(query) ||
          item.keperluan.toLowerCase().contains(query) ||
          item.namaBarang.toLowerCase().contains(query);

      final matchFilter = _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Menunggu' && item.status == 'menunggu') ||
          (_selectedFilter == 'Disetujui' && item.status == 'disetujui') ||
          (_selectedFilter == 'Selesai' && item.status == 'selesai') ||
          (_selectedFilter == 'Ditolak' && item.status == 'ditolak');

      return matchQuery && matchFilter;
    }).toList();

    final totalAktif = sewaList.where((s) => s.status == 'disetujui').length;
    final totalMenunggu = sewaList.where((s) => s.status == 'menunggu').length;
    final totalSelesai = sewaList.where((s) => s.status == 'selesai').length;

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
                'Penyewaan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kelola transaksi peminjaman aset. Pembayaran dilakukan setelah pengembalian barang.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== STATS CARDS =====
          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth > 900
                  ? 4
                  : (constraints.maxWidth > 560 ? 2 : 1);
              return GridView.count(
                crossAxisCount: cross,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 95,
                children: [
                  _buildStatMini(
                    'Total Pengajuan',
                    '${sewaList.length}',
                    Icons.assignment_outlined,
                    AppColors.primary,
                  ),
                  _buildStatMini(
                    'Sewa Aktif',
                    '$totalAktif',
                    Icons.schedule_rounded,
                    AppColors.warning,
                  ),
                  _buildStatMini(
                    'Menunggu Approval',
                    '$totalMenunggu',
                    Icons.hourglass_top_rounded,
                    AppColors.info,
                  ),
                  _buildStatMini(
                    'Selesai',
                    '$totalSelesai',
                    Icons.task_alt_rounded,
                    AppColors.success,
                  ),
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
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Cari kode sewa, nama penyewa, NPM, atau keperluan...',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textHint,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
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
                      'Semua',
                      'Menunggu',
                      'Disetujui',
                      'Selesai',
                      'Ditolak',
                    ].map((tab) {
                      final isSelected = _selectedFilter == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (val) =>
                              setState(() => _selectedFilter = tab),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ===== DAFTAR TRANSAKSI SEWA =====
          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Tidak ada data penyewaan ditemukan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final item = filtered[idx];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  padding: const EdgeInsets.all(18),
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
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.kodeSewa,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusBadge(item.status),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    item.statusBayar,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.namaPenyewa} (${item.npm}) • ${item.ormawaTujuan}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Keperluan: ${item.keperluan}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Barang: ${item.namaBarang}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Periode: ${item.tglMulai.day}/${item.tglMulai.month} s/d ${item.tglKembali.day}/${item.tglKembali.month}/${item.tglKembali.year} • Total: Rp ${item.totalHarga.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _showDetailSewa(item),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Detail'),
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

  Widget _buildStatMini(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
