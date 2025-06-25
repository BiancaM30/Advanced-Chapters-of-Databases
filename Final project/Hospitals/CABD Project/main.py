import streamlit as st
import cx_Oracle
from datetime import datetime

try:
    cx_Oracle.clientversion()  
except cx_Oracle.ProgrammingError:
    cx_Oracle.init_oracle_client(lib_dir="C:/Program Files/Oracle Client Python/instantclient-basic-windows.x64-21.13.0.0.0dbru/instantclient_21_13")


def get_connection():
    ip = ...
    port = ...
    SID = ...
    dsn_tns = cx_Oracle.makedsn(ip, port, SID)
    return cx_Oracle.connect(user='', password='', dsn=dsn_tns)


def create_patient(patient_id, name, birthday, gender, address):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO patients (patient_id, patient_name, birthday, gender, address)
            VALUES (:1, :2, TO_DATE(:3, 'YYYY-MM-DD'), :4, :5)
        """, [patient_id, name, birthday, gender, address])
        conn.commit()

def read_patient():
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM patients")
        return cursor.fetchall()

def delete_patient(patient_id):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM patients WHERE patient_id = :1", [patient_id])
        conn.commit()

def get_patient_by_id(patient_id):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT patient_name, TO_CHAR(birthday, 'YYYY-MM-DD'), gender, address
            FROM patients WHERE patient_id = :1
        """, [patient_id])
        return cursor.fetchone()

def update_patient(patient_id, name, birthday, gender, address):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE patients
            SET patient_name = :1, birthday = TO_DATE(:2, 'YYYY-MM-DD'), gender = :3, address = :4
            WHERE patient_id = :5
        """, [name, birthday, gender, address, patient_id])
        conn.commit()


def create_doctor(doctor_id, doctor_name, specialty):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO doctors (doctor_id, doctor_name, specialty)
            VALUES (:1, :2, :3)
        """, [doctor_id, doctor_name, specialty])
        conn.commit()

def read_doctors():
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM doctors")
        return cursor.fetchall()

def delete_doctor(doctor_id):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM doctors WHERE doctor_id = :1", [doctor_id])
        conn.commit()

def get_doctor_by_id(doctor_id):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT doctor_name, specialty FROM doctors WHERE doctor_id = :1
        """, [doctor_id])
        return cursor.fetchone()

def update_doctor(doctor_id, doctor_name, specialty):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE doctors SET doctor_name = :1, specialty = :2 WHERE doctor_id = :3
        """, [doctor_name, specialty, doctor_id])
        conn.commit()

def create_admission(admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO hospital_admissions 
            (admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis)
            VALUES (:1, :2, :3, TO_DATE(:4, 'YYYY-MM-DD'), TO_DATE(:5, 'YYYY-MM-DD'), :6, :7)
        """, [admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis])
        conn.commit()

def read_admissions():
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM hospital_admissions")
        return cursor.fetchall()

def get_admission_by_id(admission_id):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT admission_id, patient_id, doctor_id, TO_CHAR(admission_date, 'YYYY-MM-DD'), 
                   TO_CHAR(discharge_date, 'YYYY-MM-DD'), severity, diagnosis
            FROM hospital_admissions 
            WHERE admission_id = :1
        """, [admission_id])
        return cursor.fetchone()

def update_admission(admission_id, patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE hospital_admissions 
            SET patient_id = :1, doctor_id = :2, admission_date = TO_DATE(:3, 'YYYY-MM-DD'), 
                discharge_date = TO_DATE(:4, 'YYYY-MM-DD'), severity = :5, diagnosis = :6
            WHERE admission_id = :7
        """, [patient_id, doctor_id, admission_date, discharge_date, severity, diagnosis, admission_id])
        conn.commit()

def delete_admission(admission_id):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM hospital_admissions WHERE admission_id = :1", [admission_id])
        conn.commit()


def get_patients():
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT patient_id, patient_name FROM patients")
        return cursor.fetchall()

def get_doctors():
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT doctor_id, doctor_name FROM doctors")
        return cursor.fetchall()

def get_state_at_transaction_time(admission_id, timestamp):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT admission_id, patient_id, doctor_id, TO_CHAR(admission_date, 'YYYY-MM-DD') AS admission_date, TO_CHAR(discharge_date, 'YYYY-MM-DD') AS discharge_date, severity, diagnosis, operation_type
            FROM hospital_admissions_history
            WHERE admission_id = :1
            AND operation_time <= TO_DATE(:2, 'YYYY-MM-DD HH24:MI:SS')
            ORDER BY operation_time DESC
            FETCH FIRST 1 ROW ONLY
        """, [admission_id, timestamp])

        return cursor.fetchone()

