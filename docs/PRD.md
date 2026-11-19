# PRD KosFinder - Versi 1

## 1. Masalah dan tujuan yang bisa diukur

Informasi kos tersebar di media sosial, grup WhatsApp, dan dari mulut ke mulut. Pencari kesulitan membandingkan pilihan, sedangkan pemilik kesulitan memperbarui ketersediaan.

**Tujuan**
- Pencari dapat menemukan kos berdasarkan nama atau lokasi/area dalam satu halaman pencarian.
- Pencari dapat membandingkan harga bulanan dan mengakses nomor kontak pemilik.
- Pemilik dapat mengelola beberapa kos miliknya sendiri dan memperbarui status ketersediaan.
- Versi 1 dianggap berhasil jika:
  - pencarian nama dan lokasi bekerja dan harga maksimum dapat difilter;
  - pemilik dapat melakukan tambah, ubah, hapus, dan ubah status pada kos miliknya;
  - pemilik tidak dapat mengubah atau menghapus kos milik pengguna lain;
  - data kosong, koneksi gagal, dan sesi berakhir ditangani dengan pesan atau arah yang jelas.

## 2. Pengguna

- **Pencari kos:** mahasiswa atau masyarakat umum; dapat melihat dan mencari kos tanpa login.
- **Pemilik kos:** pengguna perorangan yang login; dapat mengelola satu atau beberapa kos miliknya.

## 3. Scope versi 1

**Masuk:**
- Melihat daftar kos tanpa login.
- Mencari berdasarkan nama kos dan lokasi/area.
- Menampilkan kos terbaru ditambahkan sebagai urutan default.
- Memfilter hasil dengan harga maksimum.
- Melihat nama kos, alamat/area, harga bulanan, deskripsi singkat, status "Tersedia"/"Penuh", dan nomor WhatsApp pemilik.
- Tombol **Hubungi Pemilik** membuka WhatsApp melalui tautan `wa.me`.
- Registrasi dan login pemilik melalui email, password, dan nama.
- Pemilik memilih role pencari atau pemilik saat registrasi; role tidak dapat diubah setelah registrasi, dan pemilik langsung dapat menambah kos tanpa persetujuan admin.
- Pencarian nama dan lokasi/area menggunakan pencocokan sebagian (contains) secara case-insensitive.
- Nomor pemilik disimpan sebagai satu kolom nomor WhatsApp.
- Pemilik menambah, mengubah, menghapus permanen, dan melihat kos miliknya.
- Penghapusan kos wajib menampilkan dialog konfirmasi `AlertDialog` sebelum data dihapus.
- Satu akun pemilik dapat mengelola beberapa kos.

**Tidak masuk:**
- Pembayaran online.
- Chat internal.
- Ulasan dan rating.
- Rekomendasi AI.
- Verifikasi identitas pemilik.
- Upload dan tampilan foto.
- Peta.
- Dashboard admin.
- Pengelola kontrakan sebagai peran khusus.
- Soft delete atau penonaktifan kos.
- Filter tipe kamar atau fasilitas.

## 4. NFR

- **Keamanan:** pemilik hanya dapat mengubah atau menghapus kos miliknya; akses dilakukan melalui Supabase Auth dan RLS yang dapat diuji dengan dua akun berbeda.
- **Keandalan:** kegagalan koneksi menampilkan pesan ramah tanpa crash; sesi habis mengarahkan pengguna ke Login. Data kosong menampilkan status yang benar.
- **Kemudahan pakai:** pesan dan label utama mudah dipahami, terutama "Kos tidak ditemukan", "Tersedia", "Penuh", dan "Hubungi Pemilik".
- **Performa:** pencarian atau pemuatan daftar menunjukkan hasil atau pesan kegagalan dalam waktu kurang dari 3 detik pada koneksi normal.
- **Privasi:** password tidak ditampilkan; penggunaan nomor WhatsApp hanya untuk aksi kontak dan tidak ditampilkan ke pihak selain pengguna aplikasi secara khusus.

## 5. User story

- **US01:** Sebagai pencari kos, saya ingin melihat daftar kos terbaru agar dapat mengenali pilihan yang tersedia.
- **US02:** Sebagai pencari kos, saya ingin mencari nama atau lokasi/area dan memfilter harga maksimum agar dapat menemukan kos yang sesuai.
- **US03:** Sebagai pencari kos, saya ingin melihat detail dan status ketersediaan kos agar dapat memutuskan kos mana yang layak dihubungi.
- **US04:** Sebagai pencari kos, saya ingin menghubungi pemilik melalui WhatsApp agar dapat menanyakan kos.
- **US05:** Sebagai pengguna, saya ingin mendaftar dengan memilih role agar mendapatkan akses yang sesuai.
- **US06:** Sebagai pemilik kos, saya ingin menambah kos agar dapat memasarkan propertinya.
- **US07:** Sebagai pemilik kos, saya ingin mengubah detail dan status kos agar informasi selalu akurat.
- **US08:** Sebagai pemilik kos, saya ingin menghapus kos milik saya agar data lama tidak tetap ditampilkan.
- **US09:** Sebagai pemilik kos, saya ingin mengelola beberapa kos dalam satu akun agar dapat memperbarui semua properti saya.

