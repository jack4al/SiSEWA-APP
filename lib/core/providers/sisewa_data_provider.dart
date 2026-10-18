import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================
// 1. DATA MODELS SINKRONISASI SISEWA
// ============================================================

class SyncBarang {
  final int id;
  final String namaBarang;
  final String kategori;
  final double hargaPerHari;
  final int stokTotal;
  int stokTersedia;
  final String kondisi;
  final String deskripsi;
  final String unitOrmawa;
  final String fotoUrl;

  SyncBarang({
    required this.id,
    required this.namaBarang,
    required this.kategori,
    required this.hargaPerHari,
    required this.stokTotal,
    required this.stokTersedia,
    required this.kondisi,
    required this.deskripsi,
    required this.unitOrmawa,
    required this.fotoUrl,
  });

  int get stokDipinjam => stokTotal - stokTersedia;
  bool get stokHabis => stokTersedia <= 0;
}

class SyncChatMessage {
  final String id;
  final String senderRole; // 'penyewa' atau 'admin_ormawa'
  final String senderName;
  final String senderUsername;
  final String receiverUsername;
  final String ormawaName;
  final String message;
  final DateTime timestamp;
  final String? kodeSewaTerkait;

  SyncChatMessage({
    required this.id,
    required this.senderRole,
    required this.senderName,
    required this.senderUsername,
    required this.receiverUsername,
    required this.ormawaName,
    required this.message,
    required this.timestamp,
    this.kodeSewaTerkait,
  });
}

class SyncPenyewaan {
  final String id;
  final String kodeSewa;
  final String namaPenyewa;
  final String usernamePenyewa;
  final String npm;
  final String noTelepon;
  final String ormawaTujuan;
  final String keperluan;
  final int barangId;
  final String namaBarang;
  final int jumlah;
  final DateTime tglMulai;
  final DateTime tglKembali;
  final double totalHarga;
  String status; // 'menunggu', 'disetujui', 'selesai', 'ditolak'
  String statusBayar; // 'Belum Bayar (Setelah Pengembalian)', 'Menunggu Verifikasi', 'Lunas', 'Batal'
  final String? catatan;

  SyncPenyewaan({
    required this.id,
    required this.kodeSewa,
    required this.namaPenyewa,
    required this.usernamePenyewa,
    required this.npm,
    required this.noTelepon,
    required this.ormawaTujuan,
    required this.keperluan,
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
    required this.tglMulai,
    required this.tglKembali,
    required this.totalHarga,
    required this.status,
    required this.statusBayar,
    this.catatan,
  });
}

class SyncPengembalian {
  final String id;
  final String kodeSewa;
  final String namaPenyewa;
  final String npm;
  final String namaBarang;
  final int jumlah;
  final DateTime tglRencanaKembali;
  DateTime? tglAktualKembali;
  String kondisiFisik; // 'baik', 'rusak_ringan', 'rusak_berat'
  double dendaKeterlambatan;
  double biayaKerusakan;
  String status; // 'menunggu_kembali', 'diterima', 'perlu_ganti_rugi'
  String? catatanInspeksi;
  final String unitOrmawa;

  SyncPengembalian({
    required this.id,
    required this.kodeSewa,
    required this.namaPenyewa,
    required this.npm,
    required this.namaBarang,
    required this.jumlah,
    required this.tglRencanaKembali,
    this.tglAktualKembali,
    required this.kondisiFisik,
    required this.dendaKeterlambatan,
    required this.biayaKerusakan,
    required this.status,
    this.catatanInspeksi,
    this.unitOrmawa = '',
  });
}

class SyncPembayaran {
  final String id;
  final String kodePembayaran;
  final String kodeSewa;
  final String namaPenyewa;
  final String usernamePenyewa;
  final String npm;
  final double nominal;
  final String jenisPembayaran; // 'Pelunasan Sewa', 'Ganti Rugi / Denda'
  String metodePembayaran; // 'QRIS Ormawa'
  final DateTime tanggalBayar;
  String status; // 'lunas', 'menunggu_verifikasi', 'ditolak', 'menunggu_pembayaran', 'batal'
  final String nomorRef;
  final String? catatan;
  final String unitOrmawa;

  SyncPembayaran({
    required this.id,
    required this.kodePembayaran,
    required this.kodeSewa,
    required this.namaPenyewa,
    required this.usernamePenyewa,
    required this.npm,
    required this.nominal,
    required this.jenisPembayaran,
    required this.metodePembayaran,
    required this.tanggalBayar,
    required this.status,
    required this.nomorRef,
    this.catatan,
    this.unitOrmawa = '',
  });
}

// ============================================================
// 2. STATE CONTAINER SINKRONISASI
// ============================================================

class SisewaSyncState {
  final List<SyncBarang> barangList;
  final List<SyncPenyewaan> sewaList;
  final List<SyncPengembalian> kembaliList;
  final List<SyncPembayaran> bayarList;
  final List<SyncChatMessage> chatList;

  SisewaSyncState({
    required this.barangList,
    required this.sewaList,
    required this.kembaliList,
    required this.bayarList,
    required this.chatList,
  });

  SisewaSyncState copyWith({
    List<SyncBarang>? barangList,
    List<SyncPenyewaan>? sewaList,
    List<SyncPengembalian>? kembaliList,
    List<SyncPembayaran>? bayarList,
    List<SyncChatMessage>? chatList,
  }) {
    return SisewaSyncState(
      barangList: barangList ?? this.barangList,
      sewaList: sewaList ?? this.sewaList,
      kembaliList: kembaliList ?? this.kembaliList,
      bayarList: bayarList ?? this.bayarList,
      chatList: chatList ?? this.chatList,
    );
  }
}

// ============================================================
// 3. NOTIFIER SINKRONISASI UTAMA
// ============================================================

