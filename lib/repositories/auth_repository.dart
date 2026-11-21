import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

abstract class AuthRepository {
  bool get hasActiveSession;

  Stream<bool> get sessionChanges;

  Future<void> restoreSession();

  Future<Profile> login({required String email, required String password});

  Future<void> logout();

  Future<Profile> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });
}

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this.client);

  final SupabaseClient client;

  @override
  bool get hasActiveSession => client.auth.currentSession != null;

  @override
  Stream<bool> get sessionChanges {
    return client.auth.onAuthStateChange.map((event) {
      return event.session != null;
    });
  }

  @override
  Future<void> restoreSession() async {
    client.auth.currentSession;
  }

  @override
  Future<Profile> login({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Login gagal.');
    }

    final metadata = user.userMetadata ?? {};
    return Profile(
      id: user.id,
      name: metadata['name']?.toString() ?? '',
      role: metadata['role']?.toString() ?? 'pencari_kos',
    );
  }

  @override
  Future<void> logout() async {
    await client.auth.signOut();
  }

  @override
  Future<Profile> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException(
        'Registrasi berhasil dibuat, tetapi konfirmasi email mungkin diperlukan.',
      );
    }

    return Profile(id: user.id, name: name, role: role);
  }
}

class MissingAuthRepository implements AuthRepository {
  const MissingAuthRepository();

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
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Profile> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    throw StateError('Konfigurasi Supabase belum tersedia.');
  }
}
