from datetime import datetime
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import relationship
from app.db.database import Base

class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True)
    seller_id = Column(ForeignKey("users.id"), nullable=False, index=True)
    category_id = Column(ForeignKey("categories.id"), nullable=False, index=True)
    title = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Numeric(12, 2), nullable=False)
    location = Column(String(100), nullable=True)
    status = Column(String(20), default="active")
    is_promoted = Column(Boolean, default=False)
    promoted_until = Column(DateTime, nullable=True)
    views_count = Column(Integer, default=0)
    contacted_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    seller = relationship("User", backref="products")
    images = relationship("ProductImage", back_populates="product", cascade="all, delete-orphan")

class ProductImage(Base):
    __tablename__ = "product_images"
    id = Column(Integer, primary_key=True)
    product_id = Column(ForeignKey("products.id"), nullable=False, index=True)
    path = Column(String(255), nullable=False)
    sort_order = Column(Integer, default=0)
    product = relationship("Product", back_populates="images")
