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
- **📊 Kampüs Raporu**: kampüs ve dönem filtresiyle hangi etkinliği kaç öğrencinin
  tamamladığını (bar + 👥 öğrenci listesi), tamamlanmaların tarihe göre yığılım
  grafiğini (günlük; uzun dönemde haftalık kovalar + lejant) gösterir.
- **⏳ Etkinlik Onayları**: öğretmenlerin oluşturduğu etkinlikler (dosya + bilgiler)
  burada onay bekler. Onaylayınca etkinlik **tüm kampüslerin** öğrenci listelerine
  düşer; reddedilirse nedeni öğretmene gösterilir. Yönetici yayındaki/reddedilen
  kayıtları silebilir.
- **💾 Veri Yedeği**: veriler demo modunda **yalnız o cihazın tarayıcısında**
  (localStorage), Supabase kuruluysa buluttadır. Yönetici panelindeki yedek
  kartından: (a) **📥 Yedek İndir** tek tıkla tüm veriyi `.json` olarak indirir
  (kampüs, profil, atama, tamamlanan, şifre kaydı, özel etkinlikler),
  (b) Chrome/Edge'de **📁 Günlük Otomatik Yedek Klasörü Seç** ile bir klasör
  belirlenirse panel **günde bir kez** `bilfen-yedek-YYYY-MM-DD.json` dosyasını o
  klasöre yazar (yazılması için panelin o gün bir kez açılması yeterli),
  (c) **🔄 Yedekten Geri Yükle** ile seçilen yedek tüm verileri geri yükler
  (mevcut veriler önce silinir). Demo (tarayıcı) yedeği, Supabase bağlantısı
  açıkken geri yüklenirse otomatik olarak bulut biçimine çevrilir: yeni UUID
  kimlikler üretilir, kampüs/öğretmen/öğrenci/etkinlik bağlantıları yeniden
  eşlenir — böylece eski tarayıcı verileri tek dosyayla buluta taşınır.
- **🔌 Bağlantı durumu**: panel açılışında bağlantı otomatik doğrulanır. Demo
  modunda "🧪 Yerel demo" rozeti görünür; Supabase kuruluysa 6 tablonun
  erişilebilirliği test edilir ve üstteki durum rozeti yeşil (tamam), sarı
  (şema eksik/güncel değil — `supabase-schema.sql` çalıştırılmalı) ya da kırmızı
  (URL/anon anahtar/ağ hatası) gösterir; "🔄 Yeniden kontrol" ile tekrar denenir.
- **🔌 Bağlantı Ayarları (yönetici)**: yönetici panelindeki karttan **Project URL**
  ve **anon public key** girilip "Kaydet ve Bağlan" denir; değerler o cihaza
  kaydedilir ve sayfa Supabase modunda yeniden açılır (portal `index.html` aynı
  ayarı kullanır). "Demo Moduna Dön" kaydı siler. Kalıcı yayın için aynı değerler
  `panel.html` / `index.html` sabitlerine de yazılabilir; cihaza kaydedilen değer
  kod sabitinin üzerine geçer.
- **🧪 Şema / Bağlantı Kontrolü (yönetici)**: Supabase modunda panel açılınca
  6 tablo ve uygulamanın kullandığı tüm kolonlar tek tek denetlenir; eksik
  tablolar / kolonlar tablo bazında listelenir ve "supabase-schema.sql dosyasını
  SQL Editor'da çalıştırın" yönergesi gösterilir. Sonuç 5 dakika önbellekte
  tutulur, "🔄 Şimdi kontrol et" ile tazelenir.
- **⏰ Yedek hatırlatıcısı**: bulut (Supabase) bağlantısı açıkken her panel
  açılışında son yedek zamanı denetlenir; son bulut yedeği 24 saatten eskiyse
  üstte "📥 Şimdi Yedek Al" kısayoluyla uyarı şeridi gösterilir (yalnızca bu
  oturumda kapatılabilir). Yedek İndir veya günlük klasör yedeklemesi zamanı
  otomatik günceller.
- Kampüs silinince içindeki öğrenciler, etkinlik atamaları ve puan kayıtları da silinir.
- `admin` kullanıcı adı kayıt formlarında engellenir (yöneticiye ayrılmıştır).
- Şifre, diğer hesaplar gibi düz metin değil PBKDF2 ile hash'lenmiş olarak doğrulanır.

> **Şifreyi değiştirmek için kodla uğraşmaya gerek yok:** yönetici panelindeki
> **🔑 Yönetici Şifresini Değiştir** kartından mevcut + yeni şifreyi girip güncelle.
> Şifre PBKDF2 ile hash'lenir; demo modunda bu cihazda, Supabase kuruluysa
> `ayar` tablosunda (bulutta) saklanır — böylece tüm cihazlarda geçerli olur.
> (Supabase şemasını daha önce kurduysan yalnızca `ayar` tablosu + politikasını
> eklemek için `supabase-schema.sql` sonundaki üç komutu çalıştır.)
>
> Varsayılan şifre **`Ag2135`**'tir ve hiç değiştirilmediyse geçerlidir.

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

### ✍️ Öğretmen kendi etkinliğini oluşturabilir (önce yönetici onayı)

Öğretmen panelinde **✍️ Etkinlik Oluştur** sekmesi:

