# Mekan Keşif Platformu — Design System v1.0

> Monokromatik gri palet üzerine inşa edilmiş, editorial ton. Mobil-first, responsive web uygulaması için.

---

## İçindekiler

1. [Renk Paleti](#1-renk-paleti)
2. [Tipografi](#2-tipografi)
3. [Boşluk Sistemi](#3-boşluk-sistemi)
4. [Border Radius](#4-border-radius)
5. [Butonlar](#5-butonlar)
6. [Badge & Durum Etiketleri](#6-badge--durum-etiketleri)
7. [Puan & Değerlendirme](#7-puan--değerlendirme)
8. [Mekan Kartları](#8-mekan-kartları)
9. [Harita Pinleri](#9-harita-pinleri)
10. [Form Bileşenleri](#10-form-bileşenleri)
11. [Navigasyon](#11-navigasyon)
12. [Değerlendirme Kartı](#12-değerlendirme-kartı)
13. [Durum Ekranları](#13-durum-ekranları)
14. [İkon Seti](#14-i̇kon-seti)
15. [CSS Değişkenleri (Token Referansı)](#15-css-değişkenleri-token-referansı)

---

## 1. Renk Paleti

### Temel Gri Skalası

| Token | Renk | Hex | Kullanım |
|---|---|---|---|
| `--color-bg` | ![#f4f4f4](https://via.placeholder.com/12/f4f4f4/000000?text=+) | `#f4f4f4` | Sayfa arka planı, input arka planı |
| `--color-border` | ![#d3d4d6](https://via.placeholder.com/12/d3d4d6/000000?text=+) | `#d3d4d6` | Kenarlıklar, ayraçlar |
| `--color-muted` | ![#a8aaad](https://via.placeholder.com/12/a8aaad/000000?text=+) | `#a8aaad` | Soluk metin, yer tutucu, ikon |
| `--color-secondary` | ![#7b7e82](https://via.placeholder.com/12/7b7e82/000000?text=+) | `#7b7e82` | İkincil metin, meta bilgi |
| `--color-primary` | ![#232529](https://via.placeholder.com/12/232529/000000?text=+) | `#232529` | Birincil metin, buton, başlık |

### Aksanlı (Semantik) Renkler

| Amaç | Arka Plan | Metin | Kullanım |
|---|---|---|---|
| Başarı / Açık | `#e8f5e9` | `#2e7d32` | Mekan açık durumu |
| Hata / Kapalı | `#fce4ec` | `#c62828` | Mekan kapalı durumu |
| Uyarı / Puan | `#fff8e1` | `#b45309` | Yıldız puanı, dikkat |
| Bilgi | `#e3f2fd` | `#1565c0` | Öne çıkan içerik |

### Kullanım Kuralları

- Renkler **anlam taşır**, dekorasyon için kullanılmaz.
- Açık/kapalı durumları hariç tüm UI **gri skalası** üzerine kuruludur.
- Semantik renkler yalnızca küçük badge, etiket ve durum göstergelerinde kullanılır.

---

## 2. Tipografi

### Font Ailesi

| Tür | Font | Kullanım |
|---|---|---|
| Display | `DM Serif Display` | Sayfa başlıkları, hero alanı, editorial vurgu |
| UI | `DM Sans` | Tüm arayüz metinleri, form, navigasyon |

```css
font-family: 'DM Serif Display', serif;   /* display */
font-family: 'DM Sans', sans-serif;       /* UI */
```

### Tipografik Hiyerarşi

| Seviye | Font | Boyut | Ağırlık | Renk | Kullanım |
|---|---|---|---|---|---|
| Display | DM Serif Display | 36px | normal | `#232529` | Hero başlık |
| Display Italic | DM Serif Display | 28px | italic | `#7b7e82` | Vurgu, slogan |
| H1 | DM Sans | 24px | 600 | `#232529` | Sayfa başlığı |
| H2 | DM Sans | 20px | 500 | `#232529` | Bölüm başlığı |
| H3 | DM Sans | 16px | 600 | `#232529` | Kart başlığı |
| Body | DM Sans | 14px | 400 | `#232529` | Genel metin |
| Caption | DM Sans | 12px | 400 | `#7b7e82` | Meta bilgi, tarih |
| Label | DM Sans | 11px | 600 | `#a8aaad` | Form etiketi (uppercase) |
| Micro | DM Sans | 10px | 400 | `#a8aaad` | Yardımcı metin |

### Tipografi Kuralları

- Satır yüksekliği (body): `1.6`
- Display başlıklar: `letter-spacing: -0.025em`
- Form etiketleri: `text-transform: uppercase; letter-spacing: 0.06em`
- Minimum font boyutu: **10px**

---

## 3. Boşluk Sistemi

4px tabanlı, çarpan sistemi.

| Token | Değer | Kullanım |
|---|---|---|
| `--sp-1` | `4px` | İkon-metin arası, badge iç boşluk |
| `--sp-2` | `8px` | Tag arası, liste elemanı gap |
| `--sp-3` | `12px` | Kart iç elemanlar arası |
| `--sp-4` | `16px` | Kart padding, form gap |
| `--sp-5` | `20px` | Form bölüm arası |
| `--sp-6` | `24px` | Bölüm içi padding |
| `--sp-8` | `32px` | Sayfa bölüm arası margin |
| `--sp-10` | `40px` | Büyük bölüm boşlukları |
| `--sp-12` | `48px` | Sayfa üst/alt padding |

---

## 4. Border Radius

| Token | Değer | Kullanım |
|---|---|---|
| `--r-sm` | `6px` | Küçük etiket, input |
| `--r-md` | `10px` | Standart bileşen |
| `--r-lg` | `16px` | Kart, modal |
| `--r-xl` | `24px` | Büyük kart, panel |
| `--r-full` | `999px` | Pill buton, chip, avatar |

---

## 5. Butonlar

### Tipler

| Tip | Arka Plan | Kenarlık | Metin | Kullanım |
|---|---|---|---|---|
| Primary | `#232529` | — | `#ffffff` | Ana eylem (Mekan Ekle, Kaydet) |
| Secondary | transparent | `1.5px solid #232529` | `#232529` | İkincil eylem (Filtrele) |
| Ghost | transparent | `1.5px solid #d3d4d6` | `#7b7e82` | Pasif eylem (İptal) |
| Icon | `#f4f4f4` | — | `#232529` | Tek ikon aksiyonu |
| Tag | `#f4f4f4` | `1px solid #d3d4d6` | `#7b7e82` | Filtre / kategori seçici |
| Tag (aktif) | `#232529` | `#232529` | `#ffffff` | Seçili filtre |

### Boyutlar

| Boyut | Padding | Font | Kullanım |
|---|---|---|---|
| Default | `10px 20px` | 13px | Standart aksiyon |
| Small | `6px 14px` | 11px | Kart içi, inline |
| Icon | `0` (38×38px) | 16px | Favori, paylaş |

### Kurallar

- Tüm butonlar `border-radius: var(--r-full)` (pill form)
- Transition: `all 0.15s ease`
- Hover: opaklık %85 veya `background` bir ton açık/koyu
- Disabled: `opacity: 0.4; cursor: not-allowed`

---

## 6. Badge & Durum Etiketleri

| Tip | Arka Plan | Metin | Kullanım |
|---|---|---|---|
| Dark | `#232529` | `#ffffff` | Yeni, öne çıkan |
| Default | `#f4f4f4` | `#7b7e82` | Trend, genel |
| Success | `#e8f5e9` | `#2e7d32` | ● Açık |
| Error | `#fce4ec` | `#c62828` | ● Kapalı |
| Warning | `#fff8e1` | `#b45309` | Yakında kapanıyor |
| Info | `#e3f2fd` | `#1565c0` | Öne çıkan |
| Rating | `#232529` | `#ffffff` | ★ 8.4 (puan) |

```css
/* Badge temel stili */
.badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  font-weight: 600;
  padding: 3px 8px;
  border-radius: var(--r-full);
}
```

---

## 7. Puan & Değerlendirme

### Yıldız Sistemi

- 5 yıldız üzerinden, `0.5` artışlarla
- Dolu yıldız rengi: `#F59E0B`
- Boş yıldız rengi: `#d3d4d6`
- Font size: `12px` (liste), `16px` (detay)

### Puan Boyutları

| Boyut | Kullanım |
|---|---|
| Kart badge: `★ 8.4` | Grid/liste kartlarda köşe rozeti |
| Yıldız + sayı: `★★★★☆ 4.5` | Kart altı, kompakt gösterim |
| Skor breakdown | Mekan detay sayfası, kategori bazlı çubuk grafik |

### Skor Breakdown (Çubuk Grafik)

Mekan detay sayfasında 4 kriter gösterilir:

- **Lezzet** — ağırlık: %35
- **Servis** — ağırlık: %25
- **Ortam** — ağırlık: %25
- **Fiyat/Kalite** — ağırlık: %15

```css
/* Çubuk parça */
.score-bar-track {
  height: 6px;
  background: #f4f4f4;
  border-radius: 3px;
}
.score-bar-fill {
  height: 100%;
  background: #232529;
  border-radius: 3px;
}
```

---

## 8. Mekan Kartları

### Grid Kart (2 Sütun)

Keşfet ve kategori listelerinde kullanılır.

```
┌────────────────────┐
│   [Fotoğraf]  [★9.2]│  ← Köşe rozeti
│               [♡]  │  ← Favori butonu
├────────────────────┤
│ Mekan Adı          │
│ 1.2 km · Nişantaşı │
│ [İtalyan] [Pizza]  │  ← Kategori etiketleri
└────────────────────┘
```

**Özellikler:**
- Resim yüksekliği: `120px`
- `border-radius: var(--r-xl)` (24px)
- Kenarlık: `1px solid rgba(35,37,41,0.07)`
- Kart gölgesi: `0 1px 3px rgba(35,37,41,0.08)`

### Liste Kart (Tam Genişlik)

Yakınımda ve harita listesi görünümünde kullanılır.

```
┌──────────────────────────────────────┐
│ [Küçük  │ Mekan Adı          [★ 8.1]│
│  Fotoğ] │ Türk Mutfağı · Beyoğlu    │
│  64×64  │ ★★★★☆  ₺₺  [Açık]  📍0.8km│
└──────────────────────────────────────┘
```

**Özellikler:**
- Küçük fotoğraf: `64×64px`, `border-radius: var(--r-md)`
- `border-radius: var(--r-lg)` (16px)
- İç padding: `14px`

### Fiyat Gösterimi

| Sembol | Anlam |
|---|---|
| `₺` | Ekonomik (0–100₺) |
| `₺₺` | Orta (100–250₺) |
| `₺₺₺` | Üst segment (250₺+) |

---

## 9. Harita Pinleri

### Renk — Kategori Eşleşmesi

| Kategori | Renk | Hex |
|---|---|---|
| Restoran | Primary | `#232529` |
| Cafe | Secondary | `#7b7e82` |
| Bar & Gece Hayatı | Muted | `#a8aaad` |
| Fırın & Pastane | Border | `#d3d4d6` |

### Pin Yapısı

```
     ●         ← Yuvarlak üst (kategori rengi)
    ╱             ← Sivri alt
[Mekan Adı]    ← Altında küçük etiket (beyaz, pill)
```

```css
.map-pin {
  width: 32px;
  height: 32px;
  border-radius: 50% 50% 50% 0;
  transform: rotate(-45deg);
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
.map-pin-inner {
  transform: rotate(45deg); /* İkon dik durur */
}
```

### Küme (Cluster) Pinleri

- 2–4 mekan: sayı göster (örn. `3`)
- 5+ mekan: daha büyük, `+N` formatında
- Arka plan: `#232529`, metin: `#ffffff`

---

## 10. Form Bileşenleri

### Input Tipleri

| Tip | Kullanım |
|---|---|
| Text input | Mekan adı, adres, açıklama |
| Search input | Ana arama çubuğu (sol ikon ile) |
| Select / Dropdown | Kategori, şehir, sıralama |
| Textarea | Yorum, açıklama |
| Star rating input | Değerlendirme formu |
| File upload zone | Fotoğraf ekleme |

### Input Temel Stili

```css
.input {
  font-family: 'DM Sans', sans-serif;
  font-size: 14px;
  border: 1.5px solid #d3d4d6;
  border-radius: var(--r-md);
  padding: 10px 14px;
  background: #ffffff;
  color: #232529;
  outline: none;
  width: 100%;
  transition: border-color 0.15s;
}
.input:focus {
  border-color: #232529;
}
```

### Mekan Ekleme Formu Alanları

1. **Mekan Adı** — text input, arama destekli (autocomplete)
2. **Kategori** — select (Restoran / Cafe / Bar / Fırın / Diğer)
3. **Semt / İlçe** — text input
4. **Açıklama** — textarea (3 satır)
5. **Fotoğraf** — drag-and-drop yükleme alanı
6. **Puanınız** — 5 yıldız tıklanabilir giriş
7. **Yorum Metni** — textarea (isteğe bağlı)

### Değerlendirme Formu Alanları

1. **Lezzet** (1–10 slider veya yıldız)
2. **Servis** (1–10)
3. **Ortam** (1–10)
4. **Fiyat/Kalite** (1–10)
5. **Etiketler** — çoklu seçim (`Hızlı Servis`, `Kalabalık`, `Romantik`...)
6. **Yorum metni** — textarea
7. **Fotoğraf** — isteğe bağlı

---

## 11. Navigasyon

### Üst Navigasyon (Desktop & Mobil)

```
[lokma]          [🔍] [♡] [AK]
─────────────────────────────────
[Keşfet] [Yakınımda] [Harita] [Listelerim]
─────────────────────────────────
[Tümü] [Restoran] [Cafe] [Bar] [Fırın] [Vejetaryen] →
```

**Özellikler:**
- Logo: `DM Serif Display`, italic vurgu
- Sekmeler: aktif tab `background: #232529; color: #fff`
- Filtre bar: yatay kaydırılabilir, `overflow-x: auto; scrollbar: none`

### Alt Navigasyon (Mobil — Bottom Nav)

```
[⌂ Keşfet]  [🗺 Harita]  [⊕]  [♡ Favoriler]  [☰ Profil]
```

- Orta buton (`+`) büyük, yuvarlak, `background: #232529`
- Aktif öge: icon + label `#232529`, font-weight: 700
- Pasif öge: `#a8aaad`

### Filtre Chip'leri

```css
.filter-chip {
  flex-shrink: 0;
  font-size: 12px;
  font-weight: 500;
  padding: 7px 14px;
  border-radius: var(--r-full);
  border: 1.5px solid #d3d4d6;
  color: #7b7e82;
  background: #ffffff;
  white-space: nowrap;
}
.filter-chip.active {
  background: #232529;
  color: #ffffff;
  border-color: #232529;
}
```

---

## 12. Değerlendirme Kartı

### Yapı

```
┌─────────────────────────────────────────┐
│ [AK] Kullanıcı Adı          ★★★★☆ 8.2  │
│      3 gün önce                         │
├─────────────────────────────────────────┤
│ Yorum metni buraya gelir, servis ve     │
│ lezzet hakkında kısa değerlendirme...   │
├─────────────────────────────────────────┤
│ [✓ Hızlı Servis] [✓ Kaliteli] [✗ Kalabalık] │
└─────────────────────────────────────────┘
```

### Aspect Tag Renkleri

| Tip | Arka Plan | Metin | Kullanım |
|---|---|---|---|
| Pozitif | `#e8f5e9` | `#2e7d32` | `✓ Hızlı Servis` |
| Negatif | `#fce4ec` | `#c62828` | `✗ Kalabalık` |
| Nötr | `#f4f4f4` | `#7b7e82` | `Park Sorunu` |

### Avatar

- Boyut: `36px × 36px`, yuvarlak
- Arka plan: `#232529`
- İçerik: kullanıcı adının baş harfleri, beyaz, 12px, font-weight: 700

---

## 13. Durum Ekranları

| Durum | İkon | Başlık | Açıklama |
|---|---|---|---|
| Boş sonuç | 🔍 | Sonuç Bulunamadı | Filtrelerinizi değiştirmeyi deneyin |
| Yükleniyor | — | Skeleton animasyon | `background: linear-gradient(...)` |
| Hata | ⚠️ | Bağlantı Hatası | Tekrar dene butonu göster |
| İlk kullanım | 🗺 | Çevrenizi Keşfedin | Konum izni iste |

### Skeleton Loading

```css
.skeleton {
  background: linear-gradient(
    90deg,
    #f4f4f4 25%,
    #d3d4d6 50%,
    #f4f4f4 75%
  );
  background-size: 200% 100%;
  border-radius: 4px;
  animation: skeleton 1.5s ease infinite;
}

@keyframes skeleton {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

---

## 14. İkon Seti

Sistem boyunca kullanılan temel ikonlar:

| İkon | Anlam | Kullanım Yeri |
|---|---|---|
| 🍽 | Restoran | Kategori, harita pini |
| ☕ | Cafe | Kategori, harita pini |
| 🍺 | Bar | Kategori, harita pini |
| 🥐 | Fırın | Kategori, harita pini |
| 📍 | Konum | Mesafe, adres |
| ⭐ | Puan | Kart rozeti, form |
| ♥ | Favori | Kart, navigasyon |
| 🗺 | Harita | Navigasyon sekme |
| 🔍 | Arama | Üst navigasyon, input |
| ⊕ | Ekle | Bottom nav CTA |
| 🕐 | Saat | Çalışma saati |
| 💬 | Yorum | Değerlendirme sayısı |

**Kullanım Kuralları:**
- Navigasyon ikonları: `18px`
- Kart iç ikonlar: `14–16px`
- Kategori temsil ikonları (büyük): `28–32px`
- Renk: `#a8aaad` (pasif), `#232529` (aktif)

---

## 15. CSS Değişkenleri (Token Referansı)

```css
:root {
  /* Renkler */
  --color-bg:         #f4f4f4;
  --color-border:     #d3d4d6;
  --color-muted:      #a8aaad;
  --color-secondary:  #7b7e82;
  --color-primary:    #232529;
  --color-white:      #ffffff;

  /* Fontlar */
  --font-display: 'DM Serif Display', serif;
  --font-body:    'DM Sans', sans-serif;

  /* Boşluklar */
  --sp-1:  4px;
  --sp-2:  8px;
  --sp-3:  12px;
  --sp-4:  16px;
  --sp-5:  20px;
  --sp-6:  24px;
  --sp-8:  32px;
  --sp-10: 40px;
  --sp-12: 48px;

  /* Border Radius */
  --r-sm:   6px;
  --r-md:   10px;
  --r-lg:   16px;
  --r-xl:   24px;
  --r-full: 999px;

  /* Gölgeler */
  --shadow-sm: 0 1px 3px rgba(35,37,41,0.08);
  --shadow-md: 0 4px 16px rgba(35,37,41,0.12);

  /* Geçişler */
  --transition: all 0.15s ease;
}
```

---

## Responsive Davranış

### Breakpoint'ler

| İsim | Genişlik | Düzen |
|---|---|---|
| Mobile | `< 480px` | Tek sütun, bottom nav |
| Tablet | `480px – 768px` | 2 sütun grid, bottom nav |
| Desktop | `768px – 1200px` | 3 sütun grid, top nav |
| Wide | `> 1200px` | 4 sütun grid, top nav + sidebar |

### Kart Grid

```css
.venue-grid {
  display: grid;
  gap: 12px;
  grid-template-columns: 1fr;             /* mobile */
}

@media (min-width: 480px) {
  .venue-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width: 768px) {
  .venue-grid { grid-template-columns: repeat(3, 1fr); }
}

@media (min-width: 1200px) {
  .venue-grid { grid-template-columns: repeat(4, 1fr); }
}
```

### Navigasyon Geçişi

- `< 768px`: Bottom navigation göster, top nav gizle
- `≥ 768px`: Top navigation göster, bottom nav gizle

---

## Kullanım Prensipleri

1. **Hiyerarşi**: Her sayfada tek bir birincil eylem (Primary buton) olmalı.
2. **Boşluk**: Yoğun listelerde bile minimum `8px` gap korunmalı.
3. **Renk kısıtlaması**: Semantik renkler (yeşil/kırmızı) yalnızca gerçek durum göstergelerinde kullanılır; dekoratif amaçla kullanılmaz.
4. **Metin kesme**: Kart başlıklarında `text-overflow: ellipsis` zorunludur.
5. **Erişilebilirlik**: Tüm interaktif elemanlar klavye ile erişilebilir olmalı; minimum dokunma hedefi `44×44px`.
6. **Yükleme**: Liste görünümlerinde her zaman skeleton ekranı göster, boş ekran gösterme.
