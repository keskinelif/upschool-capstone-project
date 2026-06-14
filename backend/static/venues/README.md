# Mekan fotoğrafları

Bu klasördeki `.jpg` dosyaları seed mekan görselleri için kullanılır.

## Dosya adları

| Mekan | Dosyalar |
|---|---|
| Kütüphane Kafe | `kutuphane-kafe-1.jpg` … `-3.jpg` |
| Bahçe Espresso | `bahce-espresso-1.jpg` … `-3.jpg` |
| Gece Kokteyl | `gece-kokteyl-1.jpg` … `-3.jpg` |
| Tatlı Köşe | `tatli-kose-1.jpg` … `-3.jpg` |

## Kendi fotoğrafını koymak

1. Aynı dosya adıyla fotoğrafı bu klasöre kopyala (eski dosyanın üzerine yaz).
2. `git add backend/static/venues/` → commit → push.
3. Render backend otomatik güncellenir (restart sonrası seed yüklenir).

URL'ler `memory_store.py` içindeki `_venue_photo(...)` ile GitHub raw linkine bağlıdır.
