# Mekan fotoğrafları

Bu klasördeki görseller seed mekanlar için kullanılır. Dosya adını değiştirirsen `memory_store.py` içindeki `_venue_photo(...)` satırını da güncelle.

## Dosya adları

| Mekan | Dosyalar |
|---|---|
| V24 Coffee Club | `v24-1.png` … `v24-3.png` |
| respublika | `respublika-1.png` … `respublika-3.png` |
| Piccolo Cocktails & More | `piccolo-1.png` … `piccolo-3.png` |
| Suflabs | `suflabs-1.png` … `suflabs-3.png` |
| Çeyrek (F/P Yemek) | `çeyrek-1.png` … `çeyrek-3.png` |

## Kendi fotoğrafını koymak

1. Aynı dosya adıyla fotoğrafı bu klasöre kopyala (eski dosyanın üzerine yaz).
2. `git add backend/static/venues/` → commit → push.
3. Render backend otomatik güncellenir.

URL'ler `memory_store.py` içindeki `_venue_photo(...)` ile GitHub raw linkine bağlıdır.
