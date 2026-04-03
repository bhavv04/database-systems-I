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



-- Drop all tables (in order of dependency)
DROP TABLE prescription;
DROP TABLE supplied_from;
DROP TABLE medication;
DROP TABLE supplier;
DROP TABLE patient;
DROP TABLE pharmacist;
DROP TABLE doctor;
DROP TABLE department;


-- Create all tables
CREATE TABLE department(
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL
);

CREATE TABLE doctor (
    doctor_id NUMBER PRIMARY KEY,
    full_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) NOT NULL,
    department_id NUMBER NOT NULL,
    foreign key (department_id) references department(department_id)
);

CREATE TABLE pharmacist (
    pharmacist_id NUMBER PRIMARY KEY,
    full_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) NOT NULL
);

CREATE TABLE patient (
    patient_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(30) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    ohip_number VARCHAR2(12) UNIQUE,
    phone_number VARCHAR2(15) UNIQUE,
    patient_description VARCHAR2(255),
    dob DATE
);

CREATE TABLE supplier (
    supplier_id NUMBER PRIMARY KEY,
    supplier_name VARCHAR2(200) NOT NULL,
    phone_number VARCHAR2(15) UNIQUE NOT NULL,
    email VARCHAR2(100),
    delivery_duration_days NUMBER NOT NULL,
    supplier_address VARCHAR2(100) NOT NULL
);

CREATE TABLE medication (
    supplier_id NUMBER NOT NULL,
    drug_name VARCHAR2(100) NOT NULL,
    PRIMARY KEY (supplier_id, drug_name),
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id) ON DELETE CASCADE
);

CREATE TABLE supplied_from (
    supplier_id NUMBER NOT NULL,
    drug_name VARCHAR2(100) NOT NULL,
    stock NUMBER NOT NULL,
    restock_alert NUMBER GENERATED ALWAYS AS (CASE WHEN stock < 10 THEN 1 ELSE 0 END) VIRTUAL,
    PRIMARY KEY (supplier_id, drug_name),
    FOREIGN KEY (supplier_id, drug_name) REFERENCES medication(supplier_id, drug_name) ON DELETE CASCADE
); 

CREATE TABLE prescription (
    prescription_id NUMBER PRIMARY KEY,
    notes VARCHAR2(200),
    date_created TIMESTAMP NOT NULL,
    date_dispensed TIMESTAMP,
    patient_id NUMBER NOT NULL,
    doctor_id NUMBER NOT NULL,
    pharmacist_id NUMBER,
    supplier_id NUMBER NOT NULL,
    drug_name VARCHAR2(100) NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    FOREIGN KEY (pharmacist_id) REFERENCES pharmacist(pharmacist_id),
    FOREIGN KEY (supplier_id, drug_name) REFERENCES medication(supplier_id, drug_name)
);



-- Drop sequence if it exists
DROP SEQUENCE prescription_seq;

-- Create sequence generator for prescription_id
CREATE SEQUENCE prescription_seq 
START WITH 1 
INCREMENT BY 1 
NOCACHE;

CREATE OR REPLACE TRIGGER prescription_id_trigger
    BEFORE INSERT ON prescription
    FOR EACH ROW
BEGIN
    IF :NEW.prescription_id IS NULL THEN
        :NEW.prescription_id := prescription_seq.NEXTVAL;
    END IF;
END;
/



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
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (2, 'Ibuprofen', 8);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (2, 'Acetaminophen', 200);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (2, 'Lisinopril', 75);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (3, 'Metformin', 5);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (3, 'Atorvastatin', 120);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (4, 'Amoxicillin', 90);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (5, 'Omeprazole', 45);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (5, 'Insulin', 3);
INSERT INTO supplied_from (supplier_id, drug_name, stock) VALUES (5, 'Albuterol', 25);

-- Insert data into prescription table (prescription ID is set by sequential generator)
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (123456789, 629518374062, 4, 'Amoxicillin', TIMESTAMP '2025-09-15 10:30:00', 'Take twice daily with food');
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (456789012, 847392561048, 2, 'Ibuprofen', TIMESTAMP '2025-09-18 14:15:00', 'Once daily before breakfast');
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (234567890, 482917635841, 3, 'Metformin', TIMESTAMP '2025-09-20 09:45:00', 'As needed for chest pain');
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (123456789, 629518374062, 5, 'Insulin', TIMESTAMP '2025-09-19 16:20:00', 'Liquid form, 5ml twice daily');
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (234567890, 482917635841, 2, 'Ibuprofen', TIMESTAMP '2025-09-21 11:55:00', 'Emergency prescription');
INSERT INTO prescription (doctor_id, patient_id, supplier_id, drug_name, date_created, notes) VALUES (456789012, 391856402739, 2, 'Ibuprofen', TIMESTAMP '2025-09-24 2:30:00', 'Take every 6 hours for 2 days');


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