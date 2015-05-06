create or replace function copy_out(order_id integer, operater integer) returns integer as
$body$
declare this_date date;
declare this_time varchar(30);
declare new_id integer;
declare this_doc_id integer;
declare original_rec record;
declare items_rec record;
declare order_as_string varchar(15);
begin
  order_as_string = cast($1 as varchar(15));
  /* select current date */
  select current_date into this_date;
  /* select current time */
  select cast(current_time as varchar(30)) into this_time;
  /* doc id */
  this_doc_id = 3; /* interna prijemnica */
  /* new id */
  select nextval('mu_nalog_mu_id_seq') into new_id;

  /* select sorages from order */
  for original_rec in
  (select
    a.mi_magacin,
    a.mi_out
   from
     mi_nalog a
   where
     a.mi_id = $1)
   loop
	INSERT INTO 
	  mu_nalog(mu_id, 
		   mu_doc, 
		   mu_datum, 
		   mu_magacin, 
		   mu_notes, 
		   mu_out, 
		   mu_storno, 
		   mu_evident, 
		   mu_operater, 
		   mu_time, 
		   mu_osnov)
	    VALUES (new_id, 
		    this_doc_id, 
		    this_date, 
		    original_rec.mi_out, 
		    'Generisana prijemnica', 
		    original_rec.mi_magacin, 
		    'Ne', 
		    'Ne', 
		    $2, 
		    this_time, 
		    order_as_string);
   end loop;
   /* selektuj stavke i prenesi */
   for items_rec in
   (select
     b.mis_artikal,
     b.mis_kolicina
    from
      mi_stavke b
    where
      b.mis_veza = $1)
    loop
	INSERT INTO 
	  mu_stavke(mus_artikal, 
		    mus_kolicina, 
		    mus_veza)
	    VALUES (items_rec.mis_artikal,
		    items_rec.mis_kolicina,
		    new_id);
    end loop;
    /* return new id */
    return new_id;
end;

$body$
  LANGUAGE plpgsql
      