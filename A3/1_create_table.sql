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
    foreign key (department_id) references department(department_id) ON DELETE CASCADE
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
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE supplied_from (
    supplier_id NUMBER NOT NULL,
    drug_name VARCHAR2(100) NOT NULL,
    stock NUMBER NOT NULL,
    restock_alert NUMBER GENERATED ALWAYS AS (CASE WHEN stock < 10 THEN 1 ELSE 0 END) VIRTUAL,
    PRIMARY KEY (supplier_id, drug_name),
    FOREIGN KEY (supplier_id, drug_name) REFERENCES medication(supplier_id, drug_name)
); 

-- TO-DO: MAKE SEQUENTIAL PKs
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

COMMIT;
