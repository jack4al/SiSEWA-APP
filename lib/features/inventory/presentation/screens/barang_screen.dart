import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/sisewa_data_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/profile_provider.dart';
import '../../domain/entities/barang_entity.dart';
import '../providers/barang_provider.dart';
import '../providers/kategori_provider.dart';
import '../widgets/barang_card.dart';
import '../widgets/barang_form_dialog.dart';

class BarangScreen extends ConsumerStatefulWidget {
  const BarangScreen({super.key});

  @override
  ConsumerState<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends ConsumerState<BarangScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm({BarangEntity? initial}) async {
    final result = await BarangFormDialog.show(context, initial: initial);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            initial == null
                ? 'Barang berhasil ditambahkan'
                : 'Barang berhasil diperbarui',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BarangEntity barang) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text(
          'Yakin ingin menghapus "${barang.namaBarang}"?\n\n'
          'Data tidak akan benar-benar hilang, hanya dinonaktifkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(sisewaSyncProvider.notifier).deleteBarang(barang.idBarang);
      await ref
          .read(barangProvider.notifier)
          .delete(barang.idBarang);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(barangProvider);
    final kategoriState = ref.watch(kategoriProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Barang',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola inventaris barang ormawa',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Barang'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== FILTER ROW =====
          Row(
            children: [
              // Search
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari barang...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref
                                  .read(barangProvider.notifier)
                                  .load(search: '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    ref.read(barangProvider.notifier).load(search: value);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Filter Kategori
              Expanded(
                flex: 1,
                child: Builder(
                  builder: (context) {
                    final seen = <int>{};
                    final uniqueKategori = kategoriState.items
                        .where((k) => seen.add(k.idKategori))
                        .toList();
                    final isValidSelection = state.filterKategoriId == null ||
                        uniqueKategori
                            .any((k) => k.idKategori == state.filterKategoriId);
                    final currentValue =
                        isValidSelection ? state.filterKategoriId : null;

                    return DropdownButtonFormField<int?>(
                      isExpanded: true,
                      initialValue: currentValue,
                      decoration: const InputDecoration(
                        hintText: 'Semua Kategori',
                        prefixIcon: Icon(Icons.filter_list_rounded),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Semua Kategori'),
                        ),
                        ...uniqueKategori.map((k) {
                          return DropdownMenuItem<int?>(
                            value: k.idKategori,
                            child: Text(k.namaKategori),
                          );
                        }),
                      ],
                      onChanged: (v) {
                        ref
                            .read(barangProvider.notifier)
                            .load(idKategori: v, clearFilter: v == null);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ===== CONTENT =====
          Expanded(child: _buildContent(state, kategoriState)),
        ],
      ),
    );
  }

  Widget _buildContent(BarangState state, KategoriState kategoriState) {
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

    // Filter inventaris ormawa sama persis dengan Katalog Inventaris di Dashboard
    final ormawaBarang = syncState.barangList.where((b) => isMatchOrmawa(b.unitOrmawa)).toList();

    final displayItems = ormawaBarang.map((b) {
      // Cari idKategori yang sesuai dari kategoriState
      int resolvedKategoriId = 1;
      if (kategoriState.items.isNotEmpty) {
        final match = kategoriState.items.where(
          (k) =>
              k.namaKategori.toLowerCase().trim() ==
                  b.kategori.toLowerCase().trim() ||
              b.kategori.toLowerCase().contains(k.namaKategori.toLowerCase()) ||
              k.namaKategori.toLowerCase().contains(b.kategori.toLowerCase()),
        ).firstOrNull;
        if (match != null) {
          resolvedKategoriId = match.idKategori;
        } else {
          resolvedKategoriId = kategoriState.items.first.idKategori;
        }
      }

      return BarangEntity(
        idBarang: b.id,
        idKategori: resolvedKategoriId,
        idOrganisasi: 1,
        namaBarang: b.namaBarang,
        deskripsi: b.deskripsi,
        fotoBarang: b.fotoUrl,
        stokTotal: b.stokTotal,
        stokTersedia: b.stokTersedia,
        kondisi: b.kondisi,
        statusRecord: 'aktif',
        hargaSewa: b.hargaPerHari,
        namaKategori: b.kategori,
        namaOrganisasi: b.unitOrmawa,
      );
    }).toList();

    if (displayItems.isEmpty) {
      return _emptyState();
    }

    final query = _searchCtrl.text.toLowerCase().trim();
    final selectedKat = state.filterKategoriId != null && kategoriState.items.isNotEmpty
        ? kategoriState.items
            .firstWhere(
              (k) => k.idKategori == state.filterKategoriId,
              orElse: () => kategoriState.items.first,
            )
            .namaKategori
            .toLowerCase()
        : null;

    final filtered = displayItems.where((b) {
      final matchQuery = query.isEmpty ||
          b.namaBarang.toLowerCase().contains(query) ||
          (b.namaKategori?.toLowerCase().contains(query) ?? false);
      final matchKategori = selectedKat == null ||
          (b.namaKategori?.toLowerCase().contains(selectedKat) ?? false);
      return matchQuery && matchKategori;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Tidak ada barang yang cocok dengan filter pencarian.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final barang = filtered[i];
        return BarangCard(
          barang: barang,
          onEdit: () => _openForm(initial: barang),
          onDelete: () => _confirmDelete(barang),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada barang',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Mulai dengan menambahkan barang pertama',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tambah Barang'),
          ),
        ],
      ),
    );
  }
}