1. **Etkinlik adı** + **Konu & Tema** yaz (örn. "Algoritma — Uzay Teması").
2. **Kullanılacağı yerler** seç — bir veya birden fazla seçilebilir:
   - **📚 Sınıf:** 1. sınıf … 7. sınıf
   - **🗂️ IPT:** 2 IPT … 7 IPT
   - **👩‍🏫 Öğretmen Aracı:** işaretlenirse etkinlik öğrencilere görünmez,
     öğretmenler ders sırasında tahtada kullanır
3. İçeriği üç yoldan biriyle ver:
   - **📄 HTML dosyası yükle** (tek dosyalık etkinlik .html)
   - **🔗 Drive bağlantısı** (paylaşım "Bağlantısı olan herkes" olmalı)
   - **✂️ Kodu yapıştır** (HTML kodunun tamamı)
4. **👁 Önizle** ile önce dene, **💾 Etkinliği Kaydet** ile kaydet.

Kaydedilen etkinlik **yönetici onayına gider** — dosya ve bilgiler öğrencilere
ve diğer öğretmenlere görünmez; öğretmen "Oluşturduğum Etkinlikler" listesinde
**⏳ Onay bekleniyor** durumunu izler. Yönetici **⏳ Etkinlik Onayları** kartından
**✅ Onayla** deyince etkinlik **tüm kampüslerin** öğrencilerinin **Etkinliklerim**
listesine düşer (HTML içerik pencerede oynar, Drive bağlantısı yeni sekmede açılır);
**🎮 Etkinlik Yönetimi** sekmesinden açık / kapalı / tarihli yapılır, puan/rozet
akışı aynen çalışır. **❌ Reddet** dersen gerekçe öğretmene gösterilir. Yayındaki
etkinlikleri yalnız yönetici silebilir; onay bekleyen/reddedilenleri öğretmen silebilir.

> Demo modunda etkinlikler bu cihazda saklanır; Supabase kuruluysa
> `ozel_etkinlik` tablosuna yazılır (`supabase-schema.sql` güncellendi — şemayı
> daha önce kurduysan dosyadaki onay akışı kolonları için yorumdaki `alter table`
> komutlarını da çalıştır; eski kayıtlar varsayılan olarak yayında kalır).

## ✨ Portal Özellikleri

- 🏫 Üst menüde **SINIF** çipleri (1 – 7), **IPT KATEGORİSİ** açılır menüsü (2 IPT – 7 IPT) ve **ÖĞRETMEN** kategorisi ayrı ayrı durur
- 👩‍🏫 Öğretmen kategorisinde tahtada yalnız öğretmenin uyguladığı etkinlikler toplanır (ör. Sınıf Çarkıfeleği) — bu araçlar **giriş yapılmadan da herkese açıktır**; öğrenci ataması/kapalı durumu bunlara uygulanmaz
- 📖 Öğretmen sekmesinde, giriş gerektirmeyen açılır **"Nasıl kullanılır?"** mini rehberi: her tahta aracının adım adım kullanımı (oyun nesnesindeki isteğe bağlı `nasil` listesinden; yoksa genel adımlar)
- 🗂️ IPT kategorilerine göre bölümler (2 IPT – 7 IPT); 1. sınıf seçilince o sınıfa uygun etkinlikler görünür
- 🖼️ Her etkinlik için gerçek önizleme görüntüsü ve açıklama kartı
- ▶️ Karta tıklayınca tam ekran oynatma penceresi (+ yeni sekmede aç)
- 🤖 Robi hem logoda hem de portalda ziyaretçileri karşılar
- 🎯 Sınıf Çarkıfeleği gibi tahta etkinlikleri, sınıf/IPC bölümlerini şişirmeden yalnız Öğretmen kategorisinde durur
- 👤 Sağ üstte **Panel** düğmesi: öğretmen kaydı + kampüs (örn. Kurtköy Bilfen), öğrenci ekleme (tek tek veya **CSV toplu**), şifre sıfırlama, etkinlik aç/kapa/tarih
- 🔐 Anasayfada **Giriş Yap** düğmesi; giriş yapınca başlık altında profil şeridi: öğrenci için avatar + ⭐ puan + ✅ etkinlik + **rozetler** (kazanılan renkli, kazanılmayan gri), öğretmen için kampüs + öğrenci/açık etkinlik sayısı, yönetici için sistem bilgisi; panel kısayolu ve **Çıkış**
- 🛡️ **admin** hesabıyla tüm kampüs, öğretmen ve öğrencilerin ekleme/silme/düzenleme, şifre sıfırlama ve takibi
- 📊 Yönetici için kampüs bazlı etkinlik raporu: etkinlik başına tamamlayan öğrenci sayısı ve zamana göre tamamlanma grafiği
- ⭐ Öğrenci panelinde puan toplama, rozet kazanma ve avatar seçme
- 📱 Telefon, tablet ve projeksiyonda çalışan duyarlı tasarım
- 🎨 **“Robi’nin Gökyüzü” çocuk dostu görsel katman** (portal): canlı ama dengeli pastel gökkuşağı paleti, büyük yuvarlak dokunma alanları, zıplayan Robi, süzülen ☁️🎈🪁 süsleri, gökkuşağı şeridi, kart başına gökkuşağı vurgu rengi ve kısa/akıcı mikro animasyonlar — tümü `prefers-reduced-motion` duyarlı ve internet gerektirmez (harici font/JS yok)
- 🧸 Panel aynı oyuncak dilde ama yoğun tablolar okunur kalır: yumuşak kartlar, basınca tepki veren (eğilip zıplayan) butonlar, eğlenceli sekmeler ve maskotlu giriş/kayıt ekranı
