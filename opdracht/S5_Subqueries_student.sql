-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S5: Subqueries
---- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
--
--
-- Opdracht: schrijf SQL-queries om onderstaande resultaten op te vragen,
-- aan te maken, verwijderen of aan te passen in de database van de
-- bedrijfscasus.
--
-- NB: Gebruik in elke vraag van deze opdracht een subquery.
--
-- Codeer je uitwerking onder de regel 'DROP VIEW ...' (bij een SELECT)
-- of boven de regel 'ON CONFLICT DO NOTHING;' (bij een INSERT)
-- Je kunt deze eigen query selecteren en los uitvoeren, en wijzigen tot
-- je tevreden bent.

-- Vervolgens kun je je uitwerkingen testen door de testregels
-- (met [TEST] erachter) te activeren (haal hiervoor de commentaartekens
-- weg) en vervolgens het hele bestand uit te voeren. Hiervoor moet je de
-- testsuite in de database hebben geladen (bedrijf_postgresql_test.sql).
-- NB: niet alle opdrachten hebben testregels.
--
-- Lever je werk pas in op Canvas als alle tests slagen.
-- ------------------------------------------------------------------------


-- S5.1.
-- Welke medewerkers hebben zowel de Java als de XML cursus
-- gevolgd? Geef hun personeelsnummers.
DROP VIEW IF EXISTS s5_1; CREATE OR REPLACE VIEW s5_1 AS                                                     -- [TEST]
SELECT i1.cursist AS personeelsnummer
FROM inschrijvingen i1
WHERE i1.cursus = 'JAV' AND EXISTS(SELECT 1 
								  FROM inschrijvingen i2
								  WHERE i1.cursist = i2.cursist AND i2.cursus = 'XML');


-- S5.2.
-- Geef de nummers van alle medewerkers die niet aan de afdeling 'OPLEIDINGEN'
-- zijn verbonden.
DROP VIEW IF EXISTS s5_2; CREATE OR REPLACE VIEW s5_2 AS                                                     -- [TEST]
SELECT medewerkers.mnr
FROM medewerkers
WHERE medewerkers.mnr NOT IN(SELECT medewerkers.mnr
							FROM medewerkers
							JOIN afdelingen ON medewerkers.afd = afdelingen.anr
							WHERE afdelingen.naam = 'OPLEIDINGEN') ;

-- S5.3.
-- Geef de nummers van alle medewerkers die de Java-cursus niet hebben
-- gevolgd.
DROP VIEW IF EXISTS s5_3; CREATE OR REPLACE VIEW s5_3 AS                                                     -- [TEST]
SELECT medewerkers.mnr
FROM medewerkers
WHERE medewerkers.mnr NOT IN (SELECT inschrijvingen.cursist
							 FROM inschrijvingen
							 JOIN medewerkers ON inschrijvingen.cursist = medewerkers.mnr
							 WHERE inschrijvingen.cursus = 'JAV');

-- S5.4.
-- a. Welke medewerkers hebben ondergeschikten? Geef hun naam.
DROP VIEW IF EXISTS s5_4a; CREATE OR REPLACE VIEW s5_4a AS                                                   -- [TEST]
SELECT medewerkers.naam
FROM medewerkers
WHERE EXISTS (SELECT *
			 FROM medewerkers med
			 WHERE med.chef = medewerkers.mnr);
-- b. En welke medewerkers hebben geen ondergeschikten? Geef wederom de naam.
DROP VIEW IF EXISTS s5_4b; CREATE OR REPLACE VIEW s5_4b AS                                                   -- [TEST]
SELECT medewerkers.naam
FROM medewerkers
WHERE NOT EXISTS (SELECT *
				 FROM medewerkers med
				 WHERE med.chef = medewerkers.mnr);

-- S5.5.
-- Geef cursuscode en begindatum van alle uitvoeringen van programmeercursussen
-- ('BLD') in 2020.
DROP VIEW IF EXISTS s5_5; CREATE OR REPLACE VIEW s5_5 AS                                                     -- [TEST]
SELECT cursus AS cursuscode, begindatum
FROM uitvoeringen
WHERE cursus IN (
    SELECT code
    FROM cursussen
    WHERE cursussen.type = 'BLD'
) AND EXTRACT(YEAR FROM begindatum) = 2020;

-- S5.6.
-- Geef van alle cursusuitvoeringen: de cursuscode, de begindatum en het
-- aantal inschrijvingen (`aantal_inschrijvingen`). Sorteer op begindatum.
DROP VIEW IF EXISTS s5_6; CREATE OR REPLACE VIEW s5_6 AS                                                     -- [TEST]
SELECT u.cursus AS cursuscode, u.begindatum, (
    SELECT COUNT(i.cursist)
    FROM inschrijvingen i
    WHERE i.cursus = u.cursus AND i.begindatum = u.begindatum
) AS aantal_inschrijvingen
FROM uitvoeringen u
ORDER BY u.begindatum;

-- S5.7.
-- Geef voorletter(s) en achternaam van alle trainers die ooit tijdens een
-- algemene ('ALG') cursus hun eigen chef als cursist hebben gehad.
DROP VIEW IF EXISTS s5_7; CREATE OR REPLACE VIEW s5_7 AS                                                     -- [TEST]
SELECT medewerkers.voorl, medewerkers.naam
FROM medewerkers
WHERE EXISTS (
    SELECT *
    FROM uitvoeringen
    WHERE uitvoeringen.docent = medewerkers.mnr
    AND uitvoeringen.cursus IN (
        SELECT cursussen.code
        FROM cursussen
        WHERE cursussen.type = 'ALG'
    ))
AND EXISTS (
    SELECT *
    FROM inschrijvingen
    WHERE inschrijvingen.cursist = medewerkers.chef
    AND inschrijvingen.cursus IN (
        SELECT cursussen.code
        FROM cursussen
        WHERE cursussen.type = 'ALG'
    ))
AND medewerkers.functie = 'TRAINER';


-- S5.8.
-- Geef de naam van de medewerkers die nog nooit een cursus hebben gegeven.
DROP VIEW IF EXISTS s5_8; CREATE OR REPLACE VIEW s5_8 AS                                                     -- [TEST]                                                    -- [TEST]
SELECT medewerkers.naam
FROM medewerkers
WHERE NOT EXISTS
        (SELECT *
         FROM uitvoeringen
         WHERE uitvoeringen.docent = medewerkers.mnr)
;



-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT * FROM test_select('S5.1') AS resultaat
UNION
SELECT * FROM test_select('S5.2') AS resultaat
UNION
SELECT * FROM test_select('S5.3') AS resultaat
UNION
SELECT * FROM test_select('S5.4a') AS resultaat
UNION
SELECT * FROM test_select('S5.4b') AS resultaat
UNION
SELECT * FROM test_select('S5.5') AS resultaat
UNION
SELECT * FROM test_select('S5.6') AS resultaat
UNION
SELECT * FROM test_select('S5.7') AS resultaat
UNION
SELECT * FROM test_select('S5.8') AS resultaat
ORDER BY resultaat;
