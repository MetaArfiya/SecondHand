
# SecondHand App 📱

Aplikasi marketplace C2C untuk jual beli barang bekas yang dibangun menggunakan Flutter sebagai frontend dan FastAPI Python sebagai backend.

SecondHand memudahkan pengguna untuk menjual dan membeli barang bekas secara online dengan proses yang praktis.

## ✨ Fitur Utama

- Autentikasi Login dan Register dengan validasi email `.com`
- Jual barang dengan upload foto
- Pencarian barang dan filter kategori
- Favorit barang
- Dashboard penjual dengan statistik iklan
- Posting barang secara gratis
- Promosi iklan berbayar dengan pembayaran manual melalui transfer bank
- Verifikasi pembayaran promosi oleh admin
- Notifikasi dan pesan

## 🛠️ Teknologi yang Digunakan

### Frontend
- Flutter
- Dart
- HTTP
- SharedPreferences
- Image Picker

### Backend
- Python
- FastAPI
- SQLAlchemy
- SQLite
- JWT Authentication
- Passlib (Bcrypt)

## 📂 Struktur Proyek

```text
SecondHand/
├── SecondHand/             # Flutter Frontend
└── SecondHand-Backend/     # Python FastAPI Backend
```

## 🚀 Cara Menjalankan Proyek

### 1. Menjalankan Backend

Masuk ke folder backend:

```bash
cd SecondHand-Backend
```

Buat virtual environment:

```bash
python -m venv venv
```

Aktifkan virtual environment di Windows:

```bash
venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Jalankan server FastAPI:

```bash
uvicorn app.main:app --reload
```

Backend dapat diakses melalui:

```text
http://127.0.0.1:8000
```

Dokumentasi API:

```text
http://127.0.0.1:8000/docs
```

### 2. Menjalankan Frontend Flutter

Buka terminal baru dan masuk ke folder Flutter:

```bash
cd SecondHand
```

Install dependencies:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

Untuk menjalankan versi web:

```bash
flutter run -d chrome
```

## 💳 Sistem Promosi Iklan

SecondHand menerapkan dua jenis layanan:

- **Posting Gratis:** Pengguna dapat mengunggah dan menjual barang tanpa biaya.
- **Promosi Berbayar:** Pengguna dapat membayar untuk mempromosikan iklan agar mendapatkan visibilitas tambahan.

Pembayaran promosi dilakukan melalui transfer bank dan diverifikasi oleh admin.

## 👩‍💻 Developer

SecondHand App

---

*Dibangun sebagai proyek pengembangan aplikasi marketplace jual beli barang bekas.*
