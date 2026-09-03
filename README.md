# 🎮 Bilfen Bilişim AI – HTML Oyunları

Bilişim Teknolojileri ve Yazılım dersi için hazırlanan HTML oyunlarının
**sınıf sınıf** toplandığı portal ana sayfası. Robi maskotuyla birlikte
tüm oyunlar tek çatı altında: karta tıkla, hemen oyna.

🔗 **Canlı:** https://ahmetgedik67.github.io/bilfenbilisimai/

🎓 *Bilfen Bilişim Zümresi*

---

## 📁 Klasör Yapısı

```
bilfenbilisimai/
├── index.html              ← Portal ana sayfası (bu dosya)
├── robi.png                ← Robi maskotu
├── games/                  ← Oyunlar (her oyun bir klasör)
│   └── carkifelek/
│       └── index.html      ← Örnek oyun: Sınıf Çarkıfeleği
├── thumbnails/             ← Oyun kartlarının önizleme görselleri
│   └── carkifelek.jpg
└── README.md
```

## ➕ Yeni Oyun Nasıl Eklenir?

1. **Oyun dosyasını ekle:** `games/<oyun-adı>/index.html` klasörüne koy.
   (Tek dosyalık oyun tercih edilir — her şey tek HTML içinde olsun.)

2. **Önizleme görselini ekle:** `thumbnails/<oyun-adı>.jpg` olarak koy.
   İstersen oyunu tarayıcıda açıp ekran görüntüsü alabilirsin (16:10 önerilir).

3. **`index.html` içindeki `OYUNLAR` listesine bir satır ekle:**

```js
{
  id: 'oyun-adi',
  ad: 'Oyunun Görünen Adı',
  sinif: 5,                          // 5, 6, 7 veya 8
  url: 'games/oyun-adi/index.html',
  onizleme: 'thumbnails/oyun-adi.jpg',
  aciklama: 'Oyunu tek cümleyle anlatan açıklama…',
  etiketler: ['Konu', 'Tür']
}
```

4. Dosyayı kaydet — oyun portalda kendi sınıfının bölümünde görünür. ✅

> İpucu: Oyunlar saf HTML + CSS + JavaScript ile yapılır; internet
> gerekmez ve her tarayıcıda (bilgisayar, tablet, projeksiyon) çalışır.

## ✨ Portal Özellikleri

- 🗂️ Sınıf sınıf bölümler ve üstte hızlı filtre çipleri (5.–8. sınıf)
- 🖼️ Her oyun için gerçek önizleme görüntüsü ve açıklama kartı
- ▶️ Karta tıklayınca tam ekran oynatma penceresi (+ yeni sekmede aç)
- 🤖 Robi maskotu portalda ziyaretçileri karşılar
- 📱 Telefon, tablet ve projeksiyonda çalışan duyarlı tasarım
