CREATE OR REPLACE TRIGGER trg_hospital_admissions_history
AFTER INSERT OR UPDATE OR DELETE ON hospital_admissions
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO hospital_admissions_history
        (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis, valid_from, valid_to, operation_type, operation_time)
        VALUES
        (:NEW.admission_id, :NEW.patient_id, :NEW.doctor_id, :NEW.admission_date, :NEW.discharge_date, :NEW.severity, :NEW.diagnosis, 
        SYSTIMESTAMP, TO_TIMESTAMP('9999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS'), 'INSERT', SYSTIMESTAMP);
    ELSIF UPDATING THEN
        INSERT INTO hospital_admissions_history
        (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis, valid_from, valid_to, operation_type, operation_time)
        VALUES
        (:NEW.admission_id, :NEW.patient_id, :NEW.doctor_id, :NEW.admission_date, :NEW.discharge_date, :NEW.severity, :NEW.diagnosis, 
        SYSTIMESTAMP, TO_TIMESTAMP('9999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS'), 'UPDATE', SYSTIMESTAMP);
    ELSIF DELETING THEN
        INSERT INTO hospital_admissions_history
        (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis, valid_from, valid_to, operation_type, operation_time)
        VALUES
        (:OLD.admission_id, :OLD.patient_id, :OLD.doctor_id, :OLD.admission_date, :OLD.discharge_date, :OLD.severity, :OLD.diagnosis, 
        SYSTIMESTAMP, TO_TIMESTAMP('9999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS'), 'DELETE', SYSTIMESTAMP);
    END IF;
END;
