-- 1. Proiectati si implementati un model de date cu atribute temporale pentru o problema la alegere.  
-- Problema trebuie sa contina: 
-- cel putin 2 entitati (tabele) cu atribute transaction time
-- cel putin 1 entitate (tabele) cu atribute valid time

CREATE TABLE patients (
    patient_id NUMBER PRIMARY KEY,
    patient_name VARCHAR2(100) NOT NULL,
    birthday DATE,
    gender VARCHAR2(10),
    address VARCHAR2(255)
);

CREATE TABLE doctors (
    doctor_id NUMBER PRIMARY KEY,
    doctor_name VARCHAR2(100) NOT NULL,
    specialty VARCHAR2(100) NOT NULL
);

CREATE TABLE drugs (
    drug_id NUMBER PRIMARY KEY,
    drug_name VARCHAR2(100) NOT NULL,
    drug_category VARCHAR2(100) NOT NULL
);

CREATE TABLE hospital_admissions (
    admission_id NUMBER PRIMARY KEY,
    patient_id NUMBER NOT NULL,
    doctor_id NUMBER NOT NULL,
    admission_date DATE NOT NULL,   
    discharge_date DATE,            
    severity NUMBER(2),
    diagnosis VARCHAR2(255),  
    PERIOD FOR valid_time (admission_date, discharge_date), 
    CONSTRAINT fk_patient_admission FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_doctor_admission FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);


CREATE TABLE prescriptions (
    prescription_id NUMBER PRIMARY KEY,
    admission_id NUMBER NOT NULL,
    drug_id NUMBER NOT NULL,
    prescription_date DATE NOT NULL,
    quantity NUMBER NOT NULL,
    CONSTRAINT fk_admission_prescription FOREIGN KEY (admission_id) REFERENCES hospital_admissions(admission_id),
    CONSTRAINT fk_drug_prescription FOREIGN KEY (drug_id) REFERENCES drugs(drug_id)
);

CREATE TABLE hospital_admissions_history (
    admission_id NUMBER,
    patient_id NUMBER,
    doctor_id NUMBER,
    admission_date DATE,
    discharge_date DATE,
    severity NUMBER(2),
    diagnosis VARCHAR2(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    operation_type VARCHAR2(10),
    operation_time TIMESTAMP,
    CONSTRAINT fk_patient_admission_hist FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_doctor_admission_hist FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE prescriptions_history (
    prescription_id NUMBER,
    admission_id NUMBER,
    drug_id NUMBER,
    prescription_date DATE,
    quantity NUMBER,
    operation_type VARCHAR2(10),
    operation_time TIMESTAMP,
    CONSTRAINT fk_admission_prescription_hist FOREIGN KEY (admission_id) REFERENCES hospital_admissions(admission_id),
    CONSTRAINT fk_drug_prescription_hist FOREIGN KEY (drug_id) REFERENCES drugs(drug_id)
);


DROP TABLE prescriptions_history;
DROP TABLE hospital_admissions_history;
DROP TABLE prescriptions;
DROP TABLE hospital_admissions;
DROP TABLE patients;
DROP TABLE doctors;
DROP TABLE drugs;

SELECT *
FROM prescriptions_history
ORDER BY operation_time DESC;

SELECT *
FROM hospital_admissions_history
ORDER BY operation_time DESC;

SELECT * FROM prescriptions;
SELECT * FROM hospital_admissions;
SELECT * FROM patients;
SELECT * FROM doctors;
SELECT * FROM drugs;

DELETE FROM hospital_admissions_history;
DELETE FROM prescriptions_history;
DELETE FROM hospital_admissions;
DELETE FROM prescriptions;

ALTER TABLE prescriptions_history
DROP CONSTRAINT fk_admission_prescription_hist;

ALTER TABLE hospital_admissions_history
DROP CONSTRAINT fk_patient_admission_hist;






--DROP TABLE insurance_cards;
--CREATE TABLE insurance_cards (
--    card_id NUMBER PRIMARY KEY,
--    patient_id NUMBER NOT NULL,
--    valid_from DATE NOT NULL,  
--    valid_to DATE NOT NULL,   
--    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
--);










