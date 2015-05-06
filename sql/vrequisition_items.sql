-- View: vrequisition_items

-- DROP VIEW vrequisition_items;

CREATE OR REPLACE VIEW vrequisition_items AS 
 SELECT a.ts_id,
    a.ts_artikal,
    a.ts_kolicina,
    a.ts_veza,
    b.art_sifra,
    b.art_naziv,
    b.jm_naziv,
    b.ag_naziv
   FROM trebovanje_stavke a,
    vproduct b
  WHERE b.art_id = a.ts_artikal
  ORDER BY a.ts_id;

ALTER TABLE vrequisition_items
  OWNER TO postgres;
