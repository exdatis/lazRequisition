create view vtmptr as 
select
  a.tmp_id,
  a.tmp_artikal,
  a.tmp_kol,
  a.tmp_magacin,
  b.art_sifra,
  b.art_naziv,
  c.jm_naziv,
  c.jm_oznaka
from
  tmptr a,
  artikal b,
  mere c
where
  b.art_id = a.tmp_artikal
  and
  c.jm_id = b.art_mera
order by
  a.tmp_id
