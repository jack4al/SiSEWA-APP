import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/menu_items.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/widgets/app_topbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../inventory/presentation/screens/barang_screen.dart';
import '../../../inventory/presentation/screens/kategori_screen.dart';
import '../../../payments/presentation/screens/civitas_pembayaran_screen.dart';
import '../../../payments/presentation/screens/pembayaran_screen.dart';
import '../../../rentals/presentation/screens/civitas_dashboard_screen.dart';
import '../../../rentals/presentation/screens/civitas_sewa_screen.dart';
import '../../../rentals/presentation/screens/pengembalian_screen.dart';
import '../../../rentals/presentation/screens/penyewaan_screen.dart';
import 'dashboard_screen.dart';
import 'laporan_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  String _activeRoute = '/dashboard';
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final role = user?.role ?? '';
    final isPenyewa = user?.isPenyewa == true;
    final profile = ref.watch(profileProvider).asData?.value;

    // Filter menu berdasarkan role
    final menus = AppMenus.items.where((m) => m.isVisibleFor(role)).toList();

    return Scaffold(
      body: Row(
        children: [
          // ===== SIDEBAR =====
          AppSidebar(
            collapsed: _sidebarCollapsed,
            activeRoute: _activeRoute,
            menus: menus,
            onMenuTap: (route) => setState(() => _activeRoute = route),
            onToggleCollapse: () =>
                setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            onLogout: _handleLogout,
            isPenyewa: isPenyewa,
          ),

          // ===== CONTENT AREA =====
          Expanded(
            child: Column(
              children: [
                // Topbar
                AppTopbar(
                  user: user,
                  namaOrganisasi: profile?.namaOrganisasi,
                  onToggleSidebar: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  onProfileTap: () => setState(() => _activeRoute = '/profil'),
                  onChatTap: () => setState(() => _activeRoute = '/chat'),
                  onLogoutTap: _handleLogout,
                ),

                // Konten halaman
                Expanded(child: _buildContent(isPenyewa)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isPenyewa) {
    // Mode Khusus Civitas (Penyewa): Fitur terpadu penyewa
    if (isPenyewa) {
      switch (_activeRoute) {
        case '/dashboard':
          return const CivitasDashboardScreen();
        case '/penyewaan':
          return const CivitasSewaScreen();
        case '/pembayaran':
          return const CivitasPembayaranScreen();
        case '/chat':
          return const ChatScreen();
        case '/profil':
          return ProfileScreen(
            onBack: () => setState(() => _activeRoute = '/dashboard'),
          );
        default:
          return const CivitasDashboardScreen();
      }
    }

    // Mode Ormawa (Admin): Fitur inventaris, operasional & keuangan
    switch (_activeRoute) {
      case '/dashboard':
        return const DashboardScreen();
      case '/barang':
        return const BarangScreen();
      case '/kategori':
        return const KategoriScreen();
      case '/penyewaan':
        return const PenyewaanScreen();
      case '/pengembalian':
        return const PengembalianScreen();
      case '/pembayaran':
        return const PembayaranScreen();
      case '/laporan':
        return const LaporanScreen();
      case '/chat':
        return const ChatScreen();
      case '/profil':
        return ProfileScreen(
          onBack: () => setState(() => _activeRoute = '/dashboard'),
        );
      default:
        return const DashboardScreen();
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}
