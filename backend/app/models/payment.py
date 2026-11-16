from datetime import datetime
from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String, Text
from app.db.database import Base

class Promotion(Base):
    __tablename__ = "promotions"
    id = Column(Integer, primary_key=True)
    product_id = Column(ForeignKey("products.id"), nullable=False, index=True)
    user_id = Column(ForeignKey("users.id"), nullable=False, index=True)
    package_days = Column(Integer, nullable=False)
    price = Column(Numeric(12, 2), nullable=False)
    status = Column(String(30), default="pending_payment")
    starts_at = Column(DateTime, nullable=True)
    ends_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class Payment(Base):
    __tablename__ = "payments"
    id = Column(Integer, primary_key=True)
    user_id = Column(ForeignKey("users.id"), nullable=False, index=True)
    promotion_id = Column(ForeignKey("promotions.id"), nullable=False)
    product_id = Column(ForeignKey("products.id"), nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    unique_code = Column(Integer, nullable=False)
    total_amount = Column(Numeric(12, 2), nullable=False)
    bank_name = Column(String(50), nullable=False)
    account_number = Column(String(50), nullable=False)
    account_name = Column(String(100), nullable=False)
    proof_path = Column(String(255), nullable=True)
    status = Column(String(30), default="pending")
    admin_note = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    confirmed_at = Column(DateTime, nullable=True)
