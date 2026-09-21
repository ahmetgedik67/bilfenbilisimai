# AGENTS.md — Bilfen Bilişim AI

Bu dosya, bu depoda çalışan tüm AI agent'ları için proje bağlamı ve çalışma kurallarıdır.

## Proje

Bilfen Bilişim Teknolojileri ve Yazılım dersi eğitim portalı (2–7. sınıf).
Saf HTML + CSS + JavaScript — **çalışma anında internet gerekmez** (etkinliklerde CDN yok).
Öğrenci tarafı `index.html`, öğretmen/yönetim `panel.html`, etkinlik detay `etkinlik.html`,
kılavuz `kullanim-kilavuzu.html`. Paylaşılan veri katmanı `assets/portal-data.js`,
tasarım sistemi `assets/portal.css` (+ `assets/etkinlik-detay.css`, `assets/panel-theme.css`).

## Değişmez proje kuralları

1. **"Oyun" kelimesi yasak.** Ne metinlerde ne kodda; her zaman **"etkinlik"** yaz.
2. Tüm kullanıcıya görünen metinler **Türkçe**.
3. Etkinlikler offline çalışmalı — yeni bağımlılık/CDN ekleme (zaten var olanlar hariç).
4. Koyu tema `html[data-tema='koyu']` ile yönetilir; yeni bileşenlerde her iki temayı da destekle.
5. Tasarım değişkenleri `assets/portal.css` `:root` bloğundan gelir; sabit renk kodu yazma.
6. Veri tek yerden: etkinlik kataloğu + özel etkinlikler `assets/portal-data.js` içinde.
7. Sunum akışı: kökte `server.cjs` (port 8741) → commit + push → GitHub Pages canlı →
   `yedek/bilfenbilisimai-yayin` kopyasını eşitle.
8. Kampus listesi sabittir (panelde düzenlenemez); Supabase tablolarına dokunurken şemayı bozma.

## Creative Web Intelligence (CWI) kütüphanesi

`cwi/` klasörü, tasarım kararları için 400+ kuralık bir karar kütüphanesidir
(kaynak: r0ine/creative-web-intelligence v6). **Çalışma kodu değildir** — agent'lar
okur, kural olarak uygular. Bu proje için uyarlanmış kullanım:

| Görev | Okunacak dosya |
|---|---|
| Yeni sayfa/bölüm tasarımı | `cwi/v5/` doktrini + `cwi/quality/V5_AUTHENTICITY_GATE.md` |
| Renk paleti / kontrast / koyu tema | `cwi/color/` + `cwi/data/color_combination_recipes.json` |
| Tipografi seçimi | `cwi/typography/` |
| Animasyon, hover, geçiş | `cwi/motion/` + `cwi/quality/` motion kuralları |
| Scroll davranışı (uzun sayfa) | `cwi/directors/scroll/SCROLL_DIRECTOR.md` |
| 3D etkinlik (Sanal Sınıf Turu vb.) | `cwi/v6/THREE_D_DIRECTOR.md` + `cwi/three/` |
| Görsel/medya seçimi (görsel mi, canvas mı, 3D mi) | `cwi/v6/MEDIA_DECISION_ENGINE.md` |
| Performans bütçesi | `cwi/v6/PERFORMANCE_BUDGET_ENGINE.md` |
| "AI yapılmışı" görünmemesi | `cwi/anti-ai/` + aşağıdaki özgünlük notu |

### Özgünlük kapısı (v5) — bu projeye uygulanışı

`cwi/quality/V5_AUTHENTICITY_GATE.md` portföy siteleri için yazılmıştır; bu proje
**çocuk dostu eğitim portalı**dır ve kullanıcı tasarım dilini (gradyan başlık, cam
çubuklar, canlı renkler) açıkça seçmiştir. Kütüphanenin kendi doktrini de kullanıcı
isteğini önceliklendir. Bu yüzden:

- **Bloker sayılmayanlar (bu projede bilinçli tercih):** hero gradyan başlığı,
  mavi-mor marka gradyanı, kart tabanlı etkinlik listesi (içerik gereği kartlaştırma).
- **Yine de kaçınılacaklar:** her bölümde aynı fade-up animasyonu, `index * 0.1s`
  merdiven gecikmeleri, tüm easing'lerin aynı olması, dinlenme alanı (rest zone)
  olmayan aşırı kalabalık bölümler, dekoratif anlamsız parçacık/3D.
- Etkinlik içi 3D (Sanal Sınıf Turu) **işlevsel** olduğu için meşru: mekân öğretir.
  Dekoratif 3D ekleme; ekleyecekse `MEDIA_DECISION_ENGINE` kararıyla ekle.

### Kullanım akışı

1. Görsel/etkileşim kararlı bir göreve başlarken yukarıdaki tablodan ilgili dosyayı oku.
2. Kural ile proje kuralı çelişirse **proje kuralı kazanır** (özellikle offline + Türkçe + kullanıcı istekleri).
3. Yeni desen eklerken `cwi/data/design_rules.json`'dan eşleşen kuralın id'sini
   commit mesajında belirtebilirsin (izlenebilirlik).
