from dataclasses import dataclass, field
from datetime import datetime, timezone
from uuid import uuid4

from app.schemas.admin import ModerationItem, ModerationStatus
from app.schemas.common import PriceBand, TagType
from app.schemas.review import ReviewStatus

CATEGORIES = [
    "Study Date",
    "F/P Yemek",
    "Kahve",
    "Romantik Date/ Kokteyl",
    "Tatlı",
]

DEMO_USERS: list[tuple[str, str]] = [
    ("ayse", "Ayşe"),
    ("mehmet", "Mehmet"),
    ("zeynep", "Zeynep"),
    ("can", "Can"),
    ("elif", "Elif"),
    ("burak", "Burak"),
    ("deniz", "Deniz"),
    ("selin", "Selin"),
    ("emre", "Emre"),
    ("fatma", "Fatma"),
    ("kerem", "Kerem"),
]

RESERVED_USERNAMES = {"admin", "demo"}

_REPO_RAW_VENUE_PHOTOS = (
    "https://raw.githubusercontent.com/keskinelif/upschool-capstone-project/main/backend/static/venues"
)


def _venue_photo(filename: str) -> str:
    return f"{_REPO_RAW_VENUE_PHOTOS}/{filename}"


def new_id() -> str:
    return str(uuid4())


@dataclass
class Store:
    users: dict[str, dict] = field(default_factory=dict)
    tags: dict[str, dict] = field(default_factory=dict)
    venues: dict[str, dict] = field(default_factory=dict)
    contributions: dict[str, dict] = field(default_factory=dict)
    reviews: dict[str, dict] = field(default_factory=dict)
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
    image_urls: list[str],
    maps_url: str,
) -> str:
    venue_id = new_id()
    urls = [url.strip() for url in image_urls if url.strip()]
    store.venues[venue_id] = {
        "id": venue_id,
        "name": name,
        "area": area,
        "lat": lat,
        "lng": lng,
        "description": description,
        "tag_ids": tag_ids,
        "price_band": price_band,
        "image_url": urls[0] if urls else None,
        "image_urls": urls,
        "maps_url": maps_url,
    }
    return venue_id


def _seed_review(
    *,
    venue_id: str,
    username: str,
    text: str,
    status: ReviewStatus = ReviewStatus.approved,
    created_at: datetime | None = None,
) -> None:
    user = store.users[username]
    review_id = new_id()
    store.reviews[review_id] = {
        "id": review_id,
        "venue_id": venue_id,
        "user_id": user["id"],
        "username": username,
        "display_name": user["display_name"],
        "text": text,
        "status": status,
        "created_at": created_at or datetime.now(tz=timezone.utc),
    }


