from pydantic import BaseModel, Field, AliasChoices, field_validator


class LoginRequest(BaseModel):
    username: str = Field(validation_alias=AliasChoices("username", "email"))
    password: str


class RegisterRequest(BaseModel):
    username: str = Field(min_length=3, max_length=32)
    password: str = Field(min_length=4, max_length=120)

    @field_validator("username")
    @classmethod
    def normalize_username(cls, value: str) -> str:
        username = value.strip().lower()
        if not username.replace("_", "").isalnum():
            raise ValueError("Username may only contain letters, numbers, and underscores.")
        return username


class RegisterResponse(BaseModel):
    username: str
    message: str = "Registration successful."


class RefreshRequest(BaseModel):
    refresh_token: str


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    is_admin: bool = False
