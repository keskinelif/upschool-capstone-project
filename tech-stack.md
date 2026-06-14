# gri. — Tech Stack

> Kullanılan teknolojiler, servis seçim gerekçeleri ve geliştirme sürecinde yapay zekâ kullanımı.  
> Ürün bağlamı: [PRD.md](./PRD.md) · İlerleme: [Progress.md](./Progress.md)

---

## Mimari özet

```
┌─────────────────┐     HTTPS      ┌──────────────────┐     HTTPS      ┌─────────────┐
│  Flutter Web    │ ─────────────► │  FastAPI (API)   │ ─────────────► │ Gemini API  │
│  (Vercel)       │                │  (Render)        │                │ (Google)    │
└─────────────────┘                └──────────────────┘                └─────────────┘
        │                                    │
        │  API_BASE_URL (build-time)         │  GEMINI_API_KEY (env, gizli)
        └────────────────────────────────────┘
```

**Prensip:** Backend ve frontend ayrık deploy; istemciler yalnızca HTTP API kontratı ile konuşur.

---

## Frontend

| Teknoloji | Sürüm / not | Gerekçe |
|---|---|---|
| **Flutter** | SDK ≥3.3 | Tek codebase ile web + ileride iOS/Android; tutarlı UI, hızlı MVP iterasyonu |
| **Dart** | Flutter ile | Tip güvenliği, `http` ile hafif API client |
| **google_fonts** | ^6.2.1 | DesignSystem: DM Sans + DM Serif Display |
| **Material 3** | Flutter built-in | DesignSystem token'ları `gri_theme.dart` üzerinden |

