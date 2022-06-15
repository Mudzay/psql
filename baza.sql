-- Adminer 4.8.1 PostgreSQL 12.6 (Ubuntu 12.6-0ubuntu0.20.04.1) dump

DROP TABLE IF EXISTS "gatunki";
DROP SEQUENCE IF EXISTS gatunki_id_seq;
CREATE SEQUENCE gatunki_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."gatunki" (
    "id" integer DEFAULT nextval('gatunki_id_seq') NOT NULL,
    "nazwa" character varying(255) NOT NULL,
    CONSTRAINT "gatunki_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "ung" UNIQUE ("nazwa")
) WITH (oids = false);

INSERT INTO "gatunki" ("id", "nazwa") VALUES
(1,	'szynszyla'),
(2,	'kapibara'),
(3,	'myszojelen'),
(4,	'szczur'),
(5,	'pies');

DROP TABLE IF EXISTS "kategorie";
DROP SEQUENCE IF EXISTS kategorie_id_seq;
CREATE SEQUENCE kategorie_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."kategorie" (
    "id" integer DEFAULT nextval('kategorie_id_seq') NOT NULL,
    "kat" character varying(255) NOT NULL,
    CONSTRAINT "kategorie_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "unk" UNIQUE ("kat")
) WITH (oids = false);

INSERT INTO "kategorie" ("id", "kat") VALUES
(1,	'karma'),
(2,	'klatka'),
(3,	'zabawka'),
(4,	'przysmak'),
(8,	'poidełko'),
(9,	'smycz'),
(10,	'szelki'),
(11,	'obroża'),
(12,	'miska'),
(13,	'ubranie'),
(14,	'buty'),
(15,	'witaminy'),
(16,	'książka'),
(17,	'akcesoria'),
(18,	'szczotka');

