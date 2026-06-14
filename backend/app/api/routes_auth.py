from fastapi import APIRouter, HTTPException, status

from app.core.security import create_token, decode_token
from app.core.settings import settings
from app.db.memory_store import RESERVED_USERNAMES, store
from app.schemas.auth import LoginRequest, RefreshRequest, RegisterRequest, RegisterResponse, TokenPair

router = APIRouter(prefix="/auth", tags=["auth"])


def _issue_tokens(user: dict) -> TokenPair:
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


@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: RegisterRequest) -> RegisterResponse:
    if payload.username in RESERVED_USERNAMES:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username is reserved.")
    if payload.username in store.users:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username already taken.")

    display_name = payload.username[:1].upper() + payload.username[1:]
    store.users[payload.username] = {
        "id": payload.username,
        "password": payload.password,
        "is_admin": False,
        "display_name": display_name,
    }
    return RegisterResponse(username=payload.username)


@router.post("/login", response_model=TokenPair)
async def login(payload: LoginRequest) -> TokenPair:
    username = payload.username.strip().lower()
    user = store.users.get(username)
    if not user or user["password"] != payload.password:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials.")
    return _issue_tokens(user)


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
