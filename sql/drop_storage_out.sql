create or replace function drop_storage_out(order_id integer) returns integer 
as
$body$
begin
DELETE FROM kartica_a Where ka_tip = 4 AND doc_id = $1;  
return 1;
end; 
$body$
language plpgsql