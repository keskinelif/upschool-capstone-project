# API Sözleşmesi

Base URL (lokal): `http://localhost:8000`

## Auth

| Method | Path | Auth | Açıklama |
|---|---|---|---|
| POST | `/auth/login` | — | `{ username, password }` → tokens |
| POST | `/auth/register` | — | `{ username, password }` → `{ username }` (giriş ayrı) |
| POST | `/auth/refresh` | refresh token | Yeni access token |

## Mekanlar

| Method | Path | Auth | Query / Body |
|---|---|---|---|
| GET | `/venues` | — | `location`, `product_tags[]`, `vibe_tags[]`, `price_band` |
| GET | `/venues/{id}` | — | Tek mekan detayı |
| POST | `/venues` | Admin JWT | `VenueCreate` |
| PATCH | `/venues/{id}` | Admin JWT | `VenueUpdate` |

`price_band`: `₺` \| `₺₺` \| `₺₺₺`

## Yorumlar

| Method | Path | Auth | Açıklama |
|---|---|---|---|
| GET | `/reviews/venue/{venue_id}` | — | Mekanın onaylı yorumları |
| POST | `/reviews` | JWT | `{ venue_id, text }` → `pending` yorum |

## Admin

| Method | Path | Auth | Açıklama |
|---|---|---|---|
| GET | `/admin/reviews/pending` | Admin JWT | Onay bekleyen yorumlar |
| GET | `/admin/reviews/venue/{venue_id}` | Admin JWT | Mekanın tüm yorumları |
| POST | `/admin/reviews/decision` | Admin JWT | `{ review_id, status }` onay/red |
| DELETE | `/admin/reviews/{review_id}` | Admin JWT | Yorumu sil |

## Etiketler

| Method | Path | Auth |
|---|---|---|
| GET | `/tags` | — |
| POST | `/tags` | Admin |
| PATCH | `/tags/{id}` | Admin |

Tag tipleri: `product`, `vibe`

## AI keşif

| Method | Path | Auth | Body |
|---|---|---|---|
| POST | `/ai/discover` | — | `{ "query": "..." }` |

Response:

```json
{
  "filters": {
    "location": "Bahçelievler",
    "product_tags": ["Kahve"],
    "vibe_tags": ["Sessiz"],
    "price_band": null
  },
  "venues": [ /* VenueResponse[] */ ],
  "summary": "Bahçelievler'de Kahve için 1 mekan bulundu.",
  "used_fallback": false
}
```

- `used_fallback: true` → Gemini başarısız, keyword fallback kullanıldı
- Mekanlar **yalnızca** memory store'daki gerçek kayıtlar; LLM mekan uydurmaz

## Sistem

| Method | Path |
|---|---|
| GET | `/health` |

## CORS (MVP)

`localhost` / `127.0.0.1` ve production için `https://*.vercel.app` (regex, `main.py`).
