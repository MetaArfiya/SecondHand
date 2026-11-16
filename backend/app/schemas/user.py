from pydantic import BaseModel

class UserMe(BaseModel):
    id: int
    name: str
    email: str
    phone: str | None = None
    location: str | None = None
    bio: str | None = None
    avatar_url: str | None = None
    is_admin: bool
    profile_visibility: str
    allow_messages: bool
    notify_transactions: bool
    notify_promos: bool
    class Config:
        from_attributes = True

class UpdateProfileRequest(BaseModel):
    name: str | None = None
    phone: str | None = None
    location: str | None = None
    bio: str | None = None

class UpdateSettingsRequest(BaseModel):
    profile_visibility: str | None = None
    allow_messages: bool | None = None
    notify_transactions: bool | None = None
    notify_promos: bool | None = None
