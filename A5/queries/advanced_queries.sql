-- Doctors with more than two unique patients
SELECT d.full_name AS doctor_name,
       COUNT(DISTINCT p.patient_id) AS unique_patients
FROM doctor d
JOIN prescription p ON d.doctor_id = p.doctor_id
JOIN patient pa ON p.patient_id = pa.patient_id
GROUP BY d.full_name
HAVING COUNT(DISTINCT p.patient_id) > 2
ORDER BY unique_patients DESC;

-- Patients with prescriptions from at least two different suppliers
SELECT pa.patient_id,
       pa.first_name || ' ' || pa.last_name AS patient_name,
       COUNT(DISTINCT p.supplier_id) AS num_suppliers
FROM patient pa
JOIN prescription p ON pa.patient_id = p.patient_id
GROUP BY pa.patient_id, pa.first_name, pa.last_name
HAVING COUNT(DISTINCT p.supplier_id) >= 2
ORDER BY num_suppliers DESC;

-- Suppliers that provide unique medications
SELECT s.supplier_name, m.drug_name
FROM supplier s
JOIN medication m ON s.supplier_id = m.supplier_id
WHERE NOT EXISTS (
    SELECT 1
    FROM medication m2
    WHERE m2.drug_name = m.drug_name
      AND m2.supplier_id <> s.supplier_id
)
ORDER BY s.supplier_name, m.drug_name;

-- Departments with average prescriptions per doctor above overall average
SELECT dep.department_name,
       AVG(doc_pres.prescriptions_count) AS avg_prescriptions
FROM department dep
JOIN doctor d ON dep.department_id = d.department_id
JOIN (
    SELECT doctor_id, COUNT(*) AS prescriptions_count
    FROM prescription
    GROUP BY doctor_id
) doc_pres ON d.doctor_id = doc_pres.doctor_id
GROUP BY dep.department_name
HAVING AVG(doc_pres.prescriptions_count) > (
    SELECT AVG(prescriptions_count)
    FROM (
        SELECT doctor_id, COUNT(*) AS prescriptions_count
        FROM prescription
        GROUP BY doctor_id
    )
)
ORDER BY avg_prescriptions DESC;

-- Patients with more than one prescription
SELECT pa.patient_id,
       pa.first_name || ' ' || pa.last_name AS patient_name,
       COUNT(p.prescription_id) AS total_prescriptions
FROM patient pa
JOIN prescription p ON pa.patient_id = p.patient_id
GROUP BY pa.patient_id, pa.first_name, pa.last_name
HAVING COUNT(p.prescription_id) > 1
ORDER BY total_prescriptions DESC;

exit;

