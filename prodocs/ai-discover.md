# AI Keşif (Gemini)

## Provider

| Ayar | Değer |
|---|---|
| Provider | Google Gemini API (OpenRouter yok) |
| Model | `gemini-2.5-flash` |
| SDK | `google-genai` |
| Env | `GEMINI_API_KEY`, `LLM_MODEL` |
| Çağrı yeri | `backend/app/services/llm/gemini.py` |

## Akış

1. `POST /ai/discover` → `discover.py`
2. Prompt'a mevcut kategori, vibe, lokasyon listesi eklenir
3. Gemini `response_json_schema` ile `DiscoverFilters` döner
4. Filtreler sanitize edilir → `filter_venues()`
5. Özet metni backend üretir

## Fallback

Gemini hata / key yok / 429 → `keyword_fallback()` devreye girer.

Response'ta `used_fallback: true`. Frontend banner'ı **yalnızca sonuç boşken** gösterir.

## Lokasyon alias'ları

`backend/app/services/llm/discover.py` → `_LOCATION_ALIASES`

## Bilinen sorunlar

| Sorun | Çözüm |
|---|---|
| Her zaman fallback banner | Eski uvicorn süreçleri `.env` okumadan 8000'de kalıyor |
| Gemini yavaş (~3–7 sn) | Normal; loading skeleton gösterilir |
| Key chat'te paylaşıldı | AI Studio'dan rotate et |

Backend temiz başlatma (Windows):

```powershell
cd backend
.\start.ps1
```

## Test sorguları

| Sorgu | Beklenen |
|---|---|
| Tunalı'da sessiz kafe | location: Tunalı, tags: Kahve, vibe: Sessiz |
| bahçeli tatlı | location: Bahçelievler, product: Tatlı |
| ucuz tatlı | product: Tatlı, price: ₺ |

## Kapsam dışı (bu faz)

- Flutter'dan doğrudan Gemini
- LLM'in mekan uydurması
- Admin moderasyon AI'ı
