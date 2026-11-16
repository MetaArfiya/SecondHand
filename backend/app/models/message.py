from datetime import datetime
from sqlalchemy import Column, DateTime, ForeignKey, Integer, Text
from app.db.database import Base

class Message(Base):
    __tablename__ = "messages"
    id = Column(Integer, primary_key=True)
    sender_id = Column(ForeignKey("users.id"), nullable=False, index=True)
    receiver_id = Column(ForeignKey("users.id"), nullable=False, index=True)
    product_id = Column(ForeignKey("products.id"), nullable=True)
    body = Column(Text, nullable=False)
    is_read = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
