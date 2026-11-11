from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.favorite import Favorite
from app.models.product import Product
from app.models.user import User
from app.routers.products import _to_out
from app.schemas.product import ProductOut

router = APIRouter(prefix="/api/favorites", tags=["Favorites"])

@router.get("", response_model=dict)
def list_favorites(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Ambil semua ID produk yang difavoritkan user
    favs = db.query(Favorite).filter(Favorite.user_id == user.id).all()
    product_ids = [f.product_id for f in favs]
    
    # Ambil detail produknya
    products = db.query(Product).filter(Product.id.in_(product_ids)).all()
    
    return {
        "success": True,
        "data": [_to_out(p) for p in products]
    }

@router.post("/{product_id}")
def add_favorite(product_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not db.query(Product).get(product_id):
        raise HTTPException(status_code=404, detail="Produk tidak ditemukan")
    
    # Cek apakah sudah ada
    exists = db.query(Favorite).filter(Favorite.user_id == user.id, Favorite.product_id == product_id).first()
    if not exists:
        db.add(Favorite(user_id=user.id, product_id=product_id))
        db.commit()
    
    return {"success": True, "message": "Ditambahkan ke favorit"}

@router.delete("/{product_id}")
def remove_favorite(product_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    db.query(Favorite).filter(Favorite.user_id == user.id, Favorite.product_id == product_id).delete()
    db.commit()
    return {"success": True, "message": "Dihapus dari favorit"}