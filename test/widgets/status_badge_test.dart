import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/widgets/status_badge.dart';

void main() {
  testWidgets('menampilkan label Tersedia', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(status: 'Tersedia')),
      ),
    );

    expect(find.text('Tersedia'), findsOneWidget);
  });

  testWidgets('menampilkan label Penuh', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(status: 'Penuh')),
      ),
    );

    expect(find.text('Penuh'), findsOneWidget);
  });
}
