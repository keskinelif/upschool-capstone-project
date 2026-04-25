from fastapi import Depends, Header, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.security import decode_token
from app.core.settings import settings

bearer_scheme = HTTPBearer()


def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme)) -> dict:
    payload = decode_token(credentials.credentials)
    if payload.get("type") != "access":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Access token required.")
    return payload


def require_admin(
    request: Request,
    user: dict = Depends(get_current_user),
    x_forwarded_for: str | None = Header(default=None),
) -> dict:
    allowed_ips = {ip.strip() for ip in settings.admin_allowed_ips.split(",") if ip.strip()}
    origin_ip = (x_forwarded_for or request.client.host or "").split(",")[0].strip()
    is_admin = bool(user.get("is_admin"))
    if is_admin:
        return user
    if origin_ip and origin_ip in allowed_ips:
        return user
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required.")
