import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_form_screen.dart';
import 'package:provider/provider.dart';

class _FakeOwnerKosRepository implements KosRepository, OwnerKosRepository {
  Kos? created;
  String? lastName;
  String? lastAddress;
  num? lastPrice;
  String? lastDescription;
  String? lastWhatsapp;
  String? lastStatus;

  @override
  Future<List<Kos>> fetchKosTerbaru() async => [];

  @override
  Future<List<Kos>> searchKosTerbaru(String query, {num? maxPrice}) async => [];

  @override
  Future<Kos?> fetchKosById(String id) async => null;

  @override
  Future<List<Kos>> fetchKosMilikPemilik() async => [];

  @override
  Future<Kos> createKos({
    required String name,
    required String addressArea,
    required num monthlyPrice,
    required String description,
    required String whatsappNumber,
    required String status,
  }) async {
    lastName = name;
    lastAddress = addressArea;
    lastPrice = monthlyPrice;
    lastDescription = description;
    lastWhatsapp = whatsappNumber;
    lastStatus = status;
    created = Kos(
      id: 'new',
      name: name,
      addressArea: addressArea,
      monthlyPrice: monthlyPrice,
      description: description,
      whatsappNumber: whatsappNumber,
      status: status,
      ownerId: 'owner-1',
    );
    return created!;
  }
}

void main() {
  testWidgets('form valid mengirim seluruh data kos', (tester) async {
    final repository = _FakeOwnerKosRepository();
    final provider = KosProvider(repository: repository);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: KosFormScreen()),
      ),
    );

    await tester.enterText(find.byKey(const Key('kos-name')), 'Kos Mawar');
    await tester.enterText(find.byKey(const Key('kos-address')), 'Singaraja');
    await tester.enterText(find.byKey(const Key('kos-price')), '800000');
    await tester.enterText(
      find.byKey(const Key('kos-description')),
      'Dekat kampus',
    );
    await tester.enterText(
      find.byKey(const Key('kos-whatsapp')),
      '628123456789',
    );

    await tester.tap(find.byKey(const Key('save-kos')));
    await tester.pumpAndSettle();

    expect(repository.lastName, 'Kos Mawar');
    expect(repository.lastAddress, 'Singaraja');
    expect(repository.lastPrice, 800000);
    expect(repository.lastDescription, 'Dekat kampus');
    expect(repository.lastWhatsapp, '628123456789');
    expect(repository.lastStatus, 'Tersedia');
  });

  testWidgets('form menolak field wajib yang kosong', (tester) async {
    final provider = KosProvider(repository: _FakeOwnerKosRepository());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: KosFormScreen()),
      ),
    );

    await tester.tap(find.byKey(const Key('save-kos')));
    await tester.pump();

    expect(find.text('Nama kos wajib diisi'), findsOneWidget);
    expect(find.text('Alamat/area wajib diisi'), findsOneWidget);
  });
}
