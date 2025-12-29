# 📦 Gudang FK — Inventory & ATK Management System

Gudang FK adalah aplikasi manajemen inventori ATK berbasis Flutter yang dirancang untuk mendukung proses pencatatan stok, pemantauan barang masuk & keluar, serta pengelolaan kondisi barang (B / RR / RB) secara terstruktur, akurat, dan mudah digunakan.

Aplikasi ini dikembangkan untuk kebutuhan operasional gudang agar proses administrasi lebih efisien, terpusat, dan terdokumentasi dengan baik.

---

## ✨ Fitur Utama

- Manajemen data barang
  - Nama barang, kategori, jumlah, kondisi, dan foto
- Barang Masuk & Barang Keluar
- Status kondisi barang
  - B (Baik)
  - RR (Rusak Ringan)
  - RB (Rusak Berat)
- Upload & update foto barang
- Validasi input sebelum penyimpanan data
- Pencarian & filter data
- Integrasi REST API backend
- Dukungan build untuk Windows (Flutter Desktop)

---

## 🧩 Teknologi yang Digunakan

- Flutter
- Dart
- REST API (HTTP)
- Shared Preferences (opsional)
- Inno Setup (untuk pembuatan installer Windows — jika digunakan)

---

## 🖥️ Sistem Minimum

- Flutter SDK (versi terbaru direkomendasikan)
- Windows 10 / 11 (untuk desktop build)
- Backend API aktif / dapat diakses

---

## 🚀 Cara Menjalankan Aplikasi

Clone repository:

```bash
git clone https://github.com/username/gudang-fk.git
cd gudang-fk
```

---

Install dependencies:

```bash
flutter pub get
flutter run
```

---

Build application:

```bash
flutter build apk --release
```
```bash
flutter build windows
```

---

## ⚙️ Konfigurasi API

Ubah base URL pada service sesuai environment server:

```dart
const String baseUrl = "https://your-backend-domain.com/api";
```
Contoh environment:
  - Development → localhost / ngrok
  - Staging → private server
  - Production → domain utama
Pastikan endpoint konsisten dengan backend.

---

## 📁 Struktur Proyek (Ringkasan)

```text
lib/
 ├─ controller/
 ├─ service/
 ├─ pages/
 ├─ widgets/
 ├─ models/
 └─ utils/
```
Struktur modular untuk memudahkan maintenance & pengembangan fitur.

---

## 🔒 Validasi & Error Handling

Beberapa skenario yang telah ditangani:
  - Data tidak valid / field kosong
  - Gagal update data (HTTP 400)
  - Gagal upload foto
  - Koneksi API gagal / timeout
  - Fallback parsing nilai stok
Pesan error dirancang informatif agar mempermudah troubleshooting.

---

## 📝 Lisensi

Proyek ini digunakan untuk kebutuhan internal.
Penggunaan di luar lingkungan terkait dapat dikonsultasikan dengan pemilik repository.

---

## 👤 Pengembang

Gudang FK dikembangkan oleh:
  - Fajar (developer)
  - Leo (AI)
