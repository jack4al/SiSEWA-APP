SISEWA

Disusun oleh : 
1. Irwansyah Ragil W. S - 25082010191 (CAPTAIN) Project Manager - Manajemen *Product Backlog*, Analisis Sistem, dan Pengujian Aplikasi.
2. Dyah Ayu Novita C. - 25082010213 (HUSTLER) Business Analyst - Analisis SOP Sewa & Kas, Riset Kebutuhan Pengguna (*User Needs*), dan Dokumentasi Proposal/Buku Panduan.
3. Naurah Qurrotu’ain. - 25082010234 (HIPSTER) UI/UX Designer & Frontend - Perancangan *User Flow*, Desain Antarmuka, dan Implementasi Widget Tampilan.
4. Alam Dwi Karunia H. - 25082010235 (HACKER) Scrum Master & Software Engineer - Fasilitator Scrum, Arsitektur Database, State Management Riverpod, dan *Core Application Logic*.

Aplikasi transaksi penyewaan dan manajemen inventaris peralatan berbasis Flutter Desktop (Windows) yang dirancang untuk menghubungkan civitas akademika kampus dengan organisasi mahasiswa (BEM, Himpunan Mahasiswa/HIMA, dan UKM).

Aplikasi ini mendigitalisasi proses peminjaman peralatan, pencegahan bentrok jadwal (*anti double-booking*), pengecekan kondisi fisik barang, kalkulasi denda otomatis, hingga pembukuan kas masuk dan pelaporan aset secara transparan dan terstruktur.


## Fitur Utama SiSEWA

### 1. Autentikasi & Multi-Role Akun Kampus
* **Dual-Role Interface:** Membedakan antarmuka secara otomatis antara peran `penyewa` (Civitas Mahasiswa) dan `admin_ormawa` (Pengelola Aset Organisasi).
* **Validasi Domain Kampus:** Pendaftaran civitas mewajibkan email institusi resmi `@student.upnjatim.ac.id` dan NPM aktif.
* **Fitur Akun Lengkap:** Pendaftaran akun baru, login aman, dialog pemulihan kata sandi (*Forgot Password*), dan pembaharuan biodata profil pengguna.

### 2. Dashboard Dinamis Berbasis Peran
* **Dashboard Civitas (Penyewa):** Menampilkan etalase katalog peralatan siap sewa lintas ormawa, fitur pencarian cepat, filter ormawa penyedia, dan filter kategori.
* **Dashboard Admin Ormawa (Pengelola):** Kartu metrik analitik (*Total Aset Barang*, *Stok Tersedia*, *Sedang Dipinjam*), serta daftar aktivitas penyewa terkini.

### 3. Manajemen Inventaris & Kategori (Ormawa)
* **CRUD Barang Inventaris:** Pendaftaran peralatan lengkap dengan nama, kategori, tarif sewa harian, jumlah stok total, kondisi fisik (*Sangat Baik*, *Baik*, *Perlu Perbaikan*), dan foto aset.
* **Pengelompokan Kategori:** Fleksibilitas pengelolaan kelompok barang (Elektronik & Audio, Tenda & Outdoor, Multimedia & Kamera, dll).
* **Isolasi Data Antar-Ormawa:** Data inventaris dan transaksi milik masing-masing ormawa (BEM, HIMASIFO, HMTI, UKM Multimedia) terisolasi secara aman dan independen.

### 4. Smart Rental Booking & Pencegahan Double-Booking
* **Kalkulator Sewa Interaktif:** Kalender rentang tanggal (*date-range picker*) yang otomatis menghitung durasi hari peminjaman dan total biaya sewa secara instan.
* **Automated Stock Deduction:** Stok barang siap sewa otomatis terpotong saat pengajuan disetujui untuk mencegah bentrok jadwal sewa antar-penyewa.

### 5. Sirkulasi Pengembalian & Kalkulator Denda Otomatis
* **Pemeriksaan Fisik Pasca-Pakai:** Pemeriksaan kelengkapan dan kondisi fisik peralatan saat dikembalikan oleh mahasiswa ke sekretariat ormawa.
* **Automated Late-Fee Engine:** Sistem mendeteksi tanggal pengembalian riil secara otomatis; jika melewati batas waktu sewa, denda keterlambatan per hari otomatis dihitung dan ditambahkan ke total invoice tagihan.

### 6. Pembayaran Pasca-Pengembalian (Post-Return Payment)
* **Tagihan Final Akurat:** Invoice tagihan diterbitkan setelah barang dikembalikan dan diperiksa, mencakup biaya sewa pokok serta denda keterlambatan (jika ada).
* **Multi-Channel & Upload Bukti:** Informasi QRIS ormawa, fitur unggah struk bukti transfer, serta panel verifikasi pelunasan kas masuk oleh bendahara ormawa.

### 7. Fitur Pesan & Konsultasi Real-Time (Chat)
* **In-App Messaging:** Jalur komunikasi langsung di dalam aplikasi antara mahasiswa dan pengurus ormawa untuk koordinasi pengambilan alat, pengecekan ketersediaan fisik, maupun janji temu.

### 8. Laporan & Rekapitulasi Kas / Utilisasi Aset
* **Filter Periode Laporan:** Fleksibilitas penarikan data transaksi berdasarkan bulan berjalan (*Bulan Ini*) maupun bulan sebelumnya (*Bulan Lalu*).
* **Statistik Utilisasi Aset:** Ringkasan kondisi aset inventaris (unit siap sewa vs unit aktif digunakan).
* **Pembukuan Kas Otomatis:** Akumulasi total penerimaan kas pelunasan valid dan tabel log transaksi komprehensif yang siap digunakan sebagai lampiran Laporan Pertanggungjawaban (LPJ).
