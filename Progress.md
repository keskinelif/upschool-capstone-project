# gri. — Progress Log

> Yapılan işler, alınan kararlar ve karşılaşılan sorunların kaydı.  
> Her önemli milestone veya oturum sonunda güncellenir.

Kaynak plan: [Plan.md](./Plan.md) · Ürün: [PRD.md](./PRD.md)

---

## Nasıl güncellenir?

Her girişte kısa tutun:

1. **Tarih** + ne yapıldı (1–3 madde)
2. **Karar** varsa → [Kararlar](#kararlar) tablosuna ekleyin
3. **Hata / öğrenilen** varsa → [Sorunlar ve çözümler](#sorunlar-ve-çözümler) bölümüne ekleyin

---

## Zaman çizelgesi

### 2026-06 — Proje başlangıcı

- `PRD.md` yazıldı; gri. vizyonu, pilot bölgeler (Tunalı, Bahçelievler), admin stratejisi tanımlandı.
- `Plan.md` PRD'den user story'lere bölündü; US3 (harita SDK) ve US5 (bulk import) bilinçli ertelendi.

### 2026-06 — MVP iskelet (commit: `f80b270`)

**Backend**
- FastAPI iskelet: auth (JWT), venues, tags, admin, contributions, map, system route'ları.
- `memory_store` seed: admin/demo kullanıcı, 3 pilot mekan, tag sistemi (product + vibe).

**Frontend**
- Flutter client iskelet; explore ekranı, API client, tema başlangıcı.

**Karar:** Gerçek DB yerine MVP'de memory store — hız için; deploy restart'ta seed'e döner.

---

### 2026-06 — Dokümantasyon reorganizasyonu (commit: `0d96e04`)

- `Plan.md`, `DesignSystem.md`, proje dokümanları düzenlendi.

---

### 2026-06 — Web auth + login (commit: `d56809c`)

- Flutter login ekranı eklendi.
- Backend CORS localhost/127.0.0.1 için açıldı (web auth).

**Karar:** Web deploy öncesi CORS production origin (Vercel) ayrıca eklenecek.

---

### 2026-06 — CI düzeltmeleri (commit: `2156ecb`)

- GitHub Actions frontend `flutter analyze` geçecek şekilde düzeltildi.

---

### 2026-06 — Keşif UX + Admin + AI keşif (commit: `023c9e7`)

**Backend**
- `POST /ai/discover` — Gemini (`gemini-2.5-flash`) structured JSON filtre + venue listesi.
- `services/llm/` (base, gemini, discover), keyword fallback (LLM hata / key yok).
- `venue_filter.py` — paylaşılan filtreleme; `routes_venues` refactor.
- Lokasyon alias: bahçeli/bahceli → Bahçelievler.
- `backend/.env.example`, `settings.py` absolute `.env` path.
- `start.ps1` — eski uvicorn süreçlerini temizleyip backend başlatma (Windows).

**Frontend**
- `HomeScreen`: kategori kartları + AI arama (`DiscoverSearchBar`).
- `AiDiscoverScreen`, `CategoryVenuesScreen` (2 sütun grid, filtre, favori).
- Admin: mekan CRUD, profil, favoriler ekranları.
- `status_states.dart` — loading / hata / boş / AI fallback banner.

**Dokümantasyon**
- `prodocs/` — ajan referans dosyaları (architecture, api, ai-discover, local-dev, …).
- `AGENTS.md` — kök agent giriş noktası.

**Güvenlik**
- `GEMINI_API_KEY` yalnızca `backend/.env` (gitignore); GitHub'a push edilmedi.
- `.env.example` boş şablon olarak repoda.

**Deploy kararı (henüz uygulanmadı)**
- Backend → **Render**
- Flutter web → **Vercel**

---

## Kararlar

| Tarih | Karar | Gerekçe |
|---|---|---|
| MVP | Memory store, kalıcı DB yok | Hız; Render restart'ta seed reset kabul edilebilir |
| MVP | US3 harita SDK ertelendi | Liste + `maps_url` linki yeterli |
| MVP | US5 bulk import ertelendi | Admin manuel CRUD yeterli |
| AI | Google Gemini, yalnızca backend | Güvenlik, structured JSON, Türkçe |
| AI | OpenRouter kullanılmaz | Brief kararı |
| AI | LLM mekan uydurmaz | Yalnızca filtre; venue listesi memory store'dan |
| AI | Fallback: keyword eşleştirme | 429 / key yok / hata → uygulama kırılmaz |
| Deploy | Render + Vercel | Ayrık backend/frontend; brief ile uyumlu |
| Secrets | Key repoya değil, Render panel + lokal `.env` | Brief güvenlik kuralı |

---

## Sorunlar ve çözümler

| Sorun | Neden | Çözüm |
|---|---|---|
| AI'da sürekli "kategori seçerek devam edebilirsin" | Eski uvicorn süreçleri `.env` okumadan port 8000'de kaldı | Zombie süreçleri kapat; `backend/start.ps1` kullan |
| Port 8000 dolu | Birden fazla backend başlatma (agent + manuel) | `start.ps1` veya `Get-NetTCPConnection` ile temizle |
| Agent terminal read-only | Cursor agent arka plan terminalleri kontrol edilemez | Backend'i kendi terminalinde çalıştır |
| Flutter hot restart CanvasKit hatası | Flutter Web bilinen bug | Tam restart (`q` + `flutter run`) veya `--web-renderer html` |
| `used_fallback: true` hızlı yanıt (~1.5 sn) | Gemini değil keyword fallback çalışıyor | Backend'in doğru süreç olduğunu `used_fallback: false` ile doğrula |
| API key chat'te paylaşıldı | Güvenlik riski | Google AI Studio'dan key rotate et |
| CORS (canlı deploy) | Şu an yalnızca localhost | Vercel URL backend CORS'a eklenmeli — **yapılmadı** |
| Seed az mekan | MVP demo verisi | Admin panelden mekan ekleme veya ileride DB |

---

### 2026-06 — Dokümantasyon: Progress + Tech Stack

- `Progress.md` eklendi — milestone, kararlar, sorun/çözüm günlüğü.
- `tech-stack.md` eklendi — teknoloji seçimleri, Render/Vercel/Gemini gerekçeleri, geliştirmede AI kullanımı.
- `README.md` güncellendi — onepager, lokal çalıştırma, deploy özeti, env güvenliği.

---

## Oturum notu şablonu

```markdown
### YYYY-MM-DD — Kısa başlık

- Yapılan: …
- Karar: …
- Sorun: … → Çözüm: …
```
