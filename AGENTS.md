# AGENTS.md

## Konteks Project

KosFinder adalah aplikasi pencarian kos berbasis Flutter untuk pencari kos dan pemilik kos. Gunakan dokumen berikut sebagai acuan sebelum mengerjakan task:

- `docs/PRD.md`: kebutuhan produk, scope, user story, dan acceptance criteria.
- `docs/ARCHITECTURE.md`: arsitektur teknis dan struktur implementasi.
- `docs/TASKS.md`: daftar task beserta ID dan urutannya.

Jika aturan antar dokumen bertentangan, hentikan pekerjaan dan minta klarifikasi daripada menebak.

## Cara Kerja

- Kerjakan satu task per permintaan.
- Jangan mengubah file di luar ruang lingkup task.
- Untuk perubahan besar, buat rencana singkat sebelum mengubah kode atau dokumen.
- Pilih solusi paling sederhana yang memenuhi kebutuhan dan pola yang sudah ada.
- Jangan menambah package atau dependency tanpa persetujuan pengguna.
- Jangan mengubah konfigurasi sistem atau secrets tanpa persetujuan pengguna.

## Teknologi

- Flutter untuk aplikasi Android.
- Dart sebagai bahasa pemrograman.
- Provider untuk state management.
- Supabase untuk autentikasi, database, dan backend.

## Keamanan

- Jangan menyimpan key, password, atau credential rahasia di source code.
- Jangan pernah menggunakan Supabase `service_role key` di aplikasi Flutter.
- Terapkan hak akses database dengan Supabase Row Level Security (RLS).
- Pemilik hanya boleh menambah, melihat, mengubah, dan menghapus kos miliknya sendiri.

## Git

- Satu task menghasilkan satu commit.
- Pesan commit wajib menyebut ID task, misalnya `Implementasikan US01` atau `TASK-01: ...`.
- Jangan mengubah atau membersihkan perubahan yang dibuat pengguna di luar task.

## Definition of Done

Sebelum menyelesaikan task, wajib:

- Menjalankan `flutter analyze` sampai bersih.
- Menjalankan `flutter test` sampai lulus.
- Menjalankan aplikasi pada device yang tersedia.
- Melaporkan apa yang sudah diuji dan apa yang belum dapat diuji.

## Halaman About

Halaman About wajib menampilkan identitas berikut:

- NIM: `2415051089`
- Nama: `Ni Luh Meka Purwani`