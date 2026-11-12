from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy import or_
from sqlalchemy.orm import Session
from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.category import Category, Location
from app.models.product import Product, ProductImage
from app.models.user import User
from app.schemas.product import ProductCreate, ProductImageOut, ProductListResponse, ProductOut
from app.utils.files import file_url, save_upload

router = APIRouter(prefix="/api", tags=["Products"])

def _to_out(p: Product) -> ProductOut:
    return ProductOut(
        id=p.id, title=p.title, description=p.description, price=p.price,
        location=p.location, status=p.status, is_promoted=p.is_promoted,
        views_count=p.views_count, contacted_count=p.contacted_count,
        category_id=p.category_id, seller_id=p.seller_id,
        seller_name=p.seller.name if p.seller else None,
        images=[ProductImageOut(id=img.id, url=file_url(img.path)) for img in p.images],
        created_at=p.created_at,
    )

@router.get("/categories")
def list_categories(db: Session = Depends(get_db)):
    cats = db.query(Category).all()
    return {"success": True, "data": [{"id": c.id, "slug": c.slug, "name": c.name} for c in cats]}

@router.get("/locations")
def list_locations(db: Session = Depends(get_db)):
    rows = db.query(Location).all()
    return {"success": True, "data": [{"id": l.id, "name": l.name} for l in rows]}

@router.get("/products", response_model=ProductListResponse)
def list_products(category: str | None = None, location: str | None = None, q: str | None = None, sort: str = Query("newest", pattern="^(newest|price_asc|price_desc)$"), page: int = 1, page_size: int = 20, db: Session = Depends(get_db)):
    query = db.query(Product).filter(Product.status == "active")
    if category and category != "all":
        cat = db.query(Category).filter(Category.slug == category).first()
        if cat: query = query.filter(Product.category_id == cat.id)
    if location: query = query.filter(Product.location.ilike(f"%{location}%"))
    if q: query = query.filter(or_(Product.title.ilike(f"%{q}%"), Product.description.ilike(f"%{q}%")))
    if sort == "price_asc": query = query.order_by(Product.is_promoted.desc(), Product.price.asc())
    elif sort == "price_desc": query = query.order_by(Product.is_promoted.desc(), Product.price.desc())
    else: query = query.order_by(Product.is_promoted.desc(), Product.created_at.desc())
    total = query.count()
    items = query.offset((page - 1) * page_size).limit(page_size).all()
    return ProductListResponse(total=total, page=page, page_size=page_size, items=[_to_out(p) for p in items])

@router.get("/products/me", response_model=list[ProductOut])
def my_products(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return [_to_out(p) for p in db.query(Product).filter(Product.seller_id == user.id).order_by(Product.created_at.desc()).all()]

@router.get("/products/{product_id}", response_model=ProductOut)
def get_product(product_id: int, db: Session = Depends(get_db)):
    p = db.query(Product).filter(Product.id == product_id).first()
    if not p: raise HTTPException(status_code=404, detail="Produk tidak ditemukan")
    p.views_count = (p.views_count or 0) + 1; db.commit(); db.refresh(p)
    return _to_out(p)

@router.post("/products/images")
def upload_product_image(file: UploadFile = File(...), _: User = Depends(get_current_user)):
    path = save_upload(file, "products")
    return {"success": True, "data": {"path": path, "url": file_url(path)}}

@router.post("/products", response_model=ProductOut)
def create_product(payload: ProductCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    cat = db.query(Category).filter(Category.id == payload.category_id).first()
    if not cat: raise HTTPException(status_code=400, detail="Kategori tidak valid")
    product = Product(seller_id=user.id, category_id=payload.category_id, title=payload.title, description=payload.description, price=payload.price, location=payload.location or user.location, status="active")
    db.add(product); db.flush()
    for idx, path in enumerate(payload.image_paths):
        db.add(ProductImage(product_id=product.id, path=path, sort_order=idx))
    db.commit(); db.refresh(product)
    return _to_out(product)
