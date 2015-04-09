CREATE OR REPLACE VIEW vstorageout_items AS 
SELECT 
  a.mis_id,
  a.mis_artikal,
  a.mis_kolicina,
  a.mis_veza,
  b.art_sifra,
  b.art_naziv,
  b.jm_naziv,
  b.ag_naziv
FROM 
  mi_stavke a,
  vproduct b
where
  b.art_id = a.mis_artikal
order by
  a.mis_id