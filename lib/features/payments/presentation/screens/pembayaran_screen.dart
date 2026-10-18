import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';

class PembayaranScreen extends ConsumerStatefulWidget {
  const PembayaranScreen({super.key});

  @override
  ConsumerState<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends ConsumerState<PembayaranScreen> {
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

  void _showBuktiDialog(SyncPembayaran item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.kodePembayaran,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'No. Sewa: ${item.kodeSewa}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusBadge(item.status),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Digital Receipt Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL PEMBAYARAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHint,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.jenisPembayaran,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatCurrency(item.nominal),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildReceiptRow(
                          'Penyewa',
                          '${item.namaPenyewa} (${item.npm})',
                        ),
                        _buildReceiptRow('Metode', item.metodePembayaran),
                        _buildReceiptRow('Referensi / ID Trx', item.nomorRef),
                        _buildReceiptRow(
                          'Waktu Transaksi',
                          '${item.tanggalBayar.day}/${item.tanggalBayar.month}/${item.tanggalBayar.year} ${item.tanggalBayar.hour.toString().padLeft(2, '0')}:${item.tanggalBayar.minute.toString().padLeft(2, '0')} WIB',
                        ),
                        if (item.catatan != null && item.catatan!.isNotEmpty)
                          _buildReceiptRow('Catatan', item.catatan!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Virtual Proof Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.status == 'lunas'
                                ? Icons.verified_outlined
                                : (item.status == 'menunggu_verifikasi'
                                    ? Icons.pending_actions_rounded
                                    : Icons.receipt_long_rounded),
                            color: item.status == 'lunas'
                                ? AppColors.success
                                : (item.status == 'menunggu_verifikasi'
                                    ? AppColors.warning
                                    : AppColors.primary),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.status == 'lunas'
                                    ? 'Bukti Tervalidasi Kas'
                                    : (item.status == 'menunggu_verifikasi'
                                        ? 'Bukti QRIS Menunggu Verifikasi'
                                        : 'Tagihan Terbit (Menunggu Pembayaran)'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.status == 'lunas'
                                    ? 'Pelunasan diverifikasi masuk ke kas ormawa • Ref: ${item.nomorRef}'
                                    : (item.status == 'menunggu_verifikasi'
                                        ? 'Penyewa telah mengirim tangkapan layar pembayaran • Ref: ${item.nomorRef}'
                                        : 'Menunggu penyewa melakukan scan & bayar via QRIS Ormawa'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
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
              child: const Text('Tutup'),
            ),
            if (item.status == 'menunggu_verifikasi' ||
                item.status == 'menunggu_pembayaran' ||
                item.status == 'belum_bayar') ...[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  ref.read(sisewaSyncProvider.notifier).tolakPembayaran(item.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pembayaran ditolak'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
                child: const Text('Tolak'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Verifikasi Lunas'),
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
                      .verifikasiPembayaran(item.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pembayaran berhasil diverifikasi Lunas! Status transaksi tersinkronisasi.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ] else ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Cetak Kuitansi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kuitansi ${item.kodePembayaran} siap dicetak / diunduh',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
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
      case 'lunas':
        bg = AppColors.successBg;
        fg = AppColors.success;
        label = 'Lunas';
        break;
      case 'menunggu_verifikasi':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        label = 'Menunggu Verifikasi';
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
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
    final syncState = ref.watch(sisewaSyncProvider);
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final profile = ref.watch(profileProvider).asData?.value;
    final adminOrg = profile?.namaOrganisasi?.trim() ?? '';
    final adminSingkatan = profile?.singkatanOrganisasi?.trim() ?? '';
    final isAdminOrmawa = user?.role == AppConstants.roleAdminOrmawa;

    // 1. Kumpulkan semua pembayaran dari syncState.bayarList
    final List<SyncPembayaran> allBayar = [...syncState.bayarList];
    final existingKodeSewa = allBayar.map((b) => b.kodeSewa).toSet();

    // 2. Backfill otomatis jika ada transaksi sewa yang belum terbit tagihannya di bayarList
    for (final s in syncState.sewaList) {
      if (!existingKodeSewa.contains(s.kodeSewa)) {
        allBayar.add(
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
            catatan: 'Tagihan sewa ${s.namaBarang} (${s.ormawaTujuan})',
          ),
        );
        existingKodeSewa.add(s.kodeSewa);
      }
    }

    bool isMatchOrmawa(String targetOrg, String? metode) {
      if (!isAdminOrmawa) return true;
      if (adminOrg.isEmpty && adminSingkatan.isEmpty) return false;

      final t = targetOrg.toLowerCase().trim();
      final m = (metode ?? '').toLowerCase().trim();
      final o = adminOrg.toLowerCase().trim();
      final s = adminSingkatan.toLowerCase().trim();

      if (t.isEmpty && m.isEmpty) return false;

      if (o.isNotEmpty && (t.contains(o) || o.contains(t) || m.contains(o))) return true;
      if (s.isNotEmpty && (t.contains(s) || s.contains(t) || m.contains(s))) return true;

      final isBemTarget = t.contains('bem') || t.contains('badan eksekutif') || m.contains('bem');
      final isBemAdmin = o.contains('bem') || o.contains('badan eksekutif') || s.contains('bem');
      if (isBemTarget && isBemAdmin) return true;

      final isHmtiTarget = t.contains('hmti') || t.contains('teknik informatika') || t.contains('teknologi informasi') || m.contains('hmti') || RegExp(r'\bti\b').hasMatch(t);
      final isHmtiAdmin = o.contains('hmti') || o.contains('teknik informatika') || o.contains('teknologi informasi') || s.contains('hmti') || RegExp(r'\bti\b').hasMatch(o) || RegExp(r'\bti\b').hasMatch(s);
      if (isHmtiTarget && isHmtiAdmin) return true;

      final isMmTarget = t.contains('multimedia') || m.contains('multimedia');
      final isMmAdmin = o.contains('multimedia') || s.contains('multimedia');
      if (isMmTarget && isMmAdmin) return true;

      return false;
    }

    final list = allBayar.where((item) {
      if (item.unitOrmawa.isNotEmpty) {
        return isMatchOrmawa(item.unitOrmawa, item.metodePembayaran);
      }
      final sewa = syncState.sewaList.where((s) => s.kodeSewa == item.kodeSewa).firstOrNull;
      if (sewa != null) {
        return isMatchOrmawa(sewa.ormawaTujuan, item.metodePembayaran);
      }
      return isMatchOrmawa(item.metodePembayaran, item.metodePembayaran);
    }).toList();

    final query = _searchCtrl.text.toLowerCase().trim();
    final filtered = list.where((item) {
      final matchQuery = query.isEmpty ||
          item.kodePembayaran.toLowerCase().contains(query) ||
          item.kodeSewa.toLowerCase().contains(query) ||
          item.namaPenyewa.toLowerCase().contains(query) ||
          item.npm.contains(query) ||
          item.nomorRef.toLowerCase().contains(query);

      final matchFilter = _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Menunggu Pembayaran' &&
              (item.status == 'menunggu_pembayaran' || item.status == 'belum_bayar')) ||
          (_selectedFilter == 'Menunggu Verifikasi' &&
              item.status == 'menunggu_verifikasi') ||
          (_selectedFilter == 'Lunas' && item.status == 'lunas') ||
          (_selectedFilter == 'Ditolak' && item.status == 'ditolak');

      return matchQuery && matchFilter;
    }).toList();

    final totalKasLunas = list
        .where((p) => p.status == 'lunas')
        .fold<double>(0, (sum, p) => sum + p.nominal);
    final countLunas = list.where((p) => p.status == 'lunas').length;
    final countMenunggu =
        list.where((p) => p.status == 'menunggu_verifikasi').length;

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
                'Pembayaran',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Rekap pelunasan kas sewa & ganti rugi. Pembayaran dilakukan setelah pengembalian aset.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== STATS 3 CARDS =====
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 860;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildStatMini(
                        'Total Kas Masuk (Lunas)',
                        _formatCurrency(totalKasLunas),
                        Icons.account_balance_wallet_outlined,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 3,
                      child: _buildStatMini(
                        'Transaksi Lunas',
                        '$countLunas Trx',
                        Icons.check_circle_outline,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 3,
                      child: _buildStatMini(
                        'Menunggu Verifikasi',
                        '$countMenunggu Trx',
                        Icons.pending_actions_rounded,
                        AppColors.warning,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildStatMini(
                      'Total Kas Masuk (Lunas)',
                      _formatCurrency(totalKasLunas),
                      Icons.account_balance_wallet_outlined,
                      AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatMini(
                            'Transaksi Lunas',
                            '$countLunas Trx',
                            Icons.check_circle_outline,
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatMini(
                            'Menunggu Verifikasi',
                            '$countMenunggu Trx',
                            Icons.pending_actions_rounded,
                            AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // ===== SEARCH & FILTERS =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              children: [
                Container(
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
                                'Cari kode bayar, no sewa, penyewa, ref bank...',
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
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Semua',
                      'Menunggu Pembayaran',
                      'Menunggu Verifikasi',
                      'Lunas',
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

          // ===== LIST TRANSAKSI PEMBAYARAN =====
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
                    'Tidak ada data pembayaran ditemukan',
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
                          Icons.receipt_long_rounded,
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
                                  item.kodePembayaran,
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
                                    item.jenisPembayaran,
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
                              '${item.namaPenyewa} (${item.npm}) • Sewa: ${item.kodeSewa}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Metode: ${item.metodePembayaran} • Ref: ${item.nomorRef}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nominal: ${_formatCurrency(item.nominal)} • Tgl: ${item.tanggalBayar.day}/${item.tanggalBayar.month}/${item.tanggalBayar.year}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            if (item.catatan != null &&
                                item.catatan!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Catatan: ${item.catatan}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textHint,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showBuktiDialog(item),
                        icon: Icon(
                          item.status == 'menunggu_verifikasi' ||
                                  item.status == 'menunggu_pembayaran'
                              ? Icons.fact_check_outlined
                              : Icons.visibility_outlined,
                          size: 16,
                        ),
                        label: Text(
                          item.status == 'menunggu_verifikasi' ||
                                  item.status == 'menunggu_pembayaran'
                              ? 'Verifikasi'
                              : 'Lihat Bukti',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              item.status == 'menunggu_verifikasi' ||
                                      item.status == 'menunggu_pembayaran'
                                  ? AppColors.primary
                                  : AppColors.background,
                          foregroundColor:
                              item.status == 'menunggu_verifikasi' ||
                                      item.status == 'menunggu_pembayaran'
                                  ? Colors.white
                                  : AppColors.textPrimary,
                          side: BorderSide(
                            color: item.status == 'menunggu_verifikasi' ||
                                    item.status == 'menunggu_pembayaran'
                                ? Colors.transparent
                                : AppColors.border,
                          ),
                          elevation: 0,
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
