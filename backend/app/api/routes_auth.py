from fastapi import APIRouter, HTTPException, status

from app.core.security import create_token, decode_token
from app.core.settings import settings
from app.db.memory_store import store
from app.schemas.auth import LoginRequest, RefreshRequest, TokenPair

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=TokenPair)
async def login(payload: LoginRequest) -> TokenPair:
    user = store.users.get(payload.username)
    if not user or user["password"] != payload.password:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials.")
    access = create_token(
        subject=user["id"],
        token_type="access",
        ttl_minutes=settings.access_token_ttl_minutes,
        extra={"is_admin": user["is_admin"]},
    )
    refresh = create_token(
        subject=user["id"],
        token_type="refresh",
        ttl_minutes=settings.refresh_token_ttl_minutes,
        extra={"is_admin": user["is_admin"]},
    )
    return TokenPair(access_token=access, refresh_token=refresh, is_admin=user["is_admin"])


@router.post("/refresh", response_model=TokenPair)
async def refresh(payload: RefreshRequest) -> TokenPair:
    if payload.refresh_token in store.revoked_refresh_tokens:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token revoked.")
    token_payload = decode_token(payload.refresh_token)
    if token_payload.get("type") != "refresh":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token required.")
    store.revoked_refresh_tokens.add(payload.refresh_token)
    access = create_token(
        subject=token_payload["sub"],
        token_type="access",
        ttl_minutes=settings.access_token_ttl_minutes,
        extra={"is_admin": token_payload.get("is_admin", False)},
    )
    refresh_token = create_token(
        subject=token_payload["sub"],
        token_type="refresh",
        ttl_minutes=settings.refresh_token_ttl_minutes,
        extra={"is_admin": token_payload.get("is_admin", False)},
    )
    return TokenPair(
        access_token=access,
        refresh_token=refresh_token,
        is_admin=bool(token_payload.get("is_admin", False)),
    )
