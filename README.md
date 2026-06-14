# gri.

Ankara odaklı (Tunalı, Bahçelievler) mekan keşif uygulaması. Kullanıcılar mekanları **niyet / vibe + kategori + lokasyon** ile keşfeder — kategori butonları veya doğal dil araması (AI) ile.

**Stack:** FastAPI backend · Flutter frontend · Google Gemini (yalnızca backend)

---

## Ne yapar? (MVP — güncel)

- Ana sayfa: “Bugün ne yapmak istiyorsun?” + **AI arama** + kategori kartları
- Kategori / AI sonuçları: 2 sütun mekan grid’i, lokasyon & fiyat filtresi
- Admin: mekan ekleme/düzenleme, yorum moderasyonu, Google Maps linki
- Mekan detay: galeri, fiyat bandı, yorumlar, harici Maps
- JWT auth (login, kayıt, admin yönlendirme)
- Favoriler (istemci tarafı)

**Pilot bölgeler:** Tunalı, Bahçelievler

**Canlı (MVP):**
- Uygulama: https://gri-web-ten.vercel.app
- API: https://upschool-capstone-project.onrender.com

---

## Repo yapısı

```
gridot/
├── backend/          FastAPI API (Render)
├── frontend/         Flutter client (Vercel)
├── prodocs/          AI ajan referans dosyaları
├── PRD.md            Ürün gereksinimleri
├── Plan.md           User story planı
├── tech-stack.md     Teknoloji seçimleri
├── Progress.md       İlerleme günlüğü
└── DesignSystem.md   UI kuralları
```

---

## Lokal çalıştırma

### 1. Backend

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
copy .env.example .env          # GEMINI_API_KEY değerini .env'e yazın
.\start.ps1                     # Windows — eski süreçleri temizler
```

API: http://127.0.0.1:8000 · Docs: http://127.0.0.1:8000/docs

### 2. Frontend

```powershell
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

### Demo hesaplar

| Kullanıcı | Şifre | Rol |
|---|---|---|
| `admin` | `admin123` | Admin |
| `demo` | `demo123` | Kullanıcı |
| `ayse` … `kerem` | `{kullanıcı}123` | Demo kullanıcı (11 kişi) |

---

## Ortam değişkenleri ve güvenlik

Gerçek API anahtarları **asla GitHub'a yüklenmemelidir.**

| Dosya / yer | İçerik |
|---|---|
| `backend/.env` | Lokal secret'lar (gitignore) |
| `backend/.env.example` | Boş şablon (repoda) |
| Render panel | `GEMINI_API_KEY`, `JWT_SECRET`, `LLM_MODEL` |

```env
GEMINI_API_KEY=...
LLM_MODEL=gemini-2.5-flash
JWT_SECRET=uzun-rastgele-deger
```

---

## Deploy (Render + Vercel)

```
Flutter Web (Vercel)  →  FastAPI (Render)  →  Gemini API
```

**Canlı URL'ler:** [gri-web-ten.vercel.app](https://gri-web-ten.vercel.app) · [API /health](https://upschool-capstone-project.onrender.com/health)

### Backend — Render

1. GitHub repo bağla → **Web Service** → root: `backend`
2. Runtime: **Python 3** (Docker değil)
3. Build: `pip install -r requirements.txt`
4. Start: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Instance: **Free** · Health check: `/health`
6. Environment: `GEMINI_API_KEY`, `JWT_SECRET`, `LLM_MODEL`
7. Git push → Render **auto-deploy**

### Frontend — Vercel (CLI)

Vercel Flutter build etmez; lokal build + CLI önerilir:

```powershell
cd frontend
flutter build web --release --dart-define=API_BASE_URL=https://upschool-capstone-project.onrender.com
cd build/web
npx.cmd vercel --prod
```

> CORS: `main.py` içinde `*.vercel.app` izinli.

### Mekan fotoğrafları

Seed görseller `backend/static/venues/` klasöründe; URL'ler GitHub raw link. Detay: [backend/static/venues/README.md](./backend/static/venues/README.md)

Detay: [tech-stack.md](./tech-stack.md) · [prodocs/local-dev.md](./prodocs/local-dev.md)

---

## Dokümantasyon

| Dosya | Açıklama |
|---|---|
| [PRD.md](./PRD.md) | Ürün anayasası |
| [Plan.md](./Plan.md) | User story yol haritası |
| [tech-stack.md](./tech-stack.md) | Teknoloji ve gerekçeler |
| [Progress.md](./Progress.md) | Kararlar ve sorun günlüğü |
| [DesignSystem.md](./DesignSystem.md) | UI token'ları |
| [prodocs/](./prodocs/) | AI ajan referansları |
| [AGENTS.md](./AGENTS.md) | Agent giriş noktası |

---

## CI

- `backend-ci.yml` — Python compile
- `frontend-ci.yml` — `flutter analyze`

---

## Sıradaki adımlar

- [x] Backend CORS → Vercel origin
- [x] Canlı deploy (Render + Vercel)
- [ ] Kalıcı veritabanı (memory store yerine)
- [ ] Frontend GitHub otomatik deploy (opsiyonel)

Capstone · [upschool-capstone-project](https://github.com/keskinelif/upschool-capstone-project)
