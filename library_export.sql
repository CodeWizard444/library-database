--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-05-12 18:50:21

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 238 (class 1255 OID 32810)
-- Name: adauga_carte_si_autor(character varying, character varying, numeric, integer, numeric, integer, date, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.adauga_carte_si_autor(IN p_titlu character varying, IN p_gen character varying, IN p_isbn numeric, IN p_nr_pag integer, IN p_pret numeric, IN p_id_editura integer, IN p_data_pub date, IN p_id_autor integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    id_carte_nou INT;
BEGIN
    -- Inserăm cartea
    INSERT INTO carti(titlu, gen_literar, isbn, nr_pagini, pret_unitar, id_editura, data_publicare)
    VALUES (p_titlu, p_gen, p_isbn, p_nr_pag, p_pret, p_id_editura, p_data_pub)
    RETURNING id_carte INTO id_carte_nou;

    -- Legăm autorul
    INSERT INTO carti_autori(id_carte, id_autor)
    VALUES (id_carte_nou, p_id_autor);
END;
$$;


ALTER PROCEDURE public.adauga_carte_si_autor(IN p_titlu character varying, IN p_gen character varying, IN p_isbn numeric, IN p_nr_pag integer, IN p_pret numeric, IN p_id_editura integer, IN p_data_pub date, IN p_id_autor integer) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 32826)
-- Name: log_pret_carte(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_pret_carte() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN 
IF NEW.pret_unitar <> OLD.pret_unitar THEN
INSERT INTO log_modificari_pret(id_carte,pret_vechi,pret_nou)
VALUES (OLD.id_carte,OLD.pret_unitar,NEW.pret_unitar);
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_pret_carte() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 32809)
-- Name: nr_carti_autor(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nr_carti_autor(p_id_autor integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
rezultat INT;
BEGIN 
SELECT COUNT(*)
INTO rezultat
FROM carti_autori
WHERE id_autor = p_id_autor;
RETURN rezultat;
END;
$$;


ALTER FUNCTION public.nr_carti_autor(p_id_autor integer) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 32812)
-- Name: stoc_carte(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stoc_carte(p_id_carte integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
total INT;
BEGIN 
SELECT SUM(cantitate)
INTO total
FROM stocuri
WHERE id_carte = p_id_carte;
RETURN COALESCE(total,0);
END;
$$;


ALTER FUNCTION public.stoc_carte(p_id_carte integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 32807)
-- Name: tota_comanda(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.tota_comanda(p_id_comanda integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
total NUMERIC :=0;
BEGIN 
SELECT SUM(cantitate * pret)
INTO total 
FROM comenzi_produse
WHERE id_comanda = p_id_comanda;
RETURN COALESCE(total,0);
END;
$$;


ALTER FUNCTION public.tota_comanda(p_id_comanda integer) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 32813)
-- Name: total_comanda(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.total_comanda(p_id_comanda integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
total NUMERIC :=0;
BEGIN 
SELECT SUM(cantitate * pret)
INTO total 
FROM comenzi_produse
WHERE id_comanda = p_id_comanda;
RETURN COALESCE(total,0);
END;
$$;


ALTER FUNCTION public.total_comanda(p_id_comanda integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 24642)
-- Name: angajati; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.angajati (
    id_angajat integer NOT NULL,
    nume character varying(100),
    functie character varying(50),
    salariu integer,
    data_anagajare date NOT NULL
);


ALTER TABLE public.angajati OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 24598)
-- Name: autori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.autori (
    id_autor integer NOT NULL,
    nume character varying(100),
    tara_origine character varying(30),
    data_nasterii date NOT NULL
);


ALTER TABLE public.autori OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 32814)
-- Name: carti_id_carte_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.carti_id_carte_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.carti_id_carte_seq OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 24608)
-- Name: carti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carti (
    id_carte integer DEFAULT nextval('public.carti_id_carte_seq'::regclass) NOT NULL,
    titlu character varying(100),
    gen_literar character varying(25),
    isbn numeric(13,0),
    nr_pagini integer,
    pret_unitar numeric(6,2),
    id_editura integer NOT NULL,
    data_publicare date NOT NULL
);


ALTER TABLE public.carti OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 24620)
-- Name: carti_autori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carti_autori (
    id_autor integer NOT NULL,
    id_carte integer NOT NULL
);


ALTER TABLE public.carti_autori OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 24635)
-- Name: clienti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clienti (
    id_client integer NOT NULL,
    nume character varying(100),
    email character varying(50),
    nr_telefon numeric(10,0),
    data_inregistrare date NOT NULL
);


ALTER TABLE public.clienti OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 24680)
-- Name: comenzi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comenzi (
    id_comanda integer NOT NULL,
    id_client integer NOT NULL,
    data_comanda date NOT NULL,
    id_angajat integer NOT NULL,
    status character varying(20),
    CONSTRAINT chk_status CHECK (((status)::text = ANY ((ARRAY['plasata'::character varying, 'in procesare'::character varying, 'expediata'::character varying, 'primita'::character varying, 'anulata'::character varying])::text[])))
);


ALTER TABLE public.comenzi OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 24696)
-- Name: comenzi_produse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comenzi_produse (
    id_comanda integer NOT NULL,
    id_carte integer NOT NULL,
    cantitate integer,
    pret numeric(6,2)
);


ALTER TABLE public.comenzi_produse OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 32794)
-- Name: comenzidetaliate; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.comenzidetaliate AS
 SELECT c.id_comanda,
    cl.nume,
    crt.titlu,
    cp.cantitate,
    cp.pret,
    ((cp.cantitate)::numeric * cp.pret) AS total
   FROM (((public.comenzi c
     JOIN public.clienti cl ON ((c.id_client = cl.id_client)))
     JOIN public.comenzi_produse cp ON ((c.id_comanda = cp.id_comanda)))
     JOIN public.carti crt ON ((cp.id_carte = crt.id_carte)));


ALTER VIEW public.comenzidetaliate OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 24603)
-- Name: edituri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.edituri (
    id_editura integer NOT NULL,
    nume character varying(100),
    tara character varying(30),
    website character varying(100)
);


ALTER TABLE public.edituri OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 24647)
-- Name: furnizori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.furnizori (
    id_furnizor integer NOT NULL,
    denumire character varying(50),
    email character varying(50),
    telefon numeric(10,0),
    tara character varying(30)
);


ALTER TABLE public.furnizori OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 32817)
-- Name: log_modificari_pret; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_modificari_pret (
    id_log integer NOT NULL,
    id_carte integer,
    pret_vechi numeric,
    pret_nou numeric,
    data_modificare timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.log_modificari_pret OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 32816)
-- Name: log_modificari_pret_id_log_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_modificari_pret_id_log_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_modificari_pret_id_log_seq OWNER TO postgres;

--
-- TOC entry 4968 (class 0 OID 0)
-- Dependencies: 232
-- Name: log_modificari_pret_id_log_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_modificari_pret_id_log_seq OWNED BY public.log_modificari_pret.id_log;


--
-- TOC entry 224 (class 1259 OID 24665)
-- Name: stocuri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stocuri (
    id_carte integer NOT NULL,
    id_furnizor integer NOT NULL,
    cantitate integer,
    data_ultima_receptie date NOT NULL
);


