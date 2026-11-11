# SecondHand App 📱

Aplikasi marketplace jual beli barang bekas (Clone) yang dibangun dengan **Flutter** (Frontend) dan **FastAPI Python** (Backend).

## Fitur Utama
- Autentikasi (Login/Register) dengan validasi email `.com`
- Jual Barang (Upload Foto & Simpan ke Database)
- Pencarian dan Filter Kategori
- Favorit (Tersimpan di Database)
- Dashboard Penjual (Statistik Iklan)
- **Promosi Iklan dengan Pembayaran Manual (Transfer Bank) + Verifikasi Admin**
- Notifikasi & Pesan

## Teknologi yang Digunakan
- **Frontend:** Flutter (Dart), HTTP, SharedPreferences, Image Picker
- **Backend:** Python, FastAPI, SQLAlchemy, SQLite, JWT Auth, Passlib (Bcrypt)

## Cara Menjalankan Proyek

### 1. Jalankan Backend
```bash
cd SecondHand-Backend
python -m venv venv
# Windows: .\venv\Scripts\activate
# Mac/Linux: source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
