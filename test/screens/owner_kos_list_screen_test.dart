import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/owner_kos_list_screen.dart';
import 'package:provider/provider.dart';

class _FakeOwnerKosRepository implements KosRepository, OwnerKosRepository {
  _FakeOwnerKosRepository(this.owned);

  List<Kos> owned;

  @override
  Future<List<Kos>> fetchKosTerbaru() async => owned;

  @override
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice}) async =>
      owned;

  @override
  Future<Kos?> fetchKosById(String id) async => null;

  @override
  Future<List<Kos>> fetchKosMilikPemilik() async => owned;

  @override
  Future<Kos> createKos({
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
  }) async {
    return Kos(
      id: 'new',
      name: name,
      addressArea: addressArea,
      monthlyPrice: monthlyPrice,
      description: description,
      whatsappNumber: whatsappNumber,
      status: status,
      ownerId: 'owner-1',
    );
  }

  @override
  Future<Kos> updateKos({
    required String id,
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
  }) async {
    return Kos(
      id: id,
      name: name,
      addressArea: addressArea,
      monthlyPrice: monthlyPrice,
      description: description,
      whatsappNumber: whatsappNumber,
      status: status,
      ownerId: 'owner-1',
    );
  }

  @override
  Future<void> deleteKos(String id) async {
    owned = owned.where((kos) => kos.id != id).toList();
  }
}

void main() {
  testWidgets('menampilkan daftar kos milik pemilik', (tester) async {
    const owned = [
      Kos(
        id: 'owned-1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
        ownerId: 'owner-1',
      ),
    ];
    final provider = KosProvider(repository: _FakeOwnerKosRepository(owned));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar'), findsOneWidget);
    expect(find.byKey(const Key('add-kos')), findsOneWidget);
  });

  testWidgets('tombol tambah membuka form kos', (tester) async {
    final provider = KosProvider(repository: _FakeOwnerKosRepository(const []));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-kos')));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kos'), findsOneWidget);
  });

  testWidgets('tombol kembali keluar dari halaman Kos Saya', (tester) async {
    final provider = KosProvider(repository: _FakeOwnerKosRepository(const []));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          routes: {
            '/home': (_) => const Scaffold(body: Text('Halaman Publik')),
          },
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const OwnerKosListScreen(),
                    ),
                  );
                },
                child: const Text('Buka Kos Saya'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka Kos Saya'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('owner-kos-back')), findsOneWidget);

    await tester.tap(find.byKey(const Key('owner-kos-back')));
    await tester.pumpAndSettle();

    expect(find.text('Buka Kos Saya'), findsOneWidget);
  });

  testWidgets('tombol edit membuka form terisi data kos', (tester) async {
    const owned = [
      Kos(
        id: 'owned-1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
        description: 'Dekat kampus',
        whatsappNumber: '628123456789',
        status: 'Penuh',
        ownerId: 'owner-1',
      ),
    ];
    final provider = KosProvider(repository: _FakeOwnerKosRepository(owned));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('edit-kos-owned-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit-kos-owned-1')));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Kos'), findsOneWidget);
    expect(find.text('Kos Mawar'), findsOneWidget);
    expect(find.text('Singaraja'), findsOneWidget);
    expect(find.text('Penuh'), findsOneWidget);
  });

  testWidgets('tombol About membuka identitas aplikasi', (tester) async {
    final provider = KosProvider(repository: _FakeOwnerKosRepository(const []));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-about')));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('2415051089 - Ni Luh Meka Purwani'), findsOneWidget);
  });

  testWidgets('pemilik dapat melihat beberapa kos miliknya sendiri', (
    tester,
  ) async {
    const owned = [
      Kos(
        id: 'owned-1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
        ownerId: 'owner-1',
      ),
      Kos(
        id: 'owned-2',
        name: 'Kos Melati',
        addressArea: 'Singaraja',
        monthlyPrice: 900000,
        ownerId: 'owner-1',
      ),
    ];
    final provider = KosProvider(repository: _FakeOwnerKosRepository(owned));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar'), findsOneWidget);
    expect(find.text('Kos Melati'), findsOneWidget);
  });

  testWidgets('delete batal tidak menghapus kos', (tester) async {
    const owned = [
      Kos(
        id: 'owned-1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
        ownerId: 'owner-1',
      ),
    ];
    final provider = KosProvider(repository: _FakeOwnerKosRepository(owned));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete-kos-owned-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delete-kos-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancel-delete-kos')));
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar'), findsOneWidget);
  });

  testWidgets('konfirmasi delete menghapus kartu kos', (tester) async {
    const owned = [
      Kos(
        id: 'owned-1',
        name: 'Kos Mawar',
        addressArea: 'Singaraja',
        monthlyPrice: 800000,
        ownerId: 'owner-1',
      ),
    ];
    final provider = KosProvider(repository: _FakeOwnerKosRepository(owned));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: OwnerKosListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete-kos-owned-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-kos')));
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar'), findsNothing);
  });
}