class SisewaSyncNotifier extends Notifier<SisewaSyncState> {
  @override
  SisewaSyncState build() {
    // Inisialisasi data terpadu & sinkron awal
    final initialBarang = [
      SyncBarang(
        id: 1,
        namaBarang: 'Proyektor Epson EB-X400',
        kategori: 'Elektronik & Audio',
        hargaPerHari: 75000,
        stokTotal: 5,
        stokTersedia: 4,
        kondisi: 'baik',
        deskripsi: 'Proyektor 3300 lumens resolusi XGA jernih untuk presentasi dan seminar.',
        unitOrmawa: 'BEM Fakultas Teknik',
        fotoUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600&auto=format&fit=crop&q=80',
      ),
      SyncBarang(
        id: 2,
        namaBarang: 'Sound System Portable',
        kategori: 'Elektronik & Audio',
        hargaPerHari: 110000,
        stokTotal: 3,
        stokTersedia: 2,
        kondisi: 'baik',
        deskripsi: 'Paket speaker aktif 12 inch wireless include bluetooth dan jack audio.',
        unitOrmawa: 'Himpunan Mahasiswa TI',
        fotoUrl: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=600&auto=format&fit=crop&q=80',
      ),
      SyncBarang(
        id: 3,
        namaBarang: 'Mic Wireless Shure SM58',
        kategori: 'Elektronik & Audio',
        hargaPerHari: 35000,
        stokTotal: 8,
        stokTersedia: 6,
        kondisi: 'baik',
        deskripsi: 'Mikrofon vokal nirkabel sensitivitas tinggi jangkauan sinyal hingga 30m.',
        unitOrmawa: 'Himpunan Mahasiswa TI',
        fotoUrl: 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=600&auto=format&fit=crop&q=80',
      ),
      SyncBarang(
        id: 4,
        namaBarang: 'Tenda Dome Pramuka 4P',
        kategori: 'Tenda & Outdoor',
        hargaPerHari: 40000,
        stokTotal: 10,
        stokTersedia: 8,
        kondisi: 'baik',
        deskripsi: 'Tenda kemah kapasitas 4 orang bahan waterproof double layer kokoh.',
        unitOrmawa: 'Pramuka Racana',
        fotoUrl: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=600&auto=format&fit=crop&q=80',
      ),
      SyncBarang(
        id: 5,
        namaBarang: 'Kamera DSLR Canon 80D',
        kategori: 'Multimedia & Kamera',
        hargaPerHari: 90000,
        stokTotal: 4,
        stokTersedia: 3,
        kondisi: 'baik',
        deskripsi: 'Kamera dokumentasi semi-pro lensa kit 18-135mm IS USM sensor 24.2MP.',
        unitOrmawa: 'UKM Multimedia',
        fotoUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600&auto=format&fit=crop&q=80',
      ),
      SyncBarang(
        id: 6,
        namaBarang: 'Tripod Takara Professional',
        kategori: 'Multimedia & Kamera',
        hargaPerHari: 25000,
        stokTotal: 8,
        stokTersedia: 7,
        kondisi: 'baik',
        deskripsi: 'Tripod kamera aluminium kokoh tinggi maks 160cm dengan pan head halus.',
        unitOrmawa: 'UKM Multimedia',
        fotoUrl: 'https://images.unsplash.com/photo-1582533561751-ef6f6ab93a2e?w=600&auto=format&fit=crop&q=80',
      ),
      SyncBarang(
        id: 7,
        namaBarang: 'Sound System BEM 15 Inch',
        kategori: 'Elektronik & Audio',
        hargaPerHari: 120000,
        stokTotal: 4,
        stokTersedia: 3,
        kondisi: 'baik',
        deskripsi: 'Paket speaker aktif 15 inch pro outdoor include 2 mic wireless dan bluetooth.',
        unitOrmawa: 'BEM Fakultas Teknik',
        fotoUrl: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=600&auto=format&fit=crop&q=80',
      ),
      SyncBarang(
        id: 8,
        namaBarang: 'Mic Wireless Dual BEM',
        kategori: 'Elektronik & Audio',
        hargaPerHari: 40000,
        stokTotal: 6,
        stokTersedia: 5,
        kondisi: 'baik',
        deskripsi: 'Set microphone UHF dual receiver anti-noise cocok untuk MC dan moderator.',
        unitOrmawa: 'BEM Fakultas Teknik',
        fotoUrl: 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=600&auto=format&fit=crop&q=80',
      ),
      SyncBarang(
        id: 9,
        namaBarang: 'Layar Proyektor Tripod 70"',
        kategori: 'Elektronik & Audio',
        hargaPerHari: 30000,
        stokTotal: 5,
        stokTersedia: 5,
        kondisi: 'baik',
        deskripsi: 'Screen projector 70 inch portable stand tripod mudah dipasang di ruang rapat.',
        unitOrmawa: 'BEM Fakultas Teknik',
        fotoUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600&auto=format&fit=crop&q=80',
      ),
    ];

    final initialSewa = [
      SyncPenyewaan(
        id: '1',
        kodeSewa: 'SW-2026-001',
        namaPenyewa: 'Fajar Ramadhan',
        usernamePenyewa: 'fajar.ramadhan',
        npm: '2110631170012',
        noTelepon: '081234567890',
        ormawaTujuan: 'BEM Fakultas Teknik',
        keperluan: 'Seminar Nasional Teknologi AI & Robotika',
        barangId: 1,
        namaBarang: '1x Proyektor Epson EB-X400',
        jumlah: 1,
        tglMulai: DateTime.now().subtract(const Duration(days: 1)),
        tglKembali: DateTime.now().add(const Duration(days: 2)),
        totalHarga: 150000,
        status: 'disetujui',
        statusBayar: 'Belum Bayar (Setelah Pengembalian)',
      ),
      SyncPenyewaan(
        id: '2',
        kodeSewa: 'SW-2026-002',
        namaPenyewa: 'Annisa Rahmawati',
        usernamePenyewa: 'annisa.rahma',
        npm: '2210631170045',
        noTelepon: '085712349876',
        ormawaTujuan: 'Himpunan Mahasiswa TI',
        keperluan: 'Workshop Web Development & Bootcamp Frontend',
        barangId: 2,
        namaBarang: '1x Sound System Portable & 2x Mic Wireless',
        jumlah: 1,
        tglMulai: DateTime.now(),
        tglKembali: DateTime.now().add(const Duration(days: 3)),
        totalHarga: 220000,
        status: 'disetujui',
        statusBayar: 'Belum Bayar (Setelah Pengembalian)',
      ),
      SyncPenyewaan(
        id: '3',
        kodeSewa: 'SW-2026-003',
        namaPenyewa: 'Dewi Anggraini',
        usernamePenyewa: 'dewi.ang',
        npm: '2110631170088',
        noTelepon: '081399887766',
        ormawaTujuan: 'UKM Multimedia',
        keperluan: 'Dokumentasi Acara Wisuda Sarjana Universitas',
        barangId: 5,
        namaBarang: '1x Kamera DSLR Canon 80D & 1x Tripod Takara',
        jumlah: 1,
        tglMulai: DateTime.now().add(const Duration(days: 1)),
        tglKembali: DateTime.now().add(const Duration(days: 4)),
        totalHarga: 180000,
        status: 'menunggu',
        statusBayar: 'Belum Bayar (Setelah Pengembalian)',
      ),
      SyncPenyewaan(
        id: '4',
        kodeSewa: 'SW-2026-004',
        namaPenyewa: 'Rian Pratama',
        usernamePenyewa: 'rian.pratama',
        npm: '2010631170034',
        noTelepon: '082155443322',
        ormawaTujuan: 'Pramuka Racana',
        keperluan: 'Kemah Bakti Mahasiswa di Gunung Puntang',
        barangId: 4,
        namaBarang: '2x Tenda Dome Pramuka 4P',
        jumlah: 2,
        tglMulai: DateTime.now().subtract(const Duration(days: 5)),
        tglKembali: DateTime.now().subtract(const Duration(days: 1)),
        totalHarga: 260000,
        status: 'selesai',
        statusBayar: 'Lunas',
      ),
      SyncPenyewaan(
        id: '5',
        kodeSewa: 'SW-2026-005',
        namaPenyewa: 'Budi Santoso',
        usernamePenyewa: 'budi.santoso',
        npm: '2210631170090',
        noTelepon: '087811223344',
        ormawaTujuan: 'BEM Fakultas Teknik',
        keperluan: 'Peminjaman Pribadi di Luar Kampus',
        barangId: 1,
        namaBarang: '1x Proyektor Epson EB-X400',
        jumlah: 1,
        tglMulai: DateTime.now().subtract(const Duration(days: 7)),
        tglKembali: DateTime.now().subtract(const Duration(days: 6)),
        totalHarga: 75000,
        status: 'ditolak',
        statusBayar: 'Batal',
      ),
    ];

    final initialKembali = [
      SyncPengembalian(
        id: '1',
        kodeSewa: 'SW-2026-001',
        namaPenyewa: 'Fajar Ramadhan',
        npm: '2110631170012',
        namaBarang: 'Proyektor Epson EB-X400 (1 Unit)',
        jumlah: 1,
        tglRencanaKembali: DateTime.now().add(const Duration(days: 2)),
        kondisiFisik: 'baik',
        dendaKeterlambatan: 0,
        biayaKerusakan: 0,
        status: 'menunggu_kembali',
        catatanInspeksi: 'Belum dikembalikan ke sekretariat ormawa',
        unitOrmawa: 'BEM Fakultas Teknik',
      ),
      SyncPengembalian(
        id: '2',
        kodeSewa: 'SW-2026-002',
        namaPenyewa: 'Annisa Rahmawati',
        npm: '2210631170045',
        namaBarang: 'Sound System Portable & 2 Mic Wireless',
        jumlah: 1,
        tglRencanaKembali: DateTime.now().subtract(const Duration(days: 1)),
        tglAktualKembali: DateTime.now(),
        kondisiFisik: 'rusak_ringan',
        dendaKeterlambatan: 25000,
        biayaKerusakan: 50000,
        status: 'perlu_ganti_rugi',
        catatanInspeksi: 'Terlambat 1 hari. 1 mic baret di bagian switch. Menunggu verifikasi bukti ganti rugi.',
        unitOrmawa: 'Himpunan Mahasiswa TI',
      ),
      SyncPengembalian(
        id: '3',
        kodeSewa: 'SW-2026-004',
        namaPenyewa: 'Rian Pratama',
        npm: '2010631170034',
        namaBarang: 'Tenda Dome Pramuka 4P (2 Unit)',
        jumlah: 2,
        tglRencanaKembali: DateTime.now().subtract(const Duration(days: 1)),
        tglAktualKembali: DateTime.now().subtract(const Duration(days: 1)),
        kondisiFisik: 'baik',
        dendaKeterlambatan: 0,
        biayaKerusakan: 0,
        status: 'diterima',
        catatanInspeksi: 'Kondisi pasak & frame lengkap, bersih, siap disimpan kembali di gudang.',
        unitOrmawa: 'Pramuka Racana',
      ),
    ];

    final initialBayar = [
      SyncPembayaran(
        id: '1',
        kodePembayaran: 'PAY-2026-001',
        kodeSewa: 'SW-2026-001',
        namaPenyewa: 'Fajar Ramadhan',
        usernamePenyewa: 'fajar.ramadhan',
        npm: '2110631170012',
        nominal: 150000,
        jenisPembayaran: 'Pelunasan Sewa',
        metodePembayaran: 'QRIS Ormawa (BEM FT)',
        tanggalBayar: DateTime.now().subtract(const Duration(days: 1)),
        status: 'lunas',
        nomorRef: 'QRIS-NMID-8849201',
        catatan: 'Pembayaran sewa proyektor seminar AI',
        unitOrmawa: 'BEM Fakultas Teknik',
      ),
      SyncPembayaran(
        id: '2',
        kodePembayaran: 'PAY-2026-002',
        kodeSewa: 'SW-2026-002',
        namaPenyewa: 'Annisa Rahmawati',
        usernamePenyewa: 'annisa.rahma',
        npm: '2210631170045',
        nominal: 220000,
        jenisPembayaran: 'Pelunasan Sewa',
        metodePembayaran: 'QRIS Ormawa (HMTI)',
        tanggalBayar: DateTime.now().subtract(const Duration(days: 2)),
        status: 'menunggu_verifikasi',
        nomorRef: 'QRIS-NMID-99238',
        catatan: 'Pelunasan sewa sound system & 2 mic setelah barang dikembalikan',
        unitOrmawa: 'Himpunan Mahasiswa TI',
      ),
      SyncPembayaran(
        id: '3',
        kodePembayaran: 'PAY-2026-004',
        kodeSewa: 'SW-2026-004',
        namaPenyewa: 'Rian Pratama',
        usernamePenyewa: 'rian.pratama',
        npm: '2010631170034',
        nominal: 260000,
        jenisPembayaran: 'Pelunasan Sewa',
        metodePembayaran: 'QRIS Ormawa (Pramuka)',
        tanggalBayar: DateTime.now().subtract(const Duration(days: 1)),
        status: 'lunas',
        nomorRef: 'QRIS-NMID-01492',
        catatan: 'Diterima tunai di sekretariat ormawa saat serah terima tenda',
        unitOrmawa: 'Pramuka Racana',
      ),
      SyncPembayaran(
        id: '4',
        kodePembayaran: 'PAY-2026-005',
        kodeSewa: 'SW-2026-002',
        namaPenyewa: 'Annisa Rahmawati',
        usernamePenyewa: 'annisa.rahma',
        npm: '2210631170045',
        nominal: 75000,
        jenisPembayaran: 'Ganti Rugi / Denda',
        metodePembayaran: 'QRIS Ormawa',
        tanggalBayar: DateTime.now(),
        status: 'menunggu_verifikasi',
        nomorRef: 'QRIS-NMID-01823',
        catatan: 'Kompensasi perbaikan mic wireless baret & denda telat 1 hari',
        unitOrmawa: 'Himpunan Mahasiswa TI',
      ),
    ];

    final initialChat = [
      SyncChatMessage(
        id: '1',
        senderRole: 'penyewa',
        senderName: 'Fajar Ramadhan',
        senderUsername: 'fajar.ramadhan',
        receiverUsername: 'bem_ft',
        ormawaName: 'BEM Fakultas Teknik',
        message:
            'Halo Admin BEM FT, apakah proyektor Epson EB-X400 untuk seminar AI bisa saya ambil pagi ini di sekre?',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        kodeSewaTerkait: 'SW-2026-001',
      ),
      SyncChatMessage(
        id: '2',
        senderRole: 'admin_ormawa',
        senderName: 'Admin BEM FT',
        senderUsername: 'bem_ft',
        receiverUsername: 'fajar.ramadhan',
        ormawaName: 'BEM Fakultas Teknik',
        message:
            'Halo Fajar! Ya, unit proyektor dan kabel roll sudah kami siapkan di meja sekre BEM. Silakan bawa KTM fisik saat serah terima ya.',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
        kodeSewaTerkait: 'SW-2026-001',
      ),
      SyncChatMessage(
        id: '3',
        senderRole: 'penyewa',
        senderName: 'Annisa Rahmawati',
        senderUsername: 'annisa.rahma',
        receiverUsername: 'hmti',
        ormawaName: 'Himpunan Mahasiswa TI',
        message:
            'Permisi min, saya sudah bayar pelunasan via QRIS HMTI untuk sewa sound system & kompensasi mic ya.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
        kodeSewaTerkait: 'SW-2026-002',
      ),
      SyncChatMessage(
        id: '4',
        senderRole: 'admin_ormawa',
        senderName: 'Bendahara HMTI',
        senderUsername: 'hmti',
        receiverUsername: 'annisa.rahma',
        ormawaName: 'Himpunan Mahasiswa TI',
        message:
            'Baik Annisa, bukti pembayaran QRIS sudah masuk dan terverifikasi di pembukuan kami.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        kodeSewaTerkait: 'SW-2026-002',
      ),
      SyncChatMessage(
        id: '5',
        senderRole: 'penyewa',
        senderName: 'Dewi Anggraini',
        senderUsername: 'dewi.ang',
        receiverUsername: 'ukm_multimedia',
        ormawaName: 'UKM Multimedia',
        message:
            'Halo UKM Multimedia, untuk kamera DSLR Canon 80D lensanya sudah include baterai cadangan & SD card?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        kodeSewaTerkait: 'SW-2026-003',
      ),
      SyncChatMessage(
        id: '6',
        senderRole: 'admin_ormawa',
        senderName: 'Divisi Alat Multimedia',
        senderUsername: 'ukm_multimedia',
        receiverUsername: 'dewi.ang',
        ormawaName: 'UKM Multimedia',
        message:
            'Sudah include 2 baterai full charge + SD card Sandisk 64GB Extreme Pro kak. Siap dipakai untuk dokumentasi wisuda.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
        kodeSewaTerkait: 'SW-2026-003',
      ),
    ];

    return SisewaSyncState(
      barangList: initialBarang,
      sewaList: initialSewa,
      kembaliList: initialKembali,
      bayarList: initialBayar,
      chatList: initialChat,
    );
  }

