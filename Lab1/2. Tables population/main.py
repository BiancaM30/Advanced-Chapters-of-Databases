import cx_Oracle
import random
from datetime import datetime, timedelta

cx_Oracle.init_oracle_client(
    lib_dir='C:/Program Files/Oracle Client Python/instantclient-basic-windows.x64-21.13.0.0.0dbru/instantclient_21_13')
ip = '193.231.20.20'
port = 15211
SID = 'orcl19c'
dsn_tns = cx_Oracle.makedsn(ip, port, SID)
connection = cx_Oracle.connect(user='mbmbd1r31', password='mbmbd1r31', dsn=dsn_tns)
cursor = connection.cursor()

def random_date(start, end):
    return start + timedelta(days=random.randint(0, int((end - start).days)))

male_first_names = ["Ion", "Andrei", "Gheorghe", "Vasile", "Florin", "Daniel", "Mihai", "Gabriel", "David", "Luca", "Tudor", "Florentin", "George", "Laur", "Toma"]
female_first_names = ["Bianca", "Maria", "Elena", "Ana", "Roxana", "Cristina", "Raluca", "Ioana", "Monica", "Iulia", "Iuliana", "Andra", "Smaranda", "Andreea", "Laura"]
last_names = ["Popescu", "Ionescu", "Marin", "Vasilescu", "Georgescu", "Dumitrescu", "Petrescu", "Dima", "Iliescu",
              "Neagu", "Oprea", "Dragomir", "Diaconu", "Mihailescu", "Munteanu", "Campanu", "Pop", "Sava"]
patients = []
for i in range(101, 201):
    gender = random.choice(["M", "F"])
    first_name = random.choice(male_first_names if gender == "M" else female_first_names)
    last_name = random.choice(last_names)
    full_name = f"{first_name} {last_name}"
    patients.append((i, full_name, gender))

doctors = [
    (201, "Dr. Mihai Stoica", "Cardiologist"),
    (202, "Dr. Ioana Ene", "Surgeon"),
    (203, "Dr. Vlad Neagu", "Pediatrician"),
    (204, "Dr. Carmen Radu", "Neurologist"),
    (205, "Dr. Stefan Iancu", "Oncologist"),
    (206, "Dr. Sorina Apostol", "Dermatologist"),
    (207, "Dr. Radu Anton", "Orthopedist"),
    (208, "Dr. Gabriela Morar", "Psychiatrist")
]

drugs = [
    (301, "Aspirin", "Non-prescription"),
    (302, "Ibuprofen", "Non-prescription"),
    (303, "Paracetamol", "Non-prescription"),
    (304, "Insulin", "Prescription"),
    (305, "Metformin", "Prescription"),
    (306, "Amoxicillin", "Prescription"),
    (307, "Lisinopril", "Prescription")
]

start_date = datetime(2024, 9, 15)
end_date = datetime(2024, 10, 15)

def insert_patients():
    insert_query = """
    INSERT INTO patients (patient_id, patient_name, birthday, gender, address)
    VALUES (:1, :2, TO_DATE(:3, 'YYYY-MM-DD'), :4, :5)
    """
    for patient in patients:
        patient_id = patient[0]
        name = patient[1]
        gender = patient[2]
        address = f"{random.choice(['Cluj-Napoca', 'Bucuresti', 'Timisoara', 'Iasi', 'Brasov', 'Constanta'])}, Romania"
        birthday = random_date(datetime(1970, 1, 1), datetime(2000, 12, 31)).strftime('%Y-%m-%d')
        cursor.execute(insert_query, (patient_id, name, birthday, gender, address))

def insert_doctors():
    insert_query = """
    INSERT INTO doctors (doctor_id, doctor_name, specialty)
    VALUES (:1, :2, :3)
    """
    for doctor in doctors:
        doctor_id = doctor[0]
        name = doctor[1]
        specialty = doctor[2]
        cursor.execute(insert_query, (doctor_id, name, specialty))
def insert_drugs():
    insert_query = """
    INSERT INTO drugs (drug_id, drug_name, drug_category)
    VALUES (:1, :2, :3)
    """
    for drug in drugs:
        drug_id = drug[0]
        name = drug[1]
        category = drug[2]
        cursor.execute(insert_query, (drug_id, name, category))

