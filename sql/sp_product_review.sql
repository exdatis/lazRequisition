create or replace function sp_product_review(date_min date, 
					     date_max date, 
					     curr_product integer,
					     curr_storage integer)
returns setof product_review
as
$body$
declare r product_review%rowtype;
declare card_rec record;
declare res_state numeric(12,3);
declare partner_name varchar(90);
declare curr_type integer;
declare measure_name varchar(70);
/* 3 je ulazna faktura */
begin
  /* curr_state = 0 */
  res_state = 0;
  /* find measure */
  select jm_naziv into measure_name
  from mere
  where jm_id IN(select art_mera 
		 from artikal where 
		 art_id = $3);
  /* query */
  for card_rec in
  (select
    a.ka_id,
    a.ka_datum,
    a.ka_tip,
    a.doc_naziv,
    a.doc_id,
    a.id_klijent,
    a.magacin_saradnik,
    a.ka_razlika
   from
     kartica_a a
   where
     a.ka_datum >= $1
     and
     a.ka_datum <= $2
     and
     a.ka_magacin = $4
     and
     a.ka_artikal = $3
   order by
     a.ka_datum,
     a.ka_tip)
     /* loop */
   loop
     if (card_rec.ka_tip = 3) then
       select pl_naziv into partner_name 
       from p_lica
       where pl_id = card_rec.id_klijent;
     else
       select m_naziv into partner_name
       from magacin
       where m_id = card_rec.magacin_saradnik; 
     end if;
     /* check partner_name */
     if(partner_name is null) then
       partner_name = '-';
     end if;
     /* set values for rec */
     r.rec_no = card_rec.ka_id;
     r.this_date = card_rec.ka_datum;
     r.doc_name = card_rec.doc_naziv;
     r.doc_id = card_rec.doc_id;
     r.partner = partner_name;
     r.turnover = card_rec.ka_razlika;
     res_state = res_state + card_rec.ka_razlika;
     r.curr_state = res_state;
     r.measure = measure_name;

     return next r;
   end loop;

   return;
     
end;
$body$
language plpgsql;