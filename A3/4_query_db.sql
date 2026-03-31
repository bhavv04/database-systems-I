-- Topic: T27 - Hospital Pharmacy DBMS
-- Group Members:
--
-- NAME: Parsa Kermani Pour
-- STUDENT_ID: 501183294
--
-- NAME: Arshia Sharifi
-- STUDENT_ID: 501158323
--
-- NAME: Bhavdeep Arora
-- STUDENT_ID: 501152698



-- Shows all prescriptions
SELECT * FROM prescription;

-- "Dispenses" a prescription as a pharmacist
UPDATE prescription
SET date_dispensed = CURRENT_TIMESTAMP,
    pharmacist_id = 678901234
WHERE prescription_id = 2;

UPDATE prescription
SET date_dispensed = CURRENT_TIMESTAMP,
    pharmacist_id = 789012345
WHERE prescription_id = 3;

-- Shows all dispensed descriptions
SELECT * FROM prescription
WHERE date_dispensed IS NOT NULL;

-- Shows all drugs from supplier VitalCare Supply Co.
SELECT m.drug_name, s.supplier_name
FROM medication m
JOIN supplier s ON m.supplier_id = s.supplier_id
WHERE s.supplier_name = 'VitalCare Supply Co';

COMMIT;