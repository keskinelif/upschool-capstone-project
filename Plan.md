# gri. MVP Geliştirme Planı (Ayrık Backend/Frontend)

> PRD.md'den türetilmiş user story planı. Güncellemeler bu dosyada yapılır.

Kaynak doküman: [PRD.md](./PRD.md)

## Mimari Prensip

- Backend, iOS dahil birden fazla istemciye hizmet edecek bağımsız bir API ürünü olarak geliştirilecek.
- Frontend (Flutter client) backend'den tamamen ayrık deploy edilecek ve ayrı release takvimiyle yönetilecek.
- API sözleşmesi (request/response, versiyonlama, auth kuralları) clientlardan bağımsız korunacak.

## Kapsam ve Sıralama

- Önce backend temel veri modeli + auth + seed/admin altyapısı kurulacak.
- Sonra frontend keşif/filtreleme deneyimi API kontratına bağlanacak (liste odaklı; harita yok).
- Son fazda moderasyon, dinamik etiket ve NFR sertleştirme tamamlanacak.

## Kapsam Dışı (bu faz)

Aşağıdaki user story'ler bilinçli olarak ertelendi; MVP hızlandırmak için şu an yapılmayacak:

| # | User Story | Neden ertelendi |
|---|------------|-----------------|
| US3 | Harita pinleme ve yol tarifi | Google Maps SDK entegrasyonu zaman alıcı; liste tabanlı keşif yeterli |
| US5 | CSV/Excel bulk import | Admin manuel CRUD ile seed data yeterli; import sonraki faza |

---

## User Story 1 — Kullanıcı olarak vibe + ürün + lokasyon filtreleriyle mekan keşfetmek istiyorum

**Durum:** 🟡 Kısmen (backend iskelet + explore ekranı var)

**Hedef:** Kullanıcı `lokasyon + ürün + vibe` kombinasyonuyla sonuçları listeleyebilsin.

**Backend Planı:**

- Birleşik filtre endpoint'i tasarla (`location`, `productTags`, `vibeTags`, opsiyonel `priceBand`).
- `venues`, `tags`, `venue_tags` many-to-many sorgularını indeksli optimize et.
- Pilot bölgeler (`Tunalı`, `Bahçelievler`) dışını backend seviyesinde kısıtla.

**Frontend Planı (Ayrı Deploy):**

- Flutter'da çoklu seçim filtre UI'si (chip/dropdown) ve sonuç listesi ekranını oluştur.
- Boş sonuç ve hata durumları için standart ekranlar tanımla.

**Kabul Kriterleri:**

- Kombine filtreler doğru sonuç döndürür.
- API p95 yanıt süresi MVP hedefini karşılar.
- Filtre seçimi değişince sonuçlar tutarlı güncellenir.

---

## User Story 2 — Kullanıcı olarak mekanlara crowdsourced sinyaller eklemek istiyorum

**Durum:** 🔴 Bekliyor

**Hedef:** Kullanıcılar priz, internet/sessizlik ve fiyat bilgisi girebilsin.

**Backend Planı:**

- Değerlendirme/veri katkı modeli oluştur (`outletAvailable`, `wifiQuietScore`, `priceBand`, `userId`, `venueId`).
- Katkı gönderme endpoint'i ve doğrulama kurallarını ekle (1–5 slider, fiyat enum).
- Aggregate hesaplama ve temel rate-limit/anti-spam kontrollerini ekle.

**Frontend Planı (Ayrı Deploy):**

- Katkı formu ekranlarını oluştur (toggle, slider, fiyat seçimleri).
- Mekan detayında aggregate verileri kullanıcıya okunabilir biçimde göster.

**Kabul Kriterleri:**

- Geçersiz input reddedilir, geçerli input kaydedilir.
- Mekan detayında güncel aggregate veriler görünür.

---

## User Story 4 — Admin olarak mekanları manuel ekleyip etiketlemek istiyorum

**Durum:** 🟡 Kısmen (backend endpoint iskeleti var; admin UI yok)

**Hedef:** Küratörlü seed data kalitesini admin panelinden yönetmek.

**Backend Planı:**

- Admin auth/authorization akışını kur (admin rolü ve/veya IP kısıtı).
- Mekan CRUD + etiket ilişkilendirme endpoint'lerini ekle.
- Audit log (kim, ne zaman, neyi değiştirdi) temel kaydını ekle.

