# gri. — Agent Instructions

Bu repo **gri.** MVP'sidir (Ankara mekan keşif, FastAPI + Flutter).

## Başlamadan önce oku

1. [prodocs/README.md](./prodocs/README.md) — indeks
2. Göreve göre: [architecture](./prodocs/architecture.md) | [api](./prodocs/api.md) | [ai-discover](./prodocs/ai-discover.md)

## Sabit kurallar

- LLM yalnızca backend'den (`GEMINI_API_KEY` client'ta yok)
- Mekanlar memory store'dan; AI mekan uydurmaz
- Pilot lokasyonlar: Tunalı, Bahçelievler
- UI: `DesignSystem.md` + `frontend/design-system-always.mdc`
- Backend değişikliği: `backend/fastapi.mdc` convention

## Lokal çalıştırma

Backend: `backend/start.ps1`  
Frontend: `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000`

Detay: [prodocs/local-dev.md](./prodocs/local-dev.md)

## Ürün kaynakları

- [PRD.md](./PRD.md)
- [Plan.md](./Plan.md)
