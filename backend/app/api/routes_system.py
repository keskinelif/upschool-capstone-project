import hashlib
from datetime import datetime, timezone

from fastapi import APIRouter, File, HTTPException, Request, UploadFile, status
from fastapi.responses import Response

from app.db.memory_store import store

router = APIRouter(tags=["system"])


@router.get("/health")
async def health() -> dict:
    return {"status": "ok", "timestamp": datetime.now(tz=timezone.utc).isoformat()}


@router.post("/images/process")
async def process_image(request: Request, file: UploadFile = File(...)) -> dict:
    body = await file.read()
    if not body:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Empty file.")
    digest = hashlib.sha256(body).hexdigest()[:16]
    content_type = file.content_type or "image/jpeg"
    store.assets[digest] = {"bytes": body, "content_type": content_type}
    base = str(request.base_url).rstrip("/")
    image_url = f"{base}/assets/{digest}"
    return {
        "filename": file.filename,
        "optimized_formats": ["webp"],
        "variants": ["thumbnail", "detail"],
        "asset_id": digest,
        "image_url": image_url,
    }


@router.get("/assets/{asset_id}")
async def get_asset(asset_id: str) -> Response:
    asset = store.assets.get(asset_id)
    if not asset:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Asset not found.")
    return Response(content=asset["bytes"], media_type=asset["content_type"])
