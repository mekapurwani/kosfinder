# kosfinder

KosFinder - aplikasi pencarian kos berbasis Flutter dan Supabase.

KosFinder membantu pencari kos menemukan kos berdasarkan nama atau lokasi dan membandingkan harga bulanan. Pemilik kos dapat mengelola kos miliknya sendiri, termasuk detail, status ketersediaan, jumlah kamar, dan nomor WhatsApp.

## Fitur Versi 1

- Daftar kos publik tanpa login.
- Pencarian nama dan lokasi/area secara case-insensitive.
- Filter harga maksimum.
- Halaman detail kos dan tombol Hubungi Pemilik melalui WhatsApp.
- Registrasi dan login dengan role Pencari Kos atau Pemilik Kos.
- CRUD kos milik pemilik dengan RLS Supabase.
- Status otomatis `Penuh` saat jumlah kamar bernilai 0.
- Halaman About.

## Batasan Versi 1

- Tidak ada pembayaran online, chat internal, ulasan/rating, atau rekomendasi AI.
- Tidak ada verifikasi identitas pemilik.
- Tidak ada upload foto atau peta.
- Tidak ada dashboard admin atau peran pengelola kontrakan.
- Tidak ada soft delete.

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
