# gri. backend

FastAPI tabanli MVP API servisi.

## Ozellikler
- JWT login + refresh token rotasyonu
- Admin rol veya allowlist IP ile korunan admin endpointleri
- Mekan/etiket yonetimi ve hibrit filtreleme
- Crowdsourcing katkilari + ozet endpointi
- Moderasyon ve CSV bulk import
- WebP pipeline simulasyonu ve healthcheck

## Calistirma
```bash
python -m venv .venv
.venv\\Scripts\\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Varsayilan Kullanici
- admin / admin123
- demo / demo123