ALTER TABLE public.stocuri OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 32799)
-- Name: stocuridetaliate; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.stocuridetaliate AS
 SELECT s.id_carte,
    crt.titlu,
    f.denumire AS furnizor,
    s.cantitate,
    s.data_ultima_receptie
   FROM ((public.stocuri s
     JOIN public.carti crt ON ((s.id_carte = crt.id_carte)))
     JOIN public.furnizori f ON ((s.id_furnizor = f.id_furnizor)));


ALTER VIEW public.stocuridetaliate OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 32790)
-- Name: topautori; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.topautori AS
 SELECT a.nume,
    count(ca.id_carte) AS nr_carti
   FROM (public.autori a
     JOIN public.carti_autori ca ON ((a.id_autor = ca.id_autor)))
  GROUP BY a.id_autor, a.nume;


ALTER VIEW public.topautori OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 32803)
-- Name: venitcarte; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.venitcarte AS
 SELECT crt.id_carte,
    crt.titlu,
    sum(((cp.cantitate)::numeric * cp.pret)) AS venit_total
   FROM (public.carti crt
     JOIN public.comenzi_produse cp ON ((crt.id_carte = cp.id_carte)))
  GROUP BY crt.id_carte, crt.titlu;


ALTER VIEW public.venitcarte OWNER TO postgres;

--
-- TOC entry 4759 (class 2604 OID 32820)
-- Name: log_modificari_pret id_log; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_modificari_pret ALTER COLUMN id_log SET DEFAULT nextval('public.log_modificari_pret_id_log_seq'::regclass);


--
-- TOC entry 4955 (class 0 OID 24642)
-- Dependencies: 222
-- Data for Name: angajati; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.angajati (id_angajat, nume, functie, salariu, data_anagajare) FROM stdin;
1	Popescu Ion	Bibliotecar	3500	2015-03-12
2	Ionescu Maria	Asistent bibliotecar	2800	2018-06-15
3	Radulescu Andrei	Manager	5500	2012-11-05
4	Dumitrescu Elena	Bibliotecar	3700	2016-09-22
5	Stanescu Mihai	IT Specialist	4500	2019-02-18
6	Georgescu Ana	Asistent bibliotecar	2900	2020-01-10
7	Florescu Dragos	Contabil	4200	2017-05-30
8	Marinescu Cristina	Bibliotecar	3600	2018-08-14
9	Constantin Gabriel	Director	6500	2010-07-01
10	Mihai Alina	Relatii cu publicul	3800	2019-04-03
11	Popovici Radu	Bibliotecar	3550	2016-11-20
12	Dobre Carmen	Asistent bibliotecar	2750	2021-02-15
13	Neagu Adrian	IT Specialist	4700	2018-10-22
14	Tudor Loredana	Bibliotecar	3650	2017-07-11
15	Barbu Stefan	Curator	5200	2014-09-08
16	Olteanu Diana	Bibliotecar	3400	2019-03-25
17	Munteanu Bogdan	Asistent bibliotecar	2850	2020-06-17
18	Iordache Simona	Relatii cu publicul	3950	2018-12-05
19	Gheorghe Cristian	Bibliotecar	3500	2017-04-19
20	Filip Adriana	Asistent manager	4800	2016-08-30
\.


--
-- TOC entry 4950 (class 0 OID 24598)
-- Dependencies: 217
-- Data for Name: autori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.autori (id_autor, nume, tara_origine, data_nasterii) FROM stdin;
1	Ion Creangă	România	1837-03-01
2	Mihai Eminescu	România	1850-01-15
3	George Coșbuc	România	1866-09-20
4	Marin Preda	România	1922-08-05
5	Gabriel García Márquez	Columbia	1927-03-06
6	Haruki Murakami	Japonia	1949-01-12
7	J.K. Rowling	Marea Britanie	1965-07-31
8	F. Scott Fitzgerald	S.U.A.	1896-09-24
9	Ernest Hemingway	S.U.A.	1899-07-21
10	Albert Camus	Franța	1913-11-07
11	Charles Dickens	Marea Britanie	1812-02-07
12	Leo Tolstoy	Rusia	1828-09-09
13	Victor Hugo	Franța	1802-02-26
14	Franz Kafka	Austria-Ungaria	1883-07-03
15	T.S. Eliot	S.U.A.	1888-09-26
16	Mark Twain	S.U.A.	1835-11-30
17	Oscar Wilde	Irlanda	1854-10-16
18	Dostoevsky	Rusia	1821-11-11
19	Herman Melville	S.U.A.	1819-08-01
20	William Faulkner	S.U.A.	1897-09-25
21	Gabriel García Márquez	Columbia	1927-03-06
22	Dylan Thomas	Marea Britanie	1914-10-27
23	Sylvia Plath	S.U.A.	1932-10-27
24	Harper Lee	S.U.A.	1926-04-28
25	John Steinbeck	S.U.A.	1902-02-27
26	William Shakespeare	Anglia	1564-04-23
27	H.P. Lovecraft	S.U.A.	1890-08-20
28	Isaac Asimov	S.U.A.	1920-01-02
29	J.R.R. Tolkien	Marea Britanie	1892-01-03
30	Agatha Christie	Marea Britanie	1890-09-15
31	George Orwell	Marea Britanie	1903-06-25
32	J.D. Salinger	S.U.A.	1919-01-01
33	Jane Austen	Marea Britanie	1775-12-16
34	Aldous Huxley	Marea Britanie	1894-07-26
35	Mary Shelley	Marea Britanie	1797-08-30
36	Bram Stoker	Irlanda	1847-11-08
37	Miguel de Cervantes	Spania	1547-09-29
38	Kurt Vonnegut	S.U.A.	1922-11-11
39	Liviu Rebreanu	România	1885-11-27
40	George Călinescu	România	1899-06-19
41	Dmitri Gluhovski	Rusia	1979-06-12
42	Camil Petrescu	România	1894-04-22
43	Mircea Eliade	România	1907-03-09
44	S.E. Hinton	SUA	1948-07-22
45	Joseph Heller	SUA	1923-05-01
46	William Golding	Anglia	1911-09-19
47	Antoine de Saint-Exupéry	Franța	1900-06-29
48	Cormac McCarthy	SUA	1933-07-20
49	Suzanne Collins	SUA	1962-08-10
50	Stephen Hawking	Anglia	1942-01-08
51	Umberto Eco	Italia	1932-01-05
52	Charles Darwin	Anglia	1809-02-12
53	Thomas Kuhn	SUA	1922-07-18
54	Isaac Newton	Anglia	1643-01-04
55	John Rawls	SUA	1921-02-21
56	Stuart Russell	Anglia	1962-01-01
57	Peter Norvig	SUA	1970-01-01
58	Clifford Geertz	SUA	1926-08-23
59	Ray Bradbury	SUA	1920-08-22
60	Jack Kerouac	SUA	1922-03-12
\.


