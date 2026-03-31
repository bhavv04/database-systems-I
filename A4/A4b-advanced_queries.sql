-- T27 - Hospital Pharmacy DBMS
-- Group Members: Parsa Kermani Pour, Arshia Sharifi, Bhavdeep Arora

--------------------
-- ADVANCED QUERIES
--------------------

-- Advanced Query 1: Shows all doctors by name and the number of prescriptions they have written
SELECT d.full_name, COUNT(p.prescription_id) AS prescription_count
FROM prescription p
JOIN doctor d ON d.doctor_id = p.doctor_id
GROUP BY d.full_name
ORDER BY prescription_count;

-- Advanced Query 2: Shows all patients who have been prescribed Ibuprofen and have not gotten their medication yet
SELECT pa.first_name || ' ' || pa.last_name AS patient_name
FROM prescription p
JOIN patient pa ON p.patient_id = pa.patient_id
WHERE p.drug_name = 'Ibuprofen'
  AND p.date_dispensed IS NULL;

-- Advanced Query 3: Shows all prescrptions made by the cardiology department.
-- Includes the doctor, patient, drug, and supplier names
SELECT
    p.prescription_id,
    pa.first_name || ' ' || pa.last_name AS patient_name,
    d.full_name AS doctor_name,
    p.drug_name,
    s.supplier_name
FROM prescription p
JOIN patient pa ON p.patient_id = pa.patient_id
JOIN doctor d ON p.doctor_id = d.doctor_id
JOIN supplier s ON p.supplier_id = s.supplier_id
JOIN department dep ON d.department_id = dep.department_id
WHERE department_name = 'Cardiology'
ORDER BY doctor_name;



--------------------
-- VIEWS
--------------------

-- View 1: Full history of all dispensed prescrptions.
CREATE OR REPLACE VIEW prescription_history (date_dispensed, pharmacist, medication, prescription_id) AS
SELECT 
    p.date_dispensed,
    ph.full_name,
    p.drug_name,
    p.prescription_id
FROM prescription p
INNER JOIN pharmacist ph ON p.pharmacist_id = ph.pharmacist_id
WHERE p.date_dispensed IS NOT NULL
ORDER BY p.date_dispensed DESC;

-- View 2: Full list of all medications that are low on stock, with the contact information of the supplier
CREATE OR REPLACE VIEW low_stock (medication, stock, supplier_name, order_number, order_email, delivery_duration_days) AS
SELECT 
    sf.drug_name,
    sf.stock,
    s.supplier_name,
    s.phone_number,
    s.email,
    s.delivery_duration_days
FROM supplied_from sf
JOIN supplier s ON s.supplier_id = sf.supplier_id
WHERE sf.restock_alert = 1
ORDER BY stock;

-- View 3: Full list of drugs and their total count (regardless of supplier) with a stock status
CREATE OR REPLACE VIEW inventory AS
SELECT
    drug_name,
    total_stock,
    CASE
        WHEN total_stock < 5 THEN 'Critial - PLACE ORDER IMMEDIATELY'
        WHEN total_stock < 10 THEN 'Low - ORDER SOON'
        WHEN total_stock < 50 THEN 'Medium - Monitor'
        ELSE 'Adequate'
    END AS stock_status
FROM (
    SELECT
        drug_name,
        SUM(stock) AS total_stock
    FROM supplied_from
    GROUP BY drug_name
)
ORDER BY total_stock;

COMMIT;