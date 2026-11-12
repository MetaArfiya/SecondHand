import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from app.config import settings
from app.core.security import hash_password
from app.db.database import Base, engine, SessionLocal
from app.models.category import Category, Location
from app.models.user import User
from app.routers import auth, users, products, favorites, notifications, messages, payments, admin

@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    seed()
    yield

def seed():
    db: Session = SessionLocal()
    try:
        if not db.query(User).filter(User.email == settings.ADMIN_EMAIL).first():
            db.add(User(name=settings.ADMIN_NAME, email=settings.ADMIN_EMAIL, password_hash=hash_password(settings.ADMIN_PASSWORD), is_admin=True))
        for slug, name in [("all", "Semua"), ("cars", "Mobil"), ("motors", "Motor"), ("bicycles", "Sepeda"), ("phones", "HP")]:
            if not db.query(Category).filter(Category.slug == slug).first(): db.add(Category(slug=slug, name=name))
        for loc in ["Jakarta", "Bandung", "Surabaya", "Yogyakarta", "Medan"]:
            if not db.query(Location).filter(Location.name == loc).first(): db.add(Location(name=loc))
        db.commit()
    finally: db.close()

app = FastAPI(title=settings.APP_NAME, lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(products.router)
app.include_router(favorites.router)
app.include_router(notifications.router)
app.include_router(messages.router)
app.include_router(payments.router)
app.include_router(admin.router)

@app.get("/")
def root():
    return {"success": True, "message": "SecondHand API is running", "docs": "/docs"}
