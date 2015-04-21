CREATE TYPE product_review AS
   (rec_no integer,
    this_date date,
    doc_name character varying(30),
    doc_id integer,
    partner character varying(90),
    turnover numeric(12,3),
    curr_state numeric(12,3),
    measure character varying(30))