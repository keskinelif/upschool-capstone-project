from dataclasses import dataclass, field
from uuid import uuid4

from app.schemas.admin import ModerationItem, ModerationStatus
from app.schemas.common import PriceBand, TagType

CATEGORIES = [
    "Study Date",
    "F/P Yemek",
    "Kahve",
    "Romantik Date/ Kokteyl",
    "Tatlı",
]


def new_id() -> str:
    return str(uuid4())


@dataclass
class Store:
    users: dict[str, dict] = field(default_factory=dict)
    tags: dict[str, dict] = field(default_factory=dict)
    venues: dict[str, dict] = field(default_factory=dict)
    contributions: dict[str, dict] = field(default_factory=dict)
    moderation_items: dict[str, ModerationItem] = field(default_factory=dict)
    revoked_refresh_tokens: set[str] = field(default_factory=set)
    assets: dict[str, dict] = field(default_factory=dict)


store = Store()


def _seed_tag(name: str, tag_type: TagType) -> str:
    tag_id = new_id()
    store.tags[tag_id] = {
        "id": tag_id,
        "name": name,
        "type": tag_type,
        "is_active": True,
    }
    return tag_id


def _seed_venue(
    *,
    name: str,
    area: str,
    lat: float,
    lng: float,
    description: str,
    tag_ids: list[str],
    price_band: PriceBand,
    image_url: str,
    maps_url: str,
) -> None:
    venue_id = new_id()
    store.venues[venue_id] = {
        "id": venue_id,
        "name": name,
        "area": area,
        "lat": lat,
        "lng": lng,
        "description": description,
        "tag_ids": tag_ids,
        "price_band": price_band,
        "image_url": image_url,
        "maps_url": maps_url,
    }


def seed_data() -> None:
    if store.users:
        return
    store.users["admin"] = {"id": "admin", "password": "admin123", "is_admin": True}
    store.users["demo"] = {"id": "demo", "password": "demo123", "is_admin": False}

    category_tags = {name: _seed_tag(name, TagType.product) for name in CATEGORIES}
    tag_study_vibe = _seed_tag("Ders Çalışma", TagType.vibe)
    tag_quiet_vibe = _seed_tag("Sessiz", TagType.vibe)

    _seed_venue(
        name="Kütüphane Kafe",
        area="Tunalı",
        lat=39.908,
        lng=32.861,
        description="Sessiz çalışma ortamı, priz mevcut.",
        tag_ids=[category_tags["Study Date"], category_tags["Kahve"], tag_study_vibe, tag_quiet_vibe],
        price_band=PriceBand.medium,
        image_url="https://picsum.photos/seed/study-date-tunali/400/500",
        maps_url="https://www.google.com/maps?q=39.908,32.861",
    )
    _seed_venue(
        name="Bahçe Espresso",
        area="Bahçelievler",
        lat=39.921,
        lng=32.824,
        description="Özel kahve çeşitleri ve sakin atmosfer.",
        tag_ids=[category_tags["Kahve"]],
        price_band=PriceBand.low,
        image_url="https://picsum.photos/seed/kahve-bahcelievler/400/500",
        maps_url="https://www.google.com/maps?q=39.921,32.824",
    )
    _seed_venue(
        name="Gece Kokteyl",
        area="Tunalı",
        lat=39.912,
        lng=32.858,
        description="Romantik akşam kokteylleri.",
        tag_ids=[category_tags["Romantik Date/ Kokteyl"]],
        price_band=PriceBand.high,
        image_url="https://picsum.photos/seed/romantik-tunali/400/500",
        maps_url="https://www.google.com/maps?q=39.912,32.858",
    )
    _seed_venue(
        name="Tatlı Köşe",
        area="Bahçelievler",
        lat=39.919,
        lng=32.826,
        description="Ucuz ve lezzetli tatlı çeşitleri.",
        tag_ids=[category_tags["Tatlı"]],
        price_band=PriceBand.low,
        image_url="https://picsum.photos/seed/tatli-bahcelievler/400/500",
        maps_url="https://www.google.com/maps?q=39.919,32.826",
    )

    item = ModerationItem(
        id=new_id(),
        user_id="demo",
        content_type="photo",
        content_url="https://example.com/photo.jpg",
        status=ModerationStatus.pending,
    )
    store.moderation_items[item.id] = item