--
-- TOC entry 4952 (class 0 OID 24608)
-- Dependencies: 219
-- Data for Name: carti; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carti (id_carte, titlu, gen_literar, isbn, nr_pagini, pret_unitar, id_editura, data_publicare) FROM stdin;
1	Marele Gatsby	Roman	9780743273565	180	39.99	1	1925-04-10
2	1984	Ficțiune distopică	9780451524935	328	29.99	2	1949-06-08
4	To Kill a Mockingbird	Ficțiune	9780061120084	336	32.00	4	1960-07-11
5	Moby-Dick	Ficțiune clasică	9781853260087	635	50.00	5	1851-11-14
6	War and Peace	Literatură clasică	9781853260629	1225	60.00	6	1869-03-04
7	Pride and Prejudice	Roman	9780141439518	432	28.00	7	1813-01-28
8	The Hobbit	Fantezie	9780345339683	310	40.00	8	1937-09-21
9	Brave New World	Ficțiune distopică	9780060850524	311	27.50	9	1932-08-01
10	The Great Expectations	Roman	9780141439563	544	35.00	10	1861-08-01
11	The Picture of Dorian Gray	Roman filosofic	9780141439570	240	22.00	11	1890-07-01
12	Frankenstein	Horror	9780486282114	280	20.00	12	1818-01-01
13	The Lord of the Rings	Fantezie	9780618640157	1178	75.00	13	1954-07-29
14	Dracula	Groază	9780141439846	488	30.00	14	1897-05-26
15	Don Quixote	Roman clasic	9780060934347	1056	55.00	15	1605-01-16
16	The Brothers Karamazov	Roman filosofic	9780374528379	796	45.00	16	1880-11-01
17	Crime and Punishment	Roman psihologic	9780140449136	430	25.00	17	1866-01-01
18	The Outsiders	Roman adolescent	9780142407332	192	20.00	18	1967-04-24
19	Catch-22	Ficțiune istorică	9781451626650	453	38.00	19	1961-11-10
20	Slaughterhouse-Five	Ficțiune anti-război	9780440180296	275	22.50	20	1969-03-31
25	Metro 2033	Dystopie	8780451524935	328	45.99	5	2002-12-08
151	Delirul	Realism	9781234567890	320	45.99	2	1975-10-01
153	Punguta cu doi bani	Basm	9781894567890	80	25.99	5	11876-06-14
21	Ion	Roman	8789732801111	256	29.99	1	1920-01-01
22	Moromeții	Roman	8789736818190	432	39.99	2	1955-01-01
23	Enigma Otiliei	Roman	8789735005678	320	34.50	3	1938-01-01
24	Padurea spânzuraților	Roman	8789734637665	288	32.99	4	1922-01-01
26	Pride and Prejudice	Clasic	8780141439518	432	28.75	6	1813-01-28
27	The Great Gatsby	Roman	8780743273565	180	37.50	7	1925-04-10
28	Lord of the Flies	Aventura	8780571191475	224	31.99	8	1954-09-17
29	To Kill a Mockingbird	Roman	8780061120084	336	42.25	9	1960-07-11
30	The Catcher in the Rye	Roman	8780316769488	234	35.99	10	1951-07-16
31	Le Petit Prince	Fictiune	8782070408504	96	25.50	11	1943-04-06
32	L'Étranger	Roman	8782070360024	123	29.99	12	1942-05-19
33	Les Misérables	Clasic	8782253005636	1463	55.75	13	1862-01-01
34	Ultima noapte de dragoste, întâia noapte de război	Roman	8786067190567	248	27.99	14	1930-01-01
35	Crima și pedeapsa	Roman psihologic	8789732332187	551	49.99	15	1866-01-01
36	Fahrenheit 451	Science Fiction	8781451673319	249	38.50	16	1953-10-19
37	Harry Potter and the Philosophers Stone	Fantasy	8780747532743	332	52.99	18	1997-06-26
38	The Hobbit	Fantasy	8780261102217	310	47.25	19	1937-09-21
39	The Road	Post-apocaliptic	8780307387899	241	36.99	20	2006-09-26
40	The Hunger Games	Science Fiction	8780439023481	374	41.50	21	2008-09-14
41	On the Road	Roman	8780141182674	320	33.75	23	1957-09-05
42	A Brief History of Time	Stiinta	8780553053401	256	44.99	22	1988-04-01
43	The Name of the Rose	Mister	8780544176560	536	39.99	24	1980-10-10
44	The Origin of Species	Stiinta	8780199219223	432	51.25	25	1859-11-24
45	Principia Mathematica	Matematica	8780521626068	992	89.99	26	1687-07-05
46	The Structure of Scientific Revolutions	Filosofie	8780226458083	264	42.50	27	1962-01-01
47	A Theory of Justice	Filosofie	8780674000780	560	58.75	28	1971-01-01
48	Artificial Intelligence: A Modern Approach	Informatica	8780262035613	1152	99.99	29	1995-01-01
49	The Interpretation of Cultures	Antropologie	8780465097197	480	46.99	30	1973-01-01
50	Maitreyi	Roman	8789735001236	224	26.50	2	1933-01-01
51	Marele Gatsby - Editia Speciala	Roman	9780743273572	250	45.99	1	2025-04-10
52	1984 - Reeditare	Ficțiune distopică	9780451524936	400	39.99	2	2025-06-08
53	The Catcher in the Rye - Remasterizat	Literatură americană	9780316769489	350	32.00	3	2025-07-16
54	To Kill a Mockingbird - Ed. Revizuită	Ficțiune	9780061120085	380	40.00	4	2025-08-11
55	Moby-Dick - Colectia Clasicilor	Ficțiune clasică	9781853260088	700	55.00	5	2025-09-14
56	War and Peace - Ed. Deluxe	Literatură clasică	9781853260630	1500	75.00	6	2025-10-04
57	Pride and Prejudice - Opere Complete	Roman	9780141439519	500	38.00	7	2025-11-28
58	The Hobbit - Ediție de Colecție	Fantezie	9780345339684	400	50.00	8	2025-12-21
59	Brave New World - Înainte de Revoluție	Ficțiune distopică	9780060850525	320	35.00	9	2026-01-01
60	The Great Expectations - Ed. Premium	Roman	9780141439564	600	48.00	10	2026-02-01
61	The Picture of Dorian Gray - Ediție Limitată	Roman filosofic	9780141439571	300	28.00	11	2026-03-01
62	Frankenstein - Ed. de Lux	Horror	9780486282115	350	35.00	12	2026-04-01
63	The Lord of the Rings - Ediție Completa	Fantezie	9780618640158	1500	90.00	13	2026-05-01
64	Dracula - Ediție de Colecție	Groază	9780141439847	600	42.00	14	2026-06-01
65	Don Quixote - Ed. Speciala	Roman clasic	9780060934348	1200	70.00	15	2026-07-16
66	The Brothers Karamazov - Colectia Filozofilor	Roman filosofic	9780374528378	1000	65.00	16	2026-08-01
67	Crime and Punishment - Ed. Ilustrata	Roman psihologic	9780140449137	600	45.00	17	2026-09-01
68	The Outsiders - Ed. Revizuită	Roman adolescent	9780142407333	250	25.00	18	2026-10-01
69	Catch-22 - Ed. Ediție Aniversară	Ficțiune istorică	9781451626651	500	50.00	19	2026-11-01
70	Slaughterhouse-Five - Ed. Limitată	Ficțiune anti-război	9780440180297	400	45.00	20	2026-12-01
71	Ion - Editia Clasică	Roman	8789732801112	350	35.99	1	2026-01-01
72	Moromeții - Ediție de Colecție	Roman	8789736818191	500	49.99	2	2026-02-01
73	Enigma Otiliei - Reeditare	Roman	8789735005679	400	40.99	3	2026-03-01
74	Padurea spânzuraților - Ed. Limitată	Roman	8789734637666	350	47.99	4	2026-04-01
75	1984 - In memoriam	Dystopie	8780451524936	400	45.99	5	2026-05-01
3	The Catcher in the Rye	Literatură americană	9780316769488	277	59.99	3	1951-07-16
76	Pride and Prejudice - Antologie	Clasic	8780141439519	500	40.00	6	2026-06-01
77	The Great Gatsby - Ed. de Colecție	Roman	8780743273566	250	48.50	7	2026-07-01
78	Lord of the Flies - Ediție Revizuită	Aventura	8780571191476	350	41.00	8	2026-08-01
79	To Kill a Mockingbird - Colectia Clasicilor	Roman	8780061120085	400	55.00	9	2026-09-01
80	The Catcher in the Rye - Ediție Revizuită	Roman	8780316769489	350	50.00	10	2026-10-01
81	Le Petit Prince - Ediție ilustrată	Fictiune	8782070408505	100	32.00	11	2026-11-01
82	LÉtranger - Ediție clasică	Roman	8782070360025	150	35.99	12	2026-12-01
83	Les Misérables - Ediție Integrală	Clasic	8782253005637	1500	95.00	13	2027-01-01
84	Ultima noapte de dragoste, întâia noapte de război - Ed. Aniversară	Roman	8786067190568	300	42.50	14	2027-02-01
85	Crima și pedeapsa - Colectia Master	Roman psihologic	8789732332188	700	55.00	15	2027-03-01
86	Fahrenheit 451 - Ed. Specială	Science Fiction	8781451673320	300	50.00	16	2027-04-01
87	Harry Potter and the Philosophers Stone - Ediție Premium	Fantasy	8780747532744	350	65.00	18	2027-05-01
88	The Hobbit - Colectia Fantasy	Fantasy	8780261102218	400	60.00	19	2027-06-01
89	The Road - Ediție Revizuită	Post-apocaliptic	8780307387900	320	55.00	20	2027-07-01
90	The Hunger Games - Ediție Limitată	Science Fiction	8780439023482	450	75.00	21	2027-08-01
91	On the Road - Editia Specială	Roman	8780141182675	350	50.00	23	2027-09-01
92	A Brief History of Time - Colectia Științifică	Stiinta	8780553053402	400	60.00	22	2027-10-01
93	The Name of the Rose - Ed. Aniversară	Mister	8780544176561	600	70.00	24	2027-11-01
94	The Origin of Species - Ediție Deluxe	Stiinta	8780199219224	500	85.00	25	2027-12-01
95	Principia Mathematica - Ediție Premium	Matematica	8780521626069	1000	120.00	26	2028-01-01
96	The Structure of Scientific Revolutions - Colectia Filosofică	Filosofie	8780226458084	300	60.00	27	2028-02-01
97	A Theory of Justice - Ediție Ilustrată	Filosofie	8780674000781	600	75.00	28	2028-03-01
98	Artificial Intelligence: A Modern Approach - Ed. Revizuită	Informatica	8780262035614	1300	110.00	29	2028-04-01
99	The Interpretation of Cultures - Ed. Specială	Antropologie	8780465097198	500	75.00	30	2028-05-01
100	Maitreyi - Ediție Limitată	Roman	8789735001237	300	35.00	2	2028-06-01
101	Rascoala	Roman	9780130101901	256	35.00	1	1932-01-01
102	Luceafărul	Poem	9780130101902	40	50.00	2	1883-03-01
103	Pădurea spânzuraților	Roman	9780130101903	288	48.00	3	1922-01-01
104	Moromeții	Roman	9780130101904	432	58.00	4	1955-01-01
105	Coloana Infinitului	Poem	9780130101905	150	60.00	5	1930-01-01
106	Căpcăunul	Roman	9780130101906	350	65.00	6	1950-05-10
107	Un veac de singurătate	Roman	9780130101907	417	70.00	7	1967-06-05
108	Kafka pe malul mării	Roman	9780130101908	400	68.00	8	1995-06-20
109	Eclipse	Roman	9780130101909	320	72.00	9	2011-05-30
110	Marele Gatsby - Ediție Limitată	Roman	9780130101910	180	89.99	10	1925-04-10
111	Pride and Prejudice - Ediție Limitată	Roman	9780130101911	432	75.00	11	1813-01-28
112	1984 - Ediție Limitată	Ficțiune distopică	9780130101912	328	85.00	12	1949-06-08
113	The Catcher in the Rye - Ediție Limitată	Literatură americană	9780130101913	277	90.00	13	1951-07-16
114	To Kill a Mockingbird - Ediție Limitată	Ficțiune	9780130101914	336	88.00	14	1960-07-11
115	War and Peace - Ediție Limitată	Literatură clasică	9780130101915	1225	120.00	15	1869-03-04
116	Moby-Dick - Ediție Limitată	Ficțiune clasică	9780130101916	635	115.00	16	1851-11-14
117	Pride and Prejudice - Ediție Limitată	Roman	9780130101917	432	99.99	17	1813-01-28
118	The Hobbit - Ediție Limitată	Fantezie	9780130101918	310	105.00	18	1937-09-21
119	Brave New World - Ediție Limitată	Ficțiune distopică	9780130101919	311	95.00	19	1932-08-01
120	The Great Expectations - Ediție Limitată	Roman	9780130101920	544	120.00	20	1861-08-01
121	The Picture of Dorian Gray - Ediție Limitată	Roman filosofic	9780130101921	240	110.00	21	1890-07-01
122	Frankenstein - Ediție Limitată	Horror	9780130101922	280	99.99	22	1818-01-01
123	The Lord of the Rings - Ediție Limitată	Fantezie	9780130101923	1178	130.00	23	1954-07-29
124	Dracula - Ediție Limitată	Groază	9780130101924	488	100.00	24	1897-05-26
125	Don Quixote - Ediție Limitată	Roman clasic	9780130101925	1056	120.00	25	1605-01-16
126	The Brothers Karamazov - Ediție Limitată	Roman filosofic	9780130101926	796	130.00	26	1880-11-01
127	Crime and Punishment - Ediție Limitată	Roman psihologic	9780130101927	430	125.00	27	1866-01-01
128	The Outsiders - Ediție Limitată	Roman adolescent	9780130101928	192	85.00	28	1967-04-24
129	Catch-22 - Ediție Limitată	Ficțiune istorică	9780130101929	453	99.99	29	1961-11-10
130	Slaughterhouse-Five - Ediție Limitată	Ficțiune anti-război	9780130101930	275	88.00	30	1969-03-31
131	Ion - Ediție Limitată	Roman	8789732801211	256	55.00	1	1920-01-01
132	Moromeții - Ediție Limitată	Roman	8789736818211	432	65.00	2	1955-01-01
133	Enigma Otiliei - Ediție Limitată	Roman	8789735005691	320	75.00	3	1938-01-01
134	Padurea spânzuraților - Ediție Limitată	Roman	8789734637685	288	80.00	4	1922-01-01
135	1984 - Ediție Limitată	Dystopie	8780451524906	328	90.00	5	1949-06-08
136	Pride and Prejudice - Ediție Limitată	Clasic	8780141439531	432	100.00	6	1813-01-28
137	The Great Gatsby - Ediție Limitată	Roman	8780743273567	180	110.00	7	1925-04-10
138	Lord of the Flies - Ediție Limitată	Aventura	8780571191477	224	95.00	8	1954-09-17
139	To Kill a Mockingbird - Ediție Limitată	Roman	8780061120091	336	120.00	9	1960-07-11
140	The Catcher in the Rye - Ediție Limitată	Roman	8780316769419	234	110.00	10	1951-07-16
141	Le Petit Prince - Ediție Limitată	Fictiune	8782070408525	96	85.00	11	1943-04-06
142	LÉtranger - Ediție Limitată	Roman	8782070360028	123	75.00	12	1942-05-19
143	Les Misérables - Ediție Limitată	Clasic	8782253005639	1463	140.00	13	1862-01-01
144	Ultima noapte de dragoste, întâia noapte de război	Roman	8786067190569	248	90.00	14	1930-01-01
145	Crima și pedeapsa - Ediție Limitată	Roman psihologic	8789732332139	551	125.00	15	1866-01-01
146	Fahrenheit 451 - Ediție Limitată	Science Fiction	8781451673322	249	110.00	16	1953-10-19
147	Harry Potter and the Philosophers Stone - Ediție Limitată	Fantasy	8780747532746	332	135.00	18	1997-06-26
148	The Hobbit - Ediție Limitată	Fantasy	8780261102219	310	140.00	19	1937-09-21
149	The Road - Ediție Limitată	Post-apocaliptic	8780307387907	241	120.00	20	2006-09-26
150	The Hunger Games - Ediție Limitată	Science Fiction	8780439023487	374	130.00	21	2008-09-14
\.


