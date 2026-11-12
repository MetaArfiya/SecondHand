from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field

class ProductImageOut(BaseModel):
    id: int
    url: str

class ProductCreate(BaseModel):
    category_id: int
    title: str = Field(min_length=3, max_length=150)
    description: str | None = None
    price: Decimal = Field(gt=0)
    location: str | None = None
    image_paths: list[str] = []

class ProductOut(BaseModel):
    id: int
    title: str
    description: str | None
    price: Decimal
    location: str | None
    status: str
    is_promoted: bool
    views_count: int
    contacted_count: int
    category_id: int
    seller_id: int
    seller_name: str | None = None
    images: list[ProductImageOut] = []
    created_at: datetime

class ProductListResponse(BaseModel):
    total: int
    page: int
    page_size: int
    items: list[ProductOut]

class DashboardStats(BaseModel):
    active_ads: int
    total_views: int
    total_contacted: int
