-- ============================================================
-- BILFEN BİLİŞİM AI — AYLIK GİRİŞ KODU GEÇİŞİ (v2.8.11)
-- Giriş kodları artık HAFTALIK değil AYLIK geçerlidir.
-- Geçerlilik: üretim anından gelecek ayın 1'i, 08:00 (TSİ / 05:00 UTC).
--
-- Kurulum: Supabase → SQL Editor → bu dosyanın tamamını çalıştır.
-- Tekrar çalıştırmak güvenlidir (idempotent). Öğrenci verisi SİLMEZ.
--
-- Not: supabase-guvenlik-v2.sql'in TAMAMINI çalıştırmayın — o dosyanın
-- 8. bölümü eski öğrenci verisini kalıcı olarak siler. Bu geçiş dosyası
-- yalnız kod fonksiyonlarını günceller.
-- ============================================================

-- ------------------------------------------------------------
-- 1) KOD YENİLEME — tek seviye. Geçerlilik artık AYLIK:
--    gelecek ayın 1'i 08:00 Türkiye saati (05:00 UTC).
-- ------------------------------------------------------------
create or replace function public.kod_yenile(p_seviye text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  yeni_kod text;
  tuz text;
  ay_sonu timestamptz;
begin
  yeni_kod := lpad((floor(random() * 9000) + 1000)::text, 4, '0');
  /* 24 + 24 haneli hex tuz, yerleşik md5(random()) ile (pgcrypto gerekmez) */
  tuz := substr(replace(md5(random()::text || clock_timestamp()::text), ' ', ''), 1, 24);
  tuz := tuz || substr(md5(clock_timestamp()::text || random()::text), 1, 24);
  -- gelecek ayın 1'i 08:00 Türkiye saati = 05:00 UTC
  ay_sonu := date_trunc('month', now() + interval '1 month') + interval '5 hours';
  insert into public.erisim_kod (seviye, kod_hash, hafta_tuz, kod_acik, gecerlilik)
  values (lower(p_seviye),
          encode(sha256(convert_to(yeni_kod || ':' || tuz, 'utf8')), 'hex'),
          tuz, yeni_kod, ay_sonu)
  on conflict (seviye) do update
    set kod_hash   = excluded.kod_hash,
        hafta_tuz  = excluded.hafta_tuz,
        kod_acik   = excluded.kod_acik,
        gecerlilik = excluded.gecerlilik,
        olusturma  = now();
  return yeni_kod;  -- yalnız bu çağrının yanıtında görünür
end;
$$;

revoke all on function public.kod_yenile(text) from anon, authenticated;

-- ------------------------------------------------------------
-- 2) GEÇİŞ: hâlâ geçerli olan (haftalık üretilmiş) kodların
--    geçerliliğini bu ayın sonuna uzat. Böylece sınıflara
--    dağıtılmış kodlar aniden geçersiz olmaz; bir sonraki
--    "🔄 Kodları Yenile" tıklamasından itibaren kodlar aylık olur.
-- ------------------------------------------------------------
update public.erisim_kod
set gecerlilik = date_trunc('month', now() + interval '1 month') + interval '5 hours'
where gecerlilik >= now()
  and gecerlilik < date_trunc('month', now() + interval '1 month') + interval '5 hours';

-- Bitti. Panel "🔑 Aylık Erişim Kodları" kartı → "Kodları Yenile"
-- bu şemadaki kodlari_yenile_tumu() fonksiyonunu çağırır; ürettiği
-- kodlar artık gelecek ayın 1'ine kadar geçerlidir.
