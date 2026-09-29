# Bilfen Bilişim AI — KVKK Uyum Notu (v2 Mimari)

> Bu belge teknik mimarinin veri koruma yaklaşımını özetler. Hukuki bağlayıcılığı
> yoktur; kurumun veri sorumlusu olarak KVKK süreçlerini (VERBİS, aydınlatma
> metni, işleme koşullarının değerlendirilmesi) ayrıca yürütmesi gerekir.

## 1. İşlenen veri — v2 mimaride

| Veri | Kim | Nerede | Saklama |
|---|---|---|---|
| Öğrenci kimliği | Öğrenci | **Toplanmaz** (ad, e-posta, şifre, puan, rozet yok) | — |
| Öğrenci sonuç verisi | Öğrenci | **Hiçbir yerde saklanmaz** (tamamlanan tablosuna yazı kapalı, eski kayıtlar silinir) | — |
| Haftalık kod | Yönetici üretir | Supabase `erisim_kod` tablosu | Yalnız SHA-256(kod+tuz) hash'i; düz kod hiç yazılmaz |
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
etkinlikleri görebilir. Tarih zorlaması istemciye güvenmez.

## 4. Roller

| Rol | Yetki |
|---|---|
| Yönetici | Haftalık kod yenileme, öğretmen ekleme/silme/şifre sıfırlama |
| Öğretmen | Etkinlik oluşturma, seviye bazlı yayınlama (açık/kapalı/tarihli), tahta etkinlikleri |
| Öğrenci | Hesapsız erişim: sınıf + haftalık kod |

## 5. Kod yenileme akışı

1. Yönetici panelde **🔑 Haftalık Erişim Kodları → 🔄 Kodları Yenile** butonuna basar.
2. Sunucu 13 seviye için 4 haneli kod üretir, hash'ini yazar, düz kodu **yalnız bu yanıtta** döner.
3. Panel kodları bir kez gösterir; liste kapatılınca geri alınamaz.
4. Yönetici kodları kurum içi kanalla öğretmenlere iletir.
5. Geçerlilik: bir sonraki haftanın pazartesi 08:00'i (Türkiye saati).

## 6. Bilinen sınırlar (şeffaflık notu)

- Panel tek dosyalık statik bir uygulama olduğundan "yönetici girişi" istemci
  taraflı kontrol + public anahtarla çalışır; Supabase yetkileri tablo
  politikalarıyla (RLS) sınırlandırılmıştır. `kodlari_yenile_tumu` anon
  anahtarla çağrılabilir — kötüye kullanım riski düşüktür (sonuç: kodlar
  yenilenir, sıradaki hafta değişir) ama kurum dilersen bu fonksiyonu
  yalnız authenticated role'e kısıtlayabilir.
- Öğrencinin cihazında kalan tek iz: `localStorage.bt_kapi` (seviye + zaman, 6 saat).
- Erişim günlüğü (log) tutulmaz; bu bilinçli bir veri minimizasyonu tercihidir.

## 7. Kuruma önerilen adımlar

1. Bu mimariyi VERBİS kayıtlarına ve varsa kurum aydınlatma metnine işleyin.
2. Öğretmen ve yönetici hesapları personel verisi içerir: saklama ve silme
   sürelerini personel çıkış sürecine bağlayın.
3. Supabase projesi AB/ABD bölgesinde barındırılır: yurt dışına veri aktarımı
   değerlendirmesini kurumun hukuk birimiyle yapın.
