
-- =============================================
-- Hospital Management System 
-- =============================================


-- ---------------------------------------------
-- SECTION 1: Views
-- ---------------------------------------------

-- vw_DoctorSchedule: Upcoming appointments per doctor
CREATE VIEW vw_DoctorSchedule AS
SELECT 
    D.DoctorID,
    D.DocName AS DoctorName,
    A.AppointmentDate,
    A.AppointmentTime,
    P.PName AS PatientName
FROM Doctors D
JOIN Appointments A ON D.DoctorID = A.DoctorID
JOIN Patients P ON A.PatientID = P.PatientID;

-- vw_PatientSummary: Patient info with their latest visit
CREATE VIEW vw_PatientSummary AS
SELECT 
    P.PatientID,
    P.PName AS PatientName,
    MAX(M.RecordDate) AS LatestVisit,
    M.Diagnosis,
    M.TreatmentPlan
FROM Patients P
JOIN MedicalRecords M ON P.PatientID = M.PatientID
GROUP BY P.PatientID, P.PName, M.Diagnosis, M.TreatmentPlan;

-- vw_DepartmentStats: Number of doctors and patients per department
CREATE VIEW vw_DepartmentStats AS
SELECT 
    DPT.DeptID,
    DPT.DepartmentName,
    COUNT(DISTINCT D.DoctorID) AS DoctorCount,
    COUNT(DISTINCT A.PatientID) AS PatientCount
FROM Departments DPT
LEFT JOIN Doctors D ON D.DeptID = DPT.DeptID
LEFT JOIN Appointments A ON D.DoctorID = A.DoctorID
GROUP BY DPT.DeptID, DPT.DepartmentName;


-- ---------------------------------------------
-- SECTION 2: Scalar Function
-- ---------------------------------------------

-- Function to calculate age from DOB
CREATE FUNCTION fn_CalculateAge(@DOB DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @DOB, GETDATE()) - 
           CASE WHEN MONTH(@DOB) > MONTH(GETDATE()) 
                 OR (MONTH(@DOB) = MONTH(GETDATE()) AND DAY(@DOB) > DAY(GETDATE()))
                THEN 1 ELSE 0 END;
END;



-- ---------------------------------------------
-- SECTION 3: Stored Procedures
-- ---------------------------------------------

-- Admit a patient (insert admission + update room availability)
CREATE PROCEDURE sp_AdmitPatient
    @AdmissionID VARCHAR(10),
    @PatientID VARCHAR(10),
    @RoomID VARCHAR(10),
    @DateIn DATE,
    @DateOut DATE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Admissions VALUES (@AdmissionID, @PatientID, @RoomID, @DateIn, @DateOut);
        UPDATE Rooms SET Availability = 0 WHERE RoomID = @RoomID;
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
    END CATCH
END;

-- Assign doctor to department and shift (simulated by updating staff table role/shift)
CREATE PROCEDURE sp_AssignDoctorToDepartment
    @DoctorID VARCHAR(10),
    @DeptID VARCHAR(10)
AS
BEGIN
    UPDATE Doctors SET DeptID = @DeptID WHERE DoctorID = @DoctorID;
END;

-- Generate invoice (insert into Bills based on admission)
CREATE PROCEDURE sp_GenerateInvoice
    @BillID VARCHAR(10),
    @PatientID VARCHAR(10),
    @AdmissionID VARCHAR(10),
    @BillingDate DATE,
    @TotalCost DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Bills VALUES (@BillID, @PatientID, @AdmissionID, @BillingDate, @TotalCost);
END;




-- ---------------------------------------------
-- SECTION 4: Triggers
-- ---------------------------------------------

-- After insert on Appointments auto log in MedicalRecords
CREATE TRIGGER trg_AfterAppointmentInsert
ON Appointments
AFTER INSERT
AS
BEGIN
    DECLARE @NextID INT;
    SELECT @NextID = COUNT(*) + 1 FROM MedicalRecords;

    INSERT INTO MedicalRecords (
        RecordID, PatientID, DoctorID, AppointmentID,
        Diagnosis, TreatmentPlan, RecordDate, Notes
    )
    SELECT 
        'MR' + CONVERT(VARCHAR, @NextID),
        i.PatientID, i.DoctorID, i.AppointmentID,
        'Pending', 'Pending', GETDATE(), 'Auto-generated after appointment'
    FROM inserted i;
END;


