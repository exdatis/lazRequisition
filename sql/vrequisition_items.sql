create view vrequisition_items as
select 
  a.ts_id,
  a.ts_artikal,
  a.ts_kolicina,
  a.ts_veza,
  b.art_sifra,
  b.art_naziv,
  b.jm_naziv,
  b.ag_naziv
from
  trebovanje_stavke a,
  vproduct b
where
  b.art_id = a.ts_id
order by 
  a.ts_id