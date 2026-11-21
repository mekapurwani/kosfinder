import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';
import 'package:provider/provider.dart';

class _FakeKosRepository implements KosRepository {
  _FakeKosRepository(this.kos);

  final List<Kos> kos;

  @override
  Future<List<Kos>> fetchKosTerbaru() async => kos;

  @override
  Future<Kos?> fetchKosById(String id) async => null;
}

void main() {
  Widget buildScreen(List<Kos> kos) {
    final provider = KosProvider(repository: _FakeKosRepository(kos));

    return ChangeNotifierProvider.value(
      value: provider,
      child: const MaterialApp(home: KosListScreen()),
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
}
