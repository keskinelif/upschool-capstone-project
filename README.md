# gri. MVP

Bu repo, ayrik backend/frontend mimarisi ile MVP gelistirme iskeletini icerir.

## Servisler
- `backend/`: FastAPI API servisi (coklu client, iOS dahil)
- `frontend/`: Flutter istemci (ayri deploy)

## User Story Kapsami (MVP)
- Hibrit filtreleme (lokasyon + urun + vibe)
- Crowdsourced sinyaller (priz, internet/sessizlik, fiyat)
- Harita pinleme ve yol tarifi akisi
- Admin paneli icin mekan/tag/moderasyon/bulk import endpointleri
- NFR altyapisi: JWT, WebP pipeline simulasyonu, healthcheck, CI ayrimi

## Hizli Baslangic
### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```