**Frontend Planı (Ayrı Deploy):**

- Admin panelinde mekan CRUD ekranı oluştur.
- Koordinat için manuel lat/lng alanları (harita seçici bu fazda yok — US3 ertelendi).

**Kabul Kriterleri:**

- Admin yeni mekan ekleyip etiketleyebilir.
- Yetkisiz kullanıcı admin endpoint'lerine erişemez.

---

## User Story 6 — Admin olarak kullanıcı içeriğini moderasyonla yönetmek istiyorum

**Durum:** 🔴 Bekliyor

**Hedef:** Fotoğraf/yorum içerikleri onay-red akışıyla kalite kontrolünden geçsin.

**Backend Planı:**

- İçerik durum modeli (`pending`, `approved`, `rejected`) tanımla.
- Moderasyon karar endpoint'leri + neden kodu + zaman damgası kaydı ekle.
- Kullanıcı tarafına yalnızca `approved` içerik servis et.

**Frontend Planı (Ayrı Deploy):**

- Admin moderasyon listesi ve karar ekranlarını geliştir.
- Bekleyen içerik metriklerini panelde görünür hale getir.

**Kabul Kriterleri:**

- Onaylanmayan içerik kullanıcıya görünmez.
- Moderasyon kararları izlenebilir şekilde loglanır.

---

## User Story 7 — Admin olarak kod değiştirmeden yeni vibe/ürün etiketi eklemek istiyorum

**Durum:** 🟡 Kısmen (tag endpoint iskeleti var)

**Hedef:** Dinamik etiket yönetimi ile ürün çevikliği.

**Backend Planı:**

- `tags` yönetimi için admin CRUD endpoint'leri ekle (`name`, `type`).
- Type güvenliği (`vibe`, `product`) ve soft delete kuralını uygula.

**Frontend Planı (Ayrı Deploy):**

- Filtre ve admin etiket ekranlarını dinamik etiket endpoint'ine bağla.

**Kabul Kriterleri:**

- Yeni etiket eklendiğinde filtrelerde kod değişmeden görünür.
- Etiket tipi doğrulaması bozuk veri girişini engeller.

---

## User Story 8 — Sistem olarak görselleri optimize edip güvenli ve ölçeklenebilir çalışmak istiyorum

**Durum:** 🟡 Kısmen (healthcheck, JWT iskelet, CI var; WebP/deploy eksik)

**Hedef:** NFR'leri MVP'de çalışır hale getirmek.

**Backend Planı:**

- Görsel upload pipeline'ını WebP dönüşüm + çoklu boyut üretimi ile kur.
- JWT access/refresh, refresh rotasyonu ve token iptal stratejisini tamamla.
- Admin için IP allowlist veya admin-scope JWT kısıtı uygula.
- Backend'i bağımsız servis olarak deploy et; healthcheck ve hata logları ekle.

**Frontend Planı (Ayrı Deploy):**

- Frontend'i backend'den bağımsız CI/CD hattı ile deploy et.
- API base URL, ortam değişkenleri ve release yönetimini client bağımsızlaştır.

**Kabul Kriterleri:**

- Yüklenen görseller WebP olarak servis edilir.
- Admin erişimi yetkisiz isteklerde engellenir.
- Servisler bağımsız deploy edilebilir ve sağlık kontrolleri çalışır.

---

## Önerilen Yol Haritası (daraltılmış MVP)

### Backend Track

- Sprint B1: Veri modeli (`venues`, `tags`, `venue_tags`), JWT, admin yetkilendirme.
- Sprint B2: Keşif filtre API'leri, dinamik etiket API.
- Sprint B3: Crowdsourcing, moderasyon.
- Sprint B4: WebP pipeline, güvenlik sertleştirme, deploy.

### Frontend Track (Flutter, Ayrı Deploy)

- Sprint F1: Keşif/listeleme UI, filtre bileşenleri, API entegrasyon iskeleti.
- Sprint F2: Crowdsourcing formları, mekan detay aggregate görünümü.
- Sprint F3: Admin ekranları (mekan CRUD, etiket yönetimi, moderasyon).
- Sprint F4: Release stabilizasyonu.

### Sonraki Faz (ertelenen)

- US3: Google Maps SDK, pinleme, yol tarifi.
- US5: CSV/Excel bulk import.
