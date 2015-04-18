create or replace function aplly_storage_out(order_id integer)
returns integer as
$body$
declare order_rec record;
declare items_rec record;
declare card_type integer;
declare count_rec integer;
begin
  /* count records */
  count_rec = 0;
  card_type = 4; /* predatnica */
  for order_rec in
  (select
    a.mi_id as mi_id,
    a.mi_doc as mi_doc,
    a.mi_datum as mi_datum,
    a.mi_magacin as mi_magacin,
    a.mi_out as mi_potrosac,
    b.doc_naziv as doc_naziv
   from
     mi_nalog a,
     doc_mizlaz b
   where
     a.mi_id = $1
     and
     b.doc_id = a.mi_doc)
  loop
  /* ovde mala petlja */
    for items_rec in
    (select
      mis_artikal,
      mis_kolicina
     from
       mi_stavke
     where
       mis_veza = $1)
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
          ka_minus,
          ka_razlika)
         values
        (order_rec.mi_datum,
        order_rec.mi_magacin,
        items_rec.mis_artikal,
        card_type,
        order_rec.doc_naziv,
        $1,
        order_rec.mi_potrosac,
        items_rec.mis_kolicina,
        -items_rec.mis_kolicina);
        count_rec = count_rec + 1;
     end loop;
      
  end loop;

  /* return counter */
  return count_rec;    
end;
$body$
language plpgsql