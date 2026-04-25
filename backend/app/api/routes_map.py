from fastapi import APIRouter, Query

from app.db.memory_store import store

router = APIRouter(prefix="/map", tags=["map"])


@router.get("/pins")
async def list_map_pins(limit: int = Query(default=200, ge=1, le=500), offset: int = Query(default=0, ge=0)) -> dict:
    rows = list(store.venues.values())[offset : offset + limit]
    pins = [
        {
            "id": row["id"],
            "name": row["name"],
            "lat": row["lat"],
            "lng": row["lng"],
            "area": row["area"],
            "price_band": row["price_band"],
        }
        for row in rows
    ]
    return {"items": pins, "limit": limit, "offset": offset, "next_offset": offset + len(rows)}
