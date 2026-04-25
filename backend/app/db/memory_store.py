from dataclasses import dataclass, field
from uuid import uuid4

from app.schemas.admin import ModerationItem, ModerationStatus
from app.schemas.common import PriceBand, TagType


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


store = Store()


def seed_data() -> None:
    if store.users:
        return
    store.users["admin"] = {"id": "admin", "password": "admin123", "is_admin": True}
    store.users["demo"] = {"id": "demo", "password": "demo123", "is_admin": False}

    tag_food = new_id()
    tag_study = new_id()
    store.tags[tag_food] = {"id": tag_food, "name": "Hamburger", "type": TagType.product, "is_active": True}
    store.tags[tag_study] = {"id": tag_study, "name": "Ders Çalışma", "type": TagType.vibe, "is_active": True}

    venue_id = new_id()
    store.venues[venue_id] = {
        "id": venue_id,
        "name": "Demo Mekan",
        "area": "Tunalı",
        "lat": 39.91,
        "lng": 32.86,
        "description": "Seed venue",
        "tag_ids": [tag_food, tag_study],
        "price_band": PriceBand.medium,
    }

    item = ModerationItem(
        id=new_id(),
        user_id="demo",
        content_type="photo",
        content_url="https://example.com/photo.jpg",
        status=ModerationStatus.pending,
    )
    store.moderation_items[item.id] = item
