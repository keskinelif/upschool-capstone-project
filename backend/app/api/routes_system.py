import hashlib
from datetime import datetime, timezone

from fastapi import APIRouter, File, UploadFile

router = APIRouter(tags=["system"])


@router.get("/health")
async def health() -> dict:
    return {"status": "ok", "timestamp": datetime.now(tz=timezone.utc).isoformat()}


@router.post("/images/process")
async def process_image(file: UploadFile = File(...)) -> dict:
    body = await file.read()
    digest = hashlib.sha256(body).hexdigest()[:16]
    return {
        "filename": file.filename,
        "optimized_formats": ["webp"],
        "variants": ["thumbnail", "detail"],
        "asset_id": digest,
    }
