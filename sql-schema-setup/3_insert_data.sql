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



-- Clear all existing data (in order of dependency)
DELETE FROM prescription;
DELETE FROM supplied_from;
DELETE FROM medication;
DELETE FROM supplier;
DELETE FROM patient;
DELETE FROM pharmacist;
DELETE FROM doctor;
DELETE FROM department;


-- Insert data into department table
INSERT INTO department VALUES (1, 'Cardiology');
INSERT INTO department VALUES (2, 'Neurology');
INSERT INTO department VALUES (3, 'Pediatrics');

-- Insert data into doctor table
INSERT INTO doctor VALUES (123456789, 'Dr. Sarah Johnson', 'sarah.johnson@hospital.com', 1);
INSERT INTO doctor VALUES (234567890, 'Dr. Michael Chen', 'michael.chen@hospital.com', 2);
INSERT INTO doctor VALUES (345678901, 'Dr. Emily Rodriguez', 'emily.rodriguez@hospital.com', 3);
INSERT INTO doctor VALUES (456789012, 'Dr. David Kim', 'david.kim@hospital.com', 1);
INSERT INTO doctor VALUES (567890123, 'Dr. Lisa Thompson', 'lisa.thompson@hospital.com', 2);

-- Insert data into pharmacist table
INSERT INTO pharmacist VALUES (678901234, 'John Williams', 'john.williams@pharmacy.com');
INSERT INTO pharmacist VALUES (789012345, 'Maria Garcia', 'maria.garcia@pharmacy.com');
INSERT INTO pharmacist VALUES (890123456, 'Robert Davis', 'robert.davis@pharmacy.com');
INSERT INTO pharmacist VALUES (901234567, 'Jennifer Lee', 'jennifer.lee@pharmacy.com');
INSERT INTO pharmacist VALUES (012345678, 'James Wilson', 'james.wilson@pharmacy.com');

-- Insert data into patient table
INSERT INTO patient VALUES (847392561048, 'Alice', 'Smith', '1234567890AB', '416-555-0123', 'Regular checkup patient', DATE '1985-03-15');
INSERT INTO patient VALUES (629518374062, 'Bob', 'Brown', '2345678901BC', '416-555-0124', 'Diabetic patient', DATE '1978-07-22');
INSERT INTO patient VALUES (391856402739, 'Carol', 'Davis', NULL, '905-555-0125', 'Heart condition', DATE '1990-11-08');
INSERT INTO patient VALUES (756284193057, 'Daniel', 'Wilson', '4567890123DE', '905-555-0126', 'Pediatric patient', DATE '2015-05-30');
INSERT INTO patient VALUES (482917635841, 'Jane', 'Doe', NULL, NULL, NULL, NULL);

-- Insert data into supplier table
INSERT INTO supplier VALUES (1, 'PharmaTech Solutions', '416-555-1001', 'orders@pharmatech.com', 3, '100 Industry Blvd, Toronto');
INSERT INTO supplier VALUES (2, 'MediCore Distribution', '905-555-1002', 'sales@medicore.com', 5, '200 Commerce Way, Mississauga');
INSERT INTO supplier VALUES (3, 'VitalCare Supply Co', '647-555-1003', 'info@vitalcare.com', 2, '300 Medical Ave, Brampton');
INSERT INTO supplier VALUES (4, 'CanadaRx Pharmaceuticals', '416-555-1004', 'contact@canadarx.com', 7, '400 Science Park, Toronto');
INSERT INTO supplier VALUES (5, 'MedSupply Plus', '905-555-1005', 'support@medsupplyplus.com', 1, '500 Quick Lane, Mississauga');

-- Insert data into medication table
INSERT INTO medication VALUES (1, 'Aspirin');
INSERT INTO medication VALUES (2, 'Ibuprofen');
INSERT INTO medication VALUES (2, 'Acetaminophen');
INSERT INTO medication VALUES (2, 'Lisinopril');
INSERT INTO medication VALUES (3, 'Metformin');
INSERT INTO medication VALUES (3, 'Atorvastatin');
INSERT INTO medication VALUES (4, 'Amoxicillin');
INSERT INTO medication VALUES (5, 'Omeprazole');
INSERT INTO medication VALUES (5, 'Insulin');
INSERT INTO medication VALUES (5, 'Albuterol');

-- Insert data into supplied_from table
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (1, 'Aspirin', 150);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (1, 'Ibuprofen', 8);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (2, 'Acetaminophen', 200);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (2, 'Lisinopril', 75);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (3, 'Metformin', 5);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (3, 'Atorvastatin', 120);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (4, 'Amoxicillin', 90);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (4, 'Omeprazole', 45);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (5, 'Insulin', 3);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (5, 'Albuterol', 25);

-- Insert data into prescription table (prescription ID is set by sequential generator)
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (123456789, 629518374062, 4, 'Amoxicillin', TIMESTAMP '2025-09-15 10:30:00', 'Take twice daily with food');
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (456789012, 847392561048, 1, 'Ibuprofen', TIMESTAMP '2025-09-18 14:15:00', 'Once daily before breakfast');
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (234567890, 482917635841, 3, 'Metformin', TIMESTAMP '2025-09-20 09:45:00', 'As needed for chest pain');
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (123456789, 629518374062, 5, 'Insulin', TIMESTAMP '2025-09-19 16:20:00', 'Liquid form, 5ml twice daily');
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (234567890, 482917635841, 1, 'Ibuprofen', TIMESTAMP '2025-09-21 11:55:00', 'Emergency prescription');

COMMIT;