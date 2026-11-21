import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/profile.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/login_screen.dart';
import 'package:provider/provider.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.error});

  final Object? error;
  bool loggedOut = false;

  @override
  bool get hasActiveSession => false;

  @override
  Stream<bool> get sessionChanges => const Stream<bool>.empty();

  @override
  Future<void> restoreSession() async {}

  @override
  Future<Profile> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    return Profile(id: 'fake-user', name: name, role: role);
  }

  @override
  Future<Profile> login({
    required String email,
    required String password,
  }) async {
    if (error != null) {
      throw error!;
    }
    return const Profile(id: 'fake-user', name: 'Meka', role: 'pemilik_kos');
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
  }
}

void main() {
  Widget buildScreen(_FakeAuthRepository repository) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(repository: repository),
      child: MaterialApp(
        routes: {
          '/register': (_) => const Scaffold(body: Text('Registrasi')),
          '/home': (_) => const Scaffold(body: Text('Beranda')),
        },
        home: const LoginScreen(),
      ),
    );
  }

  testWidgets('login menampilkan email dan password', (tester) async {
    await tester.pumpWidget(buildScreen(_FakeAuthRepository()));

    expect(find.byKey(const Key('login-email')), findsOneWidget);
    expect(find.byKey(const Key('login-password')), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });

  testWidgets('login berhasil dari form', (tester) async {
    await tester.pumpWidget(buildScreen(_FakeAuthRepository()));

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'meka@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
  });

  testWidgets('login gagal menampilkan pesan ramah', (tester) async {
    await tester.pumpWidget(
      buildScreen(_FakeAuthRepository(error: Exception('unauthorized'))),
    );

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'meka@example.com',
    );
    await tester.enterText(find.byKey(const Key('login-password')), 'salah');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Email atau password salah.'), findsOneWidget);
  });
}