DROP TABLE IF EXISTS "klient";
DROP SEQUENCE IF EXISTS klient_id_seq;
CREATE SEQUENCE klient_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."klient" (
    "id" integer DEFAULT nextval('klient_id_seq') NOT NULL,
    "imie" character varying(255) NOT NULL,
    "nazwisko" character varying(255) NOT NULL,
    "data_dolaczenia" date DEFAULT now() NOT NULL,
    CONSTRAINT "klient_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

INSERT INTO "klient" ("id", "imie", "nazwisko", "data_dolaczenia") VALUES
(1,	'Thor',	'Odinson',	'2022-06-15'),
(2,	'Loki',	'Laufeyson',	'2022-06-15'),
(4,	'Patryk',	'Pietrek',	'2022-06-15'),
(5,	'Lucy',	'Wilska',	'2022-06-15'),
(6,	'Paweł',	'Kozioł',	'2022-06-15'),
(7,	'Piotr',	'Kozioł',	'2022-06-15'),
(8,	'Stach',	'Japycz',	'2022-06-15'),
(9,	'Maciej',	'Solejuk',	'2022-06-15'),
(10,	'Tadeusz',	'Hadziuk',	'2022-06-15');

DROP TABLE IF EXISTS "magazyn";
DROP SEQUENCE IF EXISTS magazyn_id_seq;
CREATE SEQUENCE magazyn_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."magazyn" (
    "id" integer DEFAULT nextval('magazyn_id_seq') NOT NULL,
    "nazwa" character varying(255) NOT NULL,
    "kategoria" integer NOT NULL,
    "gatunek" integer NOT NULL,
    "stan" integer NOT NULL,
    "cena" double precision NOT NULL,
    CONSTRAINT "magazyn_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

INSERT INTO "magazyn" ("id", "nazwa", "kategoria", "gatunek", "stan", "cena") VALUES
(1,	'Topinambur',	4,	1,	6,	5.99),
(2,	'Korzeń mniszka',	1,	1,	3,	6.99),
(3,	'Woliera maxi+',	2,	1,	6,	2137),
(4,	'Piłka',	3,	2,	70,	10),
(5,	'szelunie',	10,	3,	67,	15),
(9,	'Szczurobuciki',	14,	4,	50,	19),
(10,	'Czapeczka',	13,	3,	1,	1),
(7,	'Jak nie dać szynszylom zawładnąć nad sobą?',	16,	1,	2,	30000),
(8,	'Miska duża',	12,	5,	7,	23.5),
(6,	'piłka',	3,	5,	17,	15.99);

DROP VIEW IF EXISTS "pokaz_mi_swoje_towary";
CREATE TABLE "pokaz_mi_swoje_towary" ("id" integer, "nazwa" character varying(255), "kategoria" character varying(255), "gatunek" character varying(255), "stan" integer, "cena" double precision);


DROP VIEW IF EXISTS "wyswietl_zamowienia";
CREATE TABLE "wyswietl_zamowienia" ("id" integer, "imie" character varying(255), "nazwisko" character varying(255), "nazwa" character varying(255), "ile" integer, "suma" double precision, "kiedy" text);


DROP TABLE IF EXISTS "zamowienie";
DROP SEQUENCE IF EXISTS zamowienie_id_seq;
CREATE SEQUENCE zamowienie_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."zamowienie" (
    "id" integer DEFAULT nextval('zamowienie_id_seq') NOT NULL,
    "kto" integer NOT NULL,
    "co" integer NOT NULL,
    "ile" integer NOT NULL,
    "suma" double precision NOT NULL,
    "kiedy" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "zamowienie_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

INSERT INTO "zamowienie" ("id", "kto", "co", "ile", "suma", "kiedy") VALUES
(6,	4,	2,	1,	6.99,	'2022-06-15 12:05:55.045422'),
(9,	1,	5,	2,	30,	'2022-06-15 12:05:55.045422'),
(10,	9,	10,	2,	2,	'2022-06-15 20:23:24.763956'),
(11,	6,	7,	1,	30000,	'2022-06-15 20:23:59.280637'),
(12,	5,	8,	2,	47,	'2022-06-15 20:24:17.756818'),
(13,	10,	6,	3,	47.97,	'2022-06-15 20:24:32.786694');

DELIMITER ;;

CREATE TRIGGER "sprawdz_stan" BEFORE INSERT ON "public"."zamowienie" FOR EACH ROW EXECUTE FUNCTION sprawdz_stan();;

CREATE TRIGGER "suma" BEFORE INSERT ON "public"."zamowienie" FOR EACH ROW EXECUTE FUNCTION suma();;

CREATE TRIGGER "zwrot" AFTER DELETE ON "public"."zamowienie" FOR EACH ROW EXECUTE FUNCTION zwrot();;

CREATE TRIGGER "sprawdz_stan_update" BEFORE UPDATE ON "public"."zamowienie" FOR EACH ROW EXECUTE FUNCTION sprawdz_stan2();;

DELIMITER ;

ALTER TABLE ONLY "public"."magazyn" ADD CONSTRAINT "magazyn_gat" FOREIGN KEY (gatunek) REFERENCES gatunki(id) NOT DEFERRABLE;
ALTER TABLE ONLY "public"."magazyn" ADD CONSTRAINT "magazyn_kat" FOREIGN KEY (kategoria) REFERENCES kategorie(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."zamowienie" ADD CONSTRAINT "zamowienie_co" FOREIGN KEY (co) REFERENCES magazyn(id) NOT DEFERRABLE;
ALTER TABLE ONLY "public"."zamowienie" ADD CONSTRAINT "zamowienie_kto" FOREIGN KEY (kto) REFERENCES klient(id) NOT DEFERRABLE;

DROP TABLE IF EXISTS "pokaz_mi_swoje_towary";
CREATE VIEW "pokaz_mi_swoje_towary" AS SELECT m.id,
    m.nazwa,
    k.kat AS kategoria,
    g.nazwa AS gatunek,
    m.stan,
    m.cena
   FROM ((magazyn m
     JOIN kategorie k ON ((m.kategoria = k.id)))
     JOIN gatunki g ON ((m.gatunek = g.id)));

DROP TABLE IF EXISTS "wyswietl_zamowienia";
CREATE VIEW "wyswietl_zamowienia" AS SELECT z.id,
    k.imie,
    k.nazwisko,
    m.nazwa,
    z.ile,
    z.suma,
    to_char(z.kiedy, 'DD-MM-YYYY HH24:MI:SS'::text) AS kiedy
   FROM ((zamowienie z
     JOIN klient k ON ((z.kto = k.id)))
     JOIN magazyn m ON ((z.co = m.id)));

-- 2022-06-16 00:54:09.977204+02
