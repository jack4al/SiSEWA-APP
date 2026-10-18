import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../features/auth/domain/entities/user_entity.dart';

class AppTopbar extends StatelessWidget {
  final UserEntity? user;
  final String? namaOrganisasi;
  final String? activeRoute;
  final VoidCallback? onToggleSidebar;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;
  final VoidCallback? onChatTap;

  const AppTopbar({
    super.key,
    required this.user,
    this.namaOrganisasi,
    this.activeRoute,
    required this.onProfileTap,
    required this.onLogoutTap,
    this.onToggleSidebar,
    this.onChatTap,
  });

  String _buildDisplayName() {
    final baseName = user?.namaLengkap ?? 'Admin Ormawa';
    if (user?.isAdminOrmawa == true) {
      final org = (namaOrganisasi != null && namaOrganisasi!.trim().isNotEmpty)
          ? namaOrganisasi!.trim()
          : 'BEM Fakultas Teknik';
      return '$baseName ($org)';
    }
    return baseName;
  }

  String _getTitle() {
    final route = activeRoute ?? '/dashboard';
    if (route == '/dashboard') {
      final name = user?.namaLengkap.trim();
      final displayName = (name != null && name.isNotEmpty) ? name : 'Civitas';
      return 'Halo, $displayName! 👋';
    }

    return switch (route) {
      '/barang' => 'Katalog & Inventaris Barang',
      '/kategori' => 'Kategori Barang',
      '/penyewaan' => user?.isPenyewa == true ? 'Penyewaan Saya' : 'Daftar Penyewaan',
      '/pengembalian' => 'Pengembalian & Denda',
      '/pembayaran' => user?.isPenyewa == true ? 'Pembayaran Saya' : 'Verifikasi Pembayaran',
      '/laporan' => 'Laporan & Rekapitulasi',
      '/chat' => 'Pesan & Konsultasi',
      '/profil' => 'Profil Pengguna',
      _ => 'SISEWA',
    };
  }

  String _getSubtitle() {
    final route = activeRoute ?? '/dashboard';
    if (route == '/dashboard') {
      if (user?.isPenyewa == true) {
        return 'Jelajahi aset ormawa kampus, ajukan sewa dengan mudah.';
      }
      final org = (namaOrganisasi != null && namaOrganisasi!.trim().isNotEmpty)
          ? namaOrganisasi!.trim()
          : 'Ormawa Kampus';
      return 'Kelola inventaris dan operasional aset milik $org';
    }

    return switch (route) {
      '/barang' => 'Kelola stok, harga sewa, dan kondisi fisik aset',
      '/kategori' => 'Kelola klasifikasi perlengkapan aset ormawa',
      '/penyewaan' => user?.isPenyewa == true
          ? 'Pantau permohonan dan jadwal sewa aktif Anda'
          : 'Kelola permohonan sewa masuk dan jadwal pinjam',
      '/pengembalian' => 'Inspeksi kondisi fisik barang & kalkulasi denda otomatis',
      '/pembayaran' => user?.isPenyewa == true
          ? 'Unggah bukti bayar dan periksa tagihan sewa'
          : 'Verifikasi bukti transfer, QRIS, dan setoran tunai',
      '/laporan' => 'Statistik transaksi sewa dan rekapitulasi kas ormawa',
      '/chat' => 'Komunikasi langsung seputar sewa & koordinasi barang',
      '/profil' => 'Informasi akun dan manajemen sesi Anda',
      _ => 'Sistem Informasi Penyewaan Barang & Inventaris Ormawa',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Toggle sidebar button (mobile/desktop responsive)
          if (onToggleSidebar != null) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: const Icon(Icons.menu_rounded, size: 20),
                color: AppColors.textPrimary,
                tooltip: 'Toggle sidebar',
                onPressed: onToggleSidebar,
              ),
            ),
            const SizedBox(width: 14),
          ],

          // Title & Greeting next to toggle sidebar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _getSubtitle(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // ===== 2. CIRCULAR ACTION BUTTONS =====
          _buildCircleIconButton(
            icon: Icons.mail_outline_rounded,
            tooltip: 'Pesan & Chat',
            onTap: onChatTap ?? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesan & surat izin kegiatan kampus'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 16),

          // ===== 3. DONEZO USER PROFILE PILL =====
          PopupMenuButton<String>(
            tooltip: 'Menu Akun',
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            onSelected: (value) {
              if (value == 'profile') onProfileTap();
              if (value == 'logout') onLogoutTap();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(Icons.person_outline_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Profil Saya'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar circle with playful Memoji color style
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE68A),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initial(user?.namaLengkap),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Name and email/role with width constraint to prevent overflow
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _buildDisplayName(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        (user?.email != null && user!.email!.trim().isNotEmpty)
                            ? user!.email!
                            : '-',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
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
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: IconButton(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 19, color: AppColors.textPrimary),
            if (hasBadge)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }

  String _initial(String? name) {
    if (name == null || name.trim().isEmpty) return 'A';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
