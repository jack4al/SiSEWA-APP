SISEWA (Sistem Informasi Penyewaan Barang & Inventaris)

Disusun Oleh :
1. Irwansyah Ragil W. S - 25082010191
2. Dyah Ayu Novita C. - 25082010213
3. Naurah Qurrotu’ain. - 25082010234
4. Alam Dwi Karunia H. - 25082010235

SISEWA adalah aplikasi transaksi penyewaan barang berbasis Flutter dirancang untuk organisasi mahasiswa (Ormawa), komunitas kampus, maupun civitas kampus. Aplikasi ini mempermudah pencatatan aset  pengajuan peminjaman/sewa, verifikasi pembayaran, hingga pengembalian dan kontrol kondisi barang secara transparan dan terstruktur.

---

## Fitur Utama

### 1. Autentikasi & Multi-Role User
- Multi-Role Access : Mendukung level akses akun seperti `admin_ormawa`, `admin_siswa`, dan `penyewa`.
- Autentikasi Aman : Login, registrasi akun baru, pembaruan profil pengguna, dan fitur ganti password.
- Session Management : Integrasi sesi tersimpan otomatis dengan `shared_preferences`.

### 2. Dashboard 
- Ringkasan Statistik : Menampilkan metrik penting secara *real-time*:
  - Total Barang 
  - Barang yang Sedang Dipinjam
  - Permohonan Sewa Menunggu Persetujuan
  - Peminjaman yang Melebihi Batas Waktu 
- Navigasi Cepat : Akses mudah ke seluruh modul operasional melalui *sidebar* dan navigasi terintegrasi.

### 3. Manajemen Inventaris & Kategori
- Katalog Barang : Pencatatan barang sewa lengkap dengan foto, kode, kondisi fisik, stok total, dan stok tersedia.
- Kategori Fleksibel : Pengelompokan barang berdasarkan kategori (Elektronik, Alat Camping, Sound System, Alat Masak, dll).
- Multi-Tier Pricing (Harga Berjenjang) : Tarif sewa harian yang dapat dibedakan berdasarkan level penyewa beserta fasilitas diskon.

### 4. Transaksi Penyewaan
- Peminjaman Terstruktur : Pembuatan pesanan sewa dengan nomor referensi / kode unik per transaksi.
- Perhitungan Otomatis : Kalkulasi otomatis subtotal dan total biaya sewa berdasarkan durasi hari dan kuantitas barang.
- Verifikasi & Approval : Alur persetujuan peminjaman oleh admin organisasi terkait.

### 5. Pembayaran & Dokumen Pendukung
- Metode Pembayaran Fleksibel : Mendukung pembayaran DP (uang muka), pelunasan, maupun denda via Transfer Bank, QRIS, atau Tunai.
- Unggah Bukti & Berkas : Penyimpanan bukti transfer pembayaran dan berkas pendukung seperti surat izin kegiatan atau proposal peminjaman.

### 6. Pengembalian & Pemeriksaan Kondisi
- Pemeriksaan Fisik : Form inspeksi kondisi fisik barang saat dikembalikan (baik, rusak ringan, rusak berat).
- Denda & Ganti Rugi : Kalkulasi otomatis denda keterlambatan dan biaya perbaikan barang jika terjadi kerusakan.

---

## Akun Default (Testing & Demo)

Saat pertama kali dijalankan, sistem otomatis membuat akun awal di database lokal:
- **Username:** `admin`
- **Password:** `admin123`
- **Role:** Administrator Ormawa
