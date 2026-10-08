-- ============================================================
-- BILFEN BİLİŞİM AI — YENİ SUPABASE PROJESİ TAM KURULUM (v2.8.11)
-- Sıfırdan (boş) proje için tek dosyalık kurulum. Geçmişteki
-- yamaların (atama-duzelt, yayın-tarihi, güvenlik-v2, aylık kod)
-- BİRLEŞMİŞ SON HALİDİR.
--
-- Öğrenci verisi SİLMEZ. Tekrar çalıştırmak güvenlidir.
-- Çalıştırma sırası: 1) bu dosya  2) veri-tasima.sql (varsa)
-- ============================================================

create extension if not exists pgcrypto;

-- ---------- Kampüsler ----------
create table if not exists campus (
  id uuid primary key default gen_random_uuid(),
  ad text not null,
  olusturma_tarihi timestamptz not null default now()
);
create unique index if not exists campus_ad_unique on campus (lower(ad));
insert into campus (ad) values
  ('Çamlıca'), ('Ataşehir'), ('Koşuyolu'), ('Sancaktepe'), ('Yenişehir'),
  ('Esenşehir'), ('Kurtköy'), ('Halkalı'), ('Maslak'), ('Bahçeşehir'),
  ('Florya'), ('Çayyolu'), ('Bornova'), ('Güzelbahçe'), ('Bursa'),
  ('Antalya'), ('Kayseri'), ('Çukurambar'), ('Oran'), ('İskenderun')
on conflict (lower(ad)) do nothing;

-- ---------- Profiller (öğretmen + öğrenciler) ----------
create table if not exists profil (
  id uuid primary key default gen_random_uuid(),
  campus_id uuid references campus(id) on delete cascade,
  kullanici_adi text not null unique,
  sifre_tuz text not null,
  sifre_hash text not null,
  ad text not null,
  rol text not null check (rol in ('ogretmen','ogrenci')),
  avatar text not null default '🐣',
  puan integer not null default 0,
  olusturma_tarihi timestamptz not null default now()
);

-- ---------- Özel etkinlikler (onay akışı, tüm sütunlar dahil) ----------
create table if not exists ozel_etkinlik (
  id uuid primary key default gen_random_uuid(),
  campus_id uuid references campus(id) on delete cascade,
  ogretmen_id uuid references profil(id) on delete set null,
  ogretmen_ad text not null default '',
  ogretmen_kullanici text not null default '',
  ad text not null,
  konu text not null default '',
  seviyeler text not null default '[]',
  tip text not null check (tip in ('dosya','drive','kod')),
  icerik text not null default '',
  durum text not null default 'bekliyor' check (durum in ('bekliyor','onaylandi','reddedildi')),
  red_nedeni text not null default '',
  onay_tarihi timestamptz,
  olusturma_tarihi timestamptz not null default now(),
  gorsel text not null default '',
  acilis timestamptz,
  kapanis timestamptz
);
create index if not exists ozel_etkinlik_campus_idx on ozel_etkinlik (campus_id);
create index if not exists ozel_etkinlik_durum_idx on ozel_etkinlik (durum);

-- ---------- Etkinlik atamaları (etkinlik-bazlı, v2.1) ----------
create table if not exists etkinlik_atama (
  campus_id uuid references campus(id) on delete cascade,
  oyun_id text not null,
  aktif boolean not null default true,
  acilis timestamptz,
  kapanis timestamptz,
  guncelleme_tarihi timestamptz not null default now(),
  primary key (oyun_id)
);

-- ---------- Tamamlanan (yazma kapalı — KVKK) ----------
create table if not exists tamamlanan (
  id uuid primary key default gen_random_uuid(),
  ogrenci_id uuid references profil(id) on delete cascade,
  campus_id uuid references campus(id) on delete cascade,
  etkinlik_id text not null,
  puan integer not null default 10,
  tarih timestamptz not null default now(),
  unique (ogrenci_id, etkinlik_id)
);

-- ---------- Ayarlar ----------
create table if not exists ayar (
  anahtar text primary key,
  deger text not null,
  guncelleme_tarihi timestamptz not null default now()
);

create index if not exists profil_campus_idx on profil (campus_id);
create index if not exists tamamlanan_ogrenci_idx on tamamlanan (ogrenci_id);
create index if not exists tamamlanan_campus_idx on tamamlanan (campus_id);

-- ============================================================
-- RLS POLİTİKALARI (güvenlik-v2 son hali)
-- ============================================================
alter table campus enable row level security;
alter table profil enable row level security;
alter table etkinlik_atama enable row level security;
alter table tamamlanan enable row level security;
alter table ayar enable row level security;
alter table ozel_etkinlik enable row level security;

