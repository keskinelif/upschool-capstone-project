# prodocs — AI Ajan Referansları

Bu klasör, **Cursor / Copilot / diğer AI ajanlarının** gri. projesinde doğru karar vermesi için kısa, güncel referans dosyalarını içerir.

## Nasıl kullanılır?

1. **Yeni bir görev başlamadan önce** ilgili dosyayı oku.
2. **Kod değişikliği yaptıktan sonra** API, mimari veya AI akışı değiştiyse ilgili prodocs dosyasını güncelle.
3. Kök dizindeki [`AGENTS.md`](../AGENTS.md) bu klasöre yönlendirir — Cursor otomatik okuyabilir.

## Dosya indeksi

| Dosya | Ne zaman oku |
|---|---|
| [architecture.md](./architecture.md) | Genel mimari, klasör yapısı, deploy |
| [api.md](./api.md) | Endpoint sözleşmeleri, auth |
| [data-model.md](./data-model.md) | Mekan, etiket, kategori, seed |
| [ai-discover.md](./ai-discover.md) | Gemini keşif, fallback, env |
| [local-dev.md](./local-dev.md) | Lokal çalıştırma, sık hatalar |
| [conventions.md](./conventions.md) | Kod stili, dosya adlandırma |

## Repo'daki diğer kaynaklar

| Dosya | İçerik |
|---|---|
| [PRD.md](../PRD.md) | Ürün gereksinimleri |
| [Plan.md](../Plan.md) | User story planı |
| [DesignSystem.md](../DesignSystem.md) | Flutter UI token'ları |
| `backend/fastapi.mdc` | Backend Cursor kuralı |
| `frontend/flutter.mdc` | Frontend Cursor kuralı |
| `frontend/design-system-always.mdc` | UI her zaman uygula |

## Güncelleme kuralı

Yeni bir özellik eklendiğinde en az şunları güncelle:

- Yeni endpoint → `api.md`
- Yeni env değişkeni → `local-dev.md` + `ai-discover.md` (AI ise)
- Yeni ekran / widget kalıbı → `conventions.md`
