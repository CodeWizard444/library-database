CREATE INDEX idx_carti_autori_id_autor 
ON public.carti_autori USING btree (id_autor);


CREATE INDEX idx_carti_autori_id_carte 
ON public.carti_autori USING btree (id_carte);


CREATE INDEX idx_comenzi_produse_id_comanda 
ON public.comenzi_produse USING btree (id_comanda);