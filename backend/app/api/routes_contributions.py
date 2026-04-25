from collections import Counter, defaultdict

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import get_current_user
from app.db.memory_store import new_id, store
from app.schemas.contribution import ContributionCreate, ContributionResponse

router = APIRouter(prefix="/contributions", tags=["contributions"])


@router.post("", response_model=ContributionResponse)
async def create_contribution(payload: ContributionCreate, user: dict = Depends(get_current_user)) -> ContributionResponse:
    if payload.venue_id not in store.venues:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Venue not found.")
    contribution_id = new_id()
    row = payload.model_dump()
    row["id"] = contribution_id
    row["user_id"] = user["sub"]
    store.contributions[contribution_id] = row
    return ContributionResponse(**row)


@router.get("/summary/{venue_id}")
async def contribution_summary(venue_id: str) -> dict:
    rows = [row for row in store.contributions.values() if row["venue_id"] == venue_id]
    if not rows:
        return {"venue_id": venue_id, "count": 0, "wifi_quiet_avg": None, "price_distribution": {}}
    avg = sum(row["wifi_quiet_score"] for row in rows) / len(rows)
    price_counter = Counter(row["price_band"] for row in rows)
    outlet_counter = defaultdict(int)
    for row in rows:
        outlet_counter["with_outlet" if row["outlet_available"] else "without_outlet"] += 1
    return {
        "venue_id": venue_id,
        "count": len(rows),
        "wifi_quiet_avg": round(avg, 2),
        "price_distribution": dict(price_counter),
        "outlet_distribution": dict(outlet_counter),
    }