-- Prevent delete on Patients if bills exist
CREATE TRIGGER trg_BeforePatientDelete
ON Patients
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Bills B WHERE B.PatientID IN (SELECT PatientID FROM deleted)
    )
    BEGIN
        RAISERROR ('Cannot delete patient with existing bills.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM Patients WHERE PatientID IN (SELECT PatientID FROM deleted);
    END
END;

-- After update on Rooms check for double booking
CREATE TRIGGER trg_AfterRoomUpdate
ON Rooms
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT RoomID FROM Rooms WHERE Availability = 0
        GROUP BY RoomID HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR ('Conflict: Multiple patients assigned to the same room.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;




-- ---------------------------------------------
-- SECTION 5: Security (DCL)
-- ---------------------------------------------

-- Create Roles
CREATE ROLE DoctorUser;
CREATE ROLE AdminUser;

-- Grant SELECT permissions to DoctorUser
GRANT SELECT ON Patients TO DoctorUser;
GRANT SELECT ON Appointments TO DoctorUser;

-- Grant INSERT, UPDATE permissions to AdminUser on all tables
GRANT INSERT, UPDATE ON Patients TO AdminUser;
GRANT INSERT, UPDATE ON Appointments TO AdminUser;
GRANT INSERT, UPDATE ON Doctors TO AdminUser;
GRANT INSERT, UPDATE ON Admissions TO AdminUser;
GRANT INSERT, UPDATE ON Bills TO AdminUser;
GRANT INSERT, UPDATE ON Services TO AdminUser;
GRANT INSERT, UPDATE ON BillingDetails TO AdminUser;
GRANT INSERT, UPDATE ON Departments TO AdminUser;
GRANT INSERT, UPDATE ON Rooms TO AdminUser;
GRANT INSERT, UPDATE ON Staffs TO AdminUser;
GRANT INSERT, UPDATE ON Users TO AdminUser;
GRANT INSERT, UPDATE ON MedicalRecords TO AdminUser;

-- Revoke DELETE permission from Doctors table for all users
REVOKE DELETE ON Doctors TO PUBLIC;



-- ---------------------------------------------
-- SECTION 6: Transaction Simulation
-- ---------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY
    -- Step 1: Admit patient
    INSERT INTO Admissions (AdmissionID, PatientID, RoomID, DateIn, DateOut)
    VALUES ('A999', 'P001', 'R005', '2024-08-10', '2024-08-15');

    -- Step 2: Mark room as unavailable
    UPDATE Rooms
    SET Availability = 0
    WHERE RoomID = 'R005';

    -- Step 3: Generate bill
    INSERT INTO Bills (BillID, PatientID, AdmissionID, BillingDate, TotalCost)
    VALUES ('B999', 'P001', 'A999', '2024-08-15', 750.00);

    COMMIT; --All steps successful
END TRY
BEGIN CATCH
    ROLLBACK; --Something failed, cancel all
    PRINT 'Transaction failed: ' + ERROR_MESSAGE();
END CATCH;


-- ---------------------------------------------
-- SECTION 7: Evaluation (DQL)
-- ---------------------------------------------

-- 1. List all patients who visited a specific doctor (DoctorID = 'D005')
SELECT DISTINCT P.PatientID, P.PName, P.Email
FROM Patients P
JOIN Appointments A ON P.PatientID = A.PatientID
WHERE A.DoctorID = 'D005';

-- 2. Count of appointments per department
SELECT 
    DPT.DepartmentName,
    COUNT(A.AppointmentID) AS TotalAppointments
FROM Appointments A
JOIN Doctors D ON A.DoctorID = D.DoctorID
JOIN Departments DPT ON D.DeptID = DPT.DeptID
GROUP BY DPT.DepartmentName;

-- 3. Retrieve doctors who have more than 5 appointments in July 2024
SELECT 
    D.DocName,
    COUNT(*) AS AppointmentCount
FROM Appointments A
JOIN Doctors D ON A.DoctorID = D.DoctorID
WHERE MONTH(AppointmentDate) = 7 AND YEAR(AppointmentDate) = 2024
GROUP BY D.DocName
HAVING COUNT(*) > 5;

-- 4. List appointments with patient, doctor, department info (JOIN 4 tables)
SELECT 
    A.AppointmentID,
    P.PName AS Patient,
    D.DocName AS Doctor,
    DPT.DepartmentName,
    A.AppointmentDate
FROM Appointments A
JOIN Patients P ON A.PatientID = P.PatientID
JOIN Doctors D ON A.DoctorID = D.DoctorID
JOIN Departments DPT ON D.DeptID = DPT.DeptID;

-- 5. Patients who have at least one appointment (EXISTS)
SELECT P.PName
FROM Patients P
WHERE EXISTS (
    SELECT 1 FROM Appointments A
    WHERE A.PatientID = P.PatientID
);

-- 6. Patients who have more than one bill (SUBQUERY)
SELECT P.PName
FROM Patients P
WHERE PatientID IN (
    SELECT PatientID
    FROM Bills
    GROUP BY PatientID
    HAVING COUNT(*) > 1
);
