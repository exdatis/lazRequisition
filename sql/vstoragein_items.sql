CREATE OR REPLACE VIEW vstoragein_items AS 
SELECT 
  a.mus_id,
  a.mus_artikal,
  a.mus_kolicina,
  a.mus_veza,
  b.art_sifra,
  b.art_naziv,
  b.jm_naziv,
  b.ag_naziv
FROM 
  mu_stavke a,
  vproduct b
where
  b.art_id = a.mus_artikal
order by
  a.mus_id