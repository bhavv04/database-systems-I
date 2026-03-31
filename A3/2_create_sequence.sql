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


COMMIT;