--
-- TOC entry 4953 (class 0 OID 24620)
-- Dependencies: 220
-- Data for Name: carti_autori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carti_autori (id_autor, id_carte) FROM stdin;
1	21
2	22
3	23
4	24
5	25
6	26
7	27
8	28
9	29
10	30
11	31
12	32
13	33
14	34
15	35
16	36
17	37
18	38
19	39
20	40
21	41
22	42
23	43
24	44
25	45
26	46
27	47
28	48
29	49
30	50
1	22
2	23
3	24
4	25
5	26
6	27
7	28
8	29
9	30
10	31
39	21
4	22
4	50
40	23
39	24
39	103
39	101
2	102
3	105
4	106
8	1
8	51
8	110
8	137
31	2
31	52
31	112
31	135
32	3
32	53
32	113
32	140
24	4
24	54
24	114
24	139
19	5
19	55
19	116
12	6
12	56
12	115
33	7
33	57
33	111
33	117
33	136
29	8
29	58
29	118
29	148
34	9
34	59
34	119
11	10
11	60
11	120
17	11
17	61
17	121
35	12
35	62
35	122
29	13
29	63
29	123
36	14
36	64
36	124
37	15
37	65
37	125
18	16
18	66
18	126
18	17
18	67
18	127
18	145
38	20
38	70
38	130
41	25
41	75
10	32
10	82
10	142
13	83
13	143
7	37
7	87
7	147
42	34
42	84
42	144
43	50
44	18
44	68
44	128
45	19
45	69
45	129
46	28
46	78
46	138
47	31
47	81
47	141
48	39
48	89
48	149
49	40
49	90
49	150
50	42
50	92
51	43
51	93
52	44
52	94
54	45
54	95
53	46
53	96
55	47
55	97
56	48
57	48
56	98
57	98
58	49
58	99
59	36
59	86
59	146
60	41
60	91
4	151
1	153
\.


