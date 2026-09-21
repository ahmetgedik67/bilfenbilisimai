# CWI Kullanım Notları — Bilfen Bilişim AI

`cwi/` = Creative Web Intelligence v6 kütüphanesi (r0ine/creative-web-intelligence).
Tasarım **karar kütüphanesidir**, çalıştırılan kod değildir. Projenin kendi kuralları
(`AGENTS.md`) çelişki durumunda önceliklidir.

## Ne zaman hangi dosya

| Durum | Oku |
|---|---|
| Yeni sayfa / büyük bölüm tasarlıyorken | `cwi/START_HERE_V5.md` + `cwi/quality/V5_AUTHENTICITY_GATE.md` |
| Renk, palet, kontrast, koyu tema | `cwi/color/` klasörü + `cwi/data/color_combination_recipes.json` |
| Font seçimi / tipografik hiyerarşi | `cwi/typography/` |
| Animasyon, hover, geçiş tasarımı | `cwi/motion/` |
| Uzun sayfa scroll davranışı | `cwi/directors/scroll/SCROLL_DIRECTOR.md` |
| 3D etkinlik geliştirirken (Robi, Sanal Tur) | `cwi/v6/THREE_D_DIRECTOR.md` + `cwi/three/` |
| "Görsel mi, 3D mi, canvas mı?" kararı | `cwi/v6/MEDIA_DECISION_ENGINE.md` |
| Sayfa ağırlığı / performans | `cwi/v6/PERFORMANCE_BUDGET_ENGINE.md` |
| "Bu fazla AI yapılmışı duruyor" hissi | `cwi/anti-ai/INDEX.md` + `cwi/data/v5/authenticity_fingerprints.json` |

## Bu projeye uyarlanmış özgünlük kapısı

Portal **çocuk dostu eğitim sitesi**dir; kullanıcı gradyan başlık + canlı marka
renklerini seçmiştir. Bu yüzden v5 blocker'larının bir kısmı burada **bilinçli
tercihtir** ve düzeltilmez:

- Hero gradyan başlığı (`background-clip: text`) — marka kimliği.
- Mavi-mor marka gradyanı — Bilfen kurumsal tonu.
- Kart tabanlı etkinlik listesi — içerik gereği (her kart bağımsız bir etkinlik).

Yine de uygulanan ve uygulanmaya devam edilecek kurallar:

- **AF-B02:** merdiven gecikmeleri (`index * 60ms`) → deterministik ama tek düze
  olmayan dağılım kullan (`(sira % 4) * 45 + (sira % 3) * 25`).
- **AF-B03:** tek easing monotoni → popup ve modal farklı eğriler kullanır
  (`.2,.9,.25,1` / `.16,1,.3,1`).
- **AF-A02:** tam sayfa dekoratif grid yok — hero deseni maskeli ve çok soluk,
  genişletilmez.
- **AF-B05:** bölüm aralarında dinlenme alanı koru; her boşluğu doldurma.

## Araçlar (Python gerekir — bu makinede yok)

`cwi/tools/v5/authenticity_check.py` ve `cwi/tools/v6/validate_v6.py` Python 3 ister.
Makinede Python bulunmadığından tarama elle yapılır: yukarıdaki fingerprint id'leri
(`AF-XX`) `cwi/data/v5/authenticity_fingerprints.json` içinde tanımlı; regex taraması
ile `index.html`, `panel.html`, `assets/*.css` üzerinde uygulanabilir.

Son tarama: 2026-09-21 — AF-B01 temiz, AF-A02 temiz (maskeli hero istisna),
AF-D02/D03 bilinçli tercih, AF-B02/AF-B03 düzeltildi.
