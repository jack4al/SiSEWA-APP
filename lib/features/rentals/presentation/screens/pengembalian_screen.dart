import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';

class PengembalianScreen extends ConsumerStatefulWidget {
  const PengembalianScreen({super.key});

  @override
  ConsumerState<PengembalianScreen> createState() => _PengembalianScreenState();
}

class _PengembalianScreenState extends ConsumerState<PengembalianScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openInspeksiDialog(SyncPengembalian item) {
    String kondisiPilihan = item.kondisiFisik;
    final dendaCtrl = TextEditingController(
      text: item.dendaKeterlambatan.toInt().toString(),
    );
    final biayaCtrl = TextEditingController(
      text: item.biayaKerusakan.toInt().toString(),
    );
    final catatanCtrl = TextEditingController(
      text: item.catatanInspeksi ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Inspeksi Fisik ${item.kodeSewa}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaBarang,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Penyewa: ${item.namaPenyewa} (${item.npm})',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Kondisi Fisik Barang',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _kondisiChoiceChip(
                              label: 'Baik',
                              value: 'baik',
                              selectedVal: kondisiPilihan,
                              color: AppColors.success,
                              onTap: () => setDialogState(() {
                                kondisiPilihan = 'baik';
                                biayaCtrl.text = '0';
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _kondisiChoiceChip(
                              label: 'Rusak Ringan',
                              value: 'rusak_ringan',
                              selectedVal: kondisiPilihan,
                              color: AppColors.warning,
                              onTap: () => setDialogState(() {
                                kondisiPilihan = 'rusak_ringan';
                                if (biayaCtrl.text == '0') biayaCtrl.text = '50000';
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _kondisiChoiceChip(
                              label: 'Rusak Berat',
                              value: 'rusak_berat',
                              selectedVal: kondisiPilihan,
                              color: AppColors.error,
                              onTap: () => setDialogState(() {
                                kondisiPilihan = 'rusak_berat';
                                if (biayaCtrl.text == '0') biayaCtrl.text = '150000';
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: dendaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Denda Telat (Rp)',
                                prefixIcon: Icon(Icons.access_time_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: biayaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Biaya Ganti Rugi (Rp)',
                                prefixIcon: Icon(Icons.build_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: catatanCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Hasil Inspeksi Fisik',
                          prefixIcon: Icon(Icons.edit_note_outlined),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    final dendaClean = dendaCtrl.text.trim().replaceAll('.', '').replaceAll(',', '');
                    final biayaClean = biayaCtrl.text.trim().replaceAll('.', '').replaceAll(',', '');
                    final dendaVal = double.tryParse(dendaClean) ?? 0;
                    final biayaVal = double.tryParse(biayaClean) ?? 0;

                    ref
                        .read(sisewaSyncProvider.notifier)
                        .selesaikanPengembalian(
                          kodeSewa: item.kodeSewa,
                          kondisiFisik: kondisiPilihan,
                          denda: dendaVal,
                          biayaKerusakan: biayaVal,
                          catatan: catatanCtrl.text.trim(),
                        );

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Inspeksi fisik berhasil dicatat! Stok inventaris dipulihkan & tagihan siap dibayar.',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Selesaikan Inspeksi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _kondisiChoiceChip({
    required String label,
    required String value,
    required String selectedVal,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedVal == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? color : AppColors.textSecondary,
          ),
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

    final list = syncState.kembaliList.where((item) {
      if (item.unitOrmawa.isNotEmpty) {
        return isMatchOrmawa(item.unitOrmawa);
      }
      final sewa = syncState.sewaList.where((s) => s.kodeSewa == item.kodeSewa).firstOrNull;
      if (sewa == null) return true;
      return isMatchOrmawa(sewa.ormawaTujuan);
    }).toList();

    final query = _searchCtrl.text.toLowerCase().trim();
    final filtered = list.where((item) {
      final matchQuery = query.isEmpty ||
          item.kodeSewa.toLowerCase().contains(query) ||
          item.namaPenyewa.toLowerCase().contains(query) ||
          item.namaBarang.toLowerCase().contains(query) ||
          item.npm.contains(query);

      final matchFilter = _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Menunggu' &&
              item.status == 'menunggu_kembali') ||
          (_selectedFilter == 'Tepat Waktu' &&
              item.status == 'diterima' &&
              item.dendaKeterlambatan == 0) ||
          (_selectedFilter == 'Terlambat/Denda' &&
              item.dendaKeterlambatan > 0) ||
          (_selectedFilter == 'Kerusakan' && item.kondisiFisik != 'baik');

      return matchQuery && matchFilter;
    }).toList();

    final totalMenunggu =
        list.where((i) => i.status == 'menunggu_kembali').length;
    final totalTepatWaktu =
        list.where((i) => i.status == 'diterima' && i.dendaKeterlambatan == 0).length;
    final totalDenda = list.where((i) => i.dendaKeterlambatan > 0).length;
    final totalRusak = list.where((i) => i.kondisiFisik != 'baik').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengembalian Aset',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Verifikasi pengembalian fisik barang, pengecekan kelengkapan, dan kalkulasi denda.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
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
                    'Menunggu Kembali',
                    '$totalMenunggu',
                    Icons.pending_actions_rounded,
                    AppColors.info,
                  ),
                  _buildStatMini(
                    'Tepat Waktu',
                    '$totalTepatWaktu',
                    Icons.check_circle_outline_rounded,
                    AppColors.success,
                  ),
                  _buildStatMini(
                    'Kena Denda Telat',
                    '$totalDenda',
                    Icons.access_alarms_rounded,
                    AppColors.warning,
                  ),
                  _buildStatMini(
                    'Ada Kerusakan',
                    '$totalRusak',
                    Icons.build_circle_outlined,
                    AppColors.error,
                  ),
                ],
              );
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
                                'Cari kode sewa, nama penyewa, atau nama barang...',
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
                      'Menunggu',
                      'Tepat Waktu',
                      'Terlambat/Denda',
                      'Kerusakan',
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

          // ===== LIST DATA PENGEMBALIAN =====
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
                    'Tidak ada data pengembalian ditemukan',
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
                          Icons.assignment_return_rounded,
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
                                _buildStatusPill(item.status),
                                const SizedBox(width: 8),
                                _buildKondisiPill(item.kondisiFisik),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.namaPenyewa} (${item.npm}) • ${item.namaBarang}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rencana Kembali: ${item.tglRencanaKembali.day}/${item.tglRencanaKembali.month}/${item.tglRencanaKembali.year} ${item.tglAktualKembali != null ? "• Aktual: ${item.tglAktualKembali!.day}/${item.tglAktualKembali!.month}" : ""}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (item.dendaKeterlambatan > 0)
                                  Text(
                                    'Denda Telat: Rp ${item.dendaKeterlambatan.toInt()}  ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                    ),
                                  ),
                                if (item.biayaKerusakan > 0)
                                  Text(
                                    'Biaya Perbaikan: Rp ${item.biayaKerusakan.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                if (item.dendaKeterlambatan == 0 &&
                                    item.biayaKerusakan == 0)
                                  const Text(
                                    'Bebas Denda / Tepat Waktu',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                              ],
                            ),
                            if (item.catatanInspeksi != null &&
                                item.catatanInspeksi!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Catatan: ${item.catatanInspeksi}',
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
                        onPressed: () => _openInspeksiDialog(item),
                        icon: const Icon(Icons.rule_rounded, size: 16),
                        label: Text(
                          item.status == 'menunggu_kembali'
                              ? 'Cek Fisik'
                              : 'Edit Cek',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
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

  Widget _buildStatusPill(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'menunggu_kembali':
        bg = AppColors.infoBg;
        fg = AppColors.info;
        label = 'Menunggu Kembali';
        break;
      case 'diterima':
        bg = AppColors.successBg;
        fg = AppColors.success;
        label = 'Diterima Lengkap';
        break;
      case 'perlu_ganti_rugi':
        bg = AppColors.errorBg;
        fg = AppColors.error;
        label = 'Denda / Ganti Rugi';
        break;
      default:
        bg = AppColors.surfaceMuted;
        fg = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildKondisiPill(String kondisi) {
    Color bg;
    Color fg;
    String label;

    switch (kondisi) {
      case 'baik':
        bg = AppColors.successBg;
        fg = AppColors.success;
        label = 'Kondisi Baik';
        break;
      case 'rusak_ringan':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        label = 'Rusak Ringan';
        break;
      case 'rusak_berat':
        bg = AppColors.errorBg;
        fg = AppColors.error;
        label = 'Rusak Berat';
        break;
      default:
        bg = AppColors.surfaceMuted;
        fg = AppColors.textSecondary;
        label = kondisi;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
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
