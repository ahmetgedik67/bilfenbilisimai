-- ============================================================
-- BILFEN BİLİŞİM AI — GÜVENLİK MİMARİSİ v2
-- Öğrenci hesabı yok · Haftalık erişim kodu (hash'li) ·
-- Yayın zamanı sunucuda zorlanır · Sonuç verisi saklanmaz
-- ------------------------------------------------------------
-- Kurulum: Supabase → SQL Editor → bu dosyanın tamamını
-- çalıştır (bir kez). Tekrar çalıştırmak güvenlidir.
--
-- ⚠️ 8. bölüm ESKİ ÖĞRENCİ VERİLERİNİ KALICI OLARAK SİLER
--    (KVKK veri minimizasyonu kararı gereği). Yedek almadan
--    çalıştırmayın.
-- ============================================================

-- ------------------------------------------------------------
-- 1) HAFTALIK ERİŞİM KODLARI
--    Doğrulama yalnız SHA-256(kod + ':' + hafta_tuz) hash'i
--    üzerinden yapılır. kod_acik sütunu yalnız öğretmen/yönetici
--    panelinin haftanın kodlarını görebilmesi içindir; öğrenci
--    hiçbir halükarda tabloya erişemez (bkz. bölüm 4).
-- ------------------------------------------------------------
create extension if not exists pgcrypto;  -- sha256 + gen_random_bytes için

create table if not exists public.erisim_kod (
  seviye        text primary key,            -- 's1'..'s7', 'i2'..'i7'
  kod_hash      text not null,               -- sha256 hex (kod + ':' + hafta_tuz)
  hafta_tuz     text not null,               -- her hafta yenilenen rastgele tuz
  kod_acik      text,                        -- öğretmen paneli için düz metin kopya (null = gösterilmez)
  olusturma     timestamptz not null default now(),
  gecerlilik    timestamptz not null default now()  -- kodun son geçerlilik anı
);

-- Eski kurulumdan gelen tabloya yeni sütunu garanti et (idempotent):
alter table public.erisim_kod add column if not exists kod_acik text;

-- ------------------------------------------------------------
-- 2) KOD DOĞRULAMA (güvenlik tanımlı) — kapı ekranı bunu çağırır.
--    Dönen değer: geçerliyse seviye, değilse null.
-- ------------------------------------------------------------
create or replace function public.kod_dogrula(p_seviye text, p_kod text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  k record;
  h text;
begin
  if p_seviye is null or p_kod is null then return null; end if;
  select * into k from public.erisim_kod where seviye = lower(p_seviye);
  if k is null then return null; end if;
  if k.gecerlilik < now() then return null; end if;   -- süresi doldu
  select encode(sha256(convert_to(p_kod || ':' || k.hafta_tuz, 'utf8')), 'hex') into h;
  if h = k.kod_hash then return lower(p_seviye); end if;
  return null;
end;
$$;

grant execute on function public.kod_dogrula(text, text) to anon, authenticated;

-- ------------------------------------------------------------
-- 3) KOD YENİLEME — tek seviye (dahili) + tüm seviyeler (panel)
--    Yeni kod yalnız çağrının YANITINDA bir kez döner;
--    tablodan asla okunamaz (bkz. bölüm 4).
--    NOT: Panel anon anahtarla çağırır; bu yüzden anon'a execute
--    verilir. Panel gerçek sunucu kimlik doğrulaması içermez —
--    riski KVKK-UYUM.md "Bilinen sınırlar" bölümünde anlatılır.
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
  hafta_sonu timestamptz;
begin
  yeni_kod := lpad((floor(random() * 9000) + 1000)::text, 4, '0');
  /* pgcrypto gerektirmez: 24 haneli hex tuz, yerleşik md5(random()) ile */
  tuz := substr(replace(md5(random()::text || clock_timestamp()::text), ' ', ''), 1, 24);
  tuz := tuz || substr(md5(clock_timestamp()::text || random()::text), 1, 24);
  -- gelecek pazartesi 08:00 Türkiye saati = 05:00 UTC
  hafta_sonu := date_trunc('week', now() + interval '7 days') + interval '5 hours';
  insert into public.erisim_kod (seviye, kod_hash, hafta_tuz, kod_acik, gecerlilik)
  values (lower(p_seviye),
          encode(sha256(convert_to(yeni_kod || ':' || tuz, 'utf8')), 'hex'),
          tuz, yeni_kod, hafta_sonu)
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

create or replace function public.kodlari_yenile_tumu()
returns table (seviye text, kod text)
language plpgsql
security definer
set search_path = public
as $$
declare
  sv text;
  yeni text;
begin
  foreach sv in array array['s1','s2','s3','s4','s5','s6','s7','i2','i3','i4','i5','i6','i7'] loop
    select kod_yenile(sv) into yeni;
    seviye := sv;
    kod := yeni;
    return next;
  end loop;
end;
$$;

grant execute on function public.kodlari_yenile_tumu() to anon, authenticated;

