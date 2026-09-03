-- ============================================================
-- Bilfen Bilişim AI – Portal & Panel veritabanı şeması
-- Bu dosyayı Supabase Dashboard → SQL Editor'a yapıştırıp RUN de.
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- Kampüsler (öğretmen kayıt olunca oluşur) ----------
create table if not exists campus (
  id uuid primary key default gen_random_uuid(),
  ad text not null,
  olusturma_tarihi timestamptz not null default now()
);

-- ---------- Profiller (öğretmen + öğrenciler) ----------
-- Giriş: basit kullanıcı adı + şifre (şifreler PBKDF2-SHA256 ile tuzlanır)
-- Not: Genel sistem yöneticisi (admin) veritabanında saklanmaz; uygulama
-- katmanında doğrulanır (panel.html içindeki ADMIN_HASH) ve tüm kayıtlara
-- uygulama üzerinden erişir. Rol değerleri bu tabloda yalnız ogretmen/ogrenci olabilir.
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

-- ---------- Öğretmenin oluşturduğu özel etkinlikler (kampüs bazlı) ----------
-- tip: 'dosya' (HTML dosyası yüklendi) | 'kod' (kopyala-yapıştır) | 'drive' (bağlantı)
-- seviyeler: JSON dizi, ör. ["2","5"] → 2 IPT ve 5 IPT; ["1"] → 1. Sınıf
create table if not exists ozel_etkinlik (
  id uuid primary key default gen_random_uuid(),
  campus_id uuid references campus(id) on delete cascade,
  ad text not null,
  konu text not null default '',
  seviyeler text not null default '[]',
  tip text not null check (tip in ('dosya','drive','kod')),
  icerik text not null default '',
  olusturma_tarihi timestamptz not null default now()
);
create index if not exists ozel_etkinlik_campus_idx on ozel_etkinlik (campus_id);

-- ---------- Etkinlik atamaları (kampüs bazlı, öğretmen kontrolünde) ----------
create table if not exists etkinlik_atama (
  campus_id uuid references campus(id) on delete cascade,
  oyun_id text not null,
  aktif boolean not null default true,
  acilis timestamptz,
  kapanis timestamptz,
  guncelleme_tarihi timestamptz not null default now(),
  primary key (campus_id, oyun_id)
);

-- ---------- Tamamlanan etkinlikler (öğrenci başına puan kaydı) ----------
create table if not exists tamamlanan (
  id uuid primary key default gen_random_uuid(),
  ogrenci_id uuid references profil(id) on delete cascade,
  campus_id uuid references campus(id) on delete cascade,
  oyun_id text not null,
  puan integer not null default 10,
  tarih timestamptz not null default now(),
  unique (ogrenci_id, oyun_id)
);

-- ---------- Ayarlar (genel sistem yöneticisi şifresi burada saklanır) ----------
-- Anahtar: 'admin_sifre' → değer: { "tuz": "...", "hash": "..." } (PBKDF2)
-- Panel içindeki "Yönetici Şifresini Değiştir" kartı burayı günceller.
create table if not exists ayar (
  anahtar text primary key,
  deger text not null,
  guncelleme_tarihi timestamptz not null default now()
);

create index if not exists profil_campus_idx on profil (campus_id);
create index if not exists tamamlanan_ogrenci_idx on tamamlanan (ogrenci_id);
create index if not exists tamamlanan_campus_idx on tamamlanan (campus_id);

-- ============================================================
-- RLS politikaları
-- Not: Bu araç sınıf içi kullanım içindir; kimlik doğrulama uygulama
-- katmanında yapılır (basit kullanıcı adı + şifre). Bu yüzden
-- politikalar herkese açık okuma/yazma izni verir. Üretim için
-- Supabase Auth'a geçilip politikalar auth.uid() ile daraltılmalıdır.
-- ============================================================
alter table campus enable row level security;
alter table profil enable row level security;
alter table etkinlik_atama enable row level security;
alter table tamamlanan enable row level security;
alter table ayar enable row level security;
alter table ozel_etkinlik enable row level security;

create policy "campus_public_all" on campus for all to anon using (true) with check (true);
create policy "profil_public_all" on profil for all to anon using (true) with check (true);
create policy "etkinlik_atama_public_all" on etkinlik_atama for all to anon using (true) with check (true);
create policy "tamamlanan_public_all" on tamamlanan for all to anon using (true) with check (true);
create policy "ayar_public_all" on ayar for all to anon using (true) with check (true);
create policy "ozel_etkinlik_public_all" on ozel_etkinlik for all to anon using (true) with check (true);

-- Not: Şemayı daha önce çalıştırdıysan yukarıdaki 'ayar' tablosu ve politikası için
-- aşağıdaki üç komutu da ayrıca çalıştırman yeterlidir (idempotent):
--   create table if not exists ayar (anahtar text primary key, deger text not null, guncelleme_tarihi timestamptz not null default now());
--   alter table ayar enable row level security;
--   create policy "ayar_public_all" on ayar for all to anon using (true) with check (true);