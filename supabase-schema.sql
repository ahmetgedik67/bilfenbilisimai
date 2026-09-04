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

-- ---------- Öğretmenin oluşturduğu özel etkinlikler (onay akışı) ----------
-- Akış: öğretmen yükler → durum 'bekliyor' (yalnız yönetici görür) → yönetici onaylar
-- → durum 'onaylandi' (tüm kampüslerdeki öğrencilerin listelerine düşer) veya reddeder.
-- tip: 'dosya' (HTML dosyası yüklendi) | 'kod' (kopyala-yapıştır) | 'drive' (bağlantı)
-- seviyeler: JSON dizi, ör. ["s3","i5"] → 3. Sınıf + 5 IPT; ["s1","s4"] → 1. ve 4. sınıf;
--            ["i2","i7"] → 2 IPT ve 7 IPT; ["arac"] → Öğretmen Aracı (öğrencilere görünmez).
--            Eski sayı biçimi (["1"], ["3"]) uygulama tarafında çözülür: 1 → s1, 2..7 → i2..i7.
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
  olusturma_tarihi timestamptz not null default now()
);
create index if not exists ozel_etkinlik_campus_idx on ozel_etkinlik (campus_id);
create index if not exists ozel_etkinlik_durum_idx on ozel_etkinlik (durum);

-- ---------- Etkinlik atamaları (kampüs bazlı, öğretmen kontrolünde) ----------
create table if not exists etkinlik_atama (
  campus_id uuid references campus(id) on delete cascade,
  etkinlik_id text not null,
  aktif boolean not null default true,
  acilis timestamptz,
  kapanis timestamptz,
  guncelleme_tarihi timestamptz not null default now(),
  primary key (campus_id, etkinlik_id)
);

-- ---------- Tamamlanan etkinlikler (öğrenci başına puan kaydı) ----------
create table if not exists tamamlanan (
  id uuid primary key default gen_random_uuid(),
  ogrenci_id uuid references profil(id) on delete cascade,
  campus_id uuid references campus(id) on delete cascade,
  etkinlik_id text not null,
  puan integer not null default 10,
  tarih timestamptz not null default now(),
  unique (ogrenci_id, etkinlik_id)
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

drop policy if exists "campus_public_all" on campus;
create policy "campus_public_all" on campus for all to anon using (true) with check (true);
drop policy if exists "profil_public_all" on profil;
create policy "profil_public_all" on profil for all to anon using (true) with check (true);
drop policy if exists "etkinlik_atama_public_all" on etkinlik_atama;
create policy "etkinlik_atama_public_all" on etkinlik_atama for all to anon using (true) with check (true);
drop policy if exists "tamamlanan_public_all" on tamamlanan;
create policy "tamamlanan_public_all" on tamamlanan for all to anon using (true) with check (true);
drop policy if exists "ayar_public_all" on ayar;
create policy "ayar_public_all" on ayar for all to anon using (true) with check (true);
drop policy if exists "ozel_etkinlik_public_all" on ozel_etkinlik;
create policy "ozel_etkinlik_public_all" on ozel_etkinlik for all to anon using (true) with check (true);

-- ============================================================
-- GÜNCELLEME: Şemayı daha önce çalıştırdıysan bu bölümü de çalıştır.
-- Komutlar idempotenttir; her çalıştırmada güvenle yeniden RUN edilebilir.
-- Not: durum default'u 'onaylandi' YALNIZCA eski (onay akışı öncesi) kayıtların
-- yayında kalması içindir; yeni yüklemeler uygulama tarafından 'bekliyor' yazılır.
-- ============================================================
alter table ozel_etkinlik add column if not exists ogretmen_id uuid references profil(id) on delete set null;
alter table ozel_etkinlik add column if not exists ogretmen_ad text not null default '';
alter table ozel_etkinlik add column if not exists ogretmen_kullanici text not null default '';
alter table ozel_etkinlik add column if not exists durum text not null default 'onaylandi';
alter table ozel_etkinlik add column if not exists red_nedeni text not null default '';
alter table ozel_etkinlik add column if not exists onay_tarihi timestamptz;
alter table ozel_etkinlik add column if not exists gorsel text not null default '';
create index if not exists ozel_etkinlik_durum_idx on ozel_etkinlik (durum);

-- oyun_id → etkinlik_id yeniden adlandırma (mevcut tablolar için):
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='etkinlik_atama' AND column_name='oyun_id') THEN ALTER TABLE etkinlik_atama RENAME COLUMN oyun_id TO etkinlik_id; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tamamlanan' AND column_name='oyun_id') THEN ALTER TABLE tamamlanan RENAME COLUMN oyun_id TO etkinlik_id; END IF; END $$;

-- 'ayar' tablosu (eski kurulumlar için eksikse tamamlar):
create table if not exists ayar (anahtar text primary key, deger text not null, guncelleme_tarihi timestamptz not null default now());
alter table ayar enable row level security;