--
-- TOC entry 4954 (class 0 OID 24635)
-- Dependencies: 221
-- Data for Name: clienti; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clienti (id_client, nume, email, nr_telefon, data_inregistrare) FROM stdin;
1	Ion Popescu	ion.popescu@example.com	712345678	2024-01-01
2	Maria Ionescu	maria.ionescu@example.com	723456789	2024-01-02
3	Andrei Georgescu	andrei.georgescu@example.com	734567890	2024-01-03
4	Elena Dumitru	elena.dumitru@example.com	745678901	2024-01-04
5	Vasile Neagu	vasile.neagu@example.com	756789012	2024-01-05
6	Gabriela Mihăilescu	gabriela.mihailescu@example.com	767890123	2024-01-06
7	Cristian Popa	cristian.popa@example.com	778901234	2024-01-07
8	Mihaela Stanescu	mihaela.stanescu@example.com	789012345	2024-01-08
9	Florin Vasile	florin.vasile@example.com	790123456	2024-01-09
10	Mihail Sandu	mihail.sandu@example.com	711234567	2024-01-10
11	Gabriela Enache	gabriela.enache@example.com	722345678	2024-01-11
12	Anca Ion	anca.ion@example.com	733456789	2024-01-12
13	Victor Bărbulescu	victor.barbu@example.com	744567890	2024-01-13
14	Loredana Radu	loredana.radu@example.com	755678901	2024-01-14
15	Radu Popovici	radu.popovici@example.com	766789012	2024-01-15
16	Cristina Oprea	cristina.oprea@example.com	777890123	2024-01-16
17	Vasile Tătaru	vasile.tataru@example.com	788901234	2024-01-17
18	Mihail Crețu	mihail.cretu@example.com	799012345	2024-01-18
19	Elena Rusu	elena.rusu@example.com	710123456	2024-01-19
20	Ion Marcu	ion.marcu@example.com	721234567	2024-01-20
21	Cosmin Avram	cosmin.avram@example.com	732345678	2024-01-21
22	Diana Petrescu	diana.petrescu@example.com	743456789	2024-01-22
23	Gheorghe Alexandru	gheorghe.alexandru@example.com	754567890	2024-01-23
24	Florina Constantin	florina.constantin@example.com	765678901	2024-01-24
25	Mihnea Badea	mihnea.badea@example.com	776789012	2024-01-25
26	Nicoleta Bălan	nicoleta.balan@example.com	787890123	2024-01-26
27	Stefan Răducanu	stefan.raducanu@example.com	798901234	2024-01-27
28	Larisa Vasile	larisa.vasile@example.com	719012345	2024-01-28
29	Mihai Constantinescu	mihai.constantinescu@example.com	720123456	2024-01-29
30	Adrian Filip	adrian.filip@example.com	731234567	2024-01-30
31	Iulia Ionescu	iulia.ionescu@example.com	742345678	2024-01-31
32	Lucian Pavel	lucian.pavel@example.com	753456789	2024-02-01
33	Irina Popa	irina.popa@example.com	764567890	2024-02-02
34	Tudor Moldovan	tudor.moldovan@example.com	775678901	2024-02-03
35	Mihaela Tofan	mihaela.tofan@example.com	786789012	2024-02-04
36	Radu Sava	radu.sava@example.com	797890123	2024-02-05
37	Ana Bărcan	ana.barcan@example.com	718901234	2024-02-06
38	Elena Popescu	elena.popescu@example.com	729012345	2024-02-07
39	Florin Dima	florin.dima@example.com	730123456	2024-02-08
40	Ion Stoica	ion.stoica@example.com	741234567	2024-02-09
41	Nina Nistor	nina.nistor@example.com	752345678	2024-02-10
42	Liviu Tiberiu	liviu.tiberiu@example.com	763456789	2024-02-11
43	Gabriela Dobre	gabriela.dobre@example.com	774567890	2024-02-12
44	Mihail Drăghici	mihail.draghici@example.com	785678901	2024-02-13
45	Irina Dumitriu	irina.dumitriu@example.com	796789012	2024-02-14
46	Tania Ispas	tania.ispas@example.com	717890123	2024-02-15
47	Gheorghe Grigore	gheorghe.grigore@example.com	728901234	2024-02-16
48	Ana Maria Pavel	anamaria.pavel@example.com	739012345	2024-02-17
49	Ion Radu	ion.radu@example.com	740123456	2024-02-18
50	Lavinia Mihailov	lavinia.mihailov@example.com	751234567	2024-02-19
51	Cosmin Rusu	cosmin.rusu@example.com	762345678	2024-02-20
52	Vasile Florea	vasile.florea@example.com	773456789	2024-02-21
53	Mihail Vâlcea	mihail.valcea@example.com	784567890	2024-02-22
54	Gabriela Roșu	gabriela.rosu@example.com	795678901	2024-02-23
55	Ion Ștefan	ion.stefan@example.com	716789012	2024-02-24
56	Irina Andrei	irina.andrei@example.com	727890123	2024-02-25
57	Mihai Nicoară	mihai.nicoara@example.com	738901234	2024-02-26
58	Gabriela Iorga	gabriela.iorga@example.com	749012345	2024-02-27
59	Adriana Drăgan	adriana.dragan@example.com	750123456	2024-02-28
60	Mircea Lazăr	mircea.lazar@example.com	761234567	2024-02-29
61	Daniel Călin	daniel.calin@example.com	772345678	2024-03-01
62	Cătălina Păun	catalina.paun@example.com	783456789	2024-03-02
63	Alina Florin	alina.florin@example.com	794567890	2024-03-03
64	Mihail Bălan	mihail.balan@example.com	715678901	2024-03-04
65	Stefan Iacob	stefan.iacob@example.com	726789012	2024-03-05
66	Elena Coman	elena.coman@example.com	737890123	2024-03-06
67	Mihail Drăguș	mihail.dragus@example.com	748901234	2024-03-07
68	Daniela Năstase	daniela.nastase@example.com	759012345	2024-03-08
69	Florina Bădescu	florina.badescu@example.com	760123456	2024-03-09
70	Mircea Călinescu	mircea.calinescu@example.com	771234567	2024-03-10
71	Ion Dănuț	ion.danut@example.com	782345678	2024-03-11
72	Cosmin Anghel	cosmin.anghel@example.com	793456789	2024-03-12
73	Florentina Gheorghe	florentina.gheorghe@example.com	714567890	2024-03-13
74	Raluca Luca	raluca.luca@example.com	725678901	2024-03-14
75	Radu Bănuț	radu.banut@example.com	736789012	2024-03-15
76	Ion Călina	ion.calina@example.com	747890123	2024-03-16
77	Ioana Drăgan	ioana.dragan@example.com	758901234	2024-03-17
78	Gheorghe Văduva	gheorghe.vaduva@example.com	769012345	2024-03-18
79	Florin Dumitrașcu	florin.dumitrascu@example.com	770123456	2024-03-19
80	Mihai Săndulescu	mihai.sandulescu@example.com	781234567	2024-03-20
81	Adrian Costache	adrian.costache@example.com	792345678	2024-03-21
82	Vasile Munteanu	vasile.munteanu@example.com	713456789	2024-03-22
83	Anca Stoica	anca.stoica@example.com	724567890	2024-03-23
84	Cristian Botez	cristian.botez@example.com	735678901	2024-03-24
85	Loredana Tofan	loredana.tofan@example.com	746789012	2024-03-25
86	Mihail Ene	mihail.ene@example.com	757890123	2024-03-26
87	Tania Pavelescu	tania.pavelescu@example.com	768901234	2024-03-27
88	Gabriela Marin	gabriela.marin@example.com	779012345	2024-03-28
89	Florin Călin	florin.calin@example.com	780123456	2024-03-29
90	Mihai Păcuraru	mihai.pacuraru@example.com	791234567	2024-03-30
91	Ion Damian	ion.damian@example.com	712345678	2024-03-31
92	Daniela Grecu	daniela.grecu@example.com	723456789	2024-04-01
93	Gabriela Ilie	gabriela.ilie@example.com	734567890	2024-04-02
94	Mihail Iancu	mihail.iancu@example.com	745678901	2024-04-03
95	Ana Luiza	ana.luiza@example.com	756789012	2024-04-04
96	Radu Popa	radu.popa@example.com	767890123	2024-04-05
97	Ion Nicolae	ion.nicolae@example.com	778901234	2024-04-06
98	Florin Istrat	florin.istrat@example.com	789012345	2024-04-07
99	Mihai Stănescu	mihai.stanescu@example.com	790123456	2024-04-08
100	Mihaela Pătrășcoiu	mihaela.patrascouiu@example.com	711234567	2024-04-09
\.


