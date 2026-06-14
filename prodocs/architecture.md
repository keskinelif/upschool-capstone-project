# Mimari

## Özet

**gri.** — Ankara (Tunalı, Bahçelievler) odaklı mekan keşif uygulaması. Kullanıcı kategori veya doğal dil ile niyet/vibe + lokasyon ile keşfeder.

## Stack

| Katman | Teknoloji | Deploy |
|---|---|---|
| Backend | FastAPI, Python 3.14+, memory store (MVP) | Render |
| Frontend | Flutter (web + mobil hedef) | Ayrık |
| AI | Google Gemini API (`gemini-2.5-flash`) | **Sadece backend** |
| Auth | JWT access + refresh | — |

## Klasör yapısı

```
gridot/
├── backend/
│   ├── app/
│   │   ├── api/          # routes_*.py
│   │   ├── core/         # settings, security
│   │   ├── db/           # memory_store (MVP seed)
│   │   ├── schemas/      # Pydantic modeller
│   │   └── services/     # llm/, venue_filter
│   ├── .env              # GEMINI_API_KEY (gitignore)
│   └── start.ps1         # Temiz backend başlatma (Windows)
├── frontend/
│   └── lib/
│       ├── screens/
│       ├── services/     # api_client.dart
│       ├── widgets/
│       └── theme/
├── prodocs/              # ← Bu klasör (ajan referansları)
├── DesignSystem.md
├── PRD.md
└── Plan.md
```

## Veri akışı — AI keşif

```
Flutter → POST /ai/discover → discover.py
                              ├─ Gemini (structured JSON filtre)
                              ├─ fallback: keyword eşleştirme
                              └─ filter_venues() → memory_store
```

**Kural:** LLM asla Flutter'dan çağrılmaz. API key client'ta yok.

## MVP sınırları

- Veri: `memory_store.py` seed (gerçek DB yok)
- Pilot lokasyonlar: `Tunalı`, `Bahçelievler` (`settings.pilot_areas`)
- Harita SDK: sonraki faz (şimdilik `maps_url` linki)
- OpenRouter / frontend LLM: kullanılmaz
