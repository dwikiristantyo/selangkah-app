# SELANGKAH

**Mengalirkan Doa di Setiap Langkah**

Aplikasi buku Yasin dan doa digital, dengan perhitungan hari/haul setelah wafat.

## Menjalankan aplikasi

Untuk mencoba di Chrome, jalankan perintah berikut dari folder proyek. Gunakan
URL dasar project Supabase (jangan tambahkan `/rest/v1`) dan publishable key:

```powershell
flutter pub get
flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

Jangan masukkan `service_role` key ke aplikasi mobile. Terapkan Row Level Security
dan kebijakan akses pada tabel serta bucket `memorial-photos` di Supabase.
Jalankan [migrasi pembuatan profil setelah registrasi](./supabase/migrations/20261112000000_create_profile_on_signup.sql)
di SQL Editor Supabase agar setiap akun Auth otomatis mendapat baris `profiles`.
Kata sandi hanya disimpan oleh Supabase Auth; jangan menambahkannya ke `profiles`.

## Struktur

- `lib/core`: tema, konfigurasi, utilitas tanggal, Supabase, dan notifikasi.
- `lib/features`: kerangka fitur auth, home, profil almarhum, kalkulator, dan buku doa.
- `test`: pengujian kalkulator tanggal peringatan.

Kalkulator menambahkan jumlah hari kalender yang ditampilkan pada nama acara ke
tanggal wafat dan menetapkan Haul 1 pada tanggal kalender yang sama tahun berikutnya.
Jika tahun berikutnya bukan tahun kabisat, 29 Februari menjadi 28 Februari.
