import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/profile.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/register_screen.dart';
import 'package:provider/provider.dart';

class _FakeAuthRepository implements AuthRepository {
  String? lastRole;

  @override
  bool get hasActiveSession => false;
  @override
  Profile? get currentProfile => null;

  @override
  Stream<bool> get sessionChanges => const Stream<bool>.empty();

  @override
  Future<void> restoreSession() async {}

  @override
  Future<Profile> login({
    required String email,
    required String password,
  }) async {
    return Profile(id: 'fake-user', name: 'Meka', role: 'pemilik_kos');
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
    lastRole = role;
    return Profile(id: 'fake-user', name: name, role: role);
  }
}

void main() {
  Widget buildScreen(_FakeAuthRepository repository) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(repository: repository),
      child: const MaterialApp(home: RegisterScreen()),
    );
  }

  testWidgets('registrasi menampilkan pilihan Pencari dan Pemilik', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(_FakeAuthRepository()));

    await tester.tap(find.byKey(const Key('register-role')));
    await tester.pumpAndSettle();

    expect(find.text('Pencari Kos'), findsWidgets);
    expect(find.text('Pemilik Kos'), findsWidgets);
  });

  testWidgets('registrasi pemilik mengirim role pemilik_kos', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(buildScreen(repository));

    await tester.enterText(find.byKey(const Key('register-name')), 'Meka');
    await tester.enterText(
      find.byKey(const Key('register-email')),
      'meka@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'password123',
    );

    await tester.tap(find.byKey(const Key('register-role')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pemilik Kos').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(repository.lastRole, 'pemilik_kos');
  });

  testWidgets('screen registrasi tidak memiliki kontrol ubah role', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(_FakeAuthRepository()));

    await tester.enterText(find.byKey(const Key('register-name')), 'Meka');
    await tester.enterText(
      find.byKey(const Key('register-email')),
      'meka@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('register-role')), findsOneWidget);
  });
}
