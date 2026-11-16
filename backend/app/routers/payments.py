import random
from datetime import datetime, timedelta
from decimal import Decimal
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session
from app.config import settings
from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.payment import Payment, Promotion
from app.models.product import Product
from app.models.user import User
from app.schemas.payment import PaymentInstruction, PromotionRequest, PaymentOut
from app.utils.files import file_url, save_upload

router = APIRouter(prefix="/api", tags=["Promotions & Payments"])
PACKAGES = {7: Decimal("25000"), 30: Decimal("75000")}

@router.get("/promotions/packages")
def packages():
    return {"success": True, "data": [{"days": d, "price": str(p)} for d, p in PACKAGES.items()]}

@router.post("/promotions/request", response_model=PaymentInstruction)
def request_promotion(payload: PromotionRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if payload.package_days not in PACKAGES: raise HTTPException(status_code=400, detail="Paket tidak valid")
    product = db.query(Product).filter(Product.id == payload.product_id, Product.seller_id == user.id).first()
    if not product: raise HTTPException(status_code=404, detail="Produk tidak ditemukan atau bukan milikmu")
    price = PACKAGES[payload.package_days]
    promo = Promotion(product_id=product.id, user_id=user.id, package_days=payload.package_days, price=price, status="pending_payment")
    db.add(promo); db.flush()
    unique_code = random.randint(100, 999)
    total = price + Decimal(unique_code)
    payment = Payment(user_id=user.id, promotion_id=promo.id, product_id=product.id, amount=price, unique_code=unique_code, total_amount=total, bank_name=settings.PAYMENT_BANK_NAME, account_number=settings.PAYMENT_ACCOUNT_NUMBER, account_name=settings.PAYMENT_ACCOUNT_NAME, status="pending")
    db.add(payment); db.commit(); db.refresh(payment)
    return PaymentInstruction(payment_id=payment.id, promotion_id=promo.id, amount=price, unique_code=unique_code, total_amount=total, bank_name=payment.bank_name, account_number=payment.account_number, account_name=payment.account_name, status=payment.status)

@router.get("/payments/{payment_id}", response_model=PaymentOut)
def get_payment(payment_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    p = db.query(Payment).filter(Payment.id == payment_id, Payment.user_id == user.id).first()
    if not p: raise HTTPException(status_code=404, detail="Pembayaran tidak ditemukan")
    data = PaymentOut.model_validate(p); data.proof_url = file_url(p.proof_path); return data

@router.post("/payments/{payment_id}/proof", response_model=PaymentOut)
def upload_proof(payment_id: int, file: UploadFile = File(...), user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    p = db.query(Payment).filter(Payment.id == payment_id, Payment.user_id == user.id).first()
    if not p: raise HTTPException(status_code=404, detail="Pembayaran tidak ditemukan")
    if p.status not in ("pending", "rejected"): raise HTTPException(status_code=400, detail="Status pembayaran tidak bisa upload bukti")
    p.proof_path = save_upload(file, "payments"); p.status = "waiting_confirmation"; db.commit(); db.refresh(p)
    data = PaymentOut.model_validate(p); data.proof_url = file_url(p.proof_path); return data
