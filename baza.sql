CREATE TABLE "klient" (
        "id" serial NOT NULL PRIMARY KEY,
        "imie" VARCHAR(255) NOT NULL,
        "nazwisko" VARCHAR(255) NOT NULL,
        "data_dolaczenia" date NOT NULL
);

CREATE TABLE "gatunki" (
        "id" serial NOT NULL PRIMARY KEY,
        "nazwa" VARCHAR(255) NOT NULL
);

CREATE TABLE "zamowienie" (
        "id" serial NOT NULL PRIMARY KEY,
        "kto" integer NOT NULL,
        "co" integer NOT NULL,
        "ile" integer NOT NULL,
        "suma" float NOT NULL,
        "kiedy" timestamp NOT NULL DEFAULT now()
);

CREATE TABLE "kategorie" (
        "id" serial NOT NULL PRIMARY KEY,
        "kat" VARCHAR(255) NOT NULL
);

CREATE TABLE "magazyn" (
        "id" serial NOT NULL PRIMARY KEY,
        "nazwa" VARCHAR(255) NOT NULL,
        "kategoria" integer NOT NULL,
        "gatunek" integer NOT NULL,
        "stan" integer NOT NULL,
        "cena" FLOAT NOT NULL ON DELETE CASCADE
);

ALTER TABLE "zamowienie" ADD CONSTRAINT "zamowienie_kto" FOREIGN KEY ("kto") REFERENCES "klient"("id");
ALTER TABLE "zamowienie" ADD CONSTRAINT "zamowienie_co" FOREIGN KEY ("co") REFERENCES "magazyn"("id");

ALTER TABLE "magazyn" ADD CONSTRAINT "magazyn_kat" FOREIGN KEY ("kategoria") REFERENCES "kategorie"("id");
ALTER TABLE "magazyn" ADD CONSTRAINT "magazyn_gat" FOREIGN KEY ("gatunek") REFERENCES "gatunki"("id");

CREATE OR REPLACE FUNCTION sprawdz_stan() RETURNS trigger AS $$
BEGIN
    IF (NEW.ile > (SELECT stan FROM magazyn WHERE id = NEW.co)) THEN
        RAISE EXCEPTION 'Zbyt mało towaru w magazynie!';
    END IF;
    UPDATE magazyn SET stan = stan - NEW.ile WHERE id = NEW.co;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sprawdz_stan BEFORE INSERT OR UPDATE ON zamowienie
FOR EACH ROW EXECUTE PROCEDURE sprawdz_stan();


CREATE OR REPLACE FUNCTION sprawdz_stan2() RETURNS trigger AS $$
BEGIN
    IF (NEW.ile - OLD.ile > (SELECT stan FROM magazyn WHERE id = NEW.co)) THEN
        RAISE EXCEPTION 'Zbyt mało towaru w magazynie!';
    END IF;
    UPDATE magazyn SET stan = stan - (NEW.ile - OLD.ile) WHERE id = NEW.co;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sprawdz_stan_update BEFORE UPDATE on zamowienie
FOR EACH ROW EXECUTE PROCEDURE sprawdz_stan2();

CREATE OR REPLACE FUNCTION zwrot() RETURNS trigger AS $$
BEGIN
    UPDATE magazyn SET stan = stan + OLD.ile WHERE id = OLD.co;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER zwrot AFTER DELETE ON zamowienie
FOR EACH ROW EXECUTE PROCEDURE zwrot();

CREATE OR REPLACE FUNCTION suma() RETURNS trigger AS $$
BEGIN
    NEW.suma = (SELECT cena FROM magazyn WHERE id = NEW.co) * NEW.ile;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER suma BEFORE INSERT ON zamowienie
FOR EACH ROW EXECUTE PROCEDURE suma();


CREATE OR REPLACE VIEW wyswietl_zamowienia AS
SELECT z.id, k.imie, k.nazwisko, m.nazwa, z.ile, z.suma
FROM zamowienie z
JOIN klient k ON z.kto = k.id
JOIN magazyn m ON z.co = m.id;

SELECT exists (SELECT 1 FROM table WHERE column = <value> LIMIT 1);

CREATE OR REPLACE FUNCTION dodaj_towar(VARCHAR(255), VARCHAR(255), VARCHAR(255), integer, float) RETURNS void AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM magazyn WHERE nazwa = $1) THEN
        RAISE EXCEPTION 'Towar o takiej nazwie juz istnieje!';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM kategorie WHERE kat = $2) THEN
        INSERT INTO kategorie (kat) VALUES ($2);
    END IF;
    IF not EXISTS (SELECT 1 FROM gatunki WHERE nazwa = $3) THEN
        INSERT INTO gatunki (nazwa) VALUES ($3);
    END IF;
    INSERT INTO magazyn (nazwa, kategoria, gatunek, stan, cena) VALUES ($1, (SELECT id FROM kategorie WHERE kat = $2), (SELECT id FROM gatunki WHERE nazwa = $3), $4, $5);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW pokaz_mi_swoje_towary AS
SELECT m.id, m.nazwa, k.kat AS kategoria, g.nazwa as gatunek, m.stan, m.cena
FROM magazyn m
JOIN kategorie k ON m.kategoria = k.id
JOIN gatunki g ON m.gatunek = g.id;

CREATE OR REPLACE FUNCTION zamowienia_klienta(integer) RETURNS SETOF wyswietl_zamowienia AS $$
BEGIN
    RETURN QUERY SELECT * FROM wyswietl_zamowienia WHERE imie = (SELECT imie FROM klient WHERE id = $1) AND nazwisko = (SELECT nazwisko FROM klient WHERE id = $1);
END;
$$ LANGUAGE plpgsql;