# Kulinerify

Aplikasi katalog kuliner kawasan Tembalang, Semarang. Dibuat dengan Flutter sebagai Tugas Akhir Praktikum Perangkat Mobile (PPB 2026).

Pengguna bisa menjelajahi restoran dan menu, mencari dan memfilter data, menyimpan favorit, membuka lokasi di Google Maps, serta menambah, mengubah, dan menghapus data restoran maupun menu.

## Fitur

- **Home**: carousel 3 restoran dengan rating tertinggi, rekomendasi tempat makan, dan menu pilihan.
- **Restoran**: daftar restoran dengan pencarian dan filter kategori.
- **Menu**: daftar menu dengan pencarian dan filter kategori.
- **Detail restoran dan menu**: informasi lengkap, daftar menu per restoran, dan tombol buka lokasi di Google Maps.
- **CRUD**: tambah, edit, dan hapus restoran dan menu (hapus memakai dialog konfirmasi).
- **Favorit**: simpan restoran dan menu favorit di perangkat (tetap ada setelah app ditutup).
- **Profile / About**: identitas pengembang dan informasi aplikasi.
- **Penanganan error**: pesan ramah, tombol "Coba Lagi", dan timeout 10 detik pada setiap request.
- **Refresh otomatis**: layar lain ikut memuat ulang data setelah ada perubahan.

## Teknologi

| Bagian | Teknologi |
|--------|-----------|
| Framework | Flutter (Material 3) |
| HTTP | `http` |
| Penyimpanan lokal | `shared_preferences` |
| Buka link eksternal | `url_launcher` |
| Backend | Node.js, Express, `mysql2` (tidak disertakan di repo ini) |
| Database | MySQL (XAMPP) |

## Struktur Folder

```
lib/
├── main.dart                 # Entry point, tema, scroll behavior
├── models/                   # Restaurant, Menu
├── providers/app_state.dart  # Favorit (SharedPreferences) dan DataSync
├── services/api_service.dart # Semua pemanggilan REST API
├── screens/                  # Home, Restoran, Menu, Detail, Favorit, Profile
├── widgets/                  # Form dialog, ErrorState, CategoryRating, dll
└── utils/format.dart         # Format rupiah
```

## Cara Menjalankan

### 1. Siapkan backend

Backend tidak ada di repo ini. Aplikasi membutuhkan REST API Node.js + MySQL yang berjalan di `http://localhost:3000`.

1. Jalankan MySQL lewat XAMPP dan buat database `db_kulinerify`.
2. Buat tabel `restaurants` dan `menus` dengan kolom berikut:

   ```sql
   CREATE TABLE restaurants (
     id INT AUTO_INCREMENT PRIMARY KEY,
     name VARCHAR(255) NOT NULL,
     category VARCHAR(100) NOT NULL,
     address VARCHAR(255) NOT NULL,
     image_url TEXT NULL,
     rating DECIMAL(2,1) NULL,
     maps_url TEXT NULL
   );

   CREATE TABLE menus (
     id INT AUTO_INCREMENT PRIMARY KEY,
     restaurant_id INT NULL,
     name VARCHAR(255) NOT NULL,
     price INT NOT NULL,
     description TEXT NULL,
     image_url TEXT NULL
   );
   ```

3. Jalankan server: `node server.js`.

Endpoint yang dipakai aplikasi:

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| GET | `/api/restaurants` | Ambil semua restoran |
| POST | `/api/restaurants` | Tambah restoran |
| PUT | `/api/restaurants/:id` | Ubah restoran |
| DELETE | `/api/restaurants/:id` | Hapus restoran (beserta menunya) |
| GET | `/api/menus` | Ambil semua menu |
| POST | `/api/menus` | Tambah menu |
| PUT | `/api/menus/:id` | Ubah menu |
| DELETE | `/api/menus/:id` | Hapus menu |

### 2. Jalankan aplikasi

```bash
flutter pub get
flutter run -d windows   # atau: flutter run -d chrome
```

Alamat API diatur di `lib/services/api_service.dart` (`baseUrl`):

- Windows desktop atau Chrome: `http://localhost:3000/api`
- Android Emulator: `http://10.0.2.2:3000/api`

### 3. Cek kualitas kode

```bash
flutter analyze
flutter test
```

## Pengembang

**Hafizh Muhammad Akbar**
Teknik Komputer, Universitas Diponegoro
Praktikum PPB 2026 - Tugas Akhir
