from pydantic import BaseModel, Field, AliasChoices


class LoginRequest(BaseModel):
    username: str = Field(validation_alias=AliasChoices("username", "email"))
    password: str


class RefreshRequest(BaseModel):
    refresh_token: str


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    is_admin: bool = False
