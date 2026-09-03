# 🧩 Bilfen Bilişim AI – HTML Etkinlikleri

Bilişim Teknolojileri ve Yazılım dersi için hazırlanan HTML etkinliklerinin
**sınıflara (1-7)**, **IPT kategorilerine** (2 IPT – 7 IPT) ve tahtada yalnız öğretmenin
uyguladığı etkinlikler için **Öğretmen kategorisine** göre toplandığı portal ana sayfası.
Robi maskotuyla birlikte tüm etkinlikler tek çatı altında: karta tıkla, hemen oyna.

🔗 **Canlı:** https://ahmetgedik67.github.io/bilfenbilisimai/

🎓 *Bilfen Bilişim Zümresi*

---

## 📁 Klasör Yapısı

```
bilfenbilisimai/
├── index.html              ← Portal ana sayfası (bu dosya)
├── robi.png                ← Robi maskotu
├── games/                  ← Etkinlikler (her etkinlik bir klasör)
│   └── carkifelek/
│       └── index.html      ← Örnek etkinlik: Sınıf Çarkıfeleği
├── thumbnails/             ← Etkinlik kartlarının önizleme görselleri
│   └── carkifelek.jpg
└── README.md
```

## ➕ Yeni Etkinlik Nasıl Eklenir?

1. **Etkinlik dosyasını ekle:** `games/<etkinlik-adı>/index.html` klasörüne koy.
   (Tek dosyalık etkinlik tercih edilir — her şey tek HTML içinde olsun.)

2. **Önizleme görselini ekle:** `thumbnails/<etkinlik-adı>.jpg` olarak koy.
   İstersen etkinliği tarayıcıda açıp ekran görüntüsü alabilirsin (16:10 önerilir).

3. **`index.html` içindeki `OYUNLAR` listesine bir satır ekle:**

```js
{
  id: 'etkinlik-adi',
  ad: 'Etkinliğin Görünen Adı',
  kategoriler: [5],                   // [5] → yalnız 5 IPT kategorisi
                                      // [2,3,4,5,6,7] → bütün IPT kategorileri
  siniflar: [1, 2, 3, 4, 5, 6, 7],    // (isteğe bağlı) etkinliğin kullanıldığı sınıflar
  ogretmen: true,                     // (öğretmen araçları) ÖĞRETMEN kategorisinde göster
  url: 'games/etkinlik-adi/index.html',
  onizleme: 'thumbnails/etkinlik-adi.jpg',
  aciklama: 'Etkinliği tek cümleyle anlatan açıklama…',
  etiketler: ['Konu', 'Tür']
}
```

4. Dosyayı kaydet — etkinlik portalda seçtiğin sınıfın / IPT kategorisinin bölümünde görünür. ✅

> İpucu: Etkinlikler saf HTML + CSS + JavaScript ile yapılır; internet
> gerekmez ve her tarayıcıda (bilgisayar, tablet, projeksiyon) çalışır.

## ✨ Portal Özellikleri

- 🏫 Üst menüde **SINIF** çipleri (1 – 7), **IPT KATEGORİSİ** açılır menüsü (2 IPT – 7 IPT) ve **ÖĞRETMEN** kategorisi ayrı ayrı durur
- 👩‍🏫 Öğretmen kategorisinde tahtada yalnız öğretmenin uyguladığı etkinlikler toplanır (ör. Sınıf Çarkıfeleği)
- 🗂️ IPT kategorilerine göre bölümler (2 IPT – 7 IPT); 1. sınıf seçilince o sınıfa uygun etkinlikler görünür
- 🖼️ Her etkinlik için gerçek önizleme görüntüsü ve açıklama kartı
- ▶️ Karta tıklayınca tam ekran oynatma penceresi (+ yeni sekmede aç)
- 🤖 Robi hem logoda hem de portalda ziyaretçileri karşılar
- 🎯 Sınıf Çarkıfeleği gibi tahta etkinlikleri, sınıf/IPC bölümlerini şişirmeden yalnız Öğretmen kategorisinde durur
- 📱 Telefon, tablet ve projeksiyonda çalışan duyarlı tasarım
