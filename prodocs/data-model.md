# Veri Modeli

## Kategoriler (product tags)

Sabit liste — `backend/app/db/memory_store.py` → `CATEGORIES`:

- Study Date
- F/P Yemek
- Kahve
- Romantik Date/ Kokteyl
- Tatlı

Frontend mirror: `frontend/lib/constants/categories.dart`

## Lokasyonlar

Pilot: **Tunalı**, **Bahçelievler** (`settings.pilot_areas`)

Kullanıcı kısaltmaları (AI + fallback):

| Yazım | Canonical |
|---|---|
| bahçeli, bahceli | Bahçelievler |
| tunalı, tunali | Tunalı |

## Venue

```python
{
  "id": "uuid",
  "name": str,
  "area": str,           # Tunalı | Bahçelievler
  "lat": float,
  "lng": float,
  "description": str,
  "tag_ids": [str],
  "price_band": "₺" | "₺₺" | "₺₺₺",
  "image_url": str | null,
  "maps_url": str | null
}
```

## Tag

```python
{
  "id": "uuid",
  "name": str,
  "type": "product" | "vibe",
  "is_active": bool
}
```

Seed vibe örnekleri: `Ders Çalışma`, `Sessiz`

## Filtreleme mantığı

- `product_tags` ve `vibe_tags` **AND** (venue tüm istenen etiketlere sahip olmalı)
- `location` exact match (case-insensitive)
- Paylaşılan fonksiyon: `backend/app/services/venue_filter.py`

## Seed admin kullanıcı

- `admin` / `admin123` (is_admin: true)
- `demo` / `demo123`
