import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/models/profile.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';
import 'package:kosfinder/screens/login_screen.dart';
import 'package:kosfinder/screens/register_screen.dart';
import 'package:provider/provider.dart';

class _FakeKosRepository implements KosRepository {
  _FakeKosRepository(this.kos);

  final List<Kos> kos;

  @override
  Future<List<Kos>> fetchKosTerbaru() async => kos;

  @override
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice}) async {
    final normalizedQuery = query.toLowerCase();
    return kos.where((item) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          item.name.toLowerCase().contains(normalizedQuery) ||
          item.addressArea.toLowerCase().contains(normalizedQuery);
      final matchesPrice = maxPrice == null || item.monthlyPrice <= maxPrice;
      return matchesQuery && matchesPrice;
    }).toList();
  }

  @override
  Future<Kos?> fetchKosById(String id) async => null;
}

class _FakeAuthRepository implements AuthRepository {
  bool _active = false;

  @override
  bool get hasActiveSession => _active;

  @override
  Stream<bool> get sessionChanges => const Stream<bool>.empty();

  @override
  Future<void> restoreSession() async {}

  @override
  Future<Profile> login({
    required String email,
    required String password,
  }) async {
    _active = true;
    return Profile(id: 'fake-user', name: 'Meka', role: 'pemilik_kos');
  }

  @override
  Future<void> logout() async {
    _active = false;
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
}

void main() {
  Widget buildScreen(List<Kos> kos, {_FakeAuthRepository? authRepository}) {
    final provider = KosProvider(repository: _FakeKosRepository(kos));
    final authProvider = AuthProvider(
      repository: authRepository ?? _FakeAuthRepository(),
    );

    return ChangeNotifierProvider.value(
      value: provider,
      child: ChangeNotifierProvider.value(
        value: authProvider,
        child: MaterialApp(
          routes: {
            '/register': (_) => const RegisterScreen(),
            '/login': (_) => const LoginScreen(),
          },
          home: const KosListScreen(),
        ),
      ),
    );
  }

  testWidgets('menampilkan daftar kos sesuai urutan repository', (
    tester,
  ) async {
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Singaraja Baru',
        addressArea: 'Singaraja',
        monthlyPrice: 900000,
      ),
      Kos(
        id: '2',
        name: 'Kos Singaraja Lama',
        addressArea: 'Singaraja',
        monthlyPrice: 700000,
      ),
    ];

    await tester.pumpWidget(buildScreen(kos));
    await tester.pumpAndSettle();

    expect(find.text('Kos Singaraja Baru'), findsOneWidget);
    expect(find.text('Kos Singaraja Lama'), findsOneWidget);
  });

  testWidgets('menampilkan Kos tidak ditemukan jika data kosong', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(const []));
    await tester.pumpAndSettle();

    expect(find.text('Kos tidak ditemukan'), findsOneWidget);
  });

  testWidgets('ketika kos ditekan membuka halaman detail', (tester) async {
    const kos = Kos(
      id: '1',
      name: 'Kos Detail',
      addressArea: 'Singaraja',
      monthlyPrice: 850000,
      description: 'Dekat kampus',
      whatsappNumber: '628123456789',
      status: 'Tersedia',
    );

    await tester.pumpWidget(buildScreen(const [kos]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kos Detail'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Kos'), findsOneWidget);
    expect(find.text('Kos Detail'), findsOneWidget);
    expect(find.text('Singaraja'), findsOneWidget);
    expect(find.text('Hubungi Pemilik'), findsOneWidget);
  });

  testWidgets('pencarian nama menampilkan hasil yang cocok', (tester) async {
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
      ),
      Kos(
        id: '2',
        name: 'Kos Melati',
        addressArea: 'Singaraja',
        monthlyPrice: 900000,
      ),
    ];

    await tester.pumpWidget(buildScreen(kos));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('search-field')), 'mawar');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar'), findsOneWidget);
    expect(find.text('Kos Melati'), findsNothing);
  });

  testWidgets('pencarian kosong menampilkan Kos tidak ditemukan', (
    tester,
  ) async {
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
      ),
    ];

    await tester.pumpWidget(buildScreen(kos));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('search-field')), 'tidak ada');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Kos tidak ditemukan'), findsOneWidget);
  });

  testWidgets('filter harga menyembunyikan kos di atas batas', (tester) async {
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Murah',
        addressArea: 'Singaraja',
        monthlyPrice: 700000,
      ),
      Kos(
        id: '2',
        name: 'Kos Mahal',
        addressArea: 'Singaraja',
        monthlyPrice: 900000,
      ),
    ];

    await tester.pumpWidget(buildScreen(kos));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('max-price-field')), '800000');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Kos Murah'), findsOneWidget);
    expect(find.text('Kos Mahal'), findsNothing);
  });

  testWidgets('pencarian dan harga maksimum digabungkan', (tester) async {
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Mawar Murah',
        addressArea: 'Singaraja',
        monthlyPrice: 700000,
      ),
      Kos(
        id: '2',
        name: 'Kos Mawar Mahal',
        addressArea: 'Singaraja',
        monthlyPrice: 900000,
      ),
      Kos(
        id: '3',
        name: 'Kos Melati Murah',
        addressArea: 'Singaraja',
        monthlyPrice: 600000,
      ),
    ];

    await tester.pumpWidget(buildScreen(kos));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('search-field')), 'mawar');
    await tester.enterText(find.byKey(const Key('max-price-field')), '800000');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar Murah'), findsOneWidget);
    expect(find.text('Kos Mawar Mahal'), findsNothing);
    expect(find.text('Kos Melati Murah'), findsNothing);
  });

  testWidgets('tombol registrasi membuka halaman registrasi', (tester) async {
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
      ),
    ];

    await tester.pumpWidget(buildScreen(kos));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-register')));
    await tester.pumpAndSettle();

    expect(find.text('Registrasi'), findsOneWidget);
    expect(find.byKey(const Key('register-name')), findsOneWidget);
    expect(find.byKey(const Key('register-role')), findsOneWidget);
  });

  testWidgets('tombol login terbuka dari AppBar', (tester) async {
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
      ),
    ];

    await tester.pumpWidget(buildScreen(kos));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open-login')), findsOneWidget);
    await tester.tap(find.byKey(const Key('open-login')));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
  });

  testWidgets('pengguna login melihat tombol logout dan bisa logout', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final authProvider = AuthProvider(repository: authRepository);
    await authProvider.login(
      email: 'meka@example.com',
      password: 'password123',
    );
    const kos = [
      Kos(
        id: '1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
      ),
    ];
    final kosProvider = KosProvider(repository: _FakeKosRepository(kos));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: kosProvider),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: MaterialApp(
          routes: {
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
          },
          home: const KosListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('logout-appbar')), findsOneWidget);
    await tester.tap(find.byKey(const Key('logout-appbar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open-login')), findsOneWidget);
  });
}
