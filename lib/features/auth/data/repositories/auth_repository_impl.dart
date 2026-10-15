import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _db;
  static const _keyUserId = 'current_user_id';

  AuthRepositoryImpl(this._db);

  // ============ LOGIN ============
  @override
  Future<UserEntity?> login(String username, String password) async {
    // 1. Cek apakah username ada dalam database
    final userByUsername = await (_db.select(_db.users)
          ..where((t) => t.username.equals(username))
          ..limit(1))
        .getSingleOrNull();

    if (userByUsername == null) {
      throw Exception('Username tidak ada atau password salah');
    }

    // 2. Cek apakah password cocok
    if (userByUsername.passwordHash != password) {
      throw Exception('Password salah');
    }

    // 3. Cek status akun
    if (userByUsername.status != 'aktif') {
      throw Exception('Akun sedang dinonaktifkan. Hubungi admin');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userByUsername.idUser);

    await (_db.update(_db.users)..where((t) => t.idUser.equals(userByUsername.idUser)))
        .write(UsersCompanion(lastLogin: Value(DateTime.now())));

    return _toEntity(userByUsername);
  }

  // ============ RESET PASSWORD ============
  @override
  Future<bool> resetPassword(String username, String newPassword) async {
    final user = await (_db.select(_db.users)
          ..where((t) => t.username.equals(username))
          ..limit(1))
        .getSingleOrNull();

    if (user == null) {
      throw Exception('Username tidak ditemukan dalam database');
    }

    await (_db.update(_db.users)..where((t) => t.idUser.equals(user.idUser)))
        .write(UsersCompanion(passwordHash: Value(newPassword)));
    return true;
  }

  // ============ CEK USERNAME ============
  @override
  Future<bool> isUsernameTaken(String username) async {
    final query = _db.select(_db.users)
      ..where((t) => t.username.equals(username))
      ..limit(1);
    final result = await query.getSingleOrNull();
    return result != null;
  }

  // ============ REGISTER ============
  @override
  Future<UserEntity> register(RegisterData data) async {
    // Validasi domain email kampus
    final email = data.email.trim().toLowerCase();
    if (!email.endsWith('@student.upnjatim.ac.id')) {
      throw Exception('Email wajib menggunakan domain @student.upnjatim.ac.id');
    }
    // Cek username dulu
    if (await isUsernameTaken(data.username)) {
      throw Exception('Username "${data.username}" sudah digunakan');
    }

    // Jalankan dalam transaction supaya kalau gagal, semua rollback
    return await _db.transaction(() async {
      // 1. Insert User
      final userId = await _db
          .into(_db.users)
          .insert(
            UsersCompanion.insert(
              username: data.username,
              passwordHash: data.password, // TODO: hash pakai bcrypt
              namaLengkap: data.namaLengkap,
              email: Value(data.email),
              noTelepon: Value(data.noTelepon),
              role: data.role,
            ),
          );

      // 2. Kalau role penyewa → buat Peminjam
      if (data.role == 'penyewa') {
        await _db
            .into(_db.peminjam)
            .insert(
              PeminjamCompanion.insert(
                idUser: userId,
                nim: Value(data.nim ?? ''),
                kelas: Value(data.kelas ?? ''),
                fakultas: Value(data.fakultas ?? ''),
                jurusan: Value(data.jurusan ?? ''),
                email: Value(data.email),
                kontak: Value(data.noTelepon),
              ),
            );
      }

      // 3. Kalau role admin_ormawa → buat Organisasi + UserOrganisasi
      if (data.role == 'admin_ormawa' && data.namaOrganisasi != null) {
        final singkatanVal = (data.singkatanOrganisasi != null &&
                data.singkatanOrganisasi!.trim().isNotEmpty)
            ? data.singkatanOrganisasi!.trim()
            : _generateSingkatan(data.namaOrganisasi!);

        final orgId = await _db
            .into(_db.organisasi)
            .insert(
              OrganisasiCompanion.insert(
                namaOrganisasi: data.namaOrganisasi!,
                singkatan: singkatanVal,
                fakultas: Value(data.fakultas ?? ''),
                jurusan: Value(data.jurusan ?? ''),
                email: Value(data.email),
                noTelepon: Value(data.noTelepon),
                namaKetua: Value(data.namaLengkap),
              ),
            );

        await _db
            .into(_db.userOrganisasi)
            .insert(
              UserOrganisasiCompanion.insert(
                idUser: userId,
                idOrganisasi: orgId,
                jabatan: const Value('ketua'),
              ),
            );
      }

      // 4. Ambil user yang baru dibuat
      final newUser = await (_db.select(
        _db.users,
      )..where((t) => t.idUser.equals(userId))).getSingle();

      return _toEntity(newUser);
    });
  }

  // ============ LOGOUT ============
  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  // ============ GET CURRENT USER ============
  @override
  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt(_keyUserId);
    if (idUser == null) return null;

    final user =
        await (_db.select(_db.users)
              ..where((t) => t.idUser.equals(idUser))
              ..limit(1))
            .getSingleOrNull();

    return user == null ? null : _toEntity(user);
  }

  UserEntity _toEntity(User user) => UserEntity(
    idUser: user.idUser,
    username: user.username,
    namaLengkap: user.namaLengkap,
    email: user.email,
    noTelepon: user.noTelepon,
    role: user.role,
    status: user.status,
  );

  String _generateSingkatan(String nama) {
    final words = nama.trim().split(RegExp(r'\s+'));
    if (words.length > 1) {
      final initials = words.map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
      if (initials.length >= 2) {
        return initials.length > 10 ? initials.substring(0, 10) : initials;
      }
    }
    final clean = nama.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (clean.length >= 2) {
      return clean.substring(0, clean.length > 10 ? 10 : clean.length);
    }
    return clean.padRight(2, 'X');
  }
}
