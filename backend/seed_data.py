import random
from datetime import datetime, timedelta
from decimal import Decimal
from sqlalchemy.orm import Session
from app.db.database import SessionLocal, engine, Base
from app.models.user import User
from app.models.product import Product, ProductImage
from app.models.category import Category

def seed_data():
    db: Session = SessionLocal()
    try:
        # 1. Buat akun penjual contoh
        seller_email = "penjual@secondhand.com"
        seller = db.query(User).filter(User.email == seller_email).first()
        if not seller:
            from app.core.security import hash_password
            seller = User(
                name="Budi Penjual",
                email=seller_email,
                password_hash=hash_password("password123"),
                location="Jakarta Selatan"
            )
            db.add(seller)
            db.commit()
            db.refresh(seller)

        # 2. Data produk contoh (pakai gambar dari Unsplash)
        dummy_products = [
            {
                "category_id": 2, # Mobil
                "title": "Toyota Avanza 2019 G MT",
                "price": 185000000,
                "location": "Jakarta Selatan",
                "description": "Mulus, tangan pertama, pajak hidup.",
                "image": "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=400&q=80"
            },
            {
                "category_id": 3, # Motor
                "title": "Honda Vario 160 CBS",
                "price": 26500000,
                "location": "Bandung",
                "description": "Tahun 2022, km rendah, surat lengkap.",
                "image": "https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=400&q=80"
            },
            {
                "category_id": 4, # Sepeda
                "title": "Polygon Xtrada 5 2021",
                "price": 4200000,
                "location": "Depok",
                "description": "Sepeda MTB, jarang dipakai, ban baru.",
                "image": "https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=400&q=80"
            },
            {
                "category_id": 5, # HP
                "title": "iPhone 13 Pro 256GB",
                "price": 12500000,
                "location": "Jakarta Pusat",
                "description": "Garansi iBox, baterai health 89%.",
                "image": "https://images.unsplash.com/photo-1632661674596-df8be070a5c5?auto=format&fit=crop&w=400&q=80"
            },
            {
                "category_id": 2, # Mobil
                "title": "Honda Brio Satya E 2020",
                "price": 145000000,
                "location": "Tangerang",
                "description": "Pajak baru diperpanjang, service rutin.",
                "image": "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=400&q=80"
            }
        ]

        for item in dummy_products:
            # Cek apakah produk sudah ada
            existing = db.query(Product).filter(Product.title == item["title"]).first()
            if not existing:
                product = Product(
                    seller_id=seller.id,
                    category_id=item["category_id"],
                    title=item["title"],
                    price=Decimal(item["price"]),
                    location=item["location"],
                    description=item["description"],
                    status="active",
                    views_count=random.randint(10, 500),
                    contacted_count=random.randint(1, 50),
                    created_at=datetime.utcnow() - timedelta(hours=random.randint(1, 48))
                )
                db.add(product)
                db.flush() # Ambil ID product
                
                # Simpan URL gambar
                db.add(ProductImage(
                    product_id=product.id,
                    path=item["image"],
                    sort_order=0
                ))
        
        db.commit()
        print("✅ Data contoh berhasil ditambahkan!")
    except Exception as e:
        print(f"❌ Gagal: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()