## 6. Acceptance criteria

### US01
- **US01-AC1 — Given** aplikasi dibuka oleh pencari tanpa login, **When** halaman daftar dimuat, **Then** kos ditampilkan menurut tanggal ditambahkan terbaru terlebih dahulu.
- **US01-AC2 — Given** tidak ada kos tersimpan, **When** daftar dimuat, **Then** aplikasi menampilkan pesan kosong yang jelas tanpa crash.

### US02
- **US02-AC1 — Given** pencarian tersedia, **When** pengguna memasukkan kata pada nama atau lokasi/area dengan huruf besar atau kecil, **Then** kos yang mengandung kata tersebut secara case-insensitive ditampilkan.
- **US02-AC2 — Given** pengguna memasukkan harga maksimum, **When** pencarian dijalankan, **Then** kos dengan harga bulanan di atas batas tidak ditampilkan.
- **US02-AC3 — Given** pencarian tidak menghasilkan kos, **When** hasil dimuat, **Then** aplikasi menampilkan teks "Kos tidak ditemukan".

### US03
- **US03-AC1 — Given** pengguna memilih satu kos, **When** halaman detail dibuka, **Then** nama, alamat/area, harga bulanan, deskripsi, status, dan nomor WhatsApp pemilik ditampilkan.
- **US03-AC2 — Given** kos berstatus penuh, **When** kos muncul di daftar atau detail, **Then** aplikasi menampilkan badge "Penuh".

### US04
- **US04-AC1 — Given** kos memiliki nomor WhatsApp pemilik, **When** pengguna memilih "Hubungi Pemilik", **Then** aplikasi membuka WhatsApp melalui tautan `wa.me` menggunakan nomor tersebut.

### US05
- **US05-AC1 — Given** pengguna belum memiliki akun, **When** pengguna mendaftar dengan email, password, nama, dan role, **Then** profil berisi role yang dipilih dan pengguna masuk ke aplikasi.
- **US05-AC2 — Given** pengguna telah memilih role saat registrasi, **When** pengguna mencoba mengubah role setelah registrasi, **Then** perubahan ditolak atau tidak tersedia.
- **US05-AC3 — Given** sesi login telah berakhir, **When** pengguna mengakses fitur yang membutuhkan login, **Then** aplikasi otomatis mengarahkan pengguna ke halaman Login.

### US06
- **US06-AC1 — Given** pemilik sudah login, **When** pemilik mengisi nama, alamat/area, harga bulanan, deskripsi, status, dan satu kolom nomor WhatsApp, **Then** kos baru tersimpan dan terhubung ke akun pemilik.
- **US06-AC2 — Given** koneksi internet gagal saat menyimpan kos, **When** penyimpanan dijalankan, **Then** aplikasi menampilkan pesan koneksi yang ramah dan tidak menyatakan kos berhasil tersimpan.

### US07
- **US07-AC1 — Given** pemilik membuka kos miliknya, **When** pemilik mengubah detail atau status menjadi "Penuh"/"Tersedia", **Then** perubahan tersimpan dan muncul pada daftar serta detail.
- **US07-AC2 — Given** Pemilik A mencoba mengubah kos milik Pemilik B, **When** aksi ubah dijalankan, **Then** perubahan ditolak dan aplikasi menampilkan pesan error.
- **US07-AC3 — Given** koneksi gagal saat mengubah kos, **When** perubahan dikirim, **Then** aplikasi menampilkan pesan koneksi yang ramah dan mempertahankan data yang belum berhasil disimpan.

### US08
- **US08-AC1 — Given** pemilik membuka kos miliknya, **When** pemilik memilih hapus dan belum mengonfirmasi, **Then** aplikasi menampilkan `AlertDialog` konfirmasi dan kos belum dihapus.
- **US08-AC2 — Given** dialog konfirmasi penghapusan ditampilkan, **When** pemilik mengonfirmasi hapus, **Then** kos dihapus permanen dan tidak lagi muncul di daftar pencari.
- **US08-AC3 — Given** Pemilik A mencoba menghapus kos milik Pemilik B, **When** aksi hapus dijalankan, **Then** penghapusan ditolak dan aplikasi menampilkan pesan error.

### US09
- **US09-AC1 — Given** satu akun pemilik memiliki beberapa kos, **When** pemilik membuka halaman kosnya, **Then** semua kos miliknya ditampilkan.
- **US09-AC2 — Given** pemilik memilih salah satu kosnya, **When** pemilik mengubah atau menghapusnya, **Then** aksi berhasil tanpa memengaruhi kos milik pemilik lain.

