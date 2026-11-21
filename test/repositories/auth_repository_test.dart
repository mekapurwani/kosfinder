import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/profile.dart';
import 'package:kosfinder/repositories/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  bool sessionActive = false;
  bool restored = false;
  final _sessionChanges = StreamController<bool>.broadcast();

  @override
  bool get hasActiveSession => sessionActive;

  @override
  Stream<bool> get sessionChanges => _sessionChanges.stream;

  @override
  Future<void> restoreSession() async {
    restored = true;
  }

  @override
  Future<Profile> login({
    required String email,
    required String password,
  }) async {
    return Profile(id: 'fake-user', name: 'Meka', role: 'pemilik_kos');
  }

  @override
  Future<void> logout() async {
    sessionActive = false;
  }

  @override
  Future<Profile> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    return Profile(id: 'fake-user', name: name, role: role);
  }

  void emitSession(bool active) {
    sessionActive = active;
    _sessionChanges.add(active);
  }

  Future<void> close() => _sessionChanges.close();
}

void main() {
  test('MissingAuthRepository tidak memiliki sesi aktif', () {
    const repository = MissingAuthRepository();

    expect(repository.hasActiveSession, isFalse);
  });

  test('restoreSession menandai pemulihan sesi', () async {
    final repository = _FakeAuthRepository();

    await repository.restoreSession();

    expect(repository.restored, isTrue);
  });

  test('sessionChanges membedakan sesi aktif dan berakhir', () async {
    final repository = _FakeAuthRepository();
    final states = <bool>[];
    final subscription = repository.sessionChanges.listen(states.add);

    repository.emitSession(true);
    repository.emitSession(false);
    await pumpEventQueue();

    expect(states, [true, false]);
    expect(repository.hasActiveSession, isFalse);

    await subscription.cancel();
    await repository.close();
  });

  test('registrasi fake mengembalikan profil beserta role', () async {
    final repository = _FakeAuthRepository();

    final profile = await repository.register(
      name: 'Meka',
      email: 'meka@example.com',
      password: 'password123',
      role: 'pemilik_kos',
    );

    expect(profile.name, 'Meka');
    expect(profile.role, 'pemilik_kos');
  });

  test('login fake mengembalikan profil pemilik', () async {
    final repository = _FakeAuthRepository();

    final profile = await repository.login(
      email: 'meka@example.com',
      password: 'password123',
    );

    expect(profile.role, 'pemilik_kos');
  });

  test('logout fake mengakhiri sesi', () async {
    final repository = _FakeAuthRepository();
    repository.emitSession(true);

    await repository.logout();

    expect(repository.hasActiveSession, isFalse);
  });
}