**Deploy hedefi:** [Vercel](https://vercel.com) — statik Flutter web build (`frontend/build/web`).

**Build:**
```bash
flutter build web --dart-define=API_BASE_URL=https://<render-backend-url>
```

**Neden Vercel?**
- Flutter web çıktısı statik dosya; Vercel CDN + otomatik deploy (Git push)
- Backend'den bağımsız release; frontend sadece `API_BASE_URL` ile backend'e bağlanır
- Capstone / MVP için ücretsiz Hobby plan yeterli (build dakikası kotasına dikkat)

**Mobil (sonraki faz):** Aynı Flutter repo; `ios/` / `android/` klasörleri `flutter create .` ile eklenecek. PRD'deki Google Maps SDK native entegrasyonu US3 kapsamında.

**Bilinçli tercih edilmeyenler:**
- React/Next ayrı web client — çift codebase maliyeti
- Flutter'dan doğrudan Gemini — API key web bundle'a sızar

---

## Backend

| Teknoloji | Sürüm / not | Gerekçe |
|---|---|---|
| **FastAPI** | latest | Async, otomatik OpenAPI docs, Pydantic entegrasyonu |
| **Python** | 3.12 (Docker) / 3.14 (lokal) | Ekip hızı, AI/LLM SDK desteği |
| **Uvicorn** | ASGI server | Production + `--reload` geliştirme |
| **Pydantic v2** | schemas | Request/response doğrulama, Gemini JSON schema |
| **PyJWT** | auth | Access + refresh token (PRD) |
| **google-genai** | Gemini SDK | Resmi SDK; structured JSON output |
| **pydantic-settings** | `.env` yükleme | Lokal + Render env değişkenleri |

**Veri (MVP):** In-memory `memory_store.py` — PostgreSQL yok. Hızlı seed/demo; Render restart'ta veri sıfırlanır. Kalıcı DB sonraki faz.

**Deploy hedefi:** [Render](https://render.com) — Docker (`backend/Dockerfile`) veya Python web service.

**Neden Render?**
- PRD'de tanımlı; FastAPI + Docker doğrudan desteklenir
- Starter plan cold-start'i azaltır (free tier uyur)
- Env variables panelinden `GEMINI_API_KEY` güvenli yönetim
- Backend'i frontend deploy'undan bağımsız scale etme imkânı

**API yüzeyi (özet):**
- `/venues`, `/tags` — keşif ve filtreleme
- `/ai/discover` — doğal dil keşif
- `/auth/*` — JWT
- Admin: `/venues` POST/PATCH, `/tags`, `/admin/*`

---

## Yapay zekâ — ürün (runtime)

| Bileşen | Seçim | Gerekçe |
|---|---|---|
| **Provider** | Google Gemini API | Brief kararı; Türkçe iyi, structured JSON native |
| **Model** | `gemini-2.5-flash` | Hız/maliyet dengesi; MVP keşif için yeterli |
| **SDK** | `google-genai` | `response_json_schema` ile tip güvenli filtre |
| **Çağrı yeri** | Yalnızca FastAPI | Key client'ta olmaz; web güvenli |
| **Fallback** | Keyword eşleştirme | 429 / key yok / hata → uygulama kırılmaz |

**Akış:** Kullanıcı sorgusu → Gemini filtre JSON → `filter_venues()` → gerçek memory store kayıtları. LLM mekan uydurmaz.

**Reddedilen alternatifler:**
- **OpenRouter** — brief dışı; ek proxy katmanı
- **Flutter'dan LLM** — API key sızıntısı
- **LLM'in tek başına keşif** — küratörlü veri kalitesi bozulur

Detay: [prodocs/ai-discover.md](./prodocs/ai-discover.md)

---

## Yapay zekâ — geliştirme süreci

Projede geliştirme hızlandırmak ve tutarlılık için AI araçları kullanıldı.

| Araç / yapı | Kullanım |
|---|---|
| **Cursor (AI agent)** | Feature implementasyonu (AI keşif, HomeScreen, admin ekranları), debug, deploy sorun giderme |
| **prodocs/** | Ajanların bağlam kaybetmemesi için referans dosyaları (API, mimari, AI akışı) |
| **AGENTS.md** | Kök dizin agent giriş noktası; sabit kurallar (LLM backend-only, secrets) |
| **`.mdc` kuralları** | `backend/fastapi.mdc`, `frontend/flutter.mdc`, `design-system-always.mdc` — kod stili |
| **DesignSystem.md** | UI token'ları; agent'ın tutarlı arayüz üretmesi |

**AI ile yapılan işler (örnek):**
- `POST /ai/discover` backend katmanı (`services/llm/`, routes, fallback)
- Flutter arama UI + `AiDiscoverScreen` + `ApiClient.discoverWithAi`
- Lokasyon alias (bahçeli → Bahçelievler)
- `Progress.md`, `prodocs/`, `start.ps1`

**İnsan / ekip sorumluluğu:**
- PRD ve Plan kararları
- API key yönetimi (`.env`, rotate, Render panel)
- Seed mekan kalitesi ve admin veri girişi
- Deploy onayı (Vercel + Render)
- Güvenlik: secret'ların repoya girmemesi

---

## Altyapı ve DevOps

| Bileşen | Teknoloji | Gerekçe |
|---|---|---|
| **Kaynak kontrol** | Git + GitHub | `keskinelif/upschool-capstone-project` |
| **CI — backend** | GitHub Actions | `pip install` + `compileall` |
| **CI — frontend** | GitHub Actions | `flutter analyze` |
| **Container** | Docker (`backend/Dockerfile`) | Render deploy tekrarlanabilirliği |
| **Secrets** | `.env` (lokal), Render/Vercel panel (canlı) | Brief: key'ler repoda değil |
| **CORS** | FastAPI middleware | MVP: localhost; production: Vercel origin eklenecek |

---

## Tasarım sistemi

| Kaynak | Kullanım |
|---|---|
| [DesignSystem.md](./DesignSystem.md) | Renk, tipografi, spacing, component kuralları |
| `frontend/lib/theme/gri_theme.dart` | Flutter token implementasyonu |
| Monokromatik gri palet + DM Sans / DM Serif Display | Editorial, mobil-first |

---

## Ortam değişkenleri

| Değişken | Nerede | Açıklama |
|---|---|---|
| `GEMINI_API_KEY` | `backend/.env`, Render | Gemini API (gizli) |
| `LLM_MODEL` | `backend/.env`, Render | Default: `gemini-2.5-flash` |
| `JWT_SECRET` | `backend/.env`, Render | Production'da güçlü değer zorunlu |
| `PILOT_AREAS` | Opsiyonel | Default: `Tunalı,Bahçelievler` |
| `API_BASE_URL` | Flutter build define | Backend URL (public, client'ta) |

Şablon: [backend/.env.example](./backend/.env.example)

---

## Sonraki faz (planlanan)

| Alan | Hedef teknoloji | Not |
|---|---|---|
| Veritabanı | PostgreSQL + SQLAlchemy | Memory store yerine kalıcılık |
| Harita | Google Maps SDK (Flutter) | US3 — native pinleme |
| Frontend deploy | Vercel production + custom domain | Staging önce |
| Backend deploy | Render Starter | CORS + env tamamlandıktan sonra |
| Görsel pipeline | WebP dönüşüm (backend) | US8 — kısmen iskelet var |

---

## İlgili dokümanlar

- [PRD.md](./PRD.md) — ürün gereksinimleri
- [Plan.md](./Plan.md) — user story yol haritası
- [Progress.md](./Progress.md) — karar ve sorun günlüğü
- [prodocs/](./prodocs/) — ajan referansları
