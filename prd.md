Master Product Requirements Document (PRD)

Proje Adı: gri.
Versiyon: MVP v1.1
Doküman Sahibi: Business & Technical Product Owners

1. Ürün Özeti ve Vizyon

gri., Ankara odağında geliştirilen, kullanıcıların mekanları sadece sundukları ürünlere (Pizza, Burger, Kahve) göre değil; o anki niyetlerine ve mekanın atmosferine (Vibe: Ders Çalışma, Date, Fiyat/Performans) göre keşfetmelerini sağlayan hibrit bir mekan bulma ve kitle kaynaklı (crowdsourced) değerlendirme platformudur.

2. Kapsam ve Coğrafi Sınırlar (MVP)

Pilot Bölgeler: İlk lansman ve veri toplama aşaması, hedef kitlenin yoğun olduğu Tunalı ve Bahçelievler lokasyonları ile sınırlandırılacaktır.

Seed Data (Çekirdek Veri): Bu pilot bölgeler için başlangıçta ~200 mekanlık veri sisteme manuel olarak entegre edilecektir.

Kapsam Dışı: Sistemin ilk aşamada optimize çalışması ve veri kirliliğini önlemek adına pilot bölgeler dışındaki lokasyonlar (örn. Sincan, Keçiören) MVP harita sınırlarına dahil edilmeyecektir. İlerleyen fazlarda kullanıcıların "Yeni Mekan Ekle" talepleriyle havuz genişletilecektir.

3. Mimari ve Teknoloji Yığını (Tech Stack)

Proje, dışa bağımlılığı (vendor lock-in) ortadan kaldıran ve tam veri kontrolü sağlayan bir altyapı üzerine kurulacaktır:

Mobil İstemci: Flutter veya React Native (iOS & Android).

Backend & API: FastAPI (Python) - Render üzerinde koşulacaktır.

Veritabanı: Bağımsız PostgreSQL (Lokasyon/Harita sorguları için PostGIS eklentisiyle).

Medya Depolama: Cloudflare R2 veya AWS S3.

Yetkilendirme (Auth): FastAPI üzerinde özel olarak yazılmış JWT (JSON Web Token) tabanlı sistem.

Harita Motoru (In-App Map): Google Maps SDK (Uygulama içi harita görüntüleme ve pinleme işlemleri için native kütüphaneler kullanılarak harita API maliyetleri sıfırlanacaktır).

4. Fonksiyonel Gereksinimler (Functional Requirements)

4.1. Kimlik Doğrulama (Authentication)

Mekanları listelemek ve haritada görmek anonim kullanıcılara açıktır.

Puan vermek, yorum yapmak ve yeni mekan önermek JWT tabanlı oturum açmayı zorunlu kılar.

4.2. Hibrit Filtreleme Sistemi (Ürün + Vibe)

Sistem, mekanları nesne (entity) olarak ele alacak ve çoklu etiketleme (multi-tagging) yapacaktır.

Ürün Etiketleri: Pizza, Hamburger, Döner, Diğer Ülke Mutfakları vb.

Vibe Etiketleri: Ders Çalışma, Date, Fiyat-Performans.

Kullanıcı aynı anda "Tunalı'da" + "Ders Çalışma (Vibe)" + "Hamburger (Ürün)" filtrelerini birlikte çalıştırabilmelidir.

4.3. Çok Boyutlu Kullanıcı Değerlendirme Modülü (Crowdsourcing)

Kullanıcılar, bir mekanın "vibe" özelliklerini doğrulamak için geri bildirimde bulunabilmelidir. Puanlama metrikleri kullanıcıyı yormayacak (low-friction) şekilde tasarlanmıştır:

Priz Durumu: Var / Yok (Boolean Toggle)

İnternet (Wi-Fi) Hızı: 1'den 5'e kadar (Yıldız/Slider)

Sessizlik Seviyesi: 1'den 5'e kadar (Yıldız/Slider)

Fiyat Seviyesi: ₺, ₺₺, ₺₺₺ (Sembolik 3'lü Seçim)

Medya: Kullanıcı kameradan veya galeriden mekana ait güncel fotoğraf yükleyebilmelidir.

4.4. Harita ve Konum Servisleri

Uygulama İçi Harita: Google Maps SDK kullanılarak postGIS üzerinden çekilen mekanlar harita üzerinde pinlenecektir.

Cihazdan alınan GPS koordinatları ile PostGIS üzerinden "Yakınımdakiler" sorgusu çalıştırılacaktır.

Yol Tarifi Mantığı: Mekan detay sayfasından cihazın yerleşik harita uygulamalarına (Apple/Google Maps) yol tarifi için çıkış yapılabilmelidir (Böylece pahalı Directions API maliyetlerinden kaçınılır).

5. Fonksiyonel Olmayan Gereksinimler (Non-Functional Requirements)

Performans: Filtreleme ve harita üzerinde pin render etme işlemleri 2 saniyenin altında gerçekleşmelidir.

Güvenlik: Kullanıcı şifreleri Bcrypt ile hashlenerek saklanacak; medya dosyalarına yetkisiz erişim CORS politikaları ve Signed URL'ler ile engellenecektir.

Tasarım Dili: "gri." ismine uygun; koyu mod (Dark Mode) destekli, minimalist ve bilgi hiyerarşisi net bir arayüz uygulanacaktır.