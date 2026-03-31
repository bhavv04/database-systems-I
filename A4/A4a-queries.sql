-- T27 - Hospital Pharmacy DBMS
-- Group Members: Parsa Kermani Pour, Arshia Sharifi, Bhavdeep Arora

-- Query 1: Department Table - List all departments ordered alphabetically
SELECT *
FROM department
ORDER BY department_name;

-- Query 2: Shows all patient data with an OHIP number sorted by date of birth
SELECT last_name||', '||first_name AS patient_name, ohip_number, dob
FROM patient
WHERE ohip_number IS NOT NULL
ORDER BY dob DESC;

-- Query 3: Doctor Table - Find doctors in Cardiology department
SELECT d.doctor_id, d.full_name, d.email, dept.department_name
FROM doctor d, department dept
WHERE d.department_id = dept.department_id
  AND dept.department_name = 'Cardiology'
ORDER BY d.full_name;

-- Query 4: Name of all doctors and their patients who they have written a prescription for.
SELECT DISTINCT patient.last_name||', '||patient.first_name AS patient_name, doctor.full_name AS doctor_name
FROM doctor, patient, prescription
WHERE doctor.doctor_id = prescription.doctor_id AND patient.patient_id = prescription.patient_id
ORDER BY patient_name;

-- Query 5: Names of all doctors and their patients who have been prescribed Ibuprofen, sorted by the patient's last name.
SELECT doctor.full_name AS doctor_name, patient.last_name||', '||patient.first_name AS patient_name
FROM doctor, prescription, patient
WHERE drug_name = 'Ibuprofen'
  AND doctor.doctor_id = prescription.doctor_id 
  AND patient.patient_id = prescription.patient_id
ORDER BY patient_name;

-- Query 6: Return a history of all dispensed prescriptions and the pharmacist who dispensed them
SELECT pres.date_dispensed, pres.prescription_id, pres.drug_name, pharm.pharmacist_id, pharm.full_name
FROM prescription pres, pharmacist pharm
WHERE pres.date_dispensed IS NOT NULL
  AND pres.pharmacist_id = pharm.pharmacist_id
ORDER BY pres.date_dispensed;

-- Query 7: Number of drugs from each supplier and sort by supplier name
SELECT s.supplier_name, COUNT(m.drug_name) AS drug_count
FROM supplier s, medication m
WHERE s.supplier_id = m.supplier_id
GROUP BY s.supplier_name
ORDER BY s.supplier_name;

-- Query 8: Show which drugs are low in stock (restock_flag is 1)
SELECT s.supplier_name, sf.drug_name, sf.stock
FROM supplied_from sf, supplier s
WHERE sf.restock_alert = 1
  AND sf.supplier_id = s.supplier_id;

SELECT *
FROM supplied_from;


