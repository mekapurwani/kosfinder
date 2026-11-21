import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/profile.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.error});

  final Object? error;
  bool loggedOut = false;
  String? lastName;
  String? lastEmail;
  String? lastPassword;
  String? lastRole;

  @override
  bool get hasActiveSession => false;

  @override
  Stream<bool> get sessionChanges => const Stream<bool>.empty();

  @override
  Future<void> restoreSession() async {}

  @override
  Future<Profile> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    if (error != null) {
      throw error!;
    }
    return Profile(id: 'fake-user', name: 'Meka', role: 'pemilik_kos');
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
  }

  @override
  Future<Profile> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    lastName = name;
    lastEmail = email;
    lastPassword = password;
    lastRole = role;
    if (error != null) {
      throw error!;
    }
    return Profile(id: 'fake-user', name: name, role: role);
  }
}

void main() {
  test('register menyimpan data profil dari role pemilik', () async {
    final repository = _FakeAuthRepository();
    final provider = AuthProvider(repository: repository);

    final success = await provider.register(
      name: 'Meka',
      email: 'meka@example.com',
      password: 'password123',
      role: 'pemilik_kos',
    );

    expect(success, isTrue);
    expect(repository.lastName, 'Meka');
    expect(repository.lastEmail, 'meka@example.com');
    expect(repository.lastPassword, 'password123');
    expect(repository.lastRole, 'pemilik_kos');
    expect(provider.profile?.role, 'pemilik_kos');
  });

  test('register untuk pencari menyimpan role pencari', () async {
    final provider = AuthProvider(repository: _FakeAuthRepository());

    final success = await provider.register(
      name: 'Pencari',
      email: 'pencari@example.com',
      password: 'password123',
      role: 'pencari_kos',
    );

    expect(success, isTrue);
    expect(provider.profile?.role, 'pencari_kos');
  });

  test('register menampilkan error ramah saat gagal', () async {
    final provider = AuthProvider(
      repository: _FakeAuthRepository(error: Exception('offline')),
    );

    final success = await provider.register(
      name: 'Meka',
      email: 'meka@example.com',
      password: 'password123',
      role: 'pemilik_kos',
    );

    expect(success, isFalse);
    expect(provider.profile, isNull);
    expect(
      provider.errorMessage,
      'Registrasi gagal. Periksa data atau koneksi Anda.',
    );
  });

  test('login menyimpan profil dan mengembalikan sukses', () async {
    final repository = _FakeAuthRepository();
    final provider = AuthProvider(repository: repository);

    final success = await provider.login(
      email: 'meka@example.com',
      password: 'password123',
    );

    expect(success, isTrue);
    expect(repository.lastEmail, 'meka@example.com');
    expect(provider.profile?.role, 'pemilik_kos');
  });

  test('login menampilkan error ramah saat gagal', () async {
    final provider = AuthProvider(
      repository: _FakeAuthRepository(error: Exception('unauthorized')),
    );

    final success = await provider.login(
      email: 'meka@example.com',
      password: 'salah',
    );

    expect(success, isFalse);
    expect(provider.errorMessage, 'Email atau password salah.');
  });

  test('logout menghapus profil', () async {
    final repository = _FakeAuthRepository();
    final provider = AuthProvider(repository: repository);
    await provider.login(email: 'meka@example.com', password: 'password123');

    await provider.logout();

    expect(repository.loggedOut, isTrue);
    expect(provider.profile, isNull);
  });
}
