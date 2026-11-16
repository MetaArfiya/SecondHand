from fastapi import APIRouter, Depends, File, UploadFile
from sqlalchemy.orm import Session
from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.product import Product
from app.models.user import User
from app.schemas.product import DashboardStats
from app.schemas.user import UpdateProfileRequest, UpdateSettingsRequest, UserMe
from app.utils.files import file_url, save_upload

router = APIRouter(prefix="/api/users", tags=["Users"])

def _to_me(user: User) -> UserMe:
    data = UserMe.model_validate(user)
    data.avatar_url = file_url(user.avatar_path)
    return data

@router.get("/me", response_model=UserMe)
def get_me(user: User = Depends(get_current_user)):
    return _to_me(user)

@router.patch("/me", response_model=UserMe)
def update_profile(payload: UpdateProfileRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(user, field, value)
    db.commit(); db.refresh(user)
    return _to_me(user)

@router.patch("/me/settings", response_model=UserMe)
def update_settings(payload: UpdateSettingsRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(user, field, value)
    db.commit(); db.refresh(user)
    return _to_me(user)

@router.post("/me/avatar", response_model=UserMe)
def upload_avatar(file: UploadFile = File(...), user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    user.avatar_path = save_upload(file, "profiles")
    db.commit(); db.refresh(user)
    return _to_me(user)

@router.get("/me/dashboard", response_model=DashboardStats)
def dashboard(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    products = db.query(Product).filter(Product.seller_id == user.id).all()
    return DashboardStats(
        active_ads=sum(1 for p in products if p.status == "active"),
        total_views=sum(p.views_count or 0 for p in products),
        total_contacted=sum(p.contacted_count or 0 for p in products),
    )
