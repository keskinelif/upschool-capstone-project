# Kod Kuralları

## Genel

- Minimal diff — istenmeyen refactor yok
- Mevcut isimlendirme ve dosya yapısına uy
- LLM / API key **asla** frontend'de

## Backend

- Route dosyaları: `routes_<domain>.py`
- Schema: `app/schemas/`
- İş mantığı: `app/services/` (route'ta kalın değil)
- Async route + sync Gemini → `asyncio.to_thread`
- Filtreleme: `venue_filter.filter_venues()` paylaş

## Frontend

- Tema: `GriTheme`, `GriColors`, `GriSpacing` — `DesignSystem.md`
- API: tek giriş `ApiClient`
- Durum ekranları: `status_states.dart` reuse
- Grid: `VenueGridCard`, `VenueGridSkeleton`

## AI keşif dosyaları

| Katman | Dosya |
|---|---|
| Route | `backend/app/api/routes_ai.py` |
| LLM | `backend/app/services/llm/` |
| Ekran | `frontend/lib/screens/ai_discover_screen.dart` |
| Arama | `frontend/lib/widgets/discover_search_bar.dart` |

## Commit / PR

- `.env`, API key commit etme
- prodocs güncelle: API veya AI akışı değiştiyse
