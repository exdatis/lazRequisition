create or replace function set_requisition_items(storage_id integer, order_id integer) returns
integer as
$body$
declare
  items record;
begin
  for items in
    (select
      tmp_artikal,
      tmp_kol
     from
      tmptr
     where
      tmp_magacin = $1)
    loop
      insert into trebovanje_stavke
      (ts_artikal,
       ts_kolicina,
       ts_veza)
       values
       (items.tmp_artikal,
        items.tmp_kol,
        $2);
     end loop;

   /* return success */
   return 1;
end;

$body$
  LANGUAGE plpgsql
      
  