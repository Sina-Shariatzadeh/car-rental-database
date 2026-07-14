/*-------------------------------------------------------------------*
 |  Part 5 – TRIGGER: AUTO-INCREMENT SIMULATION                      |
 *-------------------------------------------------------------------*/
PROMPT =============================================================
PROMPT  Part 5 - Trigger: Auto-Increment on Reservierung
PROMPT =============================================================

-- Schritt 1: Erstellen der Zähltabelle
CREATE TABLE Reservation_Counter (
  last_number NUMBER
);

-- Schritt 2: Initialisieren mit dem höchsten vorhandenen Wert oder 0
INSERT INTO Reservation_Counter
SELECT COALESCE(MAX(Reservierungsnummer), 0)
FROM Reservierung
WHERE Reservierungsnummer IS NOT NULL;

-- Schritt 3: Trigger zum Simulieren von AUTO-INCREMENT
CREATE OR REPLACE TRIGGER trg_auto_increment_reservierung
BEFORE INSERT ON Reservierung
FOR EACH ROW
BEGIN
  UPDATE Reservation_Counter
  SET last_number = last_number + 1;

  SELECT last_number INTO :NEW.Reservierungsnummer
  FROM Reservation_Counter;
END;
/

-- Schritt 4: Testeintrag (optional)
INSERT INTO Reservierung (
  Reservierungsdatum, EndeDatum, Fuehrerscheinnummer
) VALUES (
  DATE '2025-08-01', DATE '2025-08-03', 'A12345678'
);




/*-------------------------------------------------------------------*
 |  Part 6 – TRIGGER: BUSINESS LOGIC ON LONG RESERVATION             |
 *-------------------------------------------------------------------*/
PROMPT =============================================================
PROMPT  Part 6 - Trigger: Log Long Reservations (> 5 days)
PROMPT =============================================================

-- Schritt 1: Erstellen der Log-Tabelle
CREATE TABLE Log_Reservations (
  log_id NUMBER GENERATED ALWAYS AS IDENTITY,
  fuehrerscheinnummer VARCHAR2(20),
  tage NUMBER,
  log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Schritt 2: Trigger zur Erkennung langer Reservierungen
CREATE OR REPLACE TRIGGER trg_check_reservation_length
AFTER INSERT ON Reservierung
FOR EACH ROW
DECLARE
  days_diff NUMBER;
BEGIN
  days_diff := :NEW.EndeDatum - :NEW.Reservierungsdatum;

  IF days_diff > 5 THEN
    INSERT INTO Log_Reservations (fuehrerscheinnummer, tage)
    VALUES (:NEW.Fuehrerscheinnummer, days_diff);
  END IF;
END;
/

-- Schritt 3: Testeintrag (optional)
INSERT INTO Reservierung (
  Reservierungsdatum, EndeDatum, Fuehrerscheinnummer
) VALUES (
  DATE '2025-09-01', DATE '2025-09-10', 'A12345678'
);

-- Schritt 4: Log-Tabelle anzeigen (optional)
SELECT * FROM Log_Reservations;