def get_longest_severity_period_transaction_time(admission_id, aggregate_type):
    """
    Retrieves the longest period of time for which an admission record had minimum or maximum severity.
    Handles DELETE operations by subtracting 1 millisecond from their operation time.
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        query = f"""
            WITH all_rows AS (
                SELECT admission_id,
                       operation_time AS start_time,
                       LEAD(operation_time) OVER (PARTITION BY admission_id ORDER BY operation_time) AS raw_end_time,
                       LEAD(operation_type) OVER (PARTITION BY admission_id ORDER BY operation_time) AS next_operation_type,
                       severity
                FROM hospital_admissions_history
                WHERE admission_id = :1
            )
            SELECT admission_id,
                   TO_CHAR(start_time, 'YYYY-MM-DD HH24:MI:SS') AS start_time,
                   TO_CHAR(
                        CASE 
                            WHEN next_operation_type = 'DELETE' THEN raw_end_time - (INTERVAL '1' SECOND / 1000)
                            ELSE raw_end_time
                        END, 'YYYY-MM-DD HH24:MI:SS') AS end_time,
                   CASE 
                       WHEN next_operation_type = 'DELETE' THEN (raw_end_time - (INTERVAL '1' SECOND / 1000)) - start_time
                       ELSE raw_end_time - start_time
                   END AS duration
            FROM all_rows
            WHERE severity = (
                SELECT {aggregate_type}(severity)
                FROM hospital_admissions_history
                WHERE admission_id = :1
            )
            ORDER BY duration DESC NULLS LAST
            FETCH FIRST 1 ROW ONLY
        """
        cursor.execute(query, [admission_id])
        return cursor.fetchone()


def get_severity_change_report(admission_id):
    """
    Retrieves aggregated durations for consecutive rows with the same severity.
    """
    with get_connection() as conn:
        cursor = conn.cursor()
        query = """
            WITH grouped_severity AS (
                SELECT admission_id,
                       operation_time AS start_time,
                       severity,
                       ROW_NUMBER() OVER (PARTITION BY admission_id ORDER BY operation_time) -
                       ROW_NUMBER() OVER (PARTITION BY admission_id, severity ORDER BY operation_time) AS group_id
                FROM hospital_admissions_history
                WHERE admission_id = :1
            ),
            aggregated_severity AS (
                SELECT admission_id,
                       severity,
                       MIN(start_time) AS start_time,
                       MAX(start_time) AS end_time
                FROM grouped_severity
                GROUP BY admission_id, severity, group_id
            )
            SELECT admission_id,
                   TO_CHAR(start_time, 'YYYY-MM-DD HH24:MI:SS') AS start_time,
                   TO_CHAR(
                       LEAD(end_time) OVER (PARTITION BY admission_id ORDER BY start_time),
                       'YYYY-MM-DD HH24:MI:SS'
                   ) AS end_time,
                   severity,
                   ROUND(
                       (CAST(LEAD(end_time) OVER (PARTITION BY admission_id ORDER BY start_time) AS DATE) - CAST(start_time AS DATE)) * 86400
                   ) AS duration_in_seconds
            FROM aggregated_severity
            ORDER BY start_time
        """
        cursor.execute(query, [admission_id])
        return cursor.fetchall()




st.title("Hospital Management System")

menu = st.sidebar.selectbox("Menu", ["Patients", "Doctors", "Hospital Admissions", "Reports"])

# Manage Patients
if menu == "Patients":
    st.subheader("Manage Patients")
    operation = st.radio("Select Operation", ["Create", "Read", "Update", "Delete"])

    if operation == "Create":
        patient_id = st.number_input("Patient ID", min_value=1, step=1)
        name = st.text_input("Name")
        birthday = st.date_input("Birthday")
        gender = st.selectbox("Gender", ["Male", "Female", "Other"])
        address = st.text_area("Address")
        if st.button("Add Patient"):
            create_patient(patient_id, name, birthday.strftime('%Y-%m-%d'), gender, address)
            st.success("Patient added successfully!")

    elif operation == "Read":
        data = read_patient()
        st.table(data)

    elif operation == "Delete":
        patient_id = st.number_input("Patient ID to Delete", min_value=1, step=1)
        if st.button("Delete Patient"):
            delete_patient(patient_id)
            st.success("Patient deleted successfully!")

    elif operation == "Update":
        patient_id = st.number_input("Patient ID to Update", min_value=1, step=1)
        if st.button("Fetch Patient Data"):
            patient_data = get_patient_by_id(patient_id)
            if patient_data:
                st.session_state["patient_data"] = patient_data
                st.success("Patient data loaded. Edit the fields below.")
            else:
                st.error("Patient ID not found.")

        if "patient_data" in st.session_state:
            name, birthday, gender, address = st.session_state["patient_data"]
            name_input = st.text_input("Name", value=name)
            birthday_input = st.date_input("Birthday", datetime.strptime(birthday, '%Y-%m-%d'))
            gender_input = st.selectbox("Gender", ["Male", "Female", "Other"],
                                        index=["Male", "Female", "Other"].index(gender))
            address_input = st.text_area("Address", value=address)
            if st.button("Update Patient"):
                update_patient(patient_id, name_input, birthday_input.strftime('%Y-%m-%d'), gender_input, address_input)
                st.success("Patient updated successfully!")
                del st.session_state["patient_data"]

# Manage Doctors
elif menu == "Doctors":
    st.subheader("Manage Doctors")
    operation = st.radio("Select Operation", ["Create", "Read","Update", "Delete"])

    if operation == "Create":
        doctor_id = st.number_input("Doctor ID", min_value=1, step=1)
        name = st.text_input("Doctor Name")
        specialty = st.text_input("Specialty")
        if st.button("Add Doctor"):
            create_doctor(doctor_id, name, specialty)
            st.success("Doctor added successfully!")

    elif operation == "Read":
        data = read_doctors()
        st.table(data)

    elif operation == "Delete":
        doctor_id = st.number_input("Doctor ID to Delete", min_value=1, step=1)
        if st.button("Delete Doctor"):
            delete_doctor(doctor_id)
            st.success("Doctor deleted successfully!")

    elif operation == "Update":
        doctor_id = st.number_input("Doctor ID to Update", min_value=1, step=1)
        if st.button("Fetch Doctor Data"):
            doctor_data = get_doctor_by_id(doctor_id)
            if doctor_data:
                st.session_state["doctor_data"] = doctor_data
                st.success("Doctor data loaded. Edit the fields below.")
            else:
                st.error("Doctor ID not found.")

        if "doctor_data" in st.session_state:
            name, specialty = st.session_state["doctor_data"]
            name_input = st.text_input("Doctor Name", value=name)
            specialty_input = st.text_input("Specialty", value=specialty)
            if st.button("Update Doctor"):
                update_doctor(doctor_id, name_input, specialty_input)
                st.success("Doctor updated successfully!")
                del st.session_state["doctor_data"]


elif menu == "Hospital Admissions":
    st.subheader("Manage Hospital Admissions")
    operation = st.radio("Select Operation", ["Create", "Read", "Update", "Delete"])

    # Create Admission
    if operation == "Create":
        st.subheader("Add New Admission")
        admission_id = st.number_input("Admission ID", min_value=1, step=1)
        patients = get_patients()
        doctors = get_doctors()

        patient = st.selectbox("Select Patient", patients, format_func=lambda x: f"{x[0]} - {x[1]}")
        doctor = st.selectbox("Select Doctor", doctors, format_func=lambda x: f"{x[0]} - {x[1]}")
        admission_date = st.date_input("Admission Date")
        discharge_date = st.date_input("Discharge Date (Optional)", value=None)
        severity = st.number_input("Severity (1-10)", min_value=1, max_value=10, step=1)
        diagnosis = st.text_area("Diagnosis")

        if st.button("Add Admission"):
            discharge_date_str = discharge_date.strftime('%Y-%m-%d') if discharge_date else None
            create_admission(admission_id, patient[0], doctor[0], admission_date.strftime('%Y-%m-%d'), discharge_date_str, severity, diagnosis)
            st.success("Admission added successfully!")

    # Read Admissions
    elif operation == "Read":
        st.subheader("Admissions List")
        data = read_admissions()
        st.table(data)

    # Update Admission
    elif operation == "Update":
        st.subheader("Update Admission")
        admission_id = st.number_input("Admission ID to Update", min_value=1, step=1)

        if st.button("Fetch Admission Data"):
            admission_data = get_admission_by_id(admission_id)
            if admission_data:
                st.session_state["admission_data"] = admission_data
                st.success("Admission data loaded. Edit the fields below.")
            else:
                st.error("Admission ID not found.")

        if "admission_data" in st.session_state:
            admission_data = st.session_state["admission_data"]
            patients = get_patients()
            doctors = get_doctors()

            patient = st.selectbox("Select Patient", patients, index=[p[0] for p in patients].index(admission_data[1]), format_func=lambda x: f"{x[0]} - {x[1]}")
            doctor = st.selectbox("Select Doctor", doctors, index=[d[0] for d in doctors].index(admission_data[2]), format_func=lambda x: f"{x[0]} - {x[1]}")
            admission_date = st.date_input("Admission Date", datetime.strptime(admission_data[3], "%Y-%m-%d"))
            discharge_date = st.date_input("Discharge Date (Optional)", datetime.strptime(admission_data[4], "%Y-%m-%d") if admission_data[4] else None)
            severity = st.number_input("Severity (1-10)", min_value=1, max_value=10, step=1, value=int(admission_data[5]))
            diagnosis = st.text_area("Diagnosis", value=admission_data[6])

            if st.button("Update Admission"):
                discharge_date_str = discharge_date.strftime('%Y-%m-%d') if discharge_date else None
                update_admission(admission_id, patient[0], doctor[0], admission_date.strftime('%Y-%m-%d'), discharge_date_str, severity, diagnosis)
                st.success("Admission updated successfully!")
                del st.session_state["admission_data"]

    # Delete Admission
    elif operation == "Delete":
        st.subheader("Delete Admission")
        admission_id = st.number_input("Admission ID to Delete", min_value=1, step=1)
        if st.button("Delete Admission"):
            delete_admission(admission_id)
            st.success("Admission deleted successfully!")

# Reports Tab
elif menu == "Reports":
    st.subheader("Reports")
    report_type = st.radio("Select Report", ["Current State of an Admission", "State at Specific Transaction Time", "Longest Period of Min/Max Severity", "Time Differences for Severity Changes"])

    if report_type == "Current State of an Admission":
        st.subheader("Current State of a Specific Admission")
        admission_id = st.number_input("Enter Admission ID", min_value=1, step=1)

        if st.button("Get Current State"):
            data = get_admission_by_id(admission_id)

            if data:
                # Display results for the specific admission
                st.table({
                    "Field": ["Admission ID", "Patient ID", "Doctor ID", "Admission Date", "Discharge Date", "Severity", "Diagnosis"],
                    "Value": [data[0], data[1], data[2], data[3], data[4] if data[4] else "N/A", data[5], data[6]],
                })
            else:
                st.warning(f"No data found for Admission ID {admission_id}.")

    elif report_type == "State at Specific Transaction Time":
            st.subheader("State of Admission at a Specific Transaction Time")
            admission_id = st.number_input("Enter Admission ID", min_value=1, step=1)
            timestamp = st.text_input("Enter Transaction Time (YYYY-MM-DD HH:MM:SS)")

            if st.button("Get State"):
                try:
                    timestamp_obj = datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S")
                    formatted_timestamp = timestamp_obj.strftime("%Y-%m-%d %H:%M:%S")
                    data = get_state_at_transaction_time(admission_id, formatted_timestamp)

                    if data:
                        operation_type = data[7]
                        if operation_type == "DELETE":
                            st.warning(
                                f"The record for Admission ID {admission_id} was deleted at or before {timestamp}.")
                        else:
                            st.table({
                                "Field": ["Admission ID", "Patient ID", "Doctor ID", "Admission Date", "Discharge Date",
                                          "Severity", "Diagnosis"],
                                "Value": [data[0], data[1], data[2], data[3], data[4] if data[4] else "N/A", data[5],
                                          data[6]],
                            })
                    else:
                        st.warning(
                            f"No valid state found for Admission ID {admission_id} at the specified transaction time.")
                except ValueError:
                    st.error("Invalid timestamp format. Please enter in YYYY-MM-DD HH:MM:SS format.")

    elif report_type == "Longest Period of Min/Max Severity":
        st.subheader("Longest Period of Min/Max Severity")

        admission_id = st.number_input("Enter Admission ID", min_value=1, step=1)
        severity_choice = st.radio("Select Severity Type", ["Minimum", "Maximum"])
        aggregate_type = "MIN" if severity_choice == "Minimum" else "MAX"

        if st.button("Generate Report"):
            aggregate_type = "MIN" if severity_choice == "Minimum" else "MAX"
            result = get_longest_severity_period_transaction_time(admission_id, aggregate_type)

            if result:
                st.success(f"Longest period of {severity_choice.lower()} severity for Admission ID {admission_id}:")
                st.table({
                    "Field": ["Admission ID", "Start Time", "End Time", "Duration (Days)"],
                    "Value": [
                        result[0],
                        result[1],
                        result[2],
                        float(result[3].total_seconds() / 86400) if result[3] else "N/A"
                    ]
                })
            else:
                st.warning("No data found for the specified criteria.")

    elif report_type == "Time Differences for Severity Changes":
        st.subheader("Time Differences for Severity Changes")

        # Input field for Admission ID
        admission_id = st.number_input("Enter Admission ID", min_value=1, step=1)

        if st.button("Generate Report"):
            report_data = get_severity_change_report(admission_id)
            if report_data:
                st.table({
                    "Start Time": [row[1] for row in report_data],
                    "End Time": [row[2] if row[2] else "N/A" for row in report_data],
                    "Severity": [row[3] for row in report_data],
                    "Duration (Miliseconds)": [row[4] if row[4] else "N/A" for row in report_data]
                })
            else:
                st.warning("No data found for the given admission ID.")









