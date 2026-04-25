import csv
from io import StringIO

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status

from app.api.deps import require_admin
from app.db.memory_store import new_id, store
from app.schemas.admin import ImportResult, ModerationDecision, ModerationItem, ModerationStatus
from app.schemas.common import PriceBand

router = APIRouter(prefix="/admin", tags=["admin"], dependencies=[Depends(require_admin)])


@router.get("/moderation", response_model=list[ModerationItem])
async def list_moderation_items() -> list[ModerationItem]:
    return list(store.moderation_items.values())


@router.post("/moderation/decision", response_model=ModerationItem)
async def moderate(payload: ModerationDecision) -> ModerationItem:
    row = store.moderation_items.get(payload.item_id)
    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Moderation item not found.")
    if payload.status == ModerationStatus.pending:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Decision cannot stay pending.")
    row.status = payload.status
    return row


@router.post("/import", response_model=ImportResult)
async def bulk_import(file: UploadFile = File(...)) -> ImportResult:
    content = (await file.read()).decode("utf-8")
    reader = csv.DictReader(StringIO(content))
    imported = 0
    failed_rows: list[str] = []
    for index, row in enumerate(reader, start=2):
        try:
            if not row.get("name"):
                raise ValueError("Missing name")
            venue_id = new_id()
            store.venues[venue_id] = {
                "id": venue_id,
                "name": row["name"],
                "area": row.get("area", ""),
                "lat": float(row.get("lat", "0")),
                "lng": float(row.get("lng", "0")),
                "description": row.get("description", ""),
                "tag_ids": [value.strip() for value in row.get("tag_ids", "").split("|") if value.strip()],
                "price_band": PriceBand(row.get("price_band", "₺₺")),
            }
            imported += 1
        except Exception as exc:  # noqa: BLE001
            failed_rows.append(f"row {index}: {exc}")
    return ImportResult(imported=imported, failed_rows=failed_rows)