--
-- TOC entry 4958 (class 0 OID 24680)
-- Dependencies: 225
-- Data for Name: comenzi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comenzi (id_comanda, id_client, data_comanda, id_angajat, status) FROM stdin;
1	5	2023-01-10	3	primita
2	12	2023-01-15	7	expediata
3	8	2023-01-18	2	plasata
4	3	2023-01-22	5	in procesare
5	17	2023-01-25	9	primita
6	22	2023-02-03	1	anulata
7	9	2023-02-07	4	expediata
8	14	2023-02-12	6	primita
9	27	2023-02-18	8	in procesare
10	6	2023-02-21	10	expediata
11	19	2023-03-05	12	primita
12	2	2023-03-09	11	anulata
13	25	2023-03-14	13	expediata
14	11	2023-03-20	14	primita
15	7	2023-03-25	15	in procesare
16	30	2023-04-02	16	expediata
17	4	2023-04-07	17	primita
18	18	2023-04-12	18	anulata
19	21	2023-04-17	19	expediata
20	13	2023-04-22	20	primita
21	1	2023-05-01	3	in procesare
22	16	2023-05-06	7	expediata
23	23	2023-05-11	2	primita
24	10	2023-05-16	5	anulata
25	28	2023-05-21	9	expediata
26	15	2023-05-26	1	primita
27	20	2023-06-01	4	in procesare
28	29	2023-06-05	6	expediata
29	24	2023-06-10	8	primita
30	26	2023-06-15	10	anulata
31	5	2023-06-20	12	expediata
32	12	2023-06-25	11	primita
33	8	2023-07-01	13	in procesare
34	3	2023-07-05	14	expediata
35	17	2023-07-10	15	primita
36	22	2023-07-15	16	anulata
37	9	2023-07-20	17	expediata
38	14	2023-07-25	18	primita
39	27	2023-07-30	19	in procesare
40	6	2023-08-04	20	expediata
41	19	2023-08-09	3	primita
42	2	2023-08-14	7	anulata
43	25	2023-08-19	2	expediata
44	11	2023-08-24	5	primita
45	7	2023-08-29	9	in procesare
46	30	2023-09-03	1	expediata
47	4	2023-09-08	4	primita
48	18	2023-09-13	6	anulata
49	21	2023-09-18	8	expediata
50	13	2023-09-23	10	primita
\.


