# Bilfen DigiQuest — KVKK Uyum Notu (v2 Mimari)

> Bu belge teknik mimarinin veri koruma yaklaşımını özetler. Hukuki bağlayıcılığı
> yoktur; kurumun veri sorumlusu olarak KVKK süreçlerini (VERBİS, aydınlatma
> metni, işleme koşullarının değerlendirilmesi) ayrıca yürütmesi gerekir.

## 1. İşlenen veri — v2 mimaride

| Veri | Kim | Nerede | Saklama |
|---|---|---|---|
| Öğrenci kimliği | Öğrenci | **Toplanmaz** (ad, e-posta, şifre, puan, rozet yok) | — |
| Öğrenci sonuç verisi | Öğrenci | **Hiçbir yerde saklanmaz** (tamamlanan tablosuna yazı kapalı, eski kayıtlar silinir) | — |
| Haftalık kod | Yönetici üretir | Supabase `erisim_kod` tablosu | Doğrulama yalnız SHA-256(kod+tuz) hash'i ile; `kod_acik` sütunu yalnız öğretmen/yönetici paneli görüntülemesidir, öğrenci tabloya erişemez |
| Öğretmen adı + kullanıcı adı + şifre hash'i (PBKDF2-SHA256, 60k tur) | Öğretmen | Supabase `profil` tablosu | Hesap silinene kadar |
| Öğretmenin hazırladığı etkinlik içerikleri | Öğretmen | Supabase `ozel_etkinlik` | Öğretmen sildikçe |

## 2. Kimlik doğrulama akışı

- **Öğrenci:** Sınıf seçer + 4 haneli haftalık kodu girer. Kod `kod_dogrula(p_seviye, p_kod)`
  SECURITY DEFINER fonksiyonunda sunucuda hash'lenip karşılaştırılır ve geçerlilik
  tarihi kontrol edilir. Tarayıcıya yalnız "doğru/yanlış" döner; hash okunamaz
  (`erisim_kod` üzerinde RLS `false` politikası). Başarılı girişte tarayıcıda yalnız
  `{seviye, saat}` tutulur (6 saat sonra otomatik temizlenir) — kimlik verisi değildir.
- **Öğretmen / Yönetici:** Kullanıcı adı + şifre. Şifre PBKDF2 ile hash'lenir; düz metin asla gönderilmez/saklanmaz.

## 3. Yayın kontrolü sunucuda

Öğrenci, `ozel_etkinlik_ogrenci` güvenli görünümünden yalnız
`durum='onaylandi'` **ve** `acilis <= now() < kapanis` koşulunu sağlayan
etkinlikleri görebilir. Tarih zorlaması istemciye güvenmez: kapalı,
tarihi gelmemiş veya süresi dolmuş etkinlik listeye hiç düşmez; derin
bağlantıyla (`#etkinlik=…`) erişilmeye çalışılırsa `etkinlik_atama`
satırı üzerinden sunucudan yeniden doğrulanır ve engellenir.

Öğrenci ayrıca **seviye kilidi** ile kısıtlıdır: kapıdan seçilen sınıfın
(`s1…s7` / `i2…i7`) dışındaki etkinlikler listede gösterilmez, aramada
bulunmaz ve başlatılamaz; detay sayfasında da kilitlidir. Seviye seçimi
yapılmamış etkinlikler bütün sınıflara açıktır. `etkinlik_atama` tablosu
v2.1'de `oyun_id` birincil anahtarıyla etkinlik-bazlıdır (kampüs sütunu
isteğe bağlıdır); panel upsert aynı satırı günceller.

## 4. Roller

| Rol | Yetki |
|---|---|
| Yönetici | Haftalık kod yenileme, öğretmen ekleme/silme/şifre sıfırlama |
| Öğretmen | Etkinlik oluşturma, seviye bazlı yayınlama (açık/kapalı/tarihli), tahta etkinlikleri |
| Öğrenci | Hesapsız erişim: sınıf + haftalık kod |

## 5. Kod yenileme akışı

1. Yönetici panelde **🔑 Haftalık Erişim Kodları → 🔄 Kodları Yenile** butonuna basar.
2. Sunucu 13 seviye için 4 haneli kod üretir; hash'i doğrulama için, düz metin kopyası (`kod_acik`) panel görüntülemesi için yazılır.
3. Kodlar hafta boyunca yönetici kartında ve **tüm öğretmenlerin Tahta Etkinlikleri sekmesinde** otomatik görünür (`kodlari_oku` RPC — yalnız geçerli kodları döner).
4. Öğrenciye kod yalnız kapı ekranındaki giriş denemesiyle iletilir; tabloya erişimi yoktur.
5. Geçerlilik: bir sonraki haftanın pazartesi 08:00'i (Türkiye saati); süresi dolan kod panelde de gösterilmez.

## 6. Bilinen sınırlar (şeffaflık notu)

- Panel tek dosyalık statik bir uygulama olduğundan "yönetici girişi" istemci
  taraflı kontrol + public anahtarla çalışır; Supabase yetkileri tablo
  politikalarıyla (RLS) sınırlandırılmıştır. `kodlari_yenile_tumu` ve
  `kodlari_oku` anon anahtarla çağrılabilir — risk düşüktür (yenileme sadece
  kodları değiştirir; okuma sadece geçerli kodu döner, hash'e ve öğrenci
  verisine erişim yoktur) ama kurum dilersen her iki fonksiyonu yalnız
  authenticated role'e kısıtlayabilir.
- Öğrencinin cihazında kalan tek iz: `localStorage.bt_kapi` (seviye + zaman, 6 saat).
- Erişim günlüğü (log) tutulmaz; bu bilinçli bir veri minimizasyonu tercihidir.

## 7. Kuruma önerilen adımlar

1. Bu mimariyi VERBİS kayıtlarına ve varsa kurum aydınlatma metnine işleyin.
2. Öğretmen ve yönetici hesapları personel verisi içerir: saklama ve silme
   sürelerini personel çıkış sürecine bağlayın.
3. Supabase projesi AB/ABD bölgesinde barındırılır: yurt dışına veri aktarımı
   değerlendirmesini kurumun hukuk birimiyle yapın.
