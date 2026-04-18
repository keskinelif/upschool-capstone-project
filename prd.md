📄 Master Engineering & Product Requirements Document (ERD/PRD v2.0)

Proje: gri.
Faz: MVP (Sprint 1-3)
Odak Bölgeler: Tunalı & Bahçelievler
Doküman Sahibi: Business & Technical Product Owners

1. BAŞARI METRİKLERİ VE KULLANICI PERSONASI (KPIs & Personas)

Sistemin başarılı sayılması için hedeflenen metrikler:

Performans KPI: API yanıt süresi 95. yüzdelikte (p95) < 250ms olmalıdır.

İşletme KPI: "Time-to-first-review" (Kullanıcının uygulamayı açtıktan sonra ilk yorumunu bırakma süresi) < 3 dakika.

Ana Persona ("Zeynep", 21): ODTÜ öğrencisi. Tunalı'da kahve içecek bütçesi var (₺₺) ama priz ve sessizlik arıyor. Arama hızı ve veri doğruluğu (gerçekten priz var mı?) onun için ölümcüldür.

2. KESİNLEŞTİRİLMİŞ VERİTABANI ŞEMASI (PostgreSQL)

Tablo 1: users (Kullanıcılar)

id: UUID (Primary Key, Auto-generated)

email: VARCHAR(255) (Unique, Indexed)

password_hash: VARCHAR(255) (Bcrypt ile şifrelenmiş)

created_at: TIMESTAMP (Default: NOW())

is_banned: BOOLEAN (Default: False) - Spam koruması için.

Tablo 2: venues (Mekanlar)

id: UUID (Primary Key)

name: VARCHAR(100) (Indexed)

location: GEOGRAPHY(Point, 4326) - PostGIS formatında, SRID 4326.

price_level: SMALLINT (Check: 1, 2, 3) - (₺, ₺₺, ₺₺₺)

is_active: BOOLEAN (Default: True) - Kapatılan mekanları soft-delete yapmak için.

Tablo 3: reviews (Değerlendirmeler / Crowdsourcing)

id: UUID (Primary Key)

user_id: UUID (Foreign Key -> users.id)

venue_id: UUID (Foreign Key -> venues.id)

vibe_type: VARCHAR(50) - (Örn: "Ders Çalışma", "Date")

has_sockets: BOOLEAN (Nullable)

quietness_score: SMALLINT (Check: 1-5, Nullable)

wifi_score: SMALLINT (Check: 1-5, Nullable)

created_at: TIMESTAMP

Tablo 4: tags & venue_tags (Çoklu Etiketleme - Many-to-Many)

tags: id (INT), name (VARCHAR), type (ENUM: 'PRODUCT', 'VIBE')

venue_tags: venue_id (UUID), tag_id (INT) - Bileşik Primary Key.

3. API SÖZLEŞMESİ (FastAPI Endpoints)

3.1. Mekan Arama ve Filtreleme (GET /api/v1/venues/search)

Açıklama: Haversine formülü ile mesafe hesaplanır.

Query Parameters:

lat (Float): Kullanıcının enlemi (Zorunlu)

lon (Float): Kullanıcının boylamı (Zorunlu)

radius_m (Int): Arama yarıçapı metre cinsinden (Default: 2000)

vibe (String): Vibe filtresi (Opsiyonel)

product_tags (List

$$String$$

): Ürün filtresi (Opsiyonel)

Örnek Başarılı Yanıt (200 OK):

{
  "data": [
    {
      "id": "uuid-1234",
      "name": "Kavaklıdere Roasters",
      "distance_m": 450,
      "price_level": 2,
      "average_quietness": 4.2,
      "tags": ["Kahve", "Ders Çalışma"]
    }
  ]
}


3.2. Değerlendirme Gönderme (POST /api/v1/reviews)

Headers: Authorization: Bearer <JWT_TOKEN>

Validation Kuralı: Kullanıcının koordinatı, mekana 100 metreden daha uzaksa 403 Forbidden (Geo-Spoofing Detected) hatası dönülür.

4. İŞ KURALLARI VE ALGORİTMALAR (Business Logic)

4.1. Varsayılan Sıralama (Default Ranking Algorithm)

Kullanıcı ana ekrana düştüğünde mekanlar, puan ve mesafenin harmanlandığı "gri. Skoruna" göre sıralanır.

Formül: GriScore = (Rating * 0.6) - ((Distance / 1000) * 0.4)

4.2. Güven Çürüme Algoritması (Time Decay on Reviews)

Veritabanı sorgularında, son 30 gün içinde girilen yorumların ağırlığı %100 kabul edilirken, 6 aydan eski yorumların sisteme etkisi matematiksel olarak %30'a düşürülür.

5. UÇ DURUMLAR VE HATA YÖNETİMİ (Edge Cases)

GPS İzni Reddedildi (Location Denied):

Tunalı Hilmi Caddesi (Lat: 39.9015, Lon: 32.8600) varsayılan merkez (mock center) olarak kabul edilir.

Ekranda uyarısı çıkarılır.

Ağ Bağlantısı Koptu (Offline State):

"Offline" ekranı çıkar. Filtreleme butonları deaktif (greyed-out) edilir.

Arama Sonucu Boş Döndü (Zero State):

"Aradığın kriterlerde bir mekan bulamadık ama şunlar ilgini çekebilir" diyerek filtrelerden biri (örn: Ürün) düşürülüp en yakın alternatifler listelenir.

6. ALTYAPI, CI/CD VE GÜVENLİK (DevOps)

6.1. Deployment Pipeline (Render)

GitHub main branch'ine yapılan her "push", GitHub Actions tarafından yakalanır. PyTest testleri geçerse Render üzerindeki FastAPI sunucusuna otomatik deploy edilir.

6.2. Güvenlik Duvarı ve Kısıtlamalar

Rate Limiting: IP bazlı kısıtlama konulacaktır. Bir IP adresi /venues/search endpoint'ine dakikada maksimum 60 istek atabilir.

Medya Yükleme (S3/R2): Uygulama fotoğrafları doğrudan Cloudflare R2/AWS S3'e yüklenir (FastAPI'den alınan Pre-signed URL ile).