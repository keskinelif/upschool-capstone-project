Master Product Requirements Document (PRD) - v1.2
Proje Adı: gri.

Versiyon: MVP v1.2

Doküman Sahibi: Business & Technical Product Owners

Durum: Güncellendi (Admin Paneli ve Manuel Veri Girişi Stratejisi Eklendi)

1. Ürün Özeti ve Vizyon
gri., Ankara odağında geliştirilen; kullanıcıların mekanları sadece sundukları ürünlere göre değil, o anki niyetlerine ve atmosferine (Vibe) göre keşfetmelerini sağlayan hibrit bir mekan bulma ve kitle kaynaklı (crowdsourced) değerlendirme platformudur.

2. Kapsam ve Veri Stratejisi (MVP)
Pilot Bölgeler: Tunalı ve Bahçelievler.

Küratörlü Seed Data: İlk aşamada ~200 mekan, "vibe" kalitesini korumak adına Admin Paneli üzerinden manuel olarak sisteme işlenecektir.

Kapsam Dışı: Pilot bölgeler dışı lokasyonlar ve otomatik Google Places veri çekme işlemleri (ilk fazda veri kirliliğini önlemek için devre dışıdır).

3. Mimari ve Teknoloji Yığını (Tech Stack)
Sistem, tamamen ayrık (decoupled) bir mikro-servis mimarisi mantığıyla kurgulanacaktır:

3.1. Frontend & İstemci
Mobil Uygulama: Flutter. Harita performansı, akıcı animasyonlar ve her iki platformda (iOS/Android) tutarlı görsel deneyim için seçilmiştir.

Harita Motoru: Google Maps SDK (Native). Uygulama içi pinleme ve lokasyon gösterimi için kullanılacaktır.

3.2. Backend & API
Framework: FastAPI (Python). Asenkron yapısı ve yüksek performanslı API süreçleri için tercih edilmiştir.

Altyapı: Render (Starter Plan). Cold-start sorununu önlemek ve düşük gecikme süresi sağlamak adına ücretli başlangıç planı kullanılacaktır.

Kimlik Doğrulama: JWT (Access & Refresh Token). Kullanıcı oturum sürekliliği ve güvenliği için çift token yapısı uygulanacaktır.

4. Fonksiyonel Gereksinimler
4.1. Kullanıcı Modülleri
Hibrit Filtreleme: Kullanıcı "Tunalı" + "Hamburger" + "Ders Çalışma" kombinasyonunu yapabilmelidir.

Crowdsourcing: * Priz: Var/Yok (Toggle)

İnternet/Sessizlik: 1-5 (Slider)

Fiyat: ₺, ₺₺, ₺₺₺

Harita: Google Maps SDK ile native pinleme ve cihazın kendi haritasına (Apple/Google) "Yol Tarifi" için yönlendirme.

4.2. Admin ve Operasyon Modülü (Yeni)
Bu modül, business tarafının veriyi yönetmesi için kritik öneme sahiptir:

Mekan Yönetimi: Manuel mekan ekleme, koordinat belirleme ve kürasyon etiketlerini (Vibe/Ürün) atama.

Toplu Veri Aktarımı (Bulk Import): Hazırlanan Excel/CSV listelerini tek tıkla veritabanına aktarma.

İçerik Moderasyonu: Kullanıcıların yüklediği fotoğrafları ve yazdığı yorumları onaylama/reddetme arayüzü.

Dinamik Etiket Yönetimi: Yeni "Vibe" veya "Ürün" kategorileri oluşturma (Örn: "Pet Friendly" etiketini kod değiştirmeden sisteme ekleme).

5. Veri Yapısı ve İlişkiler (Teknik Not)
Mekanlar ve Etiketler arasında Many-to-Many ilişkisi kurulacaktır.

venues tablosu: Ad, koordinat (geometry), açıklama.

tags tablosu: Etiket adı, tipi (Vibe veya Ürün).

venue_tags (Junction): Hangi mekanın hangi etiketlere sahip olduğu.

6. Fonksiyonel Olmayan Gereksinimler
Görsel Optimizasyonu: Admin veya kullanıcı tarafından yüklenen tüm görseller backend'de işlenerek düşük boyutlu WebP formatına çevrilmelidir (LCP performansını artırmak için).

Güvenlik: Admin paneli sadece yetkili IP'lere veya özel admin rolleriyle kısıtlanmış JWT'lere açık olacaktır.

Ölçeklenebilirlik: Frontend ve Backend ayrı servisler olduğu için, yoğunluk durumunda sadece API servisi scale edilebilecektir.