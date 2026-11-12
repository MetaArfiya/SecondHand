from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel

class PromotionRequest(BaseModel):
    product_id: int
    package_days: int

class PaymentInstruction(BaseModel):
    payment_id: int
    promotion_id: int
    amount: Decimal
    unique_code: int
    total_amount: Decimal
    bank_name: str
    account_number: str
    account_name: str
    status: str

class PaymentOut(BaseModel):
    id: int
    product_id: int
    promotion_id: int
    amount: Decimal
    unique_code: int
    total_amount: Decimal
    status: str
    proof_url: str | None = None
    admin_note: str | None = None
    created_at: datetime
    class Config:
        from_attributes = True

class AdminPaymentAction(BaseModel):
    status: str
    admin_note: str | None = None
