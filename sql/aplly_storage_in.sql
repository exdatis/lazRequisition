﻿create or replace function aplly_storage_in(order_id integer)
returns integer as
$body$
declare order_rec record;
declare items_rec record;
declare card_type integer;
declare count_rec integer;
begin
  /* count records */
  count_rec = 0;
  card_type = 2; /* prijemnica */
  for order_rec in
  (select
    a.mu_id as mu_id,
    a.mu_doc as mu_doc,
    a.mu_datum as mu_datum,
    a.mu_magacin as mu_magacin,
    a.mu_out as mu_dobavljac,
    b.doc_naziv as doc_naziv
   from
     mu_nalog a,
     doc_mulaz b
   where
     a.mu_id = $1
     and
     b.doc_id = a.mu_doc)
  loop
  /* ovde mala petlja */
    for items_rec in
    (select
      mus_artikal,
      mus_kolicina
     from
       mu_stavke
     where
       mus_veza = $1)
     loop
       /* unesi podatke u karticu */
       insert into kartica_a
         (ka_datum,
          ka_magacin,
          ka_artikal,
          ka_tip,
          doc_naziv,
          doc_id,
          magacin_saradnik,
          ka_plus,
          ka_razlika)
         values
        (order_rec.mu_datum,
        order_rec.mu_magacin,
        items_rec.mus_artikal,
        card_type,
        order_rec.doc_naziv,
        $1,
        order_rec.mu_dobavljac,
        items_rec.mus_kolicina,
        items_rec.mus_kolicina);
        count_rec = count_rec + 1;
     end loop;
      
  end loop;

  /* return counter */
  return count_rec;    
end;
$body$
language plpgsql