myCooking - Aplikasi Manajemen Resep

myCooking adalah aplikasi *mobile* berbasis Flutter yang dirancang untuk membantu pengguna mencatat, mengelola, dan menyimpan resep masakan favorit mereka secara digital. Aplikasi ini dikembangkan sebagai Tugas Besar mata kuliah Pemrograman Mobile 1.

---

Tim Pengembang (Kelompok 8)

| 2405046 | Irfan Rafi Ananda |*Ketua Tim / Contact Person: 0813-1687-2794 |
| 2405057 | Muhamad Fadhlurrahman | Anggota |
| 2405065 | Dinda Dwi Hidayati | Anggota |

---

Fitur Utama
Aplikasi ini memiliki fitur lengkap sesuai standar CRUD dan UI/UX modern:
Jelajah Resep: Menampilkan daftar resep dari API.
Pencarian: Cari resep berdasarkan judul atau kategori.
Manajemen Resep (CRUD): Tambah, Edit, dan Hapus resep sendiri.
Favorit: Simpan resep kesukaan ke penyimpanan lokal (Offline).
Tema Gelap (Dark Mode): Dukungan tampilan *Light* dan *Dark* mode.

Teknologi yang Digunakan
Kami menggunakan pustaka (dependencies) berikut agar aplikasi berjalan optimal:
[Flutter](https://flutter.dev):** Framework UI utama.
[Provider](https://pub.dev/packages/provider):** Manajemen state aplikasi (memisahkan logika dari UI).
[Dio](https://pub.dev/packages/dio):** Menangani koneksi jaringan (HTTP Request) ke REST API.
[Shared Preferences](https://pub.dev/packages/shared_preferences):** Menyimpan data lokal (Tema & List Favorit).
[Shimmer](https://pub.dev/packages/shimmer):** Efek *loading* yang modern.

---

Cara Menjalankan Aplikasi

Ikuti langkah-langkah berikut untuk mencoba aplikasi ini di komputer Anda:

1.Persiapan (Install Dependencies)
Pastikan Flutter SDK sudah terinstall, lalu buka terminal di folder proyek dan jalankan:
dengan perintah > flutter pub get
2.Jalankan Aplikasi (Debug Mode)
Hubungkan HP Android (mode pengembang aktif) atau nyalakan Emulator, lalu ketik:
dengan perintah>flutter run
3.Build File APK (Release)
Untuk menghasilkan file .apk yang siap diinstal di HP Android:
dengan perintah>flutter build apk --release
Lokasi File APK: File hasil build akan muncul di direktori: build/app/outputs/flutter-apk/app-release.apk