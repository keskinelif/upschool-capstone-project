from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.api.deps import require_admin
from app.core.settings import settings
from app.db.memory_store import new_id, store
from app.schemas.common import PriceBand, TagType
from app.schemas.venue import VenueCreate, VenueResponse

router = APIRouter(prefix="/venues", tags=["venues"])


@router.get("", response_model=list[VenueResponse])
async def list_venues(
    location: str | None = Query(default=None),
    product_tags: list[str] = Query(default=[]),
    vibe_tags: list[str] = Query(default=[]),
    price_band: PriceBand | None = Query(default=None),
) -> list[VenueResponse]:
    allowed_areas = {area.strip() for area in settings.pilot_areas.split(",") if area.strip()}
    rows = list(store.venues.values())
    if location:
        rows = [venue for venue in rows if venue["area"].lower() == location.lower()]
    rows = [venue for venue in rows if venue["area"] in allowed_areas]
    if price_band:
        rows = [venue for venue in rows if venue["price_band"] == price_band]
    if product_tags:
        rows = [venue for venue in rows if has_required_tags(venue["tag_ids"], product_tags, TagType.product)]
    if vibe_tags:
        rows = [venue for venue in rows if has_required_tags(venue["tag_ids"], vibe_tags, TagType.vibe)]
    return [VenueResponse(**venue) for venue in rows]


def has_required_tags(venue_tag_ids: list[str], required_tags: list[str], target_type: TagType) -> bool:
    tag_names = {
        store.tags[tag_id]["name"].lower()
        for tag_id in venue_tag_ids
        if tag_id in store.tags and store.tags[tag_id]["type"] == target_type and store.tags[tag_id]["is_active"]
    }
    required = {value.lower() for value in required_tags}
    return required.issubset(tag_names)


@router.post("", response_model=VenueResponse, dependencies=[Depends(require_admin)])
async def create_venue(payload: VenueCreate) -> VenueResponse:
    missing_tags = [tag_id for tag_id in payload.tag_ids if tag_id not in store.tags]
    if missing_tags:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Some tags do not exist.")
    venue_id = new_id()
    venue = payload.model_dump()
    venue["id"] = venue_id
    store.venues[venue_id] = venue
    return VenueResponse(**venue)
