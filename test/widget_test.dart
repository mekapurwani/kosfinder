import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/services/supabase_config.dart';

void main() {
  testWidgets('menampilkan pesan konfigurasi saat dart-define belum ada', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(
        config: SupabaseConfig(url: '', anonKey: ''),
      ),
    );

    expect(
      find.textContaining('Konfigurasi Supabase belum tersedia'),
      findsOneWidget,
    );
  });
}
