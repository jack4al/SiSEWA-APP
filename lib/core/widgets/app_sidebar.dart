import 'package:flutter/material.dart';

import '../constants/menu_items.dart';
import '../theme/app_colors.dart';

class AppSidebar extends StatelessWidget {
  final bool collapsed;
  final String activeRoute;
  final List<MenuItem> menus;
  final ValueChanged<String> onMenuTap;
  final VoidCallback? onToggleCollapse;
  final VoidCallback onLogout;
  final bool isPenyewa;

  const AppSidebar({
    super.key,
    required this.collapsed,
    required this.activeRoute,
    required this.menus,
    required this.onMenuTap,
    required this.onLogout,
    this.onToggleCollapse,
    this.isPenyewa = false,
  });

  @override
  Widget build(BuildContext context) {
    // Memisahkan menu SISEWA: Operasional (MENU) dan Administrasi (GENERAL)
    final operasionalRoutes = ['/dashboard', '/barang', '/kategori', '/penyewaan', '/pengembalian', '/chat'];
    final mainMenu = menus.where((m) => operasionalRoutes.contains(m.route)).toList();
    final generalMenu = menus.where((m) => !operasionalRoutes.contains(m.route) && m.route != '/profil').toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: collapsed ? 76 : 240,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(right: BorderSide(color: AppColors.sidebarBorder, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== 1. LOGO BRAND (Donezo Concentric Style) =====
          Container(
            height: 76,
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 16 : 24),
            alignment: collapsed ? Alignment.center : Alignment.centerLeft,
            child: Row(
              children: [
                _buildConcentricLogo(),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  const Text(
                    'Sisewa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ===== 2. SCROLLABLE MENU LIST =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                // Section Header: MENU
                if (!collapsed)
                  const Padding(
                    padding: EdgeInsets.only(left: 14, top: 8, bottom: 8),
                    child: Text(
                      'MENU',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHint,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                // Main Operational Items (Dashboard, Barang, Kategori, Penyewaan, Pengembalian)
                ...mainMenu.map((menu) {
                  final isActive = activeRoute == menu.route;
                  return _buildDonezoMenuItem(menu, isActive);
                }),

                const SizedBox(height: 16),

                // Section Header: GENERAL
                if (!collapsed)
                  const Padding(
                    padding: EdgeInsets.only(left: 14, top: 8, bottom: 8),
                    child: Text(
                      'GENERAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHint,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                // Administrative Items (Pembayaran, Laporan, Pengguna)
                ...generalMenu.map((menu) {
                  final isActive = activeRoute == menu.route;
                  return _buildDonezoMenuItem(menu, isActive);
                }),

                // Logout
                _buildStaticMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isActive: false,
                  color: AppColors.textSecondary,
                  onTap: onLogout,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Logo bergaya lingkaran konsentris hijau Donezo
  Widget _buildConcentricLogo() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2.5),
      ),
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: const Icon(
          Icons.inventory_2_rounded,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Item menu dengan indikator pill di tepi kiri sesuai Donezo
  Widget _buildDonezoMenuItem(MenuItem menu, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => onMenuTap(menu.route),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12),
          child: Row(
            children: [
              // Active Indicator Pill (Gaya Donezo)
              if (isActive && !collapsed)
                Container(
                  width: 3.5,
                  height: 20,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              else if (!collapsed)
                const SizedBox(width: 15.5),

              Icon(
                menu.icon,
                size: 20,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isPenyewa
                        ? (menu.route == '/dashboard'
                            ? 'Katalog Sewa'
                            : menu.route == '/penyewaan'
                                ? 'Sewa Saya'
                                : menu.route == '/pembayaran'
                                    ? 'Pembayaran Saya'
                                    : menu.route == '/chat'
                                        ? 'Chat Ormawa'
                                        : menu.label)
                        : (menu.route == '/chat' ? 'Chat Penyewa' : menu.label),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticMenuItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12),
          child: Row(
            children: [
              if (isActive && !collapsed)
                Container(
                  width: 3.5,
                  height: 20,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              else if (!collapsed)
                const SizedBox(width: 15.5),

              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.primary : (color ?? AppColors.textSecondary),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.textPrimary : (color ?? AppColors.textSecondary),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


}
