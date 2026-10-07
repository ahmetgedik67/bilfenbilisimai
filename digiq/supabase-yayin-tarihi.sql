-- ============================================================
-- BİLFEN BİLİŞİM AI — v2.7 YAYIN TARİHİ MIGRATION
-- ------------------------------------------------------------
-- Amaç: Öğretmen etkinliği oluştururken YAYIN (AÇILIŞ) tarihini
-- girebilsin; öğrenci portalı bu tarihe kadar soluk kartta
-- canlı geri sayım göstersin, etkinlik tarihte otomatik açılsın.
--
-- Ne yapar?
--   1) ozel_etkinlik tablosuna acilis / kapanis sütunlarını ekler
--      (idempotent — tekrar çalıştırmak güvenlidir).
--   2) ozel_etkinlik_ogrenci görünümünü günceller:
--      - Atama satırı YOKSA öğretmenin etkinliğe kaydettiği
--        yayın tarihi kullanılır (yeni etkinlikler için).
--      - Atama satırı VARSA (yönetici 🎮 Etkinlik Yönetimi'nden
--        ayarladıysa veya onayda senkronlandıysa) atama tarihi
--        geçerli olmaya devam eder.
--      - İçerik (icerik) kuralı AYNEN korunur: kapalı veya tarihi
--        gelmemiş/dolmuş etkinliğin içeriği ASLA dönmez (null).
--
-- Supabase Dashboard → SQL Editor'de çalıştırın.
-- ============================================================

-- 1) Yeni sütunlar (idempotent)
alter table public.ozel_etkinlik add column if not exists acilis timestamptz;
alter table public.ozel_etkinlik add column if not exists kapanis timestamptz;

-- 2) Öğrenci güvenli görünümü — yayın tarihi desteğiyle
create or replace view public.ozel_etkinlik_ogrenci
with (security_invoker = false) as
select o.id, o.ad, o.konu, o.seviyeler, o.tip, o.gorsel,
       o.olusturma_tarihi,
       case when a.aktif = true
             and (a.acilis is null or a.acilis <= now())
             and (a.kapanis is null or a.kapanis > now())
            then o.icerik else null end as icerik,
       coalesce(a.aktif, true) as acik,
       case when a.oyun_id is null then o.acilis else a.acilis end as acilis,
       case when a.oyun_id is null then o.kapanis else a.kapanis end as kapanis
from public.ozel_etkinlik o
left join public.etkinlik_atama a
  on a.oyun_id = 'ozel:' || o.id::text
where o.durum = 'onaylandi';

grant select on public.ozel_etkinlik_ogrenci to anon;

-- NOT: İçerik (icerik) kuralı AYNEN korundu — yalnız aktif + zaman
-- penceresi içindeyken döner. Atama satırı yoksa acik=true döner ama
-- icerik koşulu (a.aktif = true) sağlanmadığından içerik yine null kalır;
-- öğrenci soluk kart görür. Panelde "✅ Onayla" işlemi atama satırını
-- öğretmenin kaydettiği tarihle otomatik oluşturduğu için normal akışta
-- bu durum yaşanmaz. Eski etkinliklerin davranışı birebir aynıdır.
