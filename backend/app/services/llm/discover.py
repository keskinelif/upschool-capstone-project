import asyncio
import logging
import unicodedata

from app.core.settings import settings
from app.db.memory_store import CATEGORIES, store
from app.schemas.common import PriceBand, TagType
from app.schemas.venue import VenueFilter
from app.services.llm.base import DiscoverFilters
from app.services.llm.gemini import GeminiProvider
from app.services.venue_filter import filter_venues

logger = logging.getLogger(__name__)

_LOCATION_ALIASES: dict[str, str] = {
    "tunali": "Tunalı",
    "tunalı": "Tunalı",
    "bahcelievler": "Bahçelievler",
    "bahçelievler": "Bahçelievler",
    "bahceli": "Bahçelievler",
    "bahçeli": "Bahçelievler",
}

_PRODUCT_KEYWORDS: list[tuple[str, str]] = [
    ("ders calis", "Study Date"),
    ("study date", "Study Date"),
    ("calisma", "Study Date"),
    ("yemek", "F/P Yemek"),
    ("restoran", "F/P Yemek"),
    ("kahve", "Kahve"),
    ("kafe", "Kahve"),
    ("romantik", "Romantik Date/ Kokteyl"),
    ("kokteyl", "Romantik Date/ Kokteyl"),
    ("date", "Romantik Date/ Kokteyl"),
    ("tatli", "Tatlı"),
    ("tatlı", "Tatlı"),
    ("desert", "Tatlı"),
]

_VIBE_KEYWORDS: list[tuple[str, str]] = [
    ("sessiz", "Sessiz"),
    ("sakin", "Sessiz"),
    ("ders calis", "Ders Çalışma"),
    ("calisma", "Ders Çalışma"),
]

_PRICE_KEYWORDS: list[tuple[str, PriceBand]] = [
    ("ucuz", PriceBand.low),
    ("ekonomik", PriceBand.low),
    ("pahali", PriceBand.high),
    ("pahalı", PriceBand.high),
    ("luks", PriceBand.high),
    ("lüks", PriceBand.high),
]


def get_discover_context() -> dict:
    product_tags = [name for name in CATEGORIES]
    vibe_tags = sorted(
        tag["name"]
        for tag in store.tags.values()
        if tag["type"] == TagType.vibe and tag["is_active"]
    )
    locations = [area.strip() for area in settings.pilot_areas.split(",") if area.strip()]
    return {
        "locations": locations,
        "product_tags": product_tags,
        "vibe_tags": vibe_tags,
        "price_bands": [band.value for band in PriceBand],
    }


def _normalize(text: str) -> str:
    normalized = unicodedata.normalize("NFKD", text.casefold())
    return "".join(ch for ch in normalized if not unicodedata.combining(ch))


def _match_known_names(query: str, known: list[str]) -> list[str]:
    normalized_query = _normalize(query)
    matches: list[str] = []
    for name in known:
        if _normalize(name) in normalized_query:
            matches.append(name)
    return matches


def resolve_location(value: str | None, allowed_locations: list[str]) -> str | None:
    if not value or not value.strip():
        return None

    allowed = {loc.casefold(): loc for loc in allowed_locations}
    stripped = value.strip()
    if stripped.casefold() in allowed:
        return allowed[stripped.casefold()]

    normalized = _normalize(stripped)
    for alias, canonical in sorted(_LOCATION_ALIASES.items(), key=lambda item: len(item[0]), reverse=True):
        if normalized == alias or alias in normalized:
            return allowed.get(canonical.casefold())

    return None


def resolve_location_from_query(query: str, allowed_locations: list[str]) -> str | None:
    normalized = _normalize(query)
    for alias, canonical in sorted(_LOCATION_ALIASES.items(), key=lambda item: len(item[0]), reverse=True):
        if alias in normalized:
            return resolve_location(canonical, allowed_locations)

    for location in allowed_locations:
        if _normalize(location) in normalized:
            return location

    return None


def keyword_fallback(query: str) -> DiscoverFilters:
    normalized = _normalize(query)
    allowed_locations = [area.strip() for area in settings.pilot_areas.split(",") if area.strip()]
    location = resolve_location_from_query(query, allowed_locations)

    product_tags = _match_known_names(query, CATEGORIES)
    for keyword, category in _PRODUCT_KEYWORDS:
        if keyword in normalized and category not in product_tags:
            product_tags.append(category)

    vibe_tags = _match_known_names(
        query,
        [tag["name"] for tag in store.tags.values() if tag["type"] == TagType.vibe and tag["is_active"]],
    )
    for keyword, vibe in _VIBE_KEYWORDS:
        if keyword in normalized and vibe not in vibe_tags:
            vibe_tags.append(vibe)

    price_band = None
    for keyword, band in _PRICE_KEYWORDS:
        if keyword in normalized:
            price_band = band
            break

    return DiscoverFilters(
        location=location,
        product_tags=product_tags,
        vibe_tags=vibe_tags,
        price_band=price_band,
    )


def _sanitize_filters(raw: DiscoverFilters, context: dict) -> VenueFilter:
    allowed_products = set(context["product_tags"])
    allowed_vibes = set(context["vibe_tags"])

    location = resolve_location(raw.location, context["locations"])
    if not location:
        location = resolve_location_from_query(raw.location or "", context["locations"])

    product_tags = [tag for tag in raw.product_tags if tag in allowed_products]
    vibe_tags = [tag for tag in raw.vibe_tags if tag in allowed_vibes]
    price_band = raw.price_band if raw.price_band in PriceBand else None

    return VenueFilter(
        location=location,
        product_tags=product_tags,
        vibe_tags=vibe_tags,
        price_band=price_band,
    )


def build_summary(filters: VenueFilter, count: int, used_fallback: bool) -> str:
    if count == 0:
        base = "Aramanıza uygun mekan bulunamadı."
        if used_fallback:
            return f"{base} Şimdilik kategori seçerek devam edebilirsin."
        return base

    prefix = f"{filters.location}'de " if filters.location else ""
    tag_hint = ""
    if filters.product_tags:
        tag_hint = ", ".join(filters.product_tags[:2])
    elif filters.vibe_tags:
        tag_hint = ", ".join(filters.vibe_tags[:2])

    if tag_hint:
        return f"{prefix}{tag_hint} için {count} mekan bulundu."
    return f"{prefix}{count} mekan bulundu."


async def discover_venues(query: str) -> tuple[VenueFilter, list, str, bool]:
    cleaned = query.strip()
    if not cleaned:
        raise ValueError("Query cannot be empty.")

    context = get_discover_context()
    used_fallback = False
    raw_filters: DiscoverFilters

    try:
        provider = GeminiProvider()
        raw_filters = await asyncio.to_thread(provider.parse_discover_query, cleaned, context)
    except Exception as exc:
        logger.warning("LLM discover failed, using keyword fallback: %s", exc)
        raw_filters = keyword_fallback(cleaned)
        used_fallback = True

    filters = _sanitize_filters(raw_filters, context)
    if not filters.location:
        resolved = resolve_location_from_query(cleaned, context["locations"])
        if resolved:
            filters = filters.model_copy(update={"location": resolved})
    venues = filter_venues(
        location=filters.location,
        product_tags=filters.product_tags,
        vibe_tags=filters.vibe_tags,
        price_band=filters.price_band,
    )
    summary = build_summary(filters, len(venues), used_fallback)
    return filters, venues, summary, used_fallback
