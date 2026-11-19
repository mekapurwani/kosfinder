# TASKS KosFinder

## Slice 1 - Daftar dan detail kos

Selesai setelah slice ini: aplikasi dapat dijalankan, menampilkan daftar kos terbaru secara publik, membuka detail, dan menampilkan status serta tombol WhatsApp.

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T01 | Membuat fondasi Flutter yang menjalankan layar daftar kos dari data Supabase dan menampilkan urutan terbaru dengan state Provider. | US01: US01-AC1, US01-AC2 | `lib/main.dart`, `lib/screens/kos_list_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `lib/models/kos.dart`, `lib/services/supabase_config.dart`, `test/providers/kos_provider_test.dart`, `test/screens/kos_list_screen_test.dart`, `pubspec.yaml` | Jalankan aplikasi tanpa login; pastikan kos terurut terbaru; kos kosong menampilkan pesan dan tidak crash. | Belum |
| T02 | Membuat halaman detail kos dan tombol Hubungi Pemilik dengan tautan `wa.me`, termasuk badge status. | US03, US04: US03-AC1, US03-AC2, US04-AC1 | `lib/screens/kos_detail_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `lib/models/kos.dart`, `lib/widgets/status_badge.dart`, `test/screens/kos_detail_screen_test.dart`, `test/widgets/status_badge_test.dart`, `pubspec.yaml` | Pilih kos dari daftar; pastikan seluruh data dan badge tampil; tekan Hubungi Pemilik dan pastikan WhatsApp dibuka dengan nomor tersimpan. | Belum |

## Slice 2 - Pencarian dan filter

Selesai setelah slice ini: aplikasi tetap dapat dijalankan sambil pencarian nama/lokasi case-insensitive dan filter harga maksimum dapat digunakan secara publik.

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T03 | Menambahkan pencarian nama dan lokasi/area dengan pencocokan contains case-insensitive. | US02: US02-AC1, US02-AC3 | `lib/screens/kos_list_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `test/providers/kos_provider_test.dart`, `test/screens/kos_list_screen_test.dart` | Cari sebagian nama atau lokasi memakai huruf besar/kecil; pastikan hasil cocok dan hasil kosong menampilkan "Kos tidak ditemukan". | Belum |
| T04 | Menambahkan filter harga maksimum dan menggabungkannya dengan pencarian. | US02: US02-AC2 | `lib/screens/kos_list_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `test/providers/kos_provider_test.dart`, `test/screens/kos_list_screen_test.dart` | Masukkan harga maksimum; pastikan kos di atas batas tidak tampil dan kombinasi pencarian serta filter menghasilkan hasil yang benar. | Belum |

## Slice 3 - Login pemilik

Selesai setelah slice ini: aplikasi dapat dijalankan dengan alur registrasi, login, pemilihan role, batasan role, dan redirect sesi berakhir.

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T05 | Membuat konfigurasi Supabase lewat `--dart-define` dan inisialisasi autentikasi tanpa menyimpan key rahasia di kode. | US05: US05-AC1, US05-AC3 | `lib/main.dart`, `lib/services/supabase_config.dart`, `lib/repositories/auth_repository.dart`, `test/services/supabase_config_test.dart`, `test/repositories/auth_repository_test.dart`, `pubspec.yaml` | Jalankan aplikasi dengan URL dan anon key dari `--dart-define`; pastikan aplikasi tidak crash tanpa key dan tidak ada service_role key di kode. | Belum |
| T06 | Membuat registrasi nama, email, password, dan pilihan role yang tersimpan sebagai profil. | US05: US05-AC1, US05-AC2 | `lib/screens/register_screen.dart`, `lib/providers/auth_provider.dart`, `lib/repositories/auth_repository.dart`, `lib/models/profile.dart`, `test/screens/register_screen_test.dart`, `test/providers/auth_provider_test.dart` | Daftarkan role pencari dan pemilik; pastikan profil tersimpan, role tidak memiliki UI ubah role, dan pemilik masuk aplikasi. | Belum |
| T07 | Membuat login, auth gate, logout, dan redirect otomatis ke Login saat sesi berakhir. | US05: US05-AC3 | `lib/main.dart`, `lib/screens/login_screen.dart`, `lib/providers/auth_provider.dart`, `lib/repositories/auth_repository.dart`, `test/screens/login_screen_test.dart`, `test/providers/auth_provider_test.dart` | Login berhasil dan gagal; akhiri atau hapus sesi lalu buka fitur login; pastikan aplikasi langsung membuka Login tanpa crash. | Belum |

