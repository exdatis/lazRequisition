select
  a.art_id,
  a.art_sifra,
  a.art_naziv,
  a.jm_naziv,
  a.ag_naziv,
  sum(b.ka_razlika)
from
  vproduct a,
  kartica_a b
where
  b.ka_artikal = a.art_id
  and
  b.ka_datum <= '2015-04-30'
  and
  ka_magacin = 1
group by
  a.art_id,
  a.art_sifra,
  a.art_naziv,
  a.jm_naziv,
  a.ag_naziv
order by
  a.art_sifra