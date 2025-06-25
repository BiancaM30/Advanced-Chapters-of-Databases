CREATE OR REPLACE TRIGGER trg_prescriptions_history
AFTER INSERT OR UPDATE OR DELETE ON prescriptions
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO prescriptions_history
        (prescription_id, admission_id, drug_id, prescription_date, quantity, operation_type, operation_time)
        VALUES
        (:NEW.prescription_id, :NEW.admission_id, :NEW.drug_id, :NEW.prescription_date, :NEW.quantity, 'INSERT', SYSTIMESTAMP);
    ELSIF UPDATING THEN
        INSERT INTO prescriptions_history
        (prescription_id, admission_id, drug_id, prescription_date, quantity, operation_type, operation_time)
        VALUES
        (:NEW.prescription_id, :NEW.admission_id, :NEW.drug_id, :NEW.prescription_date, :NEW.quantity, 'UPDATE', SYSTIMESTAMP);
    ELSIF DELETING THEN
        INSERT INTO prescriptions_history
        (prescription_id, admission_id, drug_id, prescription_date, quantity, operation_type, operation_time)
        VALUES
        (:OLD.prescription_id, :OLD.admission_id, :OLD.drug_id, :OLD.prescription_date, :OLD.quantity, 'DELETE', SYSTIMESTAMP);
    END IF;
END;
