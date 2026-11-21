import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/screens/about_screen.dart';

void main() {
  testWidgets('About menampilkan identitas yang diminta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));

    expect(find.text('About'), findsOneWidget);
    expect(find.byKey(const Key('about-identity')), findsOneWidget);
    expect(find.text('2415051089 - Ni Luh Meka Purwani'), findsOneWidget);
  });

  testWidgets('About memiliki tombol kembali', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
              );
            },
            child: const Text('Buka About'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka About'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('about-back')), findsOneWidget);

    await tester.tap(find.byKey(const Key('about-back')));
    await tester.pumpAndSettle();
    expect(find.text('Buka About'), findsOneWidget);
  });
}