--
-- TOC entry 4959 (class 0 OID 24696)
-- Dependencies: 226
-- Data for Name: comenzi_produse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comenzi_produse (id_comanda, id_carte, cantitate, pret) FROM stdin;
1	5	1	45.99
2	12	2	29.99
3	8	1	31.99
4	15	1	49.99
5	22	3	28.75
6	3	1	34.50
7	17	2	52.99
8	25	1	45.99
9	30	1	35.99
10	7	1	37.50
11	1	1	29.99
11	10	1	35.99
11	20	2	41.50
12	14	1	27.99
12	18	1	47.25
13	21	1	26.50
13	33	1	55.75
13	45	1	89.99
14	2	1	39.99
14	19	1	36.99
15	4	1	32.99
15	9	1	42.25
15	16	1	38.50
16	6	2	28.75
16	11	1	25.50
17	13	1	39.99
17	24	1	51.25
18	23	1	34.50
18	35	1	49.99
19	26	1	28.75
19	31	1	25.50
19	40	2	41.50
20	27	1	37.50
20	32	1	29.99
21	28	1	31.99
22	29	1	42.25
23	34	1	27.99
24	36	1	38.50
25	37	2	52.99
26	38	1	47.25
26	39	1	36.99
27	41	1	33.75
27	42	1	44.99
28	43	1	39.99
28	44	1	51.25
29	46	1	42.50
29	47	1	58.75
30	48	1	99.99
30	49	1	46.99
31	50	1	26.50
32	1	1	29.99
33	2	1	39.99
34	3	1	34.50
35	4	1	32.99
36	5	2	45.99
37	6	1	28.75
38	7	1	37.50
39	8	1	31.99
40	9	1	42.25
41	10	1	35.99
42	11	1	25.50
43	12	1	29.99
44	13	1	39.99
45	14	1	27.99
46	15	1	49.99
47	16	1	38.50
48	17	1	52.99
49	18	1	47.25
50	19	1	36.99
\.


--
-- TOC entry 4951 (class 0 OID 24603)
-- Dependencies: 218
-- Data for Name: edituri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.edituri (id_editura, nume, tara, website) FROM stdin;
1	Editura Humanitas	România	https://www.humanitas.ro
2	Editura Polirom	România	https://www.polirom.ro
3	Editura Cartepedia	România	https://www.cartepedia.ro
4	Editura Arthur	România	https://www.edituraarthur.ro
5	Penguin Books	Marea Britanie	https://www.penguin.co.uk
6	HarperCollins	S.U.A.	https://www.harpercollins.com
7	Simon & Schuster	S.U.A.	https://www.simonandschuster.com
8	Faber and Faber	Marea Britanie	https://www.faber.co.uk
9	Random House	S.U.A.	https://www.randomhouse.com
10	Alfred A. Knopf	S.U.A.	https://www.knopf.com
11	Hachette Livre	Franța	https://www.hachette.com
12	Gallimard	Franța	https://www.gallimard.fr
13	Actes Sud	Franța	https://www.actes-sud.fr
14	Editura Trei	România	https://www.edituratrei.ro
15	Editura Nemira	România	https://www.nemira.ro
16	Editura Univers	România	https://www.edituraunivers.ro
17	Editura Pro	România	https://www.editurapro.ro
18	Bloomsbury Publishing	Marea Britanie	https://www.bloomsbury.com
19	Macmillan	Marea Britanie	https://www.macmillan.com
20	W.W. Norton & Company	S.U.A.	https://www.wwnorton.com
21	Scholastic Corporation	S.U.A.	https://www.scholastic.com
22	Viking Press	S.U.A.	https://www.penguinrandomhouse.com/viking
23	Vintage Books	S.U.A.	https://www.penguinrandomhouse.com/vintage
24	Blackwell Publishing	Marea Britanie	https://www.blackwellpublishing.com
25	Oxford University Press	Marea Britanie	https://global.oup.com
26	Cambridge University Press	Marea Britanie	https://www.cambridge.org
27	University of Chicago Press	S.U.A.	https://www.press.uchicago.edu
28	Princeton University Press	S.U.A.	https://press.princeton.edu
29	MIT Press	S.U.A.	https://mitpress.mit.edu
30	Stanford University Press	S.U.A.	https://www.sup.org
\.


--
-- TOC entry 4956 (class 0 OID 24647)
-- Dependencies: 223
-- Data for Name: furnizori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.furnizori (id_furnizor, denumire, email, telefon, tara) FROM stdin;
1	Carturesti SRL	contact@carturesti.ro	741112233	Romania
2	Libris SRL	comenzi@libris.ro	742223344	Romania
3	Elefant Online	clienti@elefant.ro	743334455	Romania
4	Bookster International	office@bookster.com	2045678901	Marea Britanie
5	Penguin Supply	supply@penguin.co.uk	2076543210	Marea Britanie
6	Book Depository	orders@bookdepository.com	1173456789	Marea Britanie
7	Amazon Books	romania@amazon.com	751112233	S.U.A.
8	Barnes & Noble	orders@barnesandnoble.com	2125556789	S.U.A.
9	Gallimard Export	export@gallimard.fr	3140506070	Franta
10	Flammarion Logistics	logistics@flammarion.fr	3150607080	Franta
11	Librairie Française	contact@librairie.fr	3160708090	Franta
12	Antique Books Ltd	sales@antiquebooks.com	754445566	Romania
13	Litera Media Group	office@litera.ro	735556677	Romania
14	Humanitas Distributie	distributie@humanitas.ro	736667788	Romania
15	Polirom Furnizori	furnizori@polirom.ro	737778899	Romania
16	Oxford University Press Supply	supply@oup.com	1865556677	Marea Britanie
17	Cambridge Books Direct	orders@cambridge.org	1223332211	Marea Britanie
18	Nemira Distributie	distributie@nemira.ro	738889900	Romania
19	Editura Trei Logistics	logistics@edituratrei.ro	739990011	Romania
20	Bookline SRL	comenzi@bookline.ro	730001122	Romania
\.


--
-- TOC entry 4962 (class 0 OID 32817)
-- Dependencies: 233
-- Data for Name: log_modificari_pret; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_modificari_pret (id_log, id_carte, pret_vechi, pret_nou, data_modificare) FROM stdin;
1	3	25.50	59.99	2025-05-12 18:24:31.265655
\.