def seed_data() -> None:
    if store.users:
        return
    store.users["admin"] = {
        "id": "admin",
        "password": "admin123",
        "is_admin": True,
        "display_name": "Admin",
    }
    store.users["demo"] = {
        "id": "demo",
        "password": "demo123",
        "is_admin": False,
        "display_name": "Demo",
    }
    for username, display_name in DEMO_USERS:
        store.users[username] = {
            "id": username,
            "password": f"{username}123",
            "is_admin": False,
            "display_name": display_name,
        }

    category_tags = {name: _seed_tag(name, TagType.product) for name in CATEGORIES}
    tag_study_vibe = _seed_tag("Ders Çalışma", TagType.vibe)
    tag_quiet_vibe = _seed_tag("Sessiz", TagType.vibe)

    venue_kutuphane = _seed_venue(
        name="Kütüphane Kafe",
        area="Tunalı",
        lat=39.908,
        lng=32.861,
        description="Sessiz çalışma ortamı, priz mevcut.",
        tag_ids=[category_tags["Study Date"], category_tags["Kahve"], tag_study_vibe, tag_quiet_vibe],
        price_band=PriceBand.medium,
        image_urls=[
            _venue_photo("kutuphane-kafe-1.jpg"),
            _venue_photo("kutuphane-kafe-2.jpg"),
            _venue_photo("kutuphane-kafe-3.jpg"),
        ],
        maps_url="https://www.google.com/maps?q=39.908,32.861",
    )
    venue_bahce = _seed_venue(
        name="Bahçe Espresso",
        area="Bahçelievler",
        lat=39.921,
        lng=32.824,
        description="Özel kahve çeşitleri ve sakin atmosfer.",
        tag_ids=[category_tags["Kahve"]],
        price_band=PriceBand.low,
        image_urls=[
            _venue_photo("bahce-espresso-1.jpg"),
            _venue_photo("bahce-espresso-2.jpg"),
            _venue_photo("bahce-espresso-3.jpg"),
        ],
        maps_url="https://www.google.com/maps?q=39.921,32.824",
    )
    venue_kokteyl = _seed_venue(
        name="Gece Kokteyl",
        area="Tunalı",
        lat=39.912,
        lng=32.858,
        description="Romantik akşam kokteylleri.",
        tag_ids=[category_tags["Romantik Date/ Kokteyl"]],
        price_band=PriceBand.high,
        image_urls=[
            _venue_photo("gece-kokteyl-1.jpg"),
            _venue_photo("gece-kokteyl-2.jpg"),
            _venue_photo("gece-kokteyl-3.jpg"),
        ],
        maps_url="https://www.google.com/maps?q=39.912,32.858",
    )
    venue_tatli = _seed_venue(
        name="Tatlı Köşe",
        area="Bahçelievler",
        lat=39.919,
        lng=32.826,
        description="Ucuz ve lezzetli tatlı çeşitleri.",
        tag_ids=[category_tags["Tatlı"]],
        price_band=PriceBand.low,
        image_urls=[
            _venue_photo("tatli-kose-1.jpg"),
            _venue_photo("tatli-kose-2.jpg"),
            _venue_photo("tatli-kose-3.jpg"),
        ],
        maps_url="https://www.google.com/maps?q=39.919,32.826",
    )

    _seed_review(
        venue_id=venue_kutuphane,
        username="ayse",
        text="Ders çalışmak için ideal, kahveleri de güzel.",
        created_at=datetime(2026, 6, 8, 10, 30, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_kutuphane,
        username="mehmet",
        text="Priz bol, sessiz ortam gerçekten işe yarıyor.",
        created_at=datetime(2026, 6, 9, 14, 15, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_kutuphane,
        username="emre",
        text="Hafta içi sabahları en sakin saatler, tavsiye ederim.",
        created_at=datetime(2026, 6, 11, 9, 0, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_bahce,
        username="zeynep",
        text="Filtre kahve çok başarılı, Bahçelievler'in en iyisi.",
        created_at=datetime(2026, 6, 7, 16, 45, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_bahce,
        username="can",
        text="Hafta sonu biraz kalabalık ama atmosfer güzel.",
        created_at=datetime(2026, 6, 10, 11, 20, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_bahce,
        username="fatma",
        text="Latte'si yumuşak ve dengeli, fiyatına göre çok iyi.",
        created_at=datetime(2026, 6, 12, 8, 50, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_kokteyl,
        username="elif",
        text="Akşam date için mükemmel, kokteyller özenli hazırlanıyor.",
        created_at=datetime(2026, 6, 6, 21, 0, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_kokteyl,
        username="burak",
        text="Müzik sesi biraz yüksek ama kokteyl kalitesi gerçekten top.",
        created_at=datetime(2026, 6, 9, 22, 30, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_kokteyl,
        username="kerem",
        text="Negroni harikaydı, servis de hızlıydı.",
        created_at=datetime(2026, 6, 13, 20, 15, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_tatli,
        username="deniz",
        text="Fiyat performans harika, baklavayı özellikle deneyin.",
        created_at=datetime(2026, 6, 8, 18, 0, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_tatli,
        username="selin",
        text="Küçük ama şirin bir yer, tatlılar her zaman taze.",
        created_at=datetime(2026, 6, 10, 15, 40, tzinfo=timezone.utc),
    )

    item = ModerationItem(
        id=new_id(),
        user_id="demo",
        content_type="photo",
        content_url="https://example.com/photo.jpg",
        status=ModerationStatus.pending,
    )
    store.moderation_items[item.id] = item