-- ------------------------------------------------------------
-- 3b) KOD OKUMA — öğretmen/yönetici paneli haftanın kodlarını
--    otomatik görsün diye. Yalnız GEÇERLİ kodu döner; süresi
--    dolmuş kod gösterilmez. Doğrulama hâlâ hash üzerinden
--    yapılır; kod_acik yalnız panel görüntülemesidir.
-- ------------------------------------------------------------
create or replace function public.kodlari_oku()
returns table (seviye text, kod text, gecerlilik timestamptz)
language sql
security definer
set search_path = public
as $$
  select e.seviye, e.kod_acik, e.gecerlilik
  from public.erisim_kod e
  where e.kod_acik is not null
    and e.gecerlilik >= now()
  order by e.seviye;
$$;

grant execute on function public.kodlari_oku() to anon, authenticated;

-- ------------------------------------------------------------
-- 4) ERİŞİM KODU TABLOSUNA DOĞRUDAN ERİŞİM TAMAMEN KAPALI
--    (hash bile okunamaz; doğrulama yalnız RPC ile)
-- ------------------------------------------------------------
alter table public.erisim_kod enable row level security;
drop policy if exists "erisim_kod_anon_yok" on public.erisim_kod;
create policy "erisim_kod_anon_yok" on public.erisim_kod
  for all to anon, authenticated using (false) with check (false);

-- ------------------------------------------------------------
-- 5) PROFİL TABLOSU — YENİ ÖĞRENCİ HESABI OLUŞTURULAMAZ
--    Eski açık politika (profil_public_all) kapatılır; okuma
--    kalır çünkü öğretmen girişi (PBKDF2 doğrulama akışı)
--    okuma gerektirir. Yazar: artık rol='ogrenci' satır
--    eklenemez/güncellenemez — yeni öğrenci hesabı DB seviyesinde
--    engellenir. Öğrenci satırı silinebilir (temizlik için).
-- ------------------------------------------------------------
drop policy if exists "profil_public_all" on public.profil;
drop policy if exists "anon ogrenci profili okur" on public.profil;
drop policy if exists "anon profil okur" on public.profil;

create policy "profil_anon_okur" on public.profil
  for select to anon using (true);

create policy "profil_anon_ekler_ogrenci_haric" on public.profil
  for insert to anon with check (rol is distinct from 'ogrenci');

create policy "profil_anon_gunceller_ogrenci_haric" on public.profil
  for update to anon using (rol is distinct from 'ogrenci')
  with check (rol is distinct from 'ogrenci');

create policy "profil_anon_siler_yalniz_ogrenci" on public.profil
  for delete to anon using (rol = 'ogrenci');

-- ------------------------------------------------------------
-- 6) TAMAMLANAN TABLOSU — ARTIK HİÇBİR ŞEY YAZMAZ
--    Yeni sonuç verisi toplanamaz: anon yalnız okuyabilir
--    (yönetici raporu bozulmasın), ekleyemez/silemez.
--    Eski satırlar bölüm 8'de silinir.
-- ------------------------------------------------------------
alter table public.tamamlanan enable row level security;
drop policy if exists "tamamlanan_public_all" on public.tamamlanan;
drop policy if exists "anon tamamlanan okur" on public.tamamlanan;
drop policy if exists "anon tamamlanan yazar" on public.tamamlanan;
drop policy if exists "anon tamamlanan siler" on public.tamamlanan;

create policy "tamamlanan_anon_okur" on public.tamamlanan
  for select to anon using (true);

-- ------------------------------------------------------------
-- 7) YAYIN ZAMANI SUNUCUDA ZORLANIR (öğrenci için güvenli görünüm)
--    Öğrenciye yalnız: durum='onaylandi' VE aktif atama
--    (acilis <= simdi < kapanis) olan özel etkinlikler döner.
-- ------------------------------------------------------------
create or replace view public.ozel_etkinlik_ogrenci
with (security_invoker = false) as
select o.id, o.ad, o.konu, o.seviyeler, o.tip, o.gorsel,
       o.olusturma_tarihi
from public.ozel_etkinlik o
where o.durum = 'onaylandi'
  and exists (
    select 1 from public.etkinlik_atama a
    where a.oyun_id = 'ozel:' || o.id::text
      and a.aktif = true
      and (a.acilis is null or a.acilis <= now())
      and (a.kapanis is null or a.kapanis > now())
  );

grant select on public.ozel_etkinlik_ogrenci to anon;

-- Dış etkinlik atamaları için aktif (içinde zaman aralığı olan) görünüm:
create or replace view public.etkinlik_atama_aktif as
select a.oyun_id, a.acilis, a.kapanis, a.aktif
from public.etkinlik_atama a
where a.aktif = true
  and (a.acilis is null or a.acilis <= now())
  and (a.kapanis is null or a.kapanis > now());

grant select on public.etkinlik_atama_aktif to anon;

-- ------------------------------------------------------------
-- 8) ⚠️ ESKİ ÖĞRENCİ VERİSİNİN KALICI SİLİNMESİ (KVKK veri
--    minimizasyonu). Kurul onayıyla: tüm öğrenci profilleri ve
--    tüm tamamlanan kayıtları silinir. Öğretmen/yönetici
--    hesapları etkilenmez. Bu dosya tekrar çalıştırılsa da
--    silme işlemi tekrar edilebilir ama veri zaten boştur.
-- ------------------------------------------------------------
delete from public.tamamlanan;
delete from public.profil where rol = 'ogrenci';

-- Bitti. Panel "🔑 Haftalık Erişim Kodları" kartı → "Kodları Yenile"
-- bu şemadaki kodlari_yenile_tumu() fonksiyonunu çağırır.
