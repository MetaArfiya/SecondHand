import os
import uuid
from fastapi import UploadFile, HTTPException
from app.config import settings

ALLOWED_IMAGE_EXT = {".jpg", ".jpeg", ".png", ".webp"}

def save_upload(file: UploadFile, subdir: str) -> str:
    ext = os.path.splitext(file.filename or "")[1].lower()
    if ext not in ALLOWED_IMAGE_EXT:
        raise HTTPException(status_code=400, detail="Format gambar tidak didukung")
    folder = os.path.join(settings.UPLOAD_DIR, subdir)
    os.makedirs(folder, exist_ok=True)
    filename = f"{uuid.uuid4().hex}{ext}"
    path = os.path.join(folder, filename)
    with open(path, "wb") as f:
        f.write(file.file.read())
    return f"{subdir}/{filename}"

def file_url(path: str | None) -> str | None:
    if not path:
        return None
    return f"{settings.BASE_URL}/uploads/{path}"
