# Arsitektur KosFinder - Versi 1

## 1. Komponen aplikasi

Gunakan pola sederhana **Screen -> Provider -> Repository -> Supabase**:

- **Screen (US01-US09):** membangun UI Flutter, menangani input dan dialog. Screen tidak membaca Supabase langsung.
- **Provider (US01-US09):** menyimpan state layar, memanggil repository, dan meneruskan loading/error/data ke Screen. Gunakan satu Provider per area utama: AuthProvider, KosProvider, dan ProfileProvider.
- **Repository (US01-US09):** membungkus operasi Supabase Auth dan tabel database. Repository memusatkan query pencarian, pemuatan detail, dan CRUD.
- **Supabase (US05-US09):** autentikasi, tabel profil/kos, dan Row Level Security (RLS). RLS adalah lapisan wajib untuk membatasi kepemilikan.
- **Service konfigurasi (US05-US09):** membaca `SUPABASE_URL` dan `SUPABASE_ANON_KEY` dengan `--dart-define`; tidak menyimpan nilai tersebut di source.

### Daftar layar dan navigasi

- **Splash/Auth Gate:** memeriksa sesi Supabase, lalu menuju Daftar Kos atau Login bila sesi berakhir. Dibutuhkan US05.
- **Daftar Kos:** daftar tanpa login, pencarian nama/lokasi, filter harga maksimum, urutan terbaru, status `Penuh`, dan pesan kosong. Dibutuhkan US01-US02.
- **Detail Kos:** data kos dan tombol `Hubungi Pemilik`. Dibutuhkan US03-US04.
- **Login:** email dan password. Dibutuhkan US05.
- **Registrasi:** nama, email, password, dan pilihan role; role tidak dapat diubah sesudah registrasi. Dibutuhkan US05.
- **Daftar Kos Saya:** kos milik pemilik login. Dibutuhkan US06-US09.
- **Form Tambah/Edit Kos:** data kos, status, dan nomor WhatsApp; edit hanya milik pemilik. Dibutuhkan US06-US07.
- **About:** menampilkan `2415051089 - Ni Luh Meka Purwani`. Dibutuhkan sebagai identitas aplikasi.
- **Navigasi:** pencari dapat membuka Daftar -> Detail. Pemilik dapat membuka Login/Registrasi -> Daftar Kos Saya -> Tambah atau Edit; hapus menampilkan `AlertDialog` konfirmasi. Sesi berakhir kembali ke Login.

## 2. Rencana database

### Tabel `profiles`

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | `uuid` | PK dan FK ke `auth.users(id)` |
| `name` | `text` | Nama pengguna |
| `role` | `text` | `pencari_kos` atau `pemilik_kos` |
| `created_at` | `timestamptz` | Waktu dibuat |

### Tabel `kos`

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | `uuid` | PK |
| `owner_id` | `uuid` | FK ke `auth.users(id)` |
| `name` | `text` | Nama kos |
| `address_area` | `text` | Alamat/area |
| `monthly_price` | `numeric` | Harga bulanan dalam bentuk angka |
| `description` | `text` | Deskripsi singkat |
| `whatsapp_number` | `text` | Satu nomor WhatsApp |
| `status` | `text` | `Tersedia` atau `Penuh` |
| `created_at` | `timestamptz` | Waktu ditambahkan |

Relasi: satu profil dapat memiliki banyak kos; `kos.owner_id` merujuk ke pemilik yang membuat data. Kolom teks dicari dengan `ilike '%kata%'` agar pencocokan sebagian dan case-insensitive.

### Aturan akses

- **Melihat:** siapa pun, termasuk pengguna tanpa login, dapat `SELECT` data kos dan relasi publik yang dibutuhkan detail. Profil hanya diperlukan pemilik yang login (`US01-US03`, `US09`).
- **Menambah:** hanya pengguna login dengan role `pemilik_kos` yang dapat `INSERT`; `owner_id` harus sama dengan `auth.uid()` (`US06`).
- **Mengubah:** hanya pemilik yang memiliki `kos.owner_id = auth.uid()` yang dapat `UPDATE`; role pemilik juga harus ada (`US07`).
- **Menghapus:** hanya pemilik dengan `kos.owner_id = auth.uid()` yang dapat `DELETE`; penghapusan dilakukan setelah konfirmasi UI (`US08`).
- **Profil:** profil dibuat otomatis saat registrasi dari metadata Supabase; role tidak memiliki policy `UPDATE`, sehingga tidak dapat diubah setelah dibuat (`US05`).

## 3. Konfigurasi dan rilis

Konfigurasi hanya dibaca dari:

```text
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Gunakan nama variabel yang sama saat build. URL dan anon key tidak ditulis dalam kode. Jangan pernah memasukkan `service_role key`; hanya anon key yang digunakan aplikasi (`US05-US09`).

Rilis versi Android menggunakan `flutter build apk --release` dengan kedua `--dart-define`. Publikasikan APK sebagai aset pada GitHub Release repository `mekapurwani/kosfinder`, beri tag versi dan catatan ringkas (`US01-US09`). Jangan menyimpan APK atau key rahasia di source.

## 4. Package yang dibutuhkan

- **`supabase_flutter` (US05-US09):** koneksi Supabase, Auth, query, dan fitur realtime tidak dibutuhkan sehingga cukup klien langsung.
- **`provider` (US01-US09):** state management sederhana sesuai pola Provider yang dipilih project.
- **`url_launcher` (US04):** membuka tautan `https://wa.me/<nomor>` dari tombol Hubungi Pemilik.

Tidak ada package pencarian, peta, chat, upload foto, state management tambahan, atau backend lokal yang dibutuhkan untuk versi 1.