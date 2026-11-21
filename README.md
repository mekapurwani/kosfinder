# kosfinder

KosFinder - aplikasi pencarian kos berbasis Flutter dan Supabase.

## Cara Menjalankan

Konfigurasi Supabase dibaca dari `--dart-define`. URL dan anon/publishable key tidak disimpan di source code.

Isi nilai berikut dengan kredensial Supabase milik Anda sendiri:

```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL=https://contoh-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=contoh-publishable-key
```

Untuk Windows:

```powershell
flutter run -d windows `
  --dart-define=SUPABASE_URL=https://contoh-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=contoh-publishable-key
```

Untuk build APK Android:

```powershell
flutter build apk --release `
  --dart-define=SUPABASE_URL=https://contoh-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=contoh-publishable-key
```

Gunakan hanya URL dan publishable/anon key dari dashboard Supabase. Jangan menggunakan atau menyimpan `service_role key` pada aplikasi Flutter.
