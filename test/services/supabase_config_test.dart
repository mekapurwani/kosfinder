import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/services/supabase_config.dart';

void main() {
  test('konfigurasi Supabase valid dibaca sebagai terkonfigurasi', () {
    const config = SupabaseConfig(
      url: 'https://project.supabase.co',
      anonKey: 'publishable-key',
    );

    expect(config.isConfigured, isTrue);
  });

  test('konfigurasi kosong tidak terkonfigurasi', () {
    const config = SupabaseConfig(url: '', anonKey: '');

    expect(config.isConfigured, isFalse);
  });

  test('URL dan placeholder tidak dianggap valid', () {
    const missingScheme = SupabaseConfig(
      url: 'project.supabase.co',
      anonKey: 'publishable-key',
    );
    const placeholder = SupabaseConfig(
      url: 'https://project.supabase.co',
      anonKey: '<SUPABASE_ANON_KEY>',
    );

    expect(missingScheme.isConfigured, isFalse);
    expect(placeholder.isConfigured, isFalse);
  });
}