--
-- TOC entry 4957 (class 0 OID 24665)
-- Dependencies: 224
-- Data for Name: stocuri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stocuri (id_carte, id_furnizor, cantitate, data_ultima_receptie) FROM stdin;
1	1	15	2023-01-15
2	2	8	2023-02-20
3	3	12	2023-03-10
4	4	5	2023-01-28
5	5	20	2023-04-05
6	6	10	2023-02-15
7	7	7	2023-03-22
8	8	14	2023-04-18
9	9	9	2023-01-30
10	10	11	2023-02-28
11	11	6	2023-03-15
12	12	18	2023-04-10
13	13	4	2023-01-20
14	14	13	2023-02-25
15	15	16	2023-03-30
16	16	3	2023-04-22
17	17	10	2023-01-12
18	18	7	2023-02-18
19	19	12	2023-03-25
20	20	8	2023-04-28
21	1	15	2023-05-05
22	2	9	2023-05-10
23	3	11	2023-05-15
24	4	6	2023-05-20
25	5	14	2023-05-25
26	6	7	2023-06-01
27	7	13	2023-06-05
28	8	5	2023-06-10
29	9	10	2023-06-15
30	10	8	2023-06-20
31	11	12	2023-06-25
32	12	9	2023-07-01
33	13	16	2023-07-05
34	14	4	2023-07-10
35	15	11	2023-07-15
36	16	7	2023-07-20
37	17	14	2023-07-25
38	18	6	2023-08-01
39	19	10	2023-08-05
40	20	8	2023-08-10
41	1	12	2023-08-15
42	2	5	2023-08-20
43	3	9	2023-08-25
44	4	13	2023-09-01
45	5	7	2023-09-05
46	6	15	2023-09-10
47	7	4	2023-09-15
48	8	11	2023-09-20
49	9	8	2023-09-25
50	10	10	2023-09-30
\.


--
-- TOC entry 4969 (class 0 OID 0)
-- Dependencies: 231
-- Name: carti_id_carte_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.carti_id_carte_seq', 153, true);


--
-- TOC entry 4970 (class 0 OID 0)
-- Dependencies: 232
-- Name: log_modificari_pret_id_log_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_modificari_pret_id_log_seq', 1, true);


--
-- TOC entry 4779 (class 2606 OID 24646)
-- Name: angajati angajati_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.angajati
    ADD CONSTRAINT angajati_pkey PRIMARY KEY (id_angajat);


--
-- TOC entry 4763 (class 2606 OID 24602)
-- Name: autori autori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.autori
    ADD CONSTRAINT autori_pkey PRIMARY KEY (id_autor);


--
-- TOC entry 4771 (class 2606 OID 24624)
-- Name: carti_autori carti_autori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carti_autori
    ADD CONSTRAINT carti_autori_pkey PRIMARY KEY (id_autor, id_carte);


--
-- TOC entry 4767 (class 2606 OID 24614)
-- Name: carti carti_isbn_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carti
    ADD CONSTRAINT carti_isbn_key UNIQUE (isbn);


--
-- TOC entry 4769 (class 2606 OID 24612)
-- Name: carti carti_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carti
    ADD CONSTRAINT carti_pkey PRIMARY KEY (id_carte);


--
-- TOC entry 4775 (class 2606 OID 24641)
-- Name: clienti clienti_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clienti
    ADD CONSTRAINT clienti_email_key UNIQUE (email);


--
-- TOC entry 4777 (class 2606 OID 24639)
-- Name: clienti clienti_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clienti
    ADD CONSTRAINT clienti_pkey PRIMARY KEY (id_client);


--
-- TOC entry 4785 (class 2606 OID 24685)
-- Name: comenzi comenzi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comenzi
    ADD CONSTRAINT comenzi_pkey PRIMARY KEY (id_comanda);


--
-- TOC entry 4787 (class 2606 OID 24700)
-- Name: comenzi_produse comenzi_produse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comenzi_produse
    ADD CONSTRAINT comenzi_produse_pkey PRIMARY KEY (id_comanda, id_carte);


--
-- TOC entry 4765 (class 2606 OID 24607)
-- Name: edituri edituri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.edituri
    ADD CONSTRAINT edituri_pkey PRIMARY KEY (id_editura);


--
-- TOC entry 4781 (class 2606 OID 24651)
-- Name: furnizori furnizori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.furnizori
    ADD CONSTRAINT furnizori_pkey PRIMARY KEY (id_furnizor);


--
-- TOC entry 4790 (class 2606 OID 32825)
-- Name: log_modificari_pret log_modificari_pret_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_modificari_pret
    ADD CONSTRAINT log_modificari_pret_pkey PRIMARY KEY (id_log);


--
-- TOC entry 4783 (class 2606 OID 24669)
-- Name: stocuri stocuri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stocuri
    ADD CONSTRAINT stocuri_pkey PRIMARY KEY (id_carte, id_furnizor);


--
-- TOC entry 4772 (class 1259 OID 32828)
-- Name: idx_carti_autori_id_autor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_carti_autori_id_autor ON public.carti_autori USING btree (id_autor);


--
-- TOC entry 4773 (class 1259 OID 32829)
-- Name: idx_carti_autori_id_carte; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_carti_autori_id_carte ON public.carti_autori USING btree (id_carte);


--
-- TOC entry 4788 (class 1259 OID 32830)
-- Name: idx_comenzi_produse_id_comanda; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comenzi_produse_id_comanda ON public.comenzi_produse USING btree (id_comanda);


--
-- TOC entry 4800 (class 2620 OID 32827)
-- Name: carti trg_log_pret_carte; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_pret_carte AFTER UPDATE ON public.carti FOR EACH ROW EXECUTE FUNCTION public.log_pret_carte();


--
-- TOC entry 4796 (class 2606 OID 24691)
-- Name: comenzi fk_id_angajat; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comenzi
    ADD CONSTRAINT fk_id_angajat FOREIGN KEY (id_angajat) REFERENCES public.angajati(id_angajat);


--
-- TOC entry 4792 (class 2606 OID 24625)
-- Name: carti_autori fk_id_autor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carti_autori
    ADD CONSTRAINT fk_id_autor FOREIGN KEY (id_autor) REFERENCES public.autori(id_autor);


--
-- TOC entry 4793 (class 2606 OID 24630)
-- Name: carti_autori fk_id_carte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carti_autori
    ADD CONSTRAINT fk_id_carte FOREIGN KEY (id_carte) REFERENCES public.carti(id_carte);


--
-- TOC entry 4794 (class 2606 OID 24670)
-- Name: stocuri fk_id_carte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stocuri
    ADD CONSTRAINT fk_id_carte FOREIGN KEY (id_carte) REFERENCES public.carti(id_carte);


--
-- TOC entry 4798 (class 2606 OID 24706)
-- Name: comenzi_produse fk_id_carte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comenzi_produse
    ADD CONSTRAINT fk_id_carte FOREIGN KEY (id_carte) REFERENCES public.carti(id_carte);


--
-- TOC entry 4797 (class 2606 OID 24686)
-- Name: comenzi fk_id_client; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comenzi
    ADD CONSTRAINT fk_id_client FOREIGN KEY (id_client) REFERENCES public.clienti(id_client);


--
-- TOC entry 4799 (class 2606 OID 24701)
-- Name: comenzi_produse fk_id_comanda; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comenzi_produse
    ADD CONSTRAINT fk_id_comanda FOREIGN KEY (id_comanda) REFERENCES public.comenzi(id_comanda);


--
-- TOC entry 4791 (class 2606 OID 24615)
-- Name: carti fk_id_editura; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carti
    ADD CONSTRAINT fk_id_editura FOREIGN KEY (id_editura) REFERENCES public.edituri(id_editura);


--
-- TOC entry 4795 (class 2606 OID 24675)
-- Name: stocuri fk_id_furnizor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stocuri
    ADD CONSTRAINT fk_id_furnizor FOREIGN KEY (id_furnizor) REFERENCES public.furnizori(id_furnizor);


-- Completed on 2025-05-12 18:50:22

--
-- PostgreSQL database dump complete
--