drop policy if exists "campus_public_all" on campus;
create policy "campus_public_all" on campus for all to anon using (true) with check (true);
drop policy if exists "etkinlik_atama_public_all" on etkinlik_atama;
create policy "etkinlik_atama_public_all" on etkinlik_atama for all to anon using (true) with check (true);
drop policy if exists "ayar_public_all" on ayar;
create policy "ayar_public_all" on ayar for all to anon using (true) with check (true);
drop policy if exists "ozel_etkinlik_public_all" on ozel_etkinlik;
create policy "ozel_etkinlik_public_all" on ozel_etkinlik for all to anon using (true) with check (true);

-- profil: okuma açık, öğrenci satırı yazılamaz/silinebilir
drop policy if exists "profil_public_all" on profil;
drop policy if exists "profil_anon_okur" on profil;
create policy "profil_anon_okur" on profil
  for select to anon using (true);
drop policy if exists "profil_anon_ekler_ogrenci_haric" on profil;
create policy "profil_anon_ekler_ogrenci_haric" on profil
  for insert to anon with check (rol is distinct from 'ogrenci');
drop policy if exists "profil_anon_gunceller_ogrenci_haric" on profil;
create policy "profil_anon_gunceller_ogrenci_haric" on profil
  for update to anon using (rol is distinct from 'ogrenci')
  with check (rol is distinct from 'ogrenci');
drop policy if exists "profil_anon_siler_yalniz_ogrenci" on profil;
create policy "profil_anon_siler_yalniz_ogrenci" on profil
  for delete to anon using (rol = 'ogrenci');

-- tamamlanan: yalnız okuma (yeni sonuç verisi toplanamaz)
drop policy if exists "tamamlanan_public_all" on tamamlanan;
drop policy if exists "tamamlanan_anon_okur" on tamamlanan;
create policy "tamamlanan_anon_okur" on tamamlanan
  for select to anon using (true);

-- ============================================================
-- AYLIK ERİŞİM KODLARI (güvenlik-v2 §1-4 + aylık geçiş)
-- ============================================================
create table if not exists public.erisim_kod (
  seviye        text primary key,
  kod_hash      text not null,
  hafta_tuz     text not null,
  kod_acik      text,
  olusturma     timestamptz not null default now(),
  gecerlilik    timestamptz not null default now()
);
alter table public.erisim_kod add column if not exists kod_acik text;

alter table public.erisim_kod enable row level security;
drop policy if exists "erisim_kod_anon_yok" on public.erisim_kod;
create policy "erisim_kod_anon_yok" on public.erisim_kod
  for all to anon, authenticated using (false) with check (false);

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
  if k.gecerlilik < now() then return null; end if;
  select encode(sha256(convert_to(p_kod || ':' || k.hafta_tuz, 'utf8')), 'hex') into h;
  if h = k.kod_hash then return lower(p_seviye); end if;
  return null;
end;
$$;

grant execute on function public.kod_dogrula(text, text) to anon, authenticated;

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
  tuz := substr(replace(md5(random()::text || clock_timestamp()::text), ' ', ''), 1, 24);
  tuz := tuz || substr(md5(clock_timestamp()::text || random()::text), 1, 24);
  -- gelecek ayın 1'i 08:00 Türkiye saati = 05:00 UTC (AYLIK kod)
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
  return yeni_kod;
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

create or replace function public.kod_sure_bilgisi(p_seviye text)
returns table (gecerli boolean, gecerlilik timestamptz)
language sql
security definer
set search_path = public
as $$
  select (e.gecerlilik >= now()) as gecerli, e.gecerlilik
  from public.erisim_kod e
  where e.seviye = lower(p_seviye);
$$;

grant execute on function public.kod_sure_bilgisi(text) to anon, authenticated;

-- ============================================================
-- GÜVENLİ GÖRÜNÜMLER (yayın-tarihi + güvenlik-v2 son hali)
-- ============================================================
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

create or replace view public.etkinlik_atama_aktif as
select a.oyun_id, a.acilis, a.kapanis, a.aktif
from public.etkinlik_atama a
where a.aktif = true
  and (a.acilis is null or a.acilis <= now())
  and (a.kapanis is null or a.kapanis > now());

grant select on public.etkinlik_atama_aktif to anon;

-- Bitti. Bu dosyadan sonra veri-tasima.sql çalıştırılırsa veriler taşınır;
-- sonra panelde "🔄 Kodları Yenile" ile aylık kodlar üretilir.
