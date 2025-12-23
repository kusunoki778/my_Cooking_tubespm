myCooking: Smart Recipe Management System

myCooking adalah aplikasi mobile inovatif berbasis Flutter yang dirancang untuk membantu pengguna mendokumentasikan, mengelola, dan mengeksplorasi koleksi resep masakan secara digital. Aplikasi ini mengintegrasikan fungsionalitas REST API untuk sinkronisasi data awan dan Shared Preferences untuk manajemen preferensi pengguna secara persisten

---

Tim Pengembang (Kelompok 8)

| 2405046 | Irfan Rafi Ananda |*Ketua Tim / Contact Person: 0813-1687-2794 |
| 2405057 | Muhamad Fadhlurrahman | Anggota |
| 2405065 | Dinda Dwi Hidayati | Anggota |

---

Fitur Unggulan
Aplikasi ini telah mengimplementasikan seluruh fungsi utama sesuai standar penilaian:
- Autentikasi Pengguna: Sistem Login dan Register yang aman untuk personalisasi data resep.
- Manajemen Resep (CRUD): Kebebasan pengguna untuk Menambah (Create), Melihat (Read), Mengubah (Update), dan Menghapus (Delete) resep secara real-time.
- Sinkronisasi Cloud: Integrasi media storage untuk pengelolaan gambar masakan yang efisien.
- Adaptasi Visual (Dual Theme): Dukungan Tema Terang dan Gelap yang tersimpan secara permanen pada perangkat.
- User Experience Modern: Dilengkapi dengan efek shimmer loading, navigasi yang jelas, dan validasi input pada setiap formulir.

Arsitektur Sistem
Kami menerapkan prinsip Separation of Concerns (SoC) untuk menjaga kualitas kode dan kemudahan pemeliharaan:
- Presentation Layer: Folder screens dan widgets yang menangani antarmuka dan interaksi visual.
- State Management Layer: Memanfaatkan Provider untuk menangani logika data dan pembaruan UI secara reaktif.
- Network & Logic Layer: Menggunakan Dio untuk komunikasi data yang andal melalui folder services.
- Persistence Layer: Modul shared_prefs.dart yang menangani penyimpanan sesi dan preferensi pengguna.

---

Panduan Instalasi & Pengembangan
Ikuti langkah-langkah berikut untuk menjalankan proyek di lingkungan lokal Anda:
- Persiapan Proyek
git clone https://github.com/kusunoki778/my_Cooking_tubespm
cd my_resep
- Konfigurasi SDK & Dependensi Pastikan Flutter SDK sudah terpasang, lalu jalankan:
flutter pub get
- Eksekusi Aplikasi Jalankan aplikasi pada emulator atau perangkat fisik Android:
flutter run

Prosedur Build Produksi (APK)
Sesuai dengan S&K teknis, berikut adalah instruksi untuk menghasilkan file instalasi Android (.apk):
- Bersihkan cache build sebelumnya: flutter clean.
- Ambil ulang paket dependensi: flutter pub get.
- Jalankan perintah kompilasi release:
flutter build apk --release
Lokasi File: Hasil akhir dapat ditemukan di build/app/outputs/flutter-apk/app-release.apk.

Teknologi & Library Utama
Berikut adalah dependensi inti yang digunakan berdasarkan pubspec.yaml:
- Provider (^6.0.5): Manajemen state aplikasi.
- Dio (^5.0.3): Client HTTP untuk integrasi REST API.
- Shared Preferences (^2.0.15): Penyimpanan data lokal yang persisten.
- Shimmer (^3.0.0): Efek pemuatan data yang modern.
- Image Picker (^1.0.7): Penanganan pengambilan gambar dari galeri/kamera.
- Google Fonts (^6.3.3): Tipografi antarmuka yang profesional.
