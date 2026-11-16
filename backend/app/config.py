from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    APP_NAME: str = "SecondHand API"
    DEBUG: bool = True
    SECRET_KEY: str = "ubah-ini-rahasia-panjang"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7
    DATABASE_URL: str = "sqlite:///./secondhand.db"
    UPLOAD_DIR: str = "uploads"
    BASE_URL: str = "http://localhost:8000"
    PAYMENT_BANK_NAME: str = "BCA"
    PAYMENT_ACCOUNT_NUMBER: str = "1234567890"
    PAYMENT_ACCOUNT_NAME: str = "SecondHand Admin"
    ADMIN_EMAIL: str = "admin@secondhand.com"
    ADMIN_PASSWORD: str = "admin12345"
    ADMIN_NAME: str = "Admin SecondHand"
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()
