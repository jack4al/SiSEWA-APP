import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../../../inventory/presentation/providers/barang_provider.dart';
import '../../../inventory/presentation/providers/kategori_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final profile = ref.watch(profileProvider).asData?.value;
    final adminOrg = profile?.namaOrganisasi?.trim() ?? '';
    final adminSingkatan = profile?.singkatanOrganisasi?.trim() ?? '';
    final isAdminOrmawa = user?.role == AppConstants.roleAdminOrmawa;

    bool isMatchOrmawa(String targetOrg) {
      if (!isAdminOrmawa) return true;
      if (adminOrg.isEmpty && adminSingkatan.isEmpty) return false;

      final t = targetOrg.toLowerCase().trim();
      final o = adminOrg.toLowerCase().trim();
      final s = adminSingkatan.toLowerCase().trim();

      if (t.isEmpty) return false;

      if (o.isNotEmpty && (t.contains(o) || o.contains(t))) return true;
      if (s.isNotEmpty && (t.contains(s) || s.contains(t))) return true;

      final isBemTarget = t.contains('bem') || t.contains('badan eksekutif');
      final isBemAdmin = o.contains('bem') || o.contains('badan eksekutif') || s.contains('bem');
      if (isBemTarget && isBemAdmin) return true;

      final isHmtiTarget = t.contains('hmti') || t.contains('teknik informatika') || t.contains('teknologi informasi') || RegExp(r'\bti\b').hasMatch(t);
      final isHmtiAdmin = o.contains('hmti') || o.contains('teknik informatika') || o.contains('teknologi informasi') || s.contains('hmti') || RegExp(r'\bti\b').hasMatch(o) || RegExp(r'\bti\b').hasMatch(s);
      if (isHmtiTarget && isHmtiAdmin) return true;

      final isMmTarget = t.contains('multimedia');
      final isMmAdmin = o.contains('multimedia') || s.contains('multimedia');
      if (isMmTarget && isMmAdmin) return true;

      return false;
    }

    final syncState = ref.watch(sisewaSyncProvider);

    // Filter aset & barang khusus milik ormawa ini
    final ormawaBarang = syncState.barangList.where((b) => isMatchOrmawa(b.unitOrmawa)).toList();

    final totalJenis = ormawaBarang.length;
    final totalStok = ormawaBarang.fold<int>(0, (sum, b) => sum + b.stokTotal);
    final totalTersedia = ormawaBarang.fold<int>(0, (sum, b) => sum + b.stokTersedia);
    final totalDipinjam = ormawaBarang.fold<int>(0, (sum, b) => sum + b.stokDipinjam);

    // Filter aktivitas peminjaman khusus untuk ormawa ini
    final ormawaSewa = syncState.sewaList.where((s) => isMatchOrmawa(s.ormawaTujuan)).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(barangProvider.notifier).load();
        await ref.read(kategoriProvider.notifier).load();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 2. TOP 3 METRIC STAT CARDS =====
            _buildDonezoMetricCards(
              totalJenis: totalJenis,
              totalStok: totalStok,
              totalTersedia: totalTersedia,
              totalDipinjam: totalDipinjam,
            ),
            const SizedBox(height: 24),

            // ===== 3. MAIN CONTENT (PENYEWA, KATALOG, LAYANAN) =====
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 980;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kolom Kiri: Penyewa (Nama orang yang menyewa & barang milik ormawa ini)
                      Expanded(
                        flex: 6,
                        child: _buildPenyewaCard(ormawaSewa),
                      ),
                      const SizedBox(width: 20),

                      // Kolom Kanan: Katalog Inventaris
                      Expanded(
                        flex: 6,
                        child: _buildProjectListCard(context, ref, ormawaBarang),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildPenyewaCard(ormawaSewa),
                      const SizedBox(height: 18),
                      _buildProjectListCard(context, ref, ormawaBarang),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 1. TOP 3 METRIC STAT CARDS (Donezo Style with Circular Arrow)
  // ============================================================
  Widget _buildDonezoMetricCards({
    required int totalJenis,
    required int totalStok,
    required int totalTersedia,
    required int totalDipinjam,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 560
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 138,
          children: [
            // Card 1: SOLID GREEN CARD (Donezo Featured Card) -> Total Aset
            _buildFeaturedGreenCard(
              title: 'Total Aset Barang',
              value: '$totalStok',
              trend: '$totalJenis jenis terdaftar',
            ),

            // Card 2: Stok Tersedia (White Card)
            _buildWhiteStatCard(
              title: 'Stok Tersedia',
              value: '$totalTersedia',
              trend: 'Siap disewa',
            ),

            // Card 3: Sedang Dipinjam (White Card)
            _buildWhiteStatCard(
              title: 'Sedang Dipinjam',
              value: '$totalDipinjam',
              trend: 'Penyewaan aktif',
            ),
          ],
        );
      },
    );
  }

  /// Card 1: Solid Dark Forest Green Card
  Widget _buildFeaturedGreenCard({
    required String title,
    required String value,
    required String trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greenCardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              _buildCircleArrowButton(isDark: true),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '↗ Aset',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card 2, 3: White Cards with 1px Border
  Widget _buildWhiteStatCard({
    required String title,
    required String value,
    required String trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildCircleArrowButton(isDark: false),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primaryBorder, width: 1),
                ),
                child: const Text(
                  '↗ Status',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trend,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tombol lingkaran panah sudut kanan atas (Donezo ↗ button)
  Widget _buildCircleArrowButton({required bool isDark}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.border,
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.north_east_rounded,
          size: 14,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  // ============================================================
  // 3. DAFTAR PENYEWA (Nama orang yang menyewa & barang yang disewa)
  // ============================================================
  Widget _buildPenyewaCard(List<SyncPenyewaan> sewaList) {
    final avatarColors = [
      const Color(0xFFFCA5A5),
      const Color(0xFF86EFAC),
      const Color(0xFF93C5FD),
      const Color(0xFFFDE68A),
      const Color(0xFFC4B5FD),
      const Color(0xFFF9A8D4),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Penyewa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBorder, width: 1),
                ),
                child: Text(
                  '${sewaList.where((s) => s.status == 'disetujui').length} Aktif • ${sewaList.length} Total',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (sewaList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Belum ada data penyewaan',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...List.generate(sewaList.take(6).length, (index) {
              final sewa = sewaList[index];
              final color = avatarColors[index % avatarColors.length];
              final initial = sewa.namaPenyewa.isNotEmpty ? sewa.namaPenyewa[0] : 'U';

              String statusText = 'Menunggu';
              Color statusColor = AppColors.info;
              Color statusBg = AppColors.infoBg;

              if (sewa.status == 'disetujui') {
                statusText = 'Aktif';
                statusColor = AppColors.warning;
                statusBg = AppColors.warningBg;
              } else if (sewa.status == 'selesai') {
                statusText = 'Selesai';
                statusColor = AppColors.success;
                statusBg = AppColors.successBg;
              } else if (sewa.status == 'ditolak') {
                statusText = 'Ditolak';
                statusColor = AppColors.error;
                statusBg = AppColors.errorBg;
              }

              return _buildPenyewaRow(
                initial: initial,
                avatarColor: color,
                namaPenyewa: sewa.namaPenyewa,
                barangDisewa: '${sewa.namaBarang} • ${sewa.npm}',
                status: statusText,
                statusColor: statusColor,
                statusBg: statusBg,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPenyewaRow({
    required String initial,
    required Color avatarColor,
    required String namaPenyewa,
    required String barangDisewa,
    required String status,
    required Color statusColor,
    required Color statusBg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaPenyewa,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  barangDisewa,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. KATALOG INVENTARIS
  // ============================================================
  Widget _buildProjectListCard(
    BuildContext context,
    WidgetRef ref,
    List<SyncBarang> items,
  ) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFA855F7),
      const Color(0xFFF59E0B),
      const Color(0xFF6366F1),
      const Color(0xFF06B6D4),
    ];

    final icons = [
      Icons.videocam_outlined,
      Icons.speaker_group_outlined,
      Icons.mic_none_outlined,
      Icons.holiday_village_outlined,
      Icons.camera_alt_outlined,
      Icons.photo_camera_back_outlined,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Katalog Inventaris',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBorder, width: 1),
                ),
                child: Text(
                  '${items.length} Barang',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada barang inventaris ditambahkan',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...List.generate(items.length, (idx) {
              final item = items[idx];
              final iconColor = colors[idx % colors.length];
              final icon = icons[idx % icons.length];

              return _buildProjectItemRow(
                icon: icon,
                iconColor: iconColor,
                title: item.namaBarang,
                dueDate: 'Tersedia: ${item.stokTersedia}/${item.stokTotal} unit • ${item.kategori}',
              );
            }),
        ],
      ),
    );
  }

  Widget _buildProjectItemRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String dueDate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  dueDate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
