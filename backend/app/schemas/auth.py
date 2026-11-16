import re
from pydantic import BaseModel, field_validator

EMAIL_PATTERN = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")

def validate_email(value: str) -> str:
    normalized = value.strip().lower()
    if not EMAIL_PATTERN.fullmatch(normalized):
        raise ValueError("Format email tidak valid")
    return normalized

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
    @field_validator("email")
    @classmethod
    def must_be_dot_com(cls, v: str) -> str:
        v = validate_email(v)
        if not re.search(r"\.com$", v, re.IGNORECASE):
            raise ValueError("Email harus menggunakan domain .com")
        return v
    @field_validator("password")
    @classmethod
    def password_min_length(cls, v: str) -> str:
        if len(v) < 6:
            raise ValueError("Password minimal 6 karakter")
        return v

class LoginRequest(BaseModel):
    email: str
    password: str

    @field_validator("email")
    @classmethod
    def normalize_email(cls, v: str) -> str:
        return validate_email(v)

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class ForgotPasswordRequest(BaseModel):
    email: str

    @field_validator("email")
    @classmethod
    def normalize_email(cls, v: str) -> str:
        return validate_email(v)

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str
