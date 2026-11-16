from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import or_
from sqlalchemy.orm import Session
from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.message import Message
from app.models.notification import Notification
from app.models.product import Product
from app.models.user import User

router = APIRouter(prefix="/api/messages", tags=["Messages"])
class SendMessageRequest(BaseModel):
    receiver_id: int
    product_id: int | None = None
    body: str

@router.get("")
def list_messages(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(Message).filter(or_(Message.sender_id == user.id, Message.receiver_id == user.id)).order_by(Message.created_at.desc()).limit(100).all()
    return {"success": True, "data": [{"id": m.id, "sender_id": m.sender_id, "receiver_id": m.receiver_id, "product_id": m.product_id, "body": m.body, "is_read": bool(m.is_read), "created_at": m.created_at.isoformat()} for m in rows]}

@router.post("")
def send_message(payload: SendMessageRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not payload.body.strip(): raise HTTPException(status_code=400, detail="Pesan tidak boleh kosong")
    if payload.receiver_id == user.id: raise HTTPException(status_code=400, detail="Tidak dapat mengirim pesan ke diri sendiri")
    receiver = db.query(User).filter(User.id == payload.receiver_id).first()
    if not receiver or not receiver.allow_messages: raise HTTPException(status_code=400, detail="Penerima tidak tersedia")
    if payload.product_id:
        product = db.query(Product).filter(Product.id == payload.product_id).first()
        if product: product.contacted_count = (product.contacted_count or 0) + 1
    msg = Message(sender_id=user.id, receiver_id=payload.receiver_id, product_id=payload.product_id, body=payload.body.strip())
    db.add(msg)
    if receiver.notify_transactions:
        db.add(Notification(user_id=receiver.id, title=f"Pesan baru dari {user.name}", body=payload.body.strip(), kind="message"))
    db.commit()
    return {"success": True, "message": "Pesan terkirim"}
