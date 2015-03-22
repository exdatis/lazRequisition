create view vproduct as
select
  a.art_id,
  a.art_sifra,
  a.art_naziv,
  b.jm_naziv,
  b.jm_oznaka,
  c.ag_naziv
from
  artikal a,
  mere b,
  artikal_grupa c
where
  b.jm_id = a.art_mera
  and
  c.ag_id = a.art_grupa
order by
  a.art_sifra
  