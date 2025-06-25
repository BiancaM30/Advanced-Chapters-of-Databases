-- Implementati urmatoarele operatii(Query SELECT):
-- 1. Din entitatea cu atribute valid time, sa se returneze intervalul in care randul(inregistrarea) 
-- actualizat cel mai recent a avut valoarea maxima pentru un camp numeric ales la implementare 
-- The most recent row with the highest severity score
WITH Max_Severity AS (
    SELECT MAX(severity) AS max_severity
    FROM hospital_admissions
),
Recent_Modification AS (
    SELECT admission_id, MAX(operation_time) AS last_modification_time
    FROM hospital_admissions_history
    WHERE severity = (SELECT max_severity FROM Max_Severity)
    AND operation_type = 'UPDATE'
    GROUP BY admission_id
)
SELECT ha.admission_date, ha.discharge_date, ha.severity, rh.last_modification_time
FROM hospital_admissions ha
JOIN Recent_Modification rh ON ha.admission_id = rh.admission_id
WHERE ha.severity = (SELECT max_severity FROM Max_Severity)
ORDER BY rh.last_modification_time DESC;

--------------------------------------------------------------------------------------------------------------
-- 2. Dintr-o entitate cu atribute transaction time, sa se returneze numarul de randuri ce au avut operatii 
-- asupra lor (INSERT/DELETE/UPDATE) din fiecare saptamana, din ultimele 4 saptamani 
WITH Weekly_Operations AS (
    SELECT 
        TO_CHAR(operation_time, 'IYYY') AS year_number,  -- ISO year number
        TO_CHAR(operation_time, 'IW') AS week_number,    -- ISO week number
        COUNT(*) AS operation_count
    FROM hospital_admissions_history
    WHERE operation_time >= TRUNC(SYSDATE) - 28  -- Last 28 days (4 weeks)
    GROUP BY TO_CHAR(operation_time, 'IYYY'), TO_CHAR(operation_time, 'IW')
    
    UNION ALL
    
    SELECT 
        TO_CHAR(operation_time, 'IYYY') AS year_number,  -- ISO year number
        TO_CHAR(operation_time, 'IW') AS week_number,    -- ISO week number
        COUNT(*) AS operation_count
    FROM prescriptions_history
    WHERE operation_time >= TRUNC(SYSDATE) - 28  -- Last 28 days (4 weeks)
    GROUP BY TO_CHAR(operation_time, 'IYYY'), TO_CHAR(operation_time, 'IW')
)
SELECT year_number, week_number, SUM(operation_count) AS total_operations
FROM Weekly_Operations
GROUP BY year_number, week_number
ORDER BY year_number DESC, week_number DESC;


-------------------------------------------------------------------------------------------------------------
-- 3. cel putin 3 operatii (diferite) pentru date temporale care sa aiba rezultat numeric

-- 3.1. Calculate the number of days for each hospital stay 
SELECT admission_id, 
       (discharge_date - admission_date) AS num_days_stayed
FROM hospital_admissions
WHERE discharge_date IS NOT NULL;

-- 3.2. Calculate the average length of stay for hospital admissions
SELECT AVG(discharge_date - admission_date) AS avg_length_of_stay
FROM hospital_admissions
WHERE discharge_date IS NOT NULL;

-- 3.3. Count the number of prescriptions for each hospital admission
SELECT admission_id, COUNT(*) AS num_prescriptions
FROM prescriptions
GROUP BY admission_id
ORDER BY num_prescriptions DESC;


--------------------------------------------------------------------------------------------------------------
-- 4. Cel putin 3 operatii (diferite) pentru date temporale care sa aiba rezultat temporal

-- 4.1. Find the most recent prescription date for each admission
SELECT admission_id, MAX(prescription_date) AS most_recent_prescription
FROM prescriptions
GROUP BY admission_id;

-- 4.2. Find the earliest discharge date for each doctor
SELECT doctor_id, MIN(discharge_date) AS earliest_discharge
FROM hospital_admissions
WHERE discharge_date IS NOT NULL
GROUP BY doctor_id;

-- 4.3. Return all admissions with a discharge date in the last 30 days
SELECT admission_id, admission_date, discharge_date
FROM hospital_admissions
WHERE discharge_date IS NOT NULL
AND discharge_date >= TRUNC(SYSDATE) - 30;


--------------------------------------------------------------------------------------------------------------
-- 5. Cel putin 2 operatii (diferite) pentru date temporale care sa aiba rezultat boolean
-- 5.1. Check if a doctor has handled any patients with hospital stays exceeding 15 days
SELECT doctor_id, 
CASE 
    WHEN MAX(discharge_date - admission_date) > 15 THEN 'TRUE'
    ELSE 'FALSE'
END AS has_long_stays
FROM hospital_admissions
WHERE discharge_date IS NOT NULL
GROUP BY doctor_id;

-- 5.2. Check if any prescriptions were issued within the last 7 days
SELECT prescription_id, 
CASE 
    WHEN prescription_date >= TRUNC(SYSDATE) - 7 THEN 'TRUE'
    ELSE 'FALSE'
END AS issued_last_week
FROM prescriptions;

--------------------------------------------------------------------------------------------------------------
DELETE FROM prescriptions;
DELETE FROM hospital_admissions;
DELETE FROM insurance_cards;
DELETE FROM patients;
DELETE FROM doctors;
DELETE FROM drugs;

SELECT * FROM prescriptions;
SELECT * FROM hospital_admissions;
SELECT * FROM insurance_cards;
SELECT * FROM patients;
SELECT * FROM doctors;
SELECT * FROM drugs;