  // ===== FITUR CHAT SINKRON (CIVITAS & ORMAWA) =====

  /// Kirim pesan chat secara real-time
  void kirimPesan({
    required String senderRole,
    required String senderName,
    required String senderUsername,
    required String receiverUsername,
    required String ormawaName,
    required String message,
    String? kodeSewaTerkait,
  }) {
    final newChat = SyncChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderRole: senderRole,
      senderName: senderName,
      senderUsername: senderUsername,
      receiverUsername: receiverUsername,
      ormawaName: ormawaName,
      message: message,
      timestamp: DateTime.now(),
      kodeSewaTerkait: kodeSewaTerkait,
    );

    state = state.copyWith(
      chatList: [...state.chatList, newChat],
    );
  }

  static const double biayaLayananSisewa = 2500.0;

  // ===== AKSI DARI SISI CIVITAS (PENYEWA) =====

  /// Civitas mengajukan permohonan sewa baru
  void ajukanSewaBaru({
    required SyncBarang barang,
    required String namaPenyewa,
    required String usernamePenyewa,
    required String npm,
    required String noTelepon,
    required String keperluan,
    required DateTime tglMulai,
    required DateTime tglKembali,
    required int jumlah,
  }) {
    final durasiHari = tglKembali.difference(tglMulai).inDays + 1;
    final safeDurasi = durasiHari > 0 ? durasiHari : 1;
    final subtotalSewa = barang.hargaPerHari * jumlah * safeDurasi;
    final total = subtotalSewa + biayaLayananSisewa;
    final kodeSewa = 'SW-2026-00${state.sewaList.length + 1}';

    final newSewa = SyncPenyewaan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      kodeSewa: kodeSewa,
      namaPenyewa: namaPenyewa,
      usernamePenyewa: usernamePenyewa,
      npm: npm,
      noTelepon: noTelepon,
      ormawaTujuan: barang.unitOrmawa,
      keperluan: keperluan,
      barangId: barang.id,
      namaBarang: '${jumlah}x ${barang.namaBarang}',
      jumlah: jumlah,
      tglMulai: tglMulai,
      tglKembali: tglKembali,
      totalHarga: total,
      status: 'menunggu',
      statusBayar: 'Menunggu Persetujuan Ormawa',
    );

    // Terbitkan tagihan pembayaran terkait
    final newBayar = SyncPembayaran(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      kodePembayaran: 'PAY-2026-00${state.bayarList.length + 1}',
      kodeSewa: kodeSewa,
      namaPenyewa: namaPenyewa,
      usernamePenyewa: usernamePenyewa,
      npm: npm,
      nominal: total,
      jenisPembayaran: 'Pelunasan Sewa',
      metodePembayaran: 'QRIS Ormawa (${barang.unitOrmawa})',
      tanggalBayar: DateTime.now(),
      status: 'menunggu_pembayaran',
      nomorRef: 'INV-$kodeSewa',
      catatan: 'Tagihan sewa ${barang.namaBarang} ke ${barang.unitOrmawa}',
      unitOrmawa: barang.unitOrmawa,
    );

    // Pengembalian TIDAK dibuat sebelum disetujui (mencegah data hantu jika ditolak)
    state = state.copyWith(
      sewaList: [newSewa, ...state.sewaList],
      bayarList: [newBayar, ...state.bayarList],
    );
  }

  /// Civitas mengirim bukti pembayaran (Transfer / QRIS)
  void kirimBuktiPembayaran({
    required SyncPenyewaan sewa,
    required double nominal,
    required String metode,
    required String nomorRef,
    String? catatan,
  }) {
    final kodePay = 'PAY-2026-00${state.bayarList.length + 1}';
    final newBayar = SyncPembayaran(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      kodePembayaran: kodePay,
      kodeSewa: sewa.kodeSewa,
      namaPenyewa: sewa.namaPenyewa,
      usernamePenyewa: sewa.usernamePenyewa,
      npm: sewa.npm,
      nominal: nominal,
      jenisPembayaran: 'Pelunasan Sewa',
      metodePembayaran: metode,
      tanggalBayar: DateTime.now(),
      status: 'menunggu_verifikasi',
      nomorRef: nomorRef,
      catatan: catatan ?? 'Bukti pembayaran dikirimkan oleh civitas via aplikasi SISEWA',
      unitOrmawa: sewa.ormawaTujuan,
    );

    // Update status bayar di sewaList
    final updatedSewa = state.sewaList.map((s) {
      if (s.id == sewa.id) {
        s.statusBayar = 'Menunggu Verifikasi';
      }
      return s;
    }).toList();

    state = state.copyWith(
      sewaList: updatedSewa,
      bayarList: [newBayar, ...state.bayarList],
    );
  }

  // ===== AKSI DARI SISI ORMAWA (ADMIN) =====

  /// Ormawa menyetujui pengajuan sewa civitas
  bool approveSewa(String id) {
    SyncPenyewaan? targetSewa;
    for (final s in state.sewaList) {
      if (s.id == id) {
        targetSewa = s;
        break;
      }
    }
    if (targetSewa == null) return false;

    // Cek ketersediaan stok
    SyncBarang? targetBarang;
    for (final b in state.barangList) {
      if (b.id == targetSewa.barangId) {
        targetBarang = b;
        break;
      }
    }

    if (targetBarang != null && targetBarang.stokTersedia < targetSewa.jumlah) {
      // Stok tidak cukup, tidak bisa disetujui (mencegah overbooking)
      return false;
    }

    // Kurangi stok barang secara immutable
    final updatedBarangList = state.barangList.map((b) {
      if (b.id == targetSewa!.barangId) {
        final newTersedia = (b.stokTersedia - targetSewa.jumlah).clamp(0, b.stokTotal);
        return SyncBarang(
          id: b.id,
          namaBarang: b.namaBarang,
          kategori: b.kategori,
          hargaPerHari: b.hargaPerHari,
          stokTotal: b.stokTotal,
          stokTersedia: newTersedia,
          kondisi: b.kondisi,
          deskripsi: b.deskripsi,
          unitOrmawa: b.unitOrmawa,
          fotoUrl: b.fotoUrl,
        );
      }
      return b;
    }).toList();

    final updatedSewa = state.sewaList.map((s) {
      if (s.id == id) {
        s.status = 'disetujui';
        if (s.statusBayar != 'Lunas' && s.statusBayar != 'Menunggu Verifikasi') {
          s.statusBayar = 'Belum Bayar (Setelah Pengembalian)';
        }
      }
      return s;
    }).toList();

    // Buat entri pengembalian otomatis setelah sewa resmi disetujui
    final existingKembali = state.kembaliList.any((k) => k.kodeSewa == targetSewa!.kodeSewa);
    List<SyncPengembalian> updatedKembali = state.kembaliList;
    if (!existingKembali) {
      final newKembali = SyncPengembalian(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        kodeSewa: targetSewa.kodeSewa,
        namaPenyewa: targetSewa.namaPenyewa,
        npm: targetSewa.npm,
        namaBarang: targetSewa.namaBarang,
        jumlah: targetSewa.jumlah,
        tglRencanaKembali: targetSewa.tglKembali,
        kondisiFisik: 'baik',
        dendaKeterlambatan: 0,
        biayaKerusakan: 0,
        status: 'menunggu_kembali',
        catatanInspeksi: 'Penyewaan telah disetujui, menunggu jadwal pengembalian barang.',
        unitOrmawa: targetSewa.ormawaTujuan,
      );
      updatedKembali = [newKembali, ...state.kembaliList];
    }

    state = state.copyWith(
      sewaList: updatedSewa,
      barangList: updatedBarangList,
      kembaliList: updatedKembali,
    );
    return true;
  }

  /// Ormawa menolak pengajuan sewa civitas
  void rejectSewa(String id) {
    SyncPenyewaan? targetSewa;
    final updatedSewa = state.sewaList.map((s) {
      if (s.id == id) {
        targetSewa = s;
        s.status = 'ditolak';
        s.statusBayar = 'Batal';
      }
      return s;
    }).toList();

    List<SyncPengembalian> updatedKembali = state.kembaliList;
    List<SyncPembayaran> updatedBayar = state.bayarList;

    if (targetSewa != null) {
      final kode = targetSewa!.kodeSewa;
      // Hapus entri pengembalian jika ada
      updatedKembali = state.kembaliList.where((k) => k.kodeSewa != kode).toList();
      // Batalkan tagihan pembayaran yang belum lunas
      updatedBayar = state.bayarList.map((b) {
        if (b.kodeSewa == kode && b.status != 'lunas') {
          return SyncPembayaran(
            id: b.id,
            kodePembayaran: b.kodePembayaran,
            kodeSewa: b.kodeSewa,
            namaPenyewa: b.namaPenyewa,
            usernamePenyewa: b.usernamePenyewa,
            npm: b.npm,
            nominal: b.nominal,
            jenisPembayaran: b.jenisPembayaran,
            metodePembayaran: b.metodePembayaran,
            tanggalBayar: b.tanggalBayar,
            status: 'batal',
            nomorRef: b.nomorRef,
            catatan: 'Permohonan sewa ditolak oleh ormawa',
            unitOrmawa: b.unitOrmawa,
          );
        }
        return b;
      }).toList();
    }

    state = state.copyWith(
      sewaList: updatedSewa,
      kembaliList: updatedKembali,
      bayarList: updatedBayar,
    );
  }

  /// Ormawa mencatat inspeksi fisik & penerimaan barang kembali
  void selesaikanPengembalian({
    required String kodeSewa,
    required String kondisiFisik,
    required double denda,
    required double biayaKerusakan,
    required String catatan,
  }) {
    final updatedKembali = state.kembaliList.map((k) {
      if (k.kodeSewa == kodeSewa) {
        k.tglAktualKembali = DateTime.now();
        k.kondisiFisik = kondisiFisik;
        k.dendaKeterlambatan = denda;
        k.biayaKerusakan = biayaKerusakan;
        k.status = (denda > 0 || biayaKerusakan > 0) ? 'perlu_ganti_rugi' : 'diterima';
        k.catatanInspeksi = catatan;
      }
      return k;
    }).toList();

    // Pulihkan stok barang secara immutable dan tandai sewa selesai
    SyncPenyewaan? targetSewa;
    final updatedSewa = state.sewaList.map((s) {
      if (s.kodeSewa == kodeSewa) {
        targetSewa = s;
        s.status = 'selesai';
        if (s.statusBayar != 'Lunas' && s.statusBayar != 'Menunggu Verifikasi') {
          s.statusBayar = 'Menunggu Pembayaran';
        }
      }
      return s;
    }).toList();

    final sewaItem = targetSewa ??
        state.sewaList.firstWhere(
          (s) => s.kodeSewa == kodeSewa,
          orElse: () => state.sewaList.first,
        );

    final updatedBarangList = state.barangList.map((b) {
      if (b.id == sewaItem.barangId) {
        final restored = (b.stokTersedia + sewaItem.jumlah).clamp(0, b.stokTotal);
        return SyncBarang(
          id: b.id,
          namaBarang: b.namaBarang,
          kategori: b.kategori,
          hargaPerHari: b.hargaPerHari,
          stokTotal: b.stokTotal,
          stokTersedia: restored,
          kondisi: b.kondisi,
          deskripsi: b.deskripsi,
          unitOrmawa: b.unitOrmawa,
          fotoUrl: b.fotoUrl,
        );
      }
      return b;
    }).toList();

    // Otomatis terbitkan / perbarui tagihan pembayaran pasca-pengembalian
    final totalTagihan = sewaItem.totalHarga + denda + biayaKerusakan;

    final existingBayarIndex =
        state.bayarList.indexWhere((b) => b.kodeSewa == kodeSewa);
    final List<SyncPembayaran> updatedBayarList = List.from(state.bayarList);

    if (existingBayarIndex >= 0) {
      final existing = state.bayarList[existingBayarIndex];
      if (existing.status != 'lunas') {
        updatedBayarList[existingBayarIndex] = SyncPembayaran(
          id: existing.id,
          kodePembayaran: existing.kodePembayaran,
          kodeSewa: existing.kodeSewa,
          namaPenyewa: existing.namaPenyewa,
          usernamePenyewa: existing.usernamePenyewa,
          npm: existing.npm,
          nominal: totalTagihan,
          jenisPembayaran: (denda > 0 || biayaKerusakan > 0)
              ? 'Pelunasan Sewa & Denda / Kerusakan'
              : 'Pelunasan Sewa',
          metodePembayaran: existing.metodePembayaran,
          tanggalBayar: DateTime.now(),
          status: existing.status == 'menunggu_verifikasi'
              ? 'menunggu_verifikasi'
              : 'menunggu_pembayaran',
          nomorRef: existing.nomorRef,
          catatan: catatan.isNotEmpty ? catatan : existing.catatan,
          unitOrmawa: sewaItem.ormawaTujuan,
        );
      }
    } else {
      final newBayar = SyncPembayaran(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        kodePembayaran: 'PAY-2026-00${state.bayarList.length + 1}',
        kodeSewa: kodeSewa,
        namaPenyewa: sewaItem.namaPenyewa,
        usernamePenyewa: sewaItem.usernamePenyewa,
        npm: sewaItem.npm,
        nominal: totalTagihan,
        jenisPembayaran: (denda > 0 || biayaKerusakan > 0)
            ? 'Pelunasan Sewa & Denda / Kerusakan'
            : 'Pelunasan Sewa',
        metodePembayaran: 'QRIS Ormawa (${sewaItem.ormawaTujuan})',
        tanggalBayar: DateTime.now(),
        status: 'menunggu_pembayaran',
        nomorRef: 'INV-${sewaItem.kodeSewa}',
        catatan: (denda > 0 || biayaKerusakan > 0)
            ? 'Termasuk denda: Rp ${denda.toInt()} & ganti rugi: Rp ${biayaKerusakan.toInt()}. $catatan'
            : (catatan.isNotEmpty
                ? catatan
                : 'Pelunasan sewa setelah pengembalian barang fisik ke ormawa'),
        unitOrmawa: sewaItem.ormawaTujuan,
      );
      updatedBayarList.insert(0, newBayar);
    }

    state = state.copyWith(
      barangList: updatedBarangList,
      kembaliList: updatedKembali,
      sewaList: updatedSewa,
      bayarList: updatedBayarList,
    );
  }

  /// Civitas mengirimkan bukti pembayaran via QRIS untuk tagihan yang ada
  void submitBuktiPembayaran({
    required String bayarId,
    required String metode,
    required String nomorRef,
    String? catatan,
  }) {
    String? kodeSewaTerkait;
    bool found = false;
    final updatedBayar = state.bayarList.map((b) {
      if (b.id == bayarId || (bayarId.startsWith('pay_') && (b.id == bayarId.replaceFirst('pay_', '') || b.kodeSewa == bayarId.replaceFirst('pay_', '')))) {
        found = true;
        kodeSewaTerkait = b.kodeSewa;
        return SyncPembayaran(
          id: b.id,
          kodePembayaran: b.kodePembayaran,
          kodeSewa: b.kodeSewa,
          namaPenyewa: b.namaPenyewa,
          usernamePenyewa: b.usernamePenyewa,
          npm: b.npm,
          nominal: b.nominal,
          jenisPembayaran: b.jenisPembayaran,
          metodePembayaran: metode,
          tanggalBayar: DateTime.now(),
          status: 'menunggu_verifikasi',
          nomorRef: nomorRef,
          catatan: catatan ?? b.catatan,
          unitOrmawa: b.unitOrmawa,
        );
      }
      return b;
    }).toList();

    if (!found) {
      final sewaMatch = state.sewaList.where((s) =>
          s.id == bayarId ||
          'pay_${s.id}' == bayarId ||
          'pay_${s.kodeSewa}' == bayarId ||
          s.kodeSewa == bayarId).firstOrNull;
      if (sewaMatch != null) {
        kodeSewaTerkait = sewaMatch.kodeSewa;
        final newBayar = SyncPembayaran(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          kodePembayaran: 'PAY-${sewaMatch.kodeSewa}',
          kodeSewa: sewaMatch.kodeSewa,
          namaPenyewa: sewaMatch.namaPenyewa,
          usernamePenyewa: sewaMatch.usernamePenyewa,
          npm: sewaMatch.npm,
          nominal: sewaMatch.totalHarga,
          jenisPembayaran: 'Pelunasan Sewa',
          metodePembayaran: metode,
          tanggalBayar: DateTime.now(),
          status: 'menunggu_verifikasi',
          nomorRef: nomorRef,
          catatan: catatan ?? 'Bukti pembayaran QRIS dikirimkan',
          unitOrmawa: sewaMatch.ormawaTujuan,
        );
        updatedBayar.insert(0, newBayar);
      }
    }

    List<SyncPenyewaan> updatedSewa = state.sewaList;
    if (kodeSewaTerkait != null) {
      updatedSewa = state.sewaList.map((s) {
        if (s.kodeSewa == kodeSewaTerkait) {
          s.statusBayar = 'Menunggu Verifikasi';
        }
        return s;
      }).toList();
    }

    state = state.copyWith(
      bayarList: updatedBayar,
      sewaList: updatedSewa,
    );
  }

  /// Ormawa memverifikasi pembayaran kas
  void verifikasiPembayaran(String id) {
    String? kodeSewaTerkait;
    bool found = false;
    final updatedBayar = state.bayarList.map((b) {
      if (b.id == id || (id.startsWith('pay_') && (b.id == id.replaceFirst('pay_', '') || b.kodeSewa == id.replaceFirst('pay_', '')))) {
        found = true;
        kodeSewaTerkait = b.kodeSewa;
        return SyncPembayaran(
          id: b.id,
          kodePembayaran: b.kodePembayaran,
          kodeSewa: b.kodeSewa,
          namaPenyewa: b.namaPenyewa,
          usernamePenyewa: b.usernamePenyewa,
          npm: b.npm,
          nominal: b.nominal,
          jenisPembayaran: b.jenisPembayaran,
          metodePembayaran: b.metodePembayaran,
          tanggalBayar: b.tanggalBayar,
          status: 'lunas',
          nomorRef: b.nomorRef,
          catatan: b.catatan,
          unitOrmawa: b.unitOrmawa,
        );
      }
      return b;
    }).toList();

    if (!found) {
      final sewaMatch = state.sewaList.where((s) =>
          s.id == id ||
          'pay_${s.id}' == id ||
          'pay_${s.kodeSewa}' == id ||
          s.kodeSewa == id).firstOrNull;
      if (sewaMatch != null) {
        kodeSewaTerkait = sewaMatch.kodeSewa;
        final newBayar = SyncPembayaran(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          kodePembayaran: 'PAY-${sewaMatch.kodeSewa}',
          kodeSewa: sewaMatch.kodeSewa,
          namaPenyewa: sewaMatch.namaPenyewa,
          usernamePenyewa: sewaMatch.usernamePenyewa,
          npm: sewaMatch.npm,
          nominal: sewaMatch.totalHarga,
          jenisPembayaran: 'Pelunasan Sewa',
          metodePembayaran: 'QRIS Ormawa (${sewaMatch.ormawaTujuan})',
          tanggalBayar: DateTime.now(),
          status: 'lunas',
          nomorRef: 'INV-${sewaMatch.kodeSewa}',
          catatan: 'Pembayaran diverifikasi lunas oleh ormawa',
          unitOrmawa: sewaMatch.ormawaTujuan,
        );
        updatedBayar.insert(0, newBayar);
      }
    }

    List<SyncPenyewaan> updatedSewa = state.sewaList;
    if (kodeSewaTerkait != null) {
      updatedSewa = state.sewaList.map((s) {
        if (s.kodeSewa == kodeSewaTerkait) {
          s.statusBayar = 'Lunas';
        }
        return s;
      }).toList();
    }

    state = state.copyWith(
      bayarList: updatedBayar,
      sewaList: updatedSewa,
    );
  }

  /// Ormawa menolak pembayaran (bukti transfer palsu/buram)
  void tolakPembayaran(String id) {
    String? kodeSewaTerkait;
    bool found = false;
    final updatedBayar = state.bayarList.map((b) {
      if (b.id == id || (id.startsWith('pay_') && (b.id == id.replaceFirst('pay_', '') || b.kodeSewa == id.replaceFirst('pay_', '')))) {
        found = true;
        kodeSewaTerkait = b.kodeSewa;
        return SyncPembayaran(
          id: b.id,
          kodePembayaran: b.kodePembayaran,
          kodeSewa: b.kodeSewa,
          namaPenyewa: b.namaPenyewa,
          usernamePenyewa: b.usernamePenyewa,
          npm: b.npm,
          nominal: b.nominal,
          jenisPembayaran: b.jenisPembayaran,
          metodePembayaran: b.metodePembayaran,
          tanggalBayar: b.tanggalBayar,
          status: 'ditolak',
          nomorRef: b.nomorRef,
          catatan: b.catatan,
          unitOrmawa: b.unitOrmawa,
        );
      }
      return b;
    }).toList();

    if (!found) {
      final sewaMatch = state.sewaList.where((s) =>
          s.id == id ||
          'pay_${s.id}' == id ||
          'pay_${s.kodeSewa}' == id ||
          s.kodeSewa == id).firstOrNull;
      if (sewaMatch != null) {
        kodeSewaTerkait = sewaMatch.kodeSewa;
        final newBayar = SyncPembayaran(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          kodePembayaran: 'PAY-${sewaMatch.kodeSewa}',
          kodeSewa: sewaMatch.kodeSewa,
          namaPenyewa: sewaMatch.namaPenyewa,
          usernamePenyewa: sewaMatch.usernamePenyewa,
          npm: sewaMatch.npm,
          nominal: sewaMatch.totalHarga,
          jenisPembayaran: 'Pelunasan Sewa',
          metodePembayaran: 'QRIS Ormawa (${sewaMatch.ormawaTujuan})',
          tanggalBayar: DateTime.now(),
          status: 'ditolak',
          nomorRef: 'INV-${sewaMatch.kodeSewa}',
          catatan: 'Pembayaran ditolak ormawa',
          unitOrmawa: sewaMatch.ormawaTujuan,
        );
        updatedBayar.insert(0, newBayar);
      }
    }

    List<SyncPenyewaan> updatedSewa = state.sewaList;
    if (kodeSewaTerkait != null) {
      updatedSewa = state.sewaList.map((s) {
        if (s.kodeSewa == kodeSewaTerkait) {
          s.statusBayar = 'Pembayaran Ditolak';
        }
        return s;
      }).toList();
    }

    state = state.copyWith(
      bayarList: updatedBayar,
      sewaList: updatedSewa,
    );
  }

  // ===== FITUR KELOLA INVENTARIS BARANG SINKRON =====

  /// Tambah barang inventaris baru
  void tambahBarang({
    required String namaBarang,
    required String kategori,
    required double hargaPerHari,
    required int stokTotal,
    required int stokTersedia,
    required String kondisi,
    required String deskripsi,
    required String unitOrmawa,
    String? fotoUrl,
  }) {
    final nextId = (state.barangList.isNotEmpty
            ? state.barangList.map((b) => b.id).reduce((a, b) => a > b ? a : b)
            : 0) +
        1;

    final newBarang = SyncBarang(
      id: nextId,
      namaBarang: namaBarang,
      kategori: kategori,
      hargaPerHari: hargaPerHari,
      stokTotal: stokTotal,
      stokTersedia: stokTersedia,
      kondisi: kondisi,
      deskripsi: deskripsi,
      unitOrmawa: unitOrmawa,
      fotoUrl: (fotoUrl != null && fotoUrl.isNotEmpty)
          ? fotoUrl
          : 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600&auto=format&fit=crop&q=80',
    );

    state = state.copyWith(
      barangList: [newBarang, ...state.barangList],
    );
  }

  /// Update barang inventaris
  void updateBarang({
    required int id,
    required String namaBarang,
    required String kategori,
    required double hargaPerHari,
    required int stokTotal,
    required int stokTersedia,
    required String kondisi,
    required String deskripsi,
    String? fotoUrl,
  }) {
    final updatedList = state.barangList.map((b) {
      if (b.id == id) {
        return SyncBarang(
          id: id,
          namaBarang: namaBarang,
          kategori: kategori,
          hargaPerHari: hargaPerHari,
          stokTotal: stokTotal,
          stokTersedia: stokTersedia,
          kondisi: kondisi,
          deskripsi: deskripsi,
          unitOrmawa: b.unitOrmawa,
          fotoUrl: fotoUrl ?? b.fotoUrl,
        );
      }
      return b;
    }).toList();

    state = state.copyWith(barangList: updatedList);
  }

  /// Hapus barang inventaris
  void deleteBarang(int id) {
    state = state.copyWith(
      barangList: state.barangList.where((b) => b.id != id).toList(),
    );
  }
}

// ============================================================
// 4. GLOBAL RIVERPOD PROVIDER
// ============================================================
final sisewaSyncProvider =
    NotifierProvider<SisewaSyncNotifier, SisewaSyncState>(() {
  return SisewaSyncNotifier();
});
