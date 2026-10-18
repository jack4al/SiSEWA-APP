import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';

class RekapItemModel {
  final String kodeSewa;
  final String namaPenyewa;
  final String npm;
  final String barang;
  final DateTime tanggalSewa;
  final int durasiHari;
  final double totalBiaya;
  final String statusSewa; // 'Selesai', 'Berjalan', 'Menunggu', 'Ditolak'
  final String statusBayar; // 'Lunas', 'Belum Bayar'

  RekapItemModel({
    required this.kodeSewa,
    required this.namaPenyewa,
    required this.npm,
    required this.barang,
    required this.tanggalSewa,
    required this.durasiHari,
    required this.totalBiaya,
    required this.statusSewa,
    required this.statusBayar,
  });
}

class LaporanScreen extends ConsumerStatefulWidget {
  const LaporanScreen({super.key});

  @override
  ConsumerState<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends ConsumerState<LaporanScreen> {
  String _selectedPeriode = 'Bulan Ini (Oktober 2026)';
  String _selectedStatusFilter = 'Semua';
  final _searchCtrl = TextEditingController();

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

  Widget _buildStatMini(
    String title,
    String val,
    String subtitle,
    IconData icon,
    Color color,
  ) {
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
                    fontSize: 11.5,
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: color,
                    fontWeight: FontWeight.w600,
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

    final sewaList = syncState.sewaList.where((item) => isMatchOrmawa(item.ormawaTujuan)).toList();
    final bayarList = syncState.bayarList.where((b) => isMatchOrmawa(b.unitOrmawa)).toList();
    final kembaliList = syncState.kembaliList.where((k) => isMatchOrmawa(k.unitOrmawa)).toList();
    final ormawaBarangList = syncState.barangList.where((b) => isMatchOrmawa(b.unitOrmawa)).toList();

    // Mapping log rekapitulasi secara tersinkronisasi
    final rekapList = sewaList.map((s) {
      final durasiHari = s.tglKembali.difference(s.tglMulai).inDays + 1;
      String statusSewa = 'Berjalan';
      if (s.status == 'selesai') {
        statusSewa = 'Selesai';
      } else if (s.status == 'ditolak') {
        statusSewa = 'Ditolak';
      } else if (s.status == 'menunggu') {
        statusSewa = 'Menunggu';
      } else if (s.status == 'disetujui') {
        statusSewa = 'Berjalan';
      }

      return RekapItemModel(
        kodeSewa: s.kodeSewa,
        namaPenyewa: s.namaPenyewa,
        npm: s.npm,
        barang: s.namaBarang,
        tanggalSewa: s.tglMulai,
        durasiHari: durasiHari > 0 ? durasiHari : 1,
        totalBiaya: s.totalHarga,
        statusSewa: statusSewa,
        statusBayar: s.statusBayar == 'Lunas' ? 'Lunas' : 'Belum Bayar',
      );
    }).toList();

    // Filter rekap
    final query = _searchCtrl.text.toLowerCase().trim();
    final filtered = rekapList.where((item) {
      final matchQuery = query.isEmpty ||
          item.kodeSewa.toLowerCase().contains(query) ||
          item.namaPenyewa.toLowerCase().contains(query) ||
          item.npm.contains(query) ||
          item.barang.toLowerCase().contains(query);

      final matchStatus = _selectedStatusFilter == 'Semua' ||
          item.statusSewa.toLowerCase() == _selectedStatusFilter.toLowerCase();

      return matchQuery && matchStatus;
    }).toList();

    // Kalkulasi metrik analitik riil
    final totalKasMasuk = bayarList
        .where((b) => b.status == 'lunas')
        .fold<double>(0, (sum, b) => sum + b.nominal);
    final countTransaksi = sewaList.length;
    final countSelesai = kembaliList.where((k) => k.status == 'diterima').length;

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
                'Laporan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Analisis penyewaan, penerimaan kas, dan utilisasi aset inventaris ormawa.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== PERIOD SELECTOR PILLS =====
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Periode Laporan:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'Bulan Ini (Oktober 2026)',
                        'Bulan Lalu (September 2026)',
                      ].map((periode) {
                        final isSelected = _selectedPeriode == periode;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(periode),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: const Color(0xFFF3F4F6),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide.none,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedPeriode = periode);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ===== 3 METRIC CARDS =====
          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth > 850
                  ? 3
                  : (constraints.maxWidth > 560 ? 2 : 1);
              return GridView.count(
                crossAxisCount: cross,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 105,
                children: [
                  _buildStatMini(
                    'Total Transaksi',
                    '$countTransaksi Sewa',
                    'Tercatat di sistem',
                    Icons.assignment_turned_in_outlined,
                    AppColors.primary,
                  ),
                  _buildStatMini(
                    'Total Kas Masuk',
                    _formatCurrency(totalKasMasuk),
                    'Kas pelunasan valid',
                    Icons.account_balance_wallet_outlined,
                    AppColors.success,
                  ),
                  _buildStatMini(
                    'Pengembalian Lengkap',
                    '$countSelesai Selesai',
                    'Aset diterima ormawa',
                    Icons.assignment_return_outlined,
                    AppColors.info,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // ===== ANALYTICS BREAKDOWN SECTION =====
          _buildAssetPerformanceCard(ormawaBarangList),
          const SizedBox(height: 24),

          // ===== REKAP TRANSAKSI TABLE / LIST =====
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Rincian Transaksi Periode Terpilih',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Log pembukuan peminjaman yang telah selesai dan sedang berjalan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${filtered.length} Transaksi',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search & Filter
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText:
                              'Cari Kode Sewa, Penyewa, NPM, atau Nama Barang...',
                          hintStyle: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textHint,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedStatusFilter,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'Semua',
                          child: Text('Semua Status', style: TextStyle(fontSize: 12)),
                        ),
                        DropdownMenuItem(
                          value: 'Selesai',
                          child: Text('Selesai', style: TextStyle(fontSize: 12)),
                        ),
                        DropdownMenuItem(
                          value: 'Berjalan',
                          child: Text('Sedang Berjalan', style: TextStyle(fontSize: 12)),
                        ),
                        DropdownMenuItem(
                          value: 'Menunggu',
                          child: Text('Menunggu', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedStatusFilter = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table / List
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'Tidak ada data transaksi yang cocok dengan filter',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildRekapItemRow(item);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetPerformanceCard(List<SyncBarang> barangList) {
    final totalUnit =
        barangList.fold<int>(0, (sum, b) => sum + b.stokTotal);
    final totalTersedia =
        barangList.fold<int>(0, (sum, b) => sum + b.stokTersedia);
    final totalDipinjam =
        barangList.fold<int>(0, (sum, b) => sum + b.stokDipinjam);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kondisi & Utilisasi Aset Inventaris',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalUnit Total Unit Aset',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildAssetStatusRow(
            'Kondisi Baik & Siap Sewa',
            '$totalTersedia Unit Tersedia',
            Icons.check_circle_outline,
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildAssetStatusRow(
            'Sedang Digunakan Penyewa',
            '$totalDipinjam Unit Aktif',
            Icons.outbox_rounded,
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildAssetStatusRow(
            'Total Kategori Terdata',
            '${barangList.map((b) => b.kategori).toSet().length} Kategori Aset',
            Icons.category_outlined,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetStatusRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRekapItemRow(RekapItemModel item) {
    Color statusBg = AppColors.surfaceMuted;
    Color statusFg = AppColors.textSecondary;

    if (item.statusSewa == 'Selesai') {
      statusBg = AppColors.successBg;
      statusFg = AppColors.success;
    } else if (item.statusSewa == 'Berjalan') {
      statusBg = AppColors.warningBg;
      statusFg = AppColors.warning;
    } else if (item.statusSewa == 'Menunggu') {
      statusBg = AppColors.infoBg;
      statusFg = AppColors.info;
    } else if (item.statusSewa == 'Ditolak') {
      statusBg = AppColors.errorBg;
      statusFg = AppColors.error;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.assignment_outlined,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    item.kodeSewa,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.statusSewa,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: statusFg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.statusBayar == 'Lunas'
                          ? AppColors.successBg
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.statusBayar,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: item.statusBayar == 'Lunas'
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '${item.namaPenyewa} (${item.npm}) • ${item.barang}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tgl Sewa: ${item.tanggalSewa.day}/${item.tanggalSewa.month}/${item.tanggalSewa.year} • Durasi: ${item.durasiHari} Hari',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _formatCurrency(item.totalBiaya),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
