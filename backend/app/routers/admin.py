from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.dependencies import get_current_admin
from app.db.database import get_db
from app.models.notification import Notification
from app.models.payment import Payment, Promotion
from app.models.product import Product
from app.models.user import User
from app.schemas.payment import AdminPaymentAction, PaymentOut
from app.utils.files import file_url

router = APIRouter(prefix="/api/admin", tags=["Admin"])

@router.get("/payments", response_model=list[PaymentOut])
def list_payments(status: str | None = None, _: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    q = db.query(Payment).order_by(Payment.created_at.desc())
    if status: q = q.filter(Payment.status == status)
    payments = []
    for payment in q.all():
        item = PaymentOut.model_validate(payment)
        item.proof_url = file_url(payment.proof_path)
        payments.append(item)
    return payments

@router.patch("/payments/{payment_id}", response_model=PaymentOut)
def decide_payment(payment_id: int, payload: AdminPaymentAction, _: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    p = db.query(Payment).filter(Payment.id == payment_id).first()
    if not p: raise HTTPException(status_code=404, detail="Pembayaran tidak ditemukan")
    if payload.status not in ("approved", "rejected"): raise HTTPException(status_code=400, detail="Status tidak valid")
    if p.status != "waiting_confirmation": raise HTTPException(status_code=409, detail="Pembayaran belum siap ditinjau")
    p.status = payload.status; p.admin_note = payload.admin_note; p.confirmed_at = datetime.utcnow()
    promo = db.query(Promotion).filter(Promotion.id == p.promotion_id).first()
    if promo:
        if payload.status == "approved":
            now = datetime.utcnow(); promo.status = "active"; promo.starts_at = now; promo.ends_at = now + timedelta(days=promo.package_days)
            product = db.query(Product).filter(Product.id == promo.product_id).first()
            if product: product.is_promoted = True; product.promoted_until = promo.ends_at
        else: promo.status = "rejected"
    db.add(Notification(user_id=p.user_id, title="Pembayaran promosi " + ("disetujui" if payload.status == "approved" else "ditolak"), body=payload.admin_note or "", kind="promo"))
    db.commit(); db.refresh(p)
    result = PaymentOut.model_validate(p)
    result.proof_url = file_url(p.proof_path)
    return result
