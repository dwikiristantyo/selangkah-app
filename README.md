# SELANGKAH

**Mengalirkan Doa di Setiap Langkah**

Aplikasi buku Yasin dan doa digital, dengan perhitungan hari/haul setelah wafat.

## Menjalankan aplikasi

Untuk mencoba di Chrome, jalankan perintah berikut dari folder proyek. URL dasar
dan publishable key project sudah disetel sebagai default:

```powershell
flutter pub get
flutter run -d chrome
```

Jangan masukkan `service_role` key ke aplikasi mobile. Terapkan Row Level Security
dan kebijakan akses pada tabel serta bucket `memorial-photos` di Supabase.
Jalankan [migrasi pembuatan profil setelah registrasi](./supabase/migrations/20261112000000_create_profile_on_signup.sql)
dan [kebijakan akses foto Storage](./supabase/migrations/20261112010000_memorial_photo_storage_policies.sql)
di SQL Editor Supabase agar profil Auth dan galeri foto berfungsi. Pastikan bucket
`memorial-photos` sudah dibuat. Jika unggah foto mendapat `403` atau pesan
`new row violates row-level security policy`, jalankan ulang SQL kebijakan foto
tersebut; migrasi ini dapat dijalankan ulang. Foto baru disimpan di folder ID
pengguna, sedangkan kebijakan database tetap memastikan foto hanya ditautkan ke
profil almarhum milik pengguna tersebut. Kebijakan baca/hapus juga tetap menerima
foto lama yang disimpan di folder ID profil.
Kata sandi hanya disimpan oleh Supabase Auth; jangan menambahkannya ke `profiles`.

## Struktur

- `lib/core`: tema, konfigurasi, utilitas tanggal, Supabase, dan notifikasi.
- `lib/features`: kerangka fitur auth, home, profil almarhum, kalkulator, dan buku doa.
- `test`: pengujian kalkulator tanggal peringatan.

Kalkulator mengambil tanggal wafat dari profil terpilih. Jika belum ada jadwal,
tombol **Buat Perhitungan** membuat jadwal 1, 3, 7, 40, 100 hari, dan Haul 1 di
`memorial_schedules`; jika jadwal sudah ada, pengguna dapat melihatnya dan
mengaktifkan pengingat. Notifikasi lokal dijadwalkan pukul 09.00 waktu perangkat
di Android/iOS. Pratinjau Chrome tetap dapat mengelola jadwal, tetapi tidak
mendukung notifikasi lokal.

Perhitungan menambahkan jumlah hari kalender sesuai nama acara ke tanggal wafat
dan menetapkan Haul 1 pada tanggal kalender yang sama tahun berikutnya. Jika tahun
berikutnya bukan tahun kabisat, 29 Februari menjadi 28 Februari.

## Modul Buku Doa

Surat dan ayat pilihan dimuat daring dari Quran.com API v4; diperlukan koneksi
internet saat pertama kali membuka bacaan. Teks terjemahan Indonesia memakai
resource yang diidentifikasi API sebagai Indonesian Islamic Affairs Ministry.
Tahlil, doa setelah Yasin, doa arwah, dan ziarah kubur ditampilkan dari tabel
`prayers_content` Supabase jika kontennya sudah diisi. Halaman juga menyediakan
tautan rujukan untuk bacaan tahlil, doa kematian, dan Asmaul Husna.

Rujukan: [Qur’an Kemenag](https://quran.kemenag.go.id/),
[Quran.com API](https://api.quran.com/api/v4/),
[Tahlil & Doa Arwah Quran NU](https://quran.nu.or.id/tahlil),
[Doa Kematian Quran NU](https://quran.nu.or.id/doa/doa-kematian), dan
[Asmaul Husna Quran NU](https://quran.nu.or.id/wirid/munajat).
