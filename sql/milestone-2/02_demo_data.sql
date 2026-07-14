/*=====================================================================
  CAR-RENTAL  -  DEMO  (parent-first inserts, no drops)
=====================================================================*/
SET ECHO OFF
SET DEFINE OFF
SET SERVEROUTPUT ON

/*-------------------------------------------------------------------*
 |  Part 1 - INSERT SAMPLE ROWS                                      |
 *-------------------------------------------------------------------*/
PROMPT =============================================================
PROMPT  Part 1 - Insert sample rows
PROMPT =============================================================

/* independent parents */
INSERT INTO Telefonnummer VALUES ('+431111111');
INSERT INTO Telefonnummer VALUES ('+431222222');
INSERT INTO Telefonnummer VALUES ('+431333333');
INSERT INTO Telefonnummer VALUES ('+431444444');
COMMIT;

INSERT INTO Filiale (Filialnummer, Stadt) VALUES (1001,'Wien');
INSERT INTO Filiale (Filialnummer, Stadt) VALUES (1002,'Graz');
COMMIT;

INSERT INTO Fahrzeug (Fahrzeug_ID, Marke, Modell, Baujahr)
VALUES (1,'VW','Golf',2019);
INSERT INTO Fahrzeug (Fahrzeug_ID, Marke, Modell, Baujahr)
VALUES (2,'Audi','A4',2021);
COMMIT;

/* customers */
INSERT INTO Kunde (Fuehrerscheinnummer, Name, Geburtsdatum, Nummer)
VALUES ('A12345678','Anna Bauer',    DATE '1990-05-12','+431111111');
INSERT INTO Kunde (Fuehrerscheinnummer, Name, Geburtsdatum, Nummer)
VALUES ('B98765432','Bernhard Koch', DATE '1985-11-23','+431222222');
COMMIT;

/* employees */
INSERT INTO Mitarbeiter (Personalnummer, Name, Filialnummer, Nummer)
VALUES (1,'Martha Mayer',1001,'+431333333');
INSERT INTO Mitarbeiter (Personalnummer, Name, Filialnummer, Nummer)
VALUES (2,'Willi Winter',1001,'+431444444');
COMMIT;

/* roles */
INSERT INTO Inspektionsmitarbeiter VALUES (1);
INSERT INTO Ist_boss_von          VALUES (2);
COMMIT;

/* transactions */
INSERT INTO Reservierung
        (Fuehrerscheinnummer, Reservierungsnummer,
         Reservierungsdatum, EndeDatum)
VALUES  ('A12345678', 1, DATE '2025-06-01', DATE '2025-06-05');

INSERT INTO Reservierung
        (Fuehrerscheinnummer, Reservierungsnummer,
         Reservierungsdatum, EndeDatum)
VALUES  ('B98765432', 1, DATE '2025-07-10', DATE '2025-07-12');

INSERT INTO Vermieten
        (Fuehrerscheinnummer, Personalnummer, Fahrzeug_ID)
VALUES  ('A12345678',1,1);

INSERT INTO Ueberpruefen VALUES (1,1);
COMMIT;

/* branch phones */
INSERT INTO Hat_Filiale VALUES (1001,'+431333333');
INSERT INTO Hat_Filiale VALUES (1001,'+431444444');
COMMIT;

/* tidy row-count query */

PROMPT --- Row counts after Part 1 --- 

SELECT 'Telefonnummer'                AS tbl, COUNT(*)  FROM Telefonnummer UNION ALL
SELECT 'Filiale',                            COUNT(*)       FROM Filiale        UNION ALL
SELECT 'Fahrzeug',                           COUNT(*)       FROM Fahrzeug       UNION ALL
SELECT 'Kunde',                              COUNT(*)       FROM Kunde          UNION ALL
SELECT 'Mitarbeiter',                        COUNT(*)       FROM Mitarbeiter    UNION ALL
SELECT 'Inspektionsmitarbeiter',             COUNT(*)       FROM Inspektionsmitarbeiter UNION ALL
SELECT 'Ist_boss_von',                       COUNT(*)       FROM Ist_boss_von   UNION ALL
SELECT 'Reservierung',                       COUNT(*)       FROM Reservierung   UNION ALL
SELECT 'Vermieten',                          COUNT(*)       FROM Vermieten      UNION ALL
SELECT 'Ueberpruefen',                       COUNT(*)       FROM Ueberpruefen   UNION ALL
SELECT 'Hat_Filiale',                        COUNT(*)       FROM Hat_Filiale;



/*-------------------------------------------------------------------*
 |  Part 2 – KEY-CONSTRAINT DEMOS  (commented lines raise errors)    |
 *-------------------------------------------------------------------*/
PROMPT =============================================================
PROMPT  Part 2 - PK & FK enforcement 
PROMPT =============================================================

/* duplicate PK - would raise ORA-00001 */
INSERT INTO Fahrzeug (Fahrzeug_ID, Marke, Modell, Baujahr)
VALUES (1,'BMW','X1',2020);


/* orphan FK - would raise ORA-02291 */
INSERT INTO Reservierung
  (Fuehrerscheinnummer, Reservierungsnummer, Reservierungsdatum, EndeDatum)
VALUES ('Z99999999', 99, SYSDATE, SYSDATE+1);


/*-------------------------------------------------------------------*
 |  Part 3 - DELETION-RULE DEMOS                                     |
 *-------------------------------------------------------------------*/
PROMPT =============================================================
PROMPT  Part 3 - ON DELETE SET NULL  and  ON DELETE CASCADE
PROMPT =============================================================

/* SET NULL demo */
PROMPT Before SET NULL demo:
SELECT Personalnummer, Name, Filialnummer
FROM   Mitarbeiter
ORDER  BY Personalnummer;

DELETE FROM Filiale WHERE Filialnummer = 1001;
COMMIT;

PROMPT After SET NULL demo:
SELECT Personalnummer, Name, Filialnummer
FROM   Mitarbeiter
ORDER  BY Personalnummer;

/* CASCADE demo */
PROMPT Before CASCADE demo (reservations):
SELECT Reservierungsnummer, Fuehrerscheinnummer
FROM   Reservierung
ORDER  BY Reservierungsnummer;

DELETE FROM Kunde WHERE Fuehrerscheinnummer = 'B98765432';
COMMIT;

PROMPT After CASCADE demo (reservations):
SELECT Reservierungsnummer, Fuehrerscheinnummer
FROM   Reservierung
ORDER  BY Reservierungsnummer;

/*-------------------------------------------------------------------*
 |  Part 4 - VIEW & QUERY                                            |
 *-------------------------------------------------------------------*/
PROMPT =============================================================
PROMPT  Part 4 - Create view and query it
PROMPT =============================================================

CREATE OR REPLACE VIEW vw_vermietungen AS
SELECT k.Name                      AS Kunde,
       f.Marke || ' ' || f.Modell  AS Fahrzeug,
       m.Name                      AS Mitarbeiter,
       v.Fahrzeug_ID,
       v.Fuehrerscheinnummer
FROM   Vermieten   v
JOIN   Kunde       k ON k.Fuehrerscheinnummer = v.Fuehrerscheinnummer
JOIN   Fahrzeug    f ON f.Fahrzeug_ID        = v.Fahrzeug_ID
JOIN   Mitarbeiter m ON m.Personalnummer     = v.Personalnummer;

PROMPT Current rentals (view):
SELECT * FROM vw_vermietungen;

PROMPT =============================================================
PROMPT DEMO COMPLETE
PROMPT =============================================================