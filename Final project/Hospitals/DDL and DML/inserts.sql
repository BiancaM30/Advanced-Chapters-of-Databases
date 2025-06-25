DROP TABLE prescriptions_history;
DROP TABLE hospital_admissions_history;
DROP TABLE prescriptions;
DROP TABLE hospital_admissions;
DROP TABLE doctors;
DROP TABLE drugs;
DROP TABLE patients;


SELECT * FROM patients;
SELECT * FROM doctors;
SELECT * FROM hospital_admissions;

SELECT * FROM hospital_admissions
WHERE admission_id=11;

select * from hospital_admissions_history
WHERE admission_id=3;

select * from hospital_admissions_history
WHERE admission_id=1;

DELETE from hospital_admissions_history;
DELETE FROM hospital_admissions;
DELETE FROM patients;
DELETE FROM doctors;




-- Patients
INSERT INTO patients (patient_id, patient_name, birthday, gender, address)
VALUES (1, 'John Doe', TO_DATE('1990-05-15', 'YYYY-MM-DD'), 'Male', '123 Elm Street');
INSERT INTO patients (patient_id, patient_name, birthday, gender, address)
VALUES (2, 'Jane Smith', TO_DATE('1985-08-20', 'YYYY-MM-DD'), 'Female', '456 Oak Avenue');
INSERT INTO patients (patient_id, patient_name, birthday, gender, address)
VALUES (3, 'Mike Brown', TO_DATE('2000-03-10', 'YYYY-MM-DD'), 'Male', '789 Pine Road');

-- Doctors
INSERT INTO doctors (doctor_id, doctor_name, specialty)
VALUES (101, 'Dr. Emily Green', 'Cardiology');
INSERT INTO doctors (doctor_id, doctor_name, specialty)
VALUES (102, 'Dr. Liam White', 'Neurology');
INSERT INTO doctors (doctor_id, doctor_name, specialty)
VALUES (103, 'Dr. Sophia Black', 'Pediatrics');

-- Hospital Admissions Table
-- Initial Insertions
-- Step 1: Initial Inserts
INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (1, 1, 101, TO_DATE('2024-01-10', 'YYYY-MM-DD'), TO_DATE('2024-01-15', 'YYYY-MM-DD'), 5, 'Chest Pain');

INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (2, 2, 102, TO_DATE('2024-01-12', 'YYYY-MM-DD'), TO_DATE('2024-01-18', 'YYYY-MM-DD'), 7, 'Migraine');

-- Step 2: Update Admission ID 1
UPDATE hospital_admissions
SET severity = 6, diagnosis = 'Mild Chest Pain'
WHERE admission_id = 1;

-- Step 3: Insert More Admissions
INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (3, 3, 103, TO_DATE('2024-01-15', 'YYYY-MM-DD'), TO_DATE('2024-01-20', 'YYYY-MM-DD'), 4, 'Flu');

INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (4, 1, 101, TO_DATE('2024-01-20', 'YYYY-MM-DD'), NULL, 6, 'Heartburn');

-- Step 4: Update Admission ID 2
UPDATE hospital_admissions
SET discharge_date = TO_DATE('2024-01-20', 'YYYY-MM-DD')
WHERE admission_id = 2;

-- Step 5: Insert More Admissions
INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (5, 2, 102, TO_DATE('2024-01-25', 'YYYY-MM-DD'), NULL, 8, 'Severe Migraine');

INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (6, 3, 103, TO_DATE('2024-01-28', 'YYYY-MM-DD'), TO_DATE('2024-02-02', 'YYYY-MM-DD'), 6, 'Critical Flu');

-- Step 6: Update Admissions
-- Update severity for Admission ID 3
UPDATE hospital_admissions
SET severity = 5
WHERE admission_id = 3;

-- Update severity and add discharge date for Admission ID 4
UPDATE hospital_admissions
SET discharge_date = TO_DATE('2024-01-30', 'YYYY-MM-DD'), severity = 7
WHERE admission_id = 4;

-- Step 7: Delete Admission ID 1
DELETE FROM hospital_admissions
WHERE admission_id = 1;

-- Step 8: Update More Admissions
-- Update diagnosis for Admission ID 5
UPDATE hospital_admissions
SET diagnosis = 'Chronic Migraine'
WHERE admission_id = 5;

-- Update severity and diagnosis for Admission ID 6
UPDATE hospital_admissions
SET severity = 7, diagnosis = 'Recovery from Flu'
WHERE admission_id = 6;

-- Step 9: Insert More Admissions
INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (7, 1, 101, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-05', 'YYYY-MM-DD'), 4, 'Routine Checkup');

INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (8, 2, 102, TO_DATE('2024-02-02', 'YYYY-MM-DD'), NULL, 6, 'Back Pain');

-- Step 10: Delete Admission ID 4
DELETE FROM hospital_admissions
WHERE admission_id = 4;

-- Step 11: Insert Final Admissions
INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (9, 3, 103, TO_DATE('2024-02-03', 'YYYY-MM-DD'), TO_DATE('2024-02-10', 'YYYY-MM-DD'), 8, 'Severe Allergy');

INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
VALUES (10, 1, 101, TO_DATE('2024-02-05', 'YYYY-MM-DD'), TO_DATE('2024-02-10', 'YYYY-MM-DD'), 5, 'Skin Rash');

-- Step 12: Final Deletes
-- Delete Admission ID 6
DELETE FROM hospital_admissions
WHERE admission_id = 6;


