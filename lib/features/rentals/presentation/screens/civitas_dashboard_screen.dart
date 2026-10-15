import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../../../inventory/presentation/providers/barang_provider.dart';

class CivitasDashboardScreen extends ConsumerStatefulWidget {
  const CivitasDashboardScreen({super.key});

  @override
  ConsumerState<CivitasDashboardScreen> createState() =>
      _CivitasDashboardScreenState();
}

class _CivitasDashboardScreenState
    extends ConsumerState<CivitasDashboardScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(barangProvider.notifier).load();
    });
  }

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

  void _openAjukanSewaDialog(SyncBarang barang) {
    final authState = ref.read(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final profile = ref.read(profileProvider).asData?.value;
    final nim = (profile?.nim != null && profile!.nim!.trim().isNotEmpty)
        ? profile.nim!.trim()
        : '2110631170012';
    final noTelp = (profile?.noTelepon != null && profile!.noTelepon!.trim().isNotEmpty)
        ? profile.noTelepon!.trim()
        : (user?.noTelepon ?? '081234567890');

    final namaCtrl = TextEditingController(text: user?.namaLengkap ?? 'Mahasiswa Civitas');
    final npmCtrl = TextEditingController(text: nim);
    final noTelpCtrl = TextEditingController(text: noTelp);
    final keperluanCtrl = TextEditingController();
    DateTime tglMulai = DateTime.now();
    DateTime tglKembali = DateTime.now().add(const Duration(days: 2));
    int jumlah = 1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final durasiHari = tglKembali.difference(tglMulai).inDays + 1;
            final subtotalSewa = barang.hargaPerHari * jumlah * (durasiHari > 0 ? durasiHari : 1);
            const double biayaLayanan = 2500;
            final totalBiaya = subtotalSewa + biayaLayanan;

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
                    child: const Icon(Icons.assignment_add, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Formulir Pengajuan Sewa', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text(barang.namaBarang, style: const TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Info Ormawa Pemilik
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.business_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ormawa Penyedia: ${barang.unitOrmawa}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                            ),
                            Text(
                              '${_formatCurrency(barang.hargaPerHari)}/hari',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Data Peminjam Mahasiswa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: namaCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap Peminjam', prefixIcon: Icon(Icons.person_outline)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: npmCtrl,
                              decoration: const InputDecoration(labelText: 'NPM Mahasiswa', prefixIcon: Icon(Icons.numbers_outlined)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: noTelpCtrl,
                              decoration: const InputDecoration(labelText: 'No. WhatsApp', prefixIcon: Icon(Icons.phone_outlined)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: keperluanCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Keperluan Peminjaman / Nama Kegiatan',
                          hintText: 'Cth: Seminar Nasional, Latihan Pentas, dsb.',
                          prefixIcon: Icon(Icons.event_note_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Durasi & Waktu Peminjaman', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: tglMulai,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 60)),
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    tglMulai = picked;
                                    if (tglKembali.isBefore(tglMulai)) {
                                      tglKembali = tglMulai.add(const Duration(days: 1));
                                    }
                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_today_rounded, size: 15),
                              label: Text('Mulai: ${tglMulai.day}/${tglMulai.month}/${tglMulai.year}', style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: tglKembali,
                                  firstDate: tglMulai,
                                  lastDate: DateTime.now().add(const Duration(days: 60)),
                                );
                                if (picked != null) {
                                  setDialogState(() => tglKembali = picked);
                                }
                              },
                              icon: const Icon(Icons.event_available_rounded, size: 15),
                              label: Text('Kembali: ${tglKembali.day}/${tglKembali.month}/${tglKembali.year}', style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Ringkasan Estimasi Biaya & Ketentuan Tanpa DP
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Sewa Barang ($durasiHari Hari x $jumlah unit):', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                Text(_formatCurrency(subtotalSewa), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Biaya Layanan Sistem:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                Text('+ ${_formatCurrency(biayaLayanan)}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              ],
                            ),
                            const Divider(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Pembayaran:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                Text(_formatCurrency(totalBiaya), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Icon(Icons.info_outline_rounded, size: 15, color: AppColors.primary),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Aturan SISEWA: Tanpa DP. Pembayaran dilakukan secara penuh setelah barang dikembalikan ke sekretariat ormawa.',
                                    style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
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
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    if (keperluanCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harap isi keperluan peminjaman'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    ref.read(sisewaSyncProvider.notifier).ajukanSewaBaru(
                          barang: barang,
                          namaPenyewa: namaCtrl.text.trim(),
                          usernamePenyewa: user?.username ?? 'civitas',
                          npm: npmCtrl.text.trim(),
                          noTelepon: noTelpCtrl.text.trim(),
                          keperluan: keperluanCtrl.text.trim(),
                          tglMulai: tglMulai,
                          tglKembali: tglKembali,
                          jumlah: jumlah,
                        );

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pengajuan sewa ${barang.namaBarang} berhasil dikirim ke ${barang.unitOrmawa}!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Kirim Pengajuan Sewa'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(sisewaSyncProvider);
    final barangState = ref.watch(barangProvider);
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    // Gabungkan inventaris barang dari sisewaSyncProvider dan SQLite (barangProvider)
    final List<SyncBarang> allBarang = [...syncState.barangList];
    final existingNames = allBarang.map((b) => b.namaBarang.toLowerCase().trim()).toSet();

    for (final b in barangState.items) {
      final nameKey = b.namaBarang.toLowerCase().trim();
      if (!existingNames.contains(nameKey)) {
        allBarang.add(
          SyncBarang(
            id: b.idBarang,
            namaBarang: b.namaBarang,
            kategori: (b.namaKategori != null && b.namaKategori!.isNotEmpty)
                ? b.namaKategori!
                : 'Elektronik & Audio',
            hargaPerHari: b.hargaSewa > 0 ? b.hargaSewa : 50000,
            stokTotal: b.stokTotal,
            stokTersedia: b.stokTersedia,
            kondisi: b.kondisi,
            deskripsi: b.deskripsi ?? '',
            unitOrmawa: (b.namaOrganisasi != null && b.namaOrganisasi!.isNotEmpty)
                ? b.namaOrganisasi!
                : 'BEM Fakultas Teknik',
            fotoUrl: (b.fotoBarang != null && b.fotoBarang!.isNotEmpty)
                ? b.fotoBarang!
                : 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600&auto=format&fit=crop&q=80',
          ),
        );
        existingNames.add(nameKey);
      }
    }

    final query = _searchCtrl.text.toLowerCase().trim();
    final filteredBarang = allBarang.where((b) {
      final matchQuery = query.isEmpty ||
          b.namaBarang.toLowerCase().contains(query) ||
          b.deskripsi.toLowerCase().contains(query) ||
          b.kategori.toLowerCase().contains(query) ||
          b.unitOrmawa.toLowerCase().contains(query);

      return matchQuery;
    }).toList();

    // Hitung statistik civitas
    final myRentals = syncState.sewaList.where((s) => s.usernamePenyewa == (user?.username ?? '') || s.namaPenyewa == (user?.namaLengkap ?? '')).toList();
    final aktifSaya = myRentals.where((s) => s.status == 'disetujui').length;
    final menungguSaya = myRentals.where((s) => s.status == 'menunggu').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${user?.namaLengkap ?? "Civitas Mahasiswa"}! 👋',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.6),
              ),
              const SizedBox(height: 4),
              const Text(
                'Jelajahi aset ormawa kampus, ajukan sewa dengan mudah, tanpa uang muka (DP). Pelunasan setelah pengembalian.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== STATS CARDS CIVITAS (2 CARDS: AKTIF & MENUNGGU) =====
          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth > 560 ? 2 : 1;
              return GridView.count(
                crossAxisCount: cross,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 95,
                children: [
                  _buildStatCard('Sewa Aktif Saya', '$aktifSaya Peminjaman', Icons.timer_outlined, AppColors.warning),
                  _buildStatCard('Menunggu Approval', '$menungguSaya Pengajuan', Icons.hourglass_top_rounded, AppColors.info),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // ===== PENCARIAN KATALOG SEWA (TANPA FILTER KATEGORI DI BAWAHNYA) =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari nama barang, ormawa penyedia, atau jenis alat...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ===== KATALOG BARANG GRID DENGAN FOTO =====
          const Text(
            'Katalog Barang Ormawa',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth > 960 ? 3 : (constraints.maxWidth > 640 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredBarang.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 335,
                ),
                itemBuilder: (context, index) {
                  final barang = filteredBarang[index];
                  return _buildBarangCard(barang);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
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
                Text(title, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangCard(SyncBarang barang) {
    final isAvailable = barang.stokTersedia > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Barang dengan Overlay Badges
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 135,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildPhotoWidget(barang.fotoUrl),
                  // Kategori badge di atas kiri
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        barang.kategori,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Status stok di atas kanan
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.primary.withValues(alpha: 0.9)
                            : AppColors.error.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAvailable ? 'Tersedia: ${barang.stokTersedia}' : 'Habis',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            barang.namaBarang,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(
                Icons.business_outlined,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  barang.unitOrmawa,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              barang.deskripsi,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textHint,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harga Sewa',
                    style: TextStyle(fontSize: 10, color: AppColors.textHint),
                  ),
                  Text(
                    '${_formatCurrency(barang.hargaPerHari)}/hari',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: isAvailable ? () => _openAjukanSewaDialog(barang) : null,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                label: const Text('Ajukan Sewa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(String fotoUrl) {
    final trimmed = fotoUrl.trim();
    if (trimmed.isEmpty) {
      return _buildPlaceholderPhoto();
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderPhoto(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.surfaceMuted,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    }

    try {
      final file = File(trimmed);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderPhoto(),
        );
      }
    } catch (_) {}

    return _buildPlaceholderPhoto();
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 44,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
