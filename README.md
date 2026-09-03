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
├── panel.html              ← Öğretmen/Öğrenci paneli (giriş, etkinlik yönetimi, puan)
├── supabase-schema.sql     ← Bulut (Supabase) veritabanı şeması
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
   Öğrenci panelinde de görünmesi için aynı etkinliği `panel.html` içindeki
   `ETKINLIKLER` listesine de ekle (id, ad, url, açıklama).

> İpucu: Etkinlikler saf HTML + CSS + JavaScript ile yapılır; internet
> gerekmez ve her tarayıcıda (bilgisayar, tablet, projeksiyon) çalışır.

## 🔐 Panel & Giriş (Öğretmen + Öğrenci)

Sağ üstteki **👤 Panel** düğmesi `panel.html`'i açar:

- **Öğretmen:** kayıt olur ve kampüsünü oluşturur (örn. Kurtköy Bilfen) →
  öğrencilerini tek tek veya **CSV ile topluca** ekler, şifrelerini sıfırlar,
  etkinlikleri **açık / kapalı / tarihli** yapar (tek kayıt bütün kampüse uygulanır).
- **Öğrenci:** öğretmenin verdiği kullanıcı adı + şifreyle girer, açık
  etkinlikleri oynar, "Tamamladım" der → **puan** kazanır, **rozetler** ve
  **avatarlar** açılır.
- Portaldaki etkinlik kartları öğrenci hesabıyla açılmaya çalışılırsa
  öğretmenin belirlediği açık/kapalı/tarih durumuna göre izin verilir.

### Bulut senkronu (Supabase) — tek seferlik kurulum

Verilerin gerçekten çok cihazlı senkron olması için ücretsiz Supabase
kullanılır. (Kurulmadan da panel **demo modunda** bu cihazda çalışır.)

1. [supabase.com](https://supabase.com) → **New project** (ücretsiz plan).
2. Sol menüden **SQL Editor** → `supabase-schema.sql` dosyasının içeriğini
   yapıştır → **RUN**.
3. **Settings → API** sayfasından **Project URL** ve **anon public** anahtarını kopyala.
4. `panel.html` içinde `SUPABASE_URL` ve `SUPABASE_ANON` değerlerini yapıştır.
5. `index.html` içinde `CONFIG = { url: ..., anon: ... }` değerlerini aynı şekilde doldur.
6. Sayfayı yenile — demo bandı kaybolur, artık her cihazdan aynı kampüse erişilir.

> Güvenlik notu: Bu araç sınıf içi kullanım içindir. Kimlik doğrulama
> uygulama katmanında yapılır; anon anahtar ile veriler okunabilir/yazılabilir.
> Okul dışına taşınacaksa Supabase Auth'a geçilmelidir.

### 🛡️ Sistem yöneticisi (admin)

Panel, tüm kampüsleri ve öğrencileri yönetmek için genel bir **yönetici
hesabı** içerir:

- **Kullanıcı adı:** `admin` · **Şifre:** kurulumda belirlenen yönetici şifresi
- Yönetici girişinden sonra: tüm kampüsleri **görüntüle / ekle / yeniden adlandır / sil**,
  kampüslerin öğretmenlerini ve öğrencilerini **görüntüle / ekle / düzenle / sil / şifresini sıfırla**,
  öğrenci başına **puan ve tamamlanan etkinlik** sayılarını takip edebilir.
- Kampüs tablosunda her kampüsün öğretmen/öğrenci sayısı; ayrı **Tüm Öğretmenler** ve
  **Tüm Öğrenciler** listelerinde kampüs filtresi ile daraltma vardır.
- Kampüs silinince içindeki öğrenciler, etkinlik atamaları ve puan kayıtları da silinir.
- `admin` kullanıcı adı kayıt formlarında engellenir (yöneticiye ayrılmıştır).
- Şifre, diğer hesaplar gibi düz metin değil PBKDF2 ile hash'lenmiş olarak doğrulanır.

> Şifreyi değiştirmek istersen `panel.html` içindeki `ADMIN_SALT` ve `ADMIN_HASH`
> sabitlerini yeni PBKDF2 değerleriyle güncelle.

### 📄 CSV ile toplu öğrenci ekleme

Öğretmen paneli → **👨‍🎓 Öğrencilerim** sekmesinde **📥 Örnek CSV İndir**
düğmesi hazır şablonu indirir. Sütunlar: **Ad;Kullanıcı adı;Şifre**
(ayraç noktalı virgül veya virgül olabilir; başlık satırı isteğe bağlıdır):

```
Ad;Kullanıcı adı;Şifre
Ali Yılmaz;ali.yilmaz;ali1234
Ayşe Demir;ayse.demir;ayse1234
Mehmet Kaya;mehmet.kaya;mehmet1234
```

- Yüklemeden önce **önizleme** gösterilir: hangi satırlar eklenecek, hangilerinin
düzeltilmesi gerektiği (boş alan, kısa şifre, tekrar eden/alınmış kullanıcı adı) görünür.
- Şifresi boş satırlar için **"Şifresi boş satırlara otomatik şifre üret"** seçeneği
vardır (örn. `bt4821`); üretilen şifreler önizlemede gösterilir — eklemeden önce not alın.
- **➕ Toplu Ekle** tek tıkla bütün satırları kaydeder; kullanıcı adı alınmış bir satır
atlanır ve kaç satırın eklenemediği bildirilir.

## ✨ Portal Özellikleri

- 🏫 Üst menüde **SINIF** çipleri (1 – 7), **IPT KATEGORİSİ** açılır menüsü (2 IPT – 7 IPT) ve **ÖĞRETMEN** kategorisi ayrı ayrı durur
- 👩‍🏫 Öğretmen kategorisinde tahtada yalnız öğretmenin uyguladığı etkinlikler toplanır (ör. Sınıf Çarkıfeleği)
- 🗂️ IPT kategorilerine göre bölümler (2 IPT – 7 IPT); 1. sınıf seçilince o sınıfa uygun etkinlikler görünür
- 🖼️ Her etkinlik için gerçek önizleme görüntüsü ve açıklama kartı
- ▶️ Karta tıklayınca tam ekran oynatma penceresi (+ yeni sekmede aç)
- 🤖 Robi hem logoda hem de portalda ziyaretçileri karşılar
- 🎯 Sınıf Çarkıfeleği gibi tahta etkinlikleri, sınıf/IPC bölümlerini şişirmeden yalnız Öğretmen kategorisinde durur
- 👤 Sağ üstte **Panel** düğmesi: öğretmen kaydı + kampüs (örn. Kurtköy Bilfen), öğrenci ekleme (tek tek veya **CSV toplu**), şifre sıfırlama, etkinlik aç/kapa/tarih
- 🛡️ **admin** hesabıyla tüm kampüs, öğretmen ve öğrencilerin ekleme/silme/düzenleme, şifre sıfırlama ve takibi
- ⭐ Öğrenci panelinde puan toplama, rozet kazanma ve avatar seçme
- 📱 Telefon, tablet ve projeksiyonda çalışan duyarlı tasarım
