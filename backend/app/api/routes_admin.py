import csv
from io import StringIO

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status

from app.api.deps import require_admin
from app.db.memory_store import new_id, store
from app.schemas.admin import (
    AdminPendingReview,
    ImportResult,
    ModerationDecision,
    ModerationItem,
    ModerationStatus,
    ReviewDecision,
)
from app.schemas.common import PriceBand
from app.schemas.review import ReviewResponse, ReviewStatus

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


@router.get("/reviews/pending", response_model=list[AdminPendingReview])
async def list_pending_reviews() -> list[AdminPendingReview]:
    rows = [row for row in store.reviews.values() if row["status"] == ReviewStatus.pending]
    rows.sort(key=lambda row: row["created_at"], reverse=True)
    result: list[AdminPendingReview] = []
    for row in rows:
        venue = store.venues.get(row["venue_id"])
        venue_name = venue["name"] if venue else "Bilinmeyen mekan"
        result.append(AdminPendingReview(**row, venue_name=venue_name))
    return result


@router.post("/reviews/decision", response_model=ReviewResponse)
async def decide_review(payload: ReviewDecision) -> ReviewResponse:
    row = store.reviews.get(payload.review_id)
    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Review not found.")
    if payload.status == ReviewStatus.pending:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Decision cannot stay pending.")
    row["status"] = payload.status
    return ReviewResponse(**row)


@router.get("/reviews/venue/{venue_id}", response_model=list[ReviewResponse])
async def list_venue_reviews_admin(venue_id: str) -> list[ReviewResponse]:
    if venue_id not in store.venues:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Venue not found.")
    rows = [row for row in store.reviews.values() if row["venue_id"] == venue_id]
    rows.sort(key=lambda row: row["created_at"], reverse=True)
    return [ReviewResponse(**row) for row in rows]


@router.delete("/reviews/{review_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_review(review_id: str) -> None:
    if review_id not in store.reviews:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Review not found.")
    del store.reviews[review_id]


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
