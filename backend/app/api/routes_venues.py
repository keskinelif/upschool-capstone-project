from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.api.deps import require_admin
from app.db.memory_store import new_id, store
from app.schemas.common import PriceBand
from app.schemas.venue import VenueCreate, VenueResponse, VenueUpdate
from app.services.venue_filter import filter_venues
from app.services.venue_images import normalize_venue_dict

router = APIRouter(prefix="/venues", tags=["venues"])


@router.get("/{venue_id}", response_model=VenueResponse)
async def get_venue(venue_id: str) -> VenueResponse:
    venue = store.venues.get(venue_id)
    if not venue:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Venue not found.")
    return VenueResponse(**normalize_venue_dict(dict(venue)))


@router.get("", response_model=list[VenueResponse])
async def list_venues(
    location: str | None = Query(default=None),
    product_tags: list[str] = Query(default=[]),
    vibe_tags: list[str] = Query(default=[]),
    price_band: PriceBand | None = Query(default=None),
) -> list[VenueResponse]:
    return filter_venues(
        location=location,
        product_tags=product_tags,
        vibe_tags=vibe_tags,
        price_band=price_band,
    )


@router.post("", response_model=VenueResponse, dependencies=[Depends(require_admin)])
async def create_venue(payload: VenueCreate) -> VenueResponse:
    missing_tags = [tag_id for tag_id in payload.tag_ids if tag_id not in store.tags]
    if missing_tags:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Some tags do not exist.")
    venue_id = new_id()
    venue = normalize_venue_dict(payload.model_dump())
    venue["id"] = venue_id
    store.venues[venue_id] = venue
    return VenueResponse(**venue)


@router.patch("/{venue_id}", response_model=VenueResponse, dependencies=[Depends(require_admin)])
async def update_venue(venue_id: str, payload: VenueUpdate) -> VenueResponse:
    venue = store.venues.get(venue_id)
    if not venue:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Venue not found.")
    updates = payload.model_dump(exclude_unset=True)
    if "tag_ids" in updates:
        missing_tags = [tag_id for tag_id in updates["tag_ids"] if tag_id not in store.tags]
        if missing_tags:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Some tags do not exist.")
    venue.update(updates)
    normalize_venue_dict(venue)
    return VenueResponse(**venue)