""" 
Hospital Admissions: randomly selects a patient and doctor.
    - Admission Date: randomly chosen between 15 Sept 2024 and 15 Oct 2024
    - Discharge Date: either null (ongoing stay) or within 15 days of admission
    - Each patient can have between 1 and 3 prescriptions during the hospital stay
    
Prescriptions:
    - Prescription Date: random date between the admission date and discharge date (or within 15 days of admission if no discharge date)
    - Drug: randomly chosen from the predefined list
    - Quantity: random number between 1 and 5
"""
def insert_hospital_admissions_and_prescriptions():
    insert_admission_query = """
    INSERT INTO hospital_admissions (admission_id, patient_id, doctor_id, admission_date, discharge_date, diagnosis, severity)
    VALUES (:1, :2, :3, TO_DATE(:4, 'YYYY-MM-DD'), TO_DATE(:5, 'YYYY-MM-DD'), :6, :7)
    """

    insert_prescription_query = """
    INSERT INTO prescriptions (prescription_id, admission_id, drug_id, prescription_date, quantity)
    VALUES (:1, :2, :3, TO_DATE(:4, 'YYYY-MM-DD'), :5)
    """

    diagnoses = ["Flu", "Fracture", "COVID-19", "Diabetes", "Hypertension", "Allergy", "Heart attack"]
    prescription_id_counter = 1

    for i in range(1, 201):
        patient = random.choice(patients)
        doctor = random.choice(doctors)
        admission_date = random_date(start_date, end_date).strftime('%Y-%m-%d')
        diagnosis = random.choice(diagnoses)
        severity = random.randint(1, 10)

        discharge_date = random_date(
            datetime.strptime(admission_date, '%Y-%m-%d'),
            datetime.strptime(admission_date, '%Y-%m-%d') + timedelta(days=15)
        ).strftime('%Y-%m-%d')

        cursor.execute(insert_admission_query, (
            i, patient[0], doctor[0], admission_date,
            discharge_date if discharge_date else None,
            diagnosis, severity
        ))

        max_prescription_date = discharge_date if discharge_date else (
            datetime.strptime(admission_date, '%Y-%m-%d') + timedelta(days=15)).strftime('%Y-%m-%d')

        num_prescriptions = random.randint(1, 3)
        for _ in range(num_prescriptions):
            drug = random.choice(drugs)
            prescription_date = random_date(datetime.strptime(admission_date, '%Y-%m-%d'),
                                            datetime.strptime(max_prescription_date, '%Y-%m-%d')).strftime('%Y-%m-%d')

            quantity = random.randint(1, 5)

            cursor.execute(insert_prescription_query, (
                prescription_id_counter, i, drug[0], prescription_date, quantity))
            prescription_id_counter += 1





def make_insertions():
    # insert_patients()
    # insert_doctors()
    # insert_drugs()
    insert_hospital_admissions_and_prescriptions()
    connection.commit()



""" 
Updates in hospital_admissions table:
    - modifies the diagnosis and discharge_date for a random set of 5 to 10 records
Updates in prescriptions table: 
    - modifies the quantity of drugs prescribed in a random set of 5 to 10 prescription records
"""
def random_updates():
    num_updates = random.randint(5, 10)

    # Update hospital_admissions
    update_hospital_admissions = """
    UPDATE hospital_admissions
    SET diagnosis = :1, discharge_date = TO_DATE(:2, 'YYYY-MM-DD')
    WHERE admission_id = :3
    """
    admission_ids = random.sample(range(1, 201), min(num_updates, 5))
    for admission_id in admission_ids:
        new_diagnosis = random.choice(["Hypertension", "COVID-19", "Allergy", "Flu", "Diabetes"])
        new_discharge_date = (datetime.now() + timedelta(days=random.randint(1, 10))).strftime('%Y-%m-%d')
        cursor.execute(update_hospital_admissions, (new_diagnosis, new_discharge_date, admission_id))

    # Update prescriptions
    update_prescriptions = """
    UPDATE prescriptions
    SET quantity = :1
    WHERE prescription_id = :2
    """
    prescription_ids = random.sample(range(1, 101), min(num_updates, 5))
    for prescription_id in prescription_ids:
        new_quantity = random.randint(1, 5)
        cursor.execute(update_prescriptions, (new_quantity, prescription_id))

    connection.commit()






"""
Deletions in hospital_admissions table:
    - randomly selects 3 records from the hospital_admissions table and deletes them

Deletions in prescriptions table:
    - randomly selects 3 records from the prescriptions table and deletes them
    
Deletions in insurance_cards table:
    - randomly selects 3 records from the insurance_cards table and deletes them
"""
def random_deletions():
    num_deletions = 3

    # Delete prescriptions based on admission_id
    delete_prescriptions = """
    DELETE FROM prescriptions
    WHERE admission_id = :1
    """
    admission_ids = random.sample(range(1, 201), num_deletions)
    for admission_id in admission_ids:
        cursor.execute(delete_prescriptions, (admission_id,))

    # Delete hospital_admissions based on admission_id
    delete_hospital_admissions = """
    DELETE FROM hospital_admissions
    WHERE admission_id = :1
    """
    for admission_id in admission_ids:
        cursor.execute(delete_hospital_admissions, (admission_id,))

    connection.commit()




if __name__ == "__main__":
    # make_insertions()
    # print("Insertions done!")

    # random_updates()
    # print("Updates done!")

    random_deletions()
    print("Deletetions done")


cursor.close()
connection.close()

