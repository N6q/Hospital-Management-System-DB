-- ==========================================
-- HospitalDB: Database for Hospital Management System
-- ==========================================

-- Create the database
CREATE DATABASE HospitalDB;

-- Switch to the database
USE HospitalDB;

-- ==========================================
-- Table: Patients
-- Description: Stores patient demographic and identity info
-- ==========================================
CREATE TABLE Patients (
    PatientID VARCHAR(10),
    NationalID VARCHAR(20) UNIQUE NOT NULL,
    PName VARCHAR(100),
    DOB DATE,
    Gender VARCHAR(10),
    Email VARCHAR(100),
    CONSTRAINT PK_Patients PRIMARY KEY (PatientID)
);

-- Table: PatientsNo (Multivalued phone numbers for patients)
CREATE TABLE PatientsNo (
    PatientID VARCHAR(10),
    PhoneNo VARCHAR(20),
    CONSTRAINT FK_PatientsNo_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- ==========================================
-- Table: Doctors
-- Description: Stores doctor info and specialization
-- ==========================================
CREATE TABLE Doctors (
    DoctorID VARCHAR(10),
    DocName VARCHAR(100),
    Specialization VARCHAR(100),
    DeptID VARCHAR(10),
    Gender VARCHAR(10),
    Email VARCHAR(100),
    CONSTRAINT PK_Doctors PRIMARY KEY (DoctorID),
    CONSTRAINT FK_Doctors_Departments FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
);

-- Table: DoctorsNo (Multivalued phone numbers for doctors)
CREATE TABLE DoctorsNo (
    DoctorID VARCHAR(10),
    PhoneNo VARCHAR(20),
    CONSTRAINT FK_DoctorsNo_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- ==========================================
-- Table: Departments
-- Description: Stores department names
-- ==========================================
CREATE TABLE Departments (
    DeptID VARCHAR(10),
    DepartmentName VARCHAR(100),
    CONSTRAINT PK_Departments PRIMARY KEY (DeptID)
);

-- ==========================================
-- Table: Staffs
-- Description: Administrative and medical staff records
-- ==========================================
CREATE TABLE Staffs (
    StaffID VARCHAR(10),
    StaffName VARCHAR(100),
    StaffRole VARCHAR(50),
    Shift VARCHAR(20),
    DeptID VARCHAR(10),
    PhoneNo VARCHAR(20),
    Email VARCHAR(100),
    CONSTRAINT PK_Staffs PRIMARY KEY (StaffID),
    CONSTRAINT FK_Staffs_Departments FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
);

-- ==========================================
-- Table: Users
-- Description: Stores login information and system roles
-- ==========================================
CREATE TABLE Users (
    UserID VARCHAR(10),
    Username VARCHAR(50) UNIQUE NOT NULL,
    UPassword VARCHAR(100) NOT NULL,
    UserRole VARCHAR(50),
    StaffID VARCHAR(10),
    CONSTRAINT PK_Users PRIMARY KEY (UserID),
    CONSTRAINT FK_Users_Staffs FOREIGN KEY (StaffID) REFERENCES Staffs(StaffID)
);

-- ==========================================
-- Table: Rooms
-- Description: Hospital room information
-- ==========================================
CREATE TABLE Rooms (
    RoomID VARCHAR(10),
    RoomNo VARCHAR(10) UNIQUE,
    RoomType VARCHAR(20),
    Availability BIT,
    CONSTRAINT PK_Rooms PRIMARY KEY (RoomID)
);

-- ==========================================
-- Table: Admissions
-- Description: Tracks patient admission and discharge
-- ==========================================
CREATE TABLE Admissions (
    AdmissionID VARCHAR(10),
    PatientID VARCHAR(10),
    RoomID VARCHAR(10),
    DateIn DATE,
    DateOut DATE,
    CONSTRAINT PK_Admissions PRIMARY KEY (AdmissionID),
    CONSTRAINT FK_Admissions_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_Admissions_Room FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);

-- ==========================================
-- Table: Appointments
-- Description: Links patients to doctors by appointment
-- ==========================================
CREATE TABLE Appointments (
    AppointmentID VARCHAR(10),
    PatientID VARCHAR(10),
    DoctorID VARCHAR(10),
    AppointmentDate DATE,
    AppointmentTime TIME,
    CONSTRAINT PK_Appointments PRIMARY KEY (AppointmentID),
    CONSTRAINT FK_Appointments_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_Appointments_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- ==========================================
-- Table: MedicalRecords
-- Description: Diagnosis and treatment per appointment
-- ==========================================
CREATE TABLE MedicalRecords (
    RecordID VARCHAR(10),
    PatientID VARCHAR(10),
    DoctorID VARCHAR(10),
    AppointmentID VARCHAR(10),
    Diagnosis VARCHAR(255),
    TreatmentPlan VARCHAR(255),
    RecordDate DATE,
    Notes TEXT,
    CONSTRAINT PK_MedicalRecords PRIMARY KEY (RecordID),
    CONSTRAINT FK_MR_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_MR_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    CONSTRAINT FK_MR_Appointment FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);

-- ==========================================
-- Table: Bills
-- Description: Billing information per admission
-- ==========================================
CREATE TABLE Bills (
    BillID VARCHAR(10),
    PatientID VARCHAR(10),
    AdmissionID VARCHAR(10),
    BillingDate DATE,
    TotalCost DECIMAL(10,2),
    CONSTRAINT PK_Bills PRIMARY KEY (BillID),
    CONSTRAINT FK_Bills_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_Bills_Admission FOREIGN KEY (AdmissionID) REFERENCES Admissions(AdmissionID)
);

-- ==========================================
-- Table: Services
-- Description: List of billable services
-- ==========================================
CREATE TABLE Services (
    ServiceID VARCHAR(10),
    ServiceName VARCHAR(100),
    CONSTRAINT PK_Services PRIMARY KEY (ServiceID)
);

-- ==========================================
-- Table: BillingDetails
-- Description: Resolves many-to-many between Bills and Services
-- ==========================================
CREATE TABLE BillingDetails (
    BillID VARCHAR(10),
    ServiceID VARCHAR(10),
    PerformedBy VARCHAR(100),
    Quantity INT,
    UnitCost DECIMAL(10,2),
    CONSTRAINT PK_BillingDetails PRIMARY KEY (BillID, ServiceID),
    CONSTRAINT FK_BD_Bill FOREIGN KEY (BillID) REFERENCES Bills(BillID),
    CONSTRAINT FK_BD_Service FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);
