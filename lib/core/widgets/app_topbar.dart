import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../features/auth/domain/entities/user_entity.dart';

class AppTopbar extends StatelessWidget {
  final UserEntity? user;
  final String? namaOrganisasi;
  final VoidCallback? onToggleSidebar;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;
  final VoidCallback? onChatTap;

  const AppTopbar({
    super.key,
    required this.user,
    this.namaOrganisasi,
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
            IconButton(
              icon: const Icon(Icons.menu_rounded, size: 22),
              color: AppColors.textPrimary,
              tooltip: 'Toggle sidebar',
              onPressed: onToggleSidebar,
            ),
            const SizedBox(width: 8),
          ],

          // Spacer menggantikan search bar atas sehingga bersih di semua halaman
          const Spacer(),

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

                // Name and email/role
                Column(
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
                    ),
                    Text(
                      (user?.email != null && user!.email!.trim().isNotEmpty)
                          ? user!.email!
                          : '-',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
