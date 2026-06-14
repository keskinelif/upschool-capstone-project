# Lokal Geliştirme

## Backend

```powershell
cd backend
pip install -r requirements.txt
.\start.ps1
```

`start.ps1` eski uvicorn/python süreçlerini kapatıp tek instance başlatır.

Manuel:

```powershell
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

## Frontend

```powershell
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Web hot restart (`R`) bazen CanvasKit hatası verir → tam restart (`q` + tekrar run).

## Env değişkenleri (`backend/.env`)

| Değişken | Zorunlu | Açıklama |
|---|---|---|
| `GEMINI_API_KEY` | AI için | Google AI Studio |
| `LLM_MODEL` | Hayır | Default: `gemini-2.5-flash` |
| `JWT_SECRET` | Prod'da | Default: `change-me` |
| `PILOT_AREAS` | Hayır | Default: `Tunalı,Bahçelievler` |

`.env` gitignore'da — asla commit etme.

## Sağlık kontrolü

```powershell
Invoke-RestMethod http://127.0.0.1:8000/health
```

Gemini aktif mi:

```powershell
$r = Invoke-RestMethod -Uri http://127.0.0.1:8000/ai/discover -Method POST -ContentType application/json -Body '{"query":"bahceli tatli"}'
$r.used_fallback   # False = Gemini çalışıyor
```

## Render deploy

Environment:
- `GEMINI_API_KEY`
- `LLM_MODEL=gemini-2.5-flash`
- `JWT_SECRET` (güçlü değer)

## Sık hatalar

| Belirti | Neden | Çözüm |
|---|---|---|
| `used_fallback: true` sürekli | Eski backend süreci | `start.ps1` |
| Port 8000 dolu | Birden fazla uvicorn | Tüm python uvicorn süreçlerini kapat |
| CORS hatası (web) | Origin allowlist dar | `main.py` CORS güncelle |
| Flutter bağlanamıyor | Yanlış API URL | `--dart-define=API_BASE_URL=...` |
