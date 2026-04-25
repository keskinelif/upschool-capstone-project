# gri. frontend

Flutter istemcisi, backend API servisinden tamamen ayrik release edilir.

## Ayrik Deploy Prensibi
- Bu istemci backend ile yalnizca HTTP API kontratiyla haberlesir.
- Backend deploymentindan bagimsiz versiyonlanir.
- API adresi `API_BASE_URL` build define ile verilir.

## Calistirma
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

## MVP Akislari
- Kesif ve filtreleme ekrani
- API tabanli mekan listesi
- Bos durum, yukleniyor, hata gosterimi
