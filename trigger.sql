CREATE TRIGGER trg_log_pret_carte 
AFTER UPDATE ON public.carti 
FOR EACH ROW EXECUTE FUNCTION log_pret_carte();