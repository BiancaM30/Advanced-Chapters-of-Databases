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