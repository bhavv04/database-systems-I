-- Drop all tables (in order of dependency)
DROP TABLE prescription;
DROP TABLE supplied_from;
DROP TABLE medication;
DROP TABLE supplier;
DROP TABLE patient;
DROP TABLE pharmacist;
DROP TABLE doctor;
DROP TABLE department;

COMMIT;

exit;
