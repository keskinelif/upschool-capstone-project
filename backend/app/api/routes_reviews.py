from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import get_current_user
from app.db.memory_store import new_id, store
from app.schemas.review import ReviewCreate, ReviewResponse, ReviewStatus

router = APIRouter(prefix="/reviews", tags=["reviews"])


def _resolve_user(username: str) -> dict:
    user = store.users.get(username)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found.")
    return user


@router.get("/venue/{venue_id}", response_model=list[ReviewResponse])
async def list_venue_reviews(venue_id: str) -> list[ReviewResponse]:
    if venue_id not in store.venues:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Venue not found.")
    rows = [
        row
        for row in store.reviews.values()
        if row["venue_id"] == venue_id and row["status"] == ReviewStatus.approved
    ]
    rows.sort(key=lambda row: row["created_at"], reverse=True)
    return [ReviewResponse(**row) for row in rows]


@router.post("", response_model=ReviewResponse, status_code=status.HTTP_201_CREATED)
async def create_review(
    payload: ReviewCreate,
    token: dict = Depends(get_current_user),
) -> ReviewResponse:
    if payload.venue_id not in store.venues:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Venue not found.")

    username = token["sub"]
    user = _resolve_user(username)
    review_id = new_id()
    row = {
        "id": review_id,
        "venue_id": payload.venue_id,
        "user_id": user["id"],
        "username": username,
        "display_name": user.get("display_name", username),
        "text": payload.text.strip(),
        "status": ReviewStatus.pending,
        "created_at": datetime.now(tz=timezone.utc),
    }
    store.reviews[review_id] = row
    return ReviewResponse(**row)
