-- ============================================================
-- BILFEN BİLİŞİM AI — ETKİNLİK ATAMA TABLOSU DÜZELTMESİ (v2.1)
-- Sorun: etkinlik_atama tablosunda birincil anahtar gerçekten
-- kurulmamıştı; aynı etkinlik için kampüs başına birden çok satır
-- birikmişti (aktif=false kopyalar öğrenci görünümlerini ve
-- paneli yanıltıyordu). v2'de atamalar ETKİNLİK bazlıdır
-- (campus_id boş kalır) ve upsert oyun_id üzerinden çalışır.
-- Çalıştırma: Supabase SQL Editor → bu dosyanın tamamı.
-- Tekrar çalıştırılması güvenlidir (idempotent).
-- ============================================================

-- 1) Aynı oyun_id için birden çok satır varsa yalnız BİRİNİ tut:
--    tercih sırası: campus_id boş (yeni etkinlik-bazlı) satır > en yeni güncelleme.
delete from public.etkinlik_atama a
using public.etkinlik_atama b
where a.oyun_id = b.oyun_id
  and a.ctid <> b.ctid
  and (
    (b.campus_id is null and a.campus_id is not null)
    or (b.campus_id is null and a.campus_id is null and a.guncelleme_tarihi < b.guncelleme_tarihi)
    or (b.campus_id is not null and a.campus_id is not null
        and coalesce(a.guncelleme_tarihi, 'epoch') < coalesce(b.guncelleme_tarihi, 'epoch'))
  );

-- 2) Birincil anahtarı kur (yoksa). Panel upsert'i bundan sonra
--    aynı satırı günceller; çoklu satır birikmez.
alter table public.etkinlik_atama
  drop constraint if exists etkinlik_atama_pkey;
alter table public.etkinlik_atama
  add constraint etkinlik_atama_pkey primary key (oyun_id);

-- 3) campus_id artık zorunlu DEĞİL: v2'de atamalar etkinlik bazlıdır,
--    panel (yönetici oturumu dahil) campus göndermeden yazar.
alter table public.etkinlik_atama
  alter column campus_id drop not null;

-- 4) Kontrol: tablo başına tek satır kalmalı.
--    select oyun_id, count(*) from public.etkinlik_atama group by 1 order by 2 desc;
