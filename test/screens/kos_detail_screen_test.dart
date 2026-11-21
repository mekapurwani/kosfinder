import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';

void main() {
  testWidgets('menampilkan seluruh data detail kos', (tester) async {
    const kos = Kos(
      id: '1',
      name: 'Kos Putri Singaraja',
      addressArea: 'Singaraja Barat',
      monthlyPrice: 950000,
      description: 'Dekat kampus dan minimarket',
      whatsappNumber: '628123456789',
      status: 'Penuh',
      roomCount: 3,
    );

    await tester.pumpWidget(const MaterialApp(home: KosDetailScreen(kos: kos)));

    expect(find.text('Kos Putri Singaraja'), findsOneWidget);
    expect(find.text('Singaraja Barat'), findsOneWidget);
    expect(find.text('Rp950000 / bulan'), findsOneWidget);
    expect(find.text('Dekat kampus dan minimarket'), findsOneWidget);
    expect(find.text('Penuh'), findsOneWidget);
    expect(find.text('Jumlah kamar: 3'), findsOneWidget);
    expect(find.text('Hubungi Pemilik'), findsOneWidget);
  });

  test('membuat tautan wa.me dari nomor WhatsApp', () {
    const kos = Kos(
      id: '1',
      name: 'Kos',
      addressArea: 'Singaraja',
      monthlyPrice: 800000,
      whatsappNumber: '+62 812-3456-789',
    );

    expect(kos.whatsappUri.toString(), 'https://wa.me/628123456789');
  });
}
