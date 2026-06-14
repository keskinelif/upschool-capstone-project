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
        name="V24 Coffee Club",
        area="Tunalı",
        lat=39.9044246,
        lng=32.8613693,
        description="Renkli ve sıradışı bir iç mekan.",
        tag_ids=[category_tags["Study Date"], category_tags["Kahve"], tag_study_vibe, tag_quiet_vibe],
        price_band=PriceBand.medium,
        image_urls=[
            _venue_photo("v24-1.png"),
            _venue_photo("v24-2.png"),
            _venue_photo("v24-3.png"),
        ],
        maps_url="https://www.google.com/maps/place/V24+Coffee+Club/@39.9044062,32.8615724,15z/data=!4m6!3m5!1s0x14d34f1da2fc0527:0xd22fa5184e229224!8m2!3d39.9044246!4d32.8613693!16s%2Fg%2F11y9kpkx5m!5m1!1e2?authuser=0&entry=ttu&g_ep=EgoyMDI2MDYxMC4wIKXMDSoASAFQAw%3D%3D",
    )
    venue_bahce = _seed_venue(
        name="respublika",
        area="Tunalı",
        lat=39.905124,
        lng=32.8649269,
        description="Özel kahve çeşitleri ve sakin atmosfer.",
        tag_ids=[category_tags["Kahve"]],
        price_band=PriceBand.low,
        image_urls=[
            _venue_photo("respublika-1.png"),
            _venue_photo("respublika-2.png"),
            _venue_photo("respublika-3.png"),
        ],
        maps_url="https://www.google.com/maps/place/respublika/@39.9051054,32.8648156,3a,75y,90t/data=!3m7!1e2!3m5!1sCIABIhCZNjqqGgXXo7zCCqJI79xC!2e10!3e12!7i4032!8i3024!4m11!1m2!2m1!1sstudy!3m7!1s0x14d34fb40f9f763d:0xdc9a77d81e27eaf6!8m2!3d39.905124!4d32.8649269!10e5!15sCgVzdHVkeVoHIgVzdHVkeZIBBGNhZmWaAURDaTlEUVVsUlFVTnZaRU5vZEhsalJqbHZUMnBDYkZoNmJEQmlSbEkyVGxVeFZtTXlkRkpPVlRGcVdEQTBOR0pJWXhBQuABAPoBBAgREDw!16s%2Fg%2F11rg38mt61!5m1!1e2?authuser=0&entry=ttu&g_ep=EgoyMDI2MDYxMC4wIKXMDSoASAFQAw%3D%3D",
    )
    venue_kokteyl = _seed_venue(
        name="Piccolo Cocktails & More",
        area="Tunalı",
        lat=39.895031,
        lng=32.855668,
        description="Romantik akşam kokteylleri.",
        tag_ids=[category_tags["Romantik Date/ Kokteyl"]],
        price_band=PriceBand.high,
        image_urls=[
            _venue_photo("piccolo-1.png"),
            _venue_photo("piccolo-2.png"),
            _venue_photo("piccolo-3.png"),
        ],
        maps_url="https://www.google.com/maps/place/Piccolo+Cocktails+%26+More/@39.895031,32.855668,17z/data=!4m6!3m5!1s0x14d34f79575b4b4d:0x47bd3af3784906cc!8m2!3d39.895031!4d32.855668!16s%2Fg%2F11yfvbpbtg!5m1!1e2?authuser=0&entry=ttu&g_ep=EgoyMDI2MDYxMC4wIKXMDSoASAFQAw%3D%3D",
    )
    venue_tatli = _seed_venue(
        name="Suflabs",
        area="Bahçelievler",
        lat=39.9220226,
        lng=32.8251176,
        description="Uygun fiyat ve lezzetli sufle çeşitleri.",
        tag_ids=[category_tags["Tatlı"]],
        price_band=PriceBand.low,
        image_urls=[
            _venue_photo("suflabs-1.png"),
            _venue_photo("suflabs-2.png"),
            _venue_photo("suflabs-3.png"),
        ],
        maps_url="https://www.google.com/maps/place/Suflabs/@39.9211072,32.825178,17z/data=!4m15!1m8!3m7!1s0x14d34f0d7e07ad4f:0x2b874c753b7cdced!2sSuflabs!8m2!3d39.9220226!4d32.8251176!10e5!16s%2Fg%2F11sxwzn_gj!3m5!1s0x14d34f0d7e07ad4f:0x2b874c753b7cdced!8m2!3d39.9220226!4d32.8251176!16s%2Fg%2F11sxwzn_gj!5m1!1e2?authuser=0&entry=ttu&g_ep=EgoyMDI2MDYxMC4wIKXMDSoASAFQAw%3D%3D",
    )
    venue_fp = _seed_venue(
        name="Çeyrek",
        area="Tunalı",
        lat=39.907,
        lng=32.862,
        description="Fiyat performans odaklı lezzetli burger ve atıştırmalıklar.",
        tag_ids=[category_tags["F/P Yemek"]],
        price_band=PriceBand.low,
        image_urls=[
            _venue_photo("çeyrek-1.png"),
            _venue_photo("çeyrek-2.png"),
            _venue_photo("çeyrek-3.png"),
        ],
        maps_url="https://www.google.com/maps?q=39.907,32.862",
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
    _seed_review(
        venue_id=venue_fp,
        username="mehmet",
        text="Fiyatına göre porsiyon çok iyi, burgerleri doyurucu.",
        created_at=datetime(2026, 6, 11, 13, 0, tzinfo=timezone.utc),
    )
    _seed_review(
        venue_id=venue_fp,
        username="can",
        text="Öğle arası hızlı ve uygun fiyatlı bir seçenek.",
        created_at=datetime(2026, 6, 12, 12, 30, tzinfo=timezone.utc),
    )

    item = ModerationItem(
        id=new_id(),
        user_id="demo",
        content_type="photo",
        content_url="https://example.com/photo.jpg",
        status=ModerationStatus.pending,
    )
    store.moderation_items[item.id] = item
