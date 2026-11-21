# Rencana Pengujian KosFinder

| ID | AC terkait | Langkah | Hasil yang diharapkan | Hasil nyata | Lulus |
|---|---|---|---|---|---|
| TP01 | US01-AC1 | Buka aplikasi sebagai pencari tanpa login lalu buka daftar kos. | Kos ditampilkan dari yang terbaru ditambahkan sampai yang terlama. | Sesuai Harapan | Ya |
| TP02 | US01-AC2 | Kosongkan semua data kos lalu muat halaman daftar. | Aplikasi menampilkan pesan kosong yang jelas dan tidak crash. | Sesuai Harapan | Ya |
| TP03 | US02-AC1 | Cari satu kos menggunakan sebagian nama atau lokasi dengan huruf besar dan kecil. | Kos yang mengandung kata pencarian secara case-insensitive ditampilkan. | Sesuai Harapan | Ya |
| TP04 | US02-AC2 | Masukkan harga maksimum lalu jalankan pencarian. | Kos dengan harga bulanan di atas harga maksimum tidak ditampilkan. | Sesuai Harapan | Ya |
| TP05 | US02-AC3 | Cari kata atau lokasi yang tidak cocok dengan data kos apa pun. | Aplikasi menampilkan teks "Kos tidak ditemukan". | Sesuai Harapan | Ya |
| TP06 | US02-AC3; negatif hasil kosong | Kosongkan hasil pencarian dan filter sekaligus. | Aplikasi menampilkan status hasil kosong dan tidak menampilkan data lama secara keliru. | Sesuai Harapan | Ya |
| TP07 | US03-AC1 | Pilih satu kos lalu buka halaman detail. | Nama, alamat/area, harga bulanan, deskripsi, status, dan nomor WhatsApp pemilik ditampilkan. | Sesuai Harapan | Ya |
| TP08 | US03-AC2 | Buka daftar atau detail kos yang berstatus Penuh. | Badge "Penuh" ditampilkan pada daftar dan detail. | Sesuai Harapan | Ya |
| TP09 | US04-AC1 | Pilih kos dengan nomor WhatsApp lalu tekan "Hubungi Pemilik". | WhatsApp terbuka melalui tautan `wa.me` dengan nomor pemilik yang benar. | Sesuai Harapan | Ya |
| TP10 | US05-AC1 | Daftarkan pengguna baru dengan nama, email, password, dan pilih role Pencari atau Pemilik. | Profil tersimpan dengan role yang dipilih dan pengguna masuk ke aplikasi. | Sesuai Harapan | Ya |
| TP11 | US05-AC2 | Setelah registrasi, coba mengubah role melalui UI atau request perubahan. | Perubahan role ditolak atau kontrol ubah role tidak tersedia. | Sesuai Harapan | Ya |
| TP12 | US05-AC3 | Hapus atau biarkan sesi login berakhir lalu akses fitur login. | Aplikasi otomatis mengarahkan pengguna ke halaman Login. | Sesuai Harapan | Ya |
| TP13 | US06-AC1 | Login sebagai pemilik lalu isi seluruh field kos dan simpan. | Kos tersimpan, terhubung ke pemilik login, dan muncul pada daftar kos miliknya. | Sesuai Harapan | Ya |
| TP14 | US06-AC1; negatif input tidak valid | Kirim form kos dengan nama, alamat, harga, deskripsi, WhatsApp, atau status kosong/tidak valid. | Data tidak tersimpan dan aplikasi menampilkan pesan validasi atau error yang jelas. | Sesuai Harapan | Ya |
| TP15 | US06-AC2; negatif tanpa internet | Putuskan koneksi lalu tekan simpan kos baru. | Aplikasi menampilkan pesan koneksi ramah dan kos tidak dinyatakan berhasil tersimpan. | Sesuai Harapan | Ya |
| TP16 | US07-AC1 | Ubah nama, alamat, harga, deskripsi, WhatsApp, atau status kos milik sendiri lalu simpan. | Perubahan tersimpan dan muncul terbaru pada daftar serta detail. | Sesuai Harapan | Ya |
| TP17 | US07-AC1; negatif input tidak valid | Ubah kos milik sendiri dengan harga negatif atau field wajib kosong. | Perubahan ditolak dan pesan validasi ditampilkan. | Sesuai Harapan | Ya |
| TP18 | US07-AC2; negatif pemilik lain | Login sebagai Pemilik A lalu coba mengubah kos milik Pemilik B. | Supabase dan UI menolak perubahan serta menampilkan pesan akses ditolak. | Sesuai Harapan | Ya |
| TP19 | US07-AC3; negatif tanpa internet | Putuskan koneksi lalu ubah kos milik sendiri dan simpan. | Aplikasi menampilkan pesan koneksi ramah dan data lama tidak berubah menjadi palsu. | Sesuai Harapan | Ya |
| TP20 | US08-AC1 | Pilih hapus pada kos milik sendiri tetapi jangan mengonfirmasi dialog. | AlertDialog tampil, kos belum dihapus, dan daftar tetap sama. | Sesuai Harapan | Ya |
| TP21 | US08-AC2 | Konfirmasi hapus pada kos milik sendiri. | Kos dihapus permanen dan tidak lagi muncul pada daftar pencari maupun daftar pemilik. | Sesuai Harapan | Ya |
| TP22 | US08-AC3; negatif pemilik lain | Login sebagai Pemilik A lalu coba menghapus kos milik Pemilik B. | Penghapusan ditolak dan aplikasi menampilkan pesan error. | Sesuai Harapan | Ya |
| TP23 | US09-AC1 | Login sebagai pemilik yang memiliki beberapa kos lalu buka halaman kosnya. | Semua kos milik pemilik itu ditampilkan dan kos milik pemilik lain tidak ditampilkan. | Sesuai Harapan | Ya |
| TP24 | US09-AC2 | Pilih satu kos milik sendiri lalu ubah atau hapus. | Aksi berhasil pada kos tersebut dan kos milik pemilik lain tidak berubah. | Sesuai Harapan | Ya |
| TP25 | Negatif umum tanpa internet | Matikan koneksi saat membuka daftar, pencarian, detail, atau data pemilik. | Aplikasi menampilkan pesan koneksi ramah dan tidak crash atau menampilkan data keliru sebagai berhasil. | Sesuai Harapan | Ya |
| TP26 | Negatif input pencarian dan harga | Masukkan harga maksimum negatif, teks pada harga, atau format pencarian tidak valid. | Aplikasi menolak atau mengabaikan input tidak valid dan menampilkan validasi tanpa crash. | Sesuai Harapan | Ya |
| TP27 | Negatif autentikasi | Kunjungi aksi pemilik tanpa login atau dengan sesi berakhir. | Pengguna diarahkan ke halaman Login dan tidak dapat melakukan tambah, ubah, atau hapus. | Sesuai Harapan | Ya |