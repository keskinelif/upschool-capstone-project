from app.core.settings import settings
from app.db.memory_store import store
from app.schemas.common import PriceBand, TagType
from app.schemas.venue import VenueResponse
from app.services.venue_images import normalize_venue_dict


def has_required_tags(venue_tag_ids: list[str], required_tags: list[str], target_type: TagType) -> bool:
    tag_names = {
        store.tags[tag_id]["name"].casefold()
        for tag_id in venue_tag_ids
        if tag_id in store.tags and store.tags[tag_id]["type"] == target_type and store.tags[tag_id]["is_active"]
    }
    required = {value.casefold() for value in required_tags}
    return required.issubset(tag_names)


def filter_venues(
    *,
    location: str | None = None,
    product_tags: list[str] | None = None,
    vibe_tags: list[str] | None = None,
    price_band: PriceBand | None = None,
) -> list[VenueResponse]:
    allowed_areas = {area.strip() for area in settings.pilot_areas.split(",") if area.strip()}
    rows = list(store.venues.values())
    rows = [venue for venue in rows if venue["area"] in allowed_areas]

    if location:
        rows = [venue for venue in rows if venue["area"].casefold() == location.casefold()]
    if price_band:
        rows = [venue for venue in rows if venue["price_band"] == price_band]
    if product_tags:
        rows = [venue for venue in rows if has_required_tags(venue["tag_ids"], product_tags, TagType.product)]
    if vibe_tags:
        rows = [venue for venue in rows if has_required_tags(venue["tag_ids"], vibe_tags, TagType.vibe)]

    return [VenueResponse(**normalize_venue_dict(dict(venue))) for venue in rows]