## Slice 4 - Tambah, ubah, hapus kos milik sendiri

Selesai setelah slice ini: aplikasi dapat dijalankan sebagai pemilik dan melakukan CRUD hanya pada kos milik sendiri, termasuk konfirmasi hapus.

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T08 | Membuat daftar kos milik pemilik login dan form tambah kos lengkap. | US06, US09: US06-AC1, US09-AC1, US09-AC2 | `lib/screens/owner_kos_list_screen.dart`, `lib/screens/kos_form_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `lib/models/kos.dart`, `test/screens/owner_kos_list_screen_test.dart`, `test/screens/kos_form_screen_test.dart` | Login sebagai pemilik, tambah kos dengan seluruh field, dan pastikan kos muncul hanya di daftar pemilik tersebut. | Belum |
| T09 | Menambahkan ubah data kos milik sendiri dan penolakan ubah kos milik pemilik lain. | US07: US07-AC1, US07-AC2, US07-AC3 | `lib/screens/kos_form_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `test/providers/kos_provider_test.dart`, `test/screens/kos_form_screen_test.dart` | Ubah kos milik sendiri dan status; uji akun lain mengubah kos ini; putus koneksi saat menyimpan dan pastikan pesan ramah tanpa crash. | Belum |
| T10 | Menambahkan hapus permanen dengan `AlertDialog` konfirmasi, penolakan hak milik orang lain, dan refresh daftar. | US08: US08-AC1, US08-AC2, US08-AC3 | `lib/screens/owner_kos_list_screen.dart`, `lib/screens/kos_detail_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `test/screens/owner_kos_list_screen_test.dart`, `test/providers/kos_provider_test.dart` | Pilih hapus dan batal; pastikan belum terhapus; konfirmasi; pastikan hilang permanen; coba akun lain menghapus kos ini. | Belum |
| T11 | Menyelesaikan halaman About dan batas akses multi-property pemilik. | US09: US09-AC1, US09-AC2; identitas halaman About | `lib/screens/about_screen.dart`, `lib/screens/owner_kos_list_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `test/screens/about_screen_test.dart`, `test/screens/owner_kos_list_screen_test.dart` | Buka About dan pastikan `2415051089 - Ni Luh Meka Purwani` tampil; login pemilik dengan beberapa kos dan pastikan hanya kos miliknya yang dapat dikelola. | Belum |

## Slice 5 - Bonus ketersediaan kamar

Selesai setelah slice ini: aplikasi bonus tetap dapat dijalankan dengan status ketersediaan `Tersedia`/`Penuh` yang konsisten dari form pemilik sampai daftar dan detail.

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T12 | Menyempurnakan sinkronisasi status ketersediaan kos pada form, daftar, detail, dan penanganan offline. | US03, US07: US03-AC2, US07-AC1, US07-AC3 | `lib/screens/kos_form_screen.dart`, `lib/screens/kos_list_screen.dart`, `lib/screens/kos_detail_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `lib/widgets/status_badge.dart`, `test/screens/kos_list_screen_test.dart`, `test/screens/kos_detail_screen_test.dart`, `test/providers/kos_provider_test.dart` | Pemilik mengubah status menjadi Penuh atau Tersedia; pastikan badge, daftar, dan detail sinkron; uji putus koneksi saat perubahan status. | Belum |