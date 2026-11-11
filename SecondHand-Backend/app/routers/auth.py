import secrets
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.security import create_access_token, hash_password, verify_password
from app.db.database import get_db
from app.models.user import User, PasswordResetToken
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse, ForgotPasswordRequest, ResetPasswordRequest

router = APIRouter(prefix="/api/auth", tags=["Auth"])

@router.post("/register", response_model=TokenResponse)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == payload.email).first():
        raise HTTPException(status_code=400, detail="Email sudah terdaftar")
    user = User(name=payload.name, email=payload.email, password_hash=hash_password(payload.password))
    db.add(user); db.commit(); db.refresh(user)
    return TokenResponse(access_token=create_access_token({"sub": str(user.id)}))

@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email.lower()).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Email atau password salah")
    return TokenResponse(access_token=create_access_token({"sub": str(user.id)}))

@router.post("/forgot-password")
def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email.lower()).first()
    if not user:
        return {"success": True, "message": "Jika email terdaftar, link reset akan dikirim"}
    token = secrets.token_hex(32)
    db.add(PasswordResetToken(user_id=user.id, token=token, expires_at=datetime.utcnow() + timedelta(hours=1)))
    db.commit()
    print(f"[RESET PASSWORD] email={user.email} token={token}")
    return {"success": True, "message": "Token reset dibuat", "data": {"dev_token": token}}

@router.post("/reset-password")
def reset_password(payload: ResetPasswordRequest, db: Session = Depends(get_db)):
    row = db.query(PasswordResetToken).filter(PasswordResetToken.token == payload.token, PasswordResetToken.used.is_(False)).first()
    if not row or row.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Token tidak valid atau kedaluwarsa")
    user = db.query(User).filter(User.id == row.user_id).first()
    user.password_hash = hash_password(payload.new_password)
    row.used = True; db.commit()
    return {"success": True, "message": "Password berhasil direset"}
