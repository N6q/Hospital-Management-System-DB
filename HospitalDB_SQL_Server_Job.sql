-- ==========================================
-- SQL Server Agent Job: Doctor_Daily_Schedule_Report
-- ==========================================

-- Step 1: Create the report table (if not exists)
IF OBJECT_ID('DoctorDailyScheduleLog', 'U') IS NULL
BEGIN
    CREATE TABLE DoctorDailyScheduleLog (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        DoctorID VARCHAR(10),
        DoctorName VARCHAR(100),
        AppointmentDate DATE,
        AppointmentTime TIME,
        PatientName VARCHAR(100),
        LoggedAt DATETIME DEFAULT GETDATE()
    );
END;

-- Step 2: Create the stored procedure that inserts today's doctor schedule
IF OBJECT_ID('sp_LogDoctorDailySchedule', 'P') IS NOT NULL
    DROP PROCEDURE sp_LogDoctorDailySchedule;
GO

CREATE PROCEDURE sp_LogDoctorDailySchedule
AS
BEGIN
    INSERT INTO DoctorDailyScheduleLog (DoctorID, DoctorName, AppointmentDate, AppointmentTime, PatientName)
    SELECT 
        D.DoctorID,
        D.DocName,
        A.AppointmentDate,
        A.AppointmentTime,
        P.PName
    FROM Appointments A
    JOIN Doctors D ON A.DoctorID = D.DoctorID
    JOIN Patients P ON A.PatientID = P.PatientID
    WHERE CONVERT(DATE, A.AppointmentDate ) = CONVERT(DATE, GETDATE());
END;
GO

-- Step 3: Create SQL Server Agent Job to run it daily at 7:00 AM

-- Add the job
EXEC msdb.dbo.sp_add_job
    @job_name = N'Doctor_Daily_Schedule_Report',
    @enabled = 1,
    @description = N'Logs doctor appointments into a report table daily at 7:00 AM';

-- Add job step to run the stored procedure
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Doctor_Daily_Schedule_Report',
    @step_name = N'Insert Daily Schedule',
    @subsystem = N'TSQL',
    @command = N'EXEC sp_LogDoctorDailySchedule;',
    @database_name = N'HospitalDB';

-- Add the schedule
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Daily_7AM_Schedule',
    @freq_type = 4,                -- daily
    @freq_interval = 1,
    @active_start_time = 070000;  -- 7:00 AM

-- Attach the schedule to the job
EXEC msdb.dbo.sp_attach_schedule
    @job_name = N'Doctor_Daily_Schedule_Report',
    @schedule_name = N'Daily_7AM_Schedule';

-- Add the job to SQL Server Agent
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Doctor_Daily_Schedule_Report';


-- ==========================================
-- SQL Server Agent Job: Doctor_Daily_Schedule_Report
-- ==========================================

-- Step 1: Create the report table (if not exists)
IF OBJECT_ID('DoctorDailyScheduleLog', 'U') IS NULL
BEGIN
    CREATE TABLE DoctorDailyScheduleLog (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        DoctorID VARCHAR(10),
        DoctorName VARCHAR(100),
        AppointmentDate DATE,
        AppointmentTime TIME,
        PatientName VARCHAR(100),
        LoggedAt DATETIME DEFAULT GETDATE()
    );
END;

-- Step 2: Create the stored procedure that inserts today's doctor schedule
IF OBJECT_ID('sp_LogDoctorDailySchedule', 'P') IS NOT NULL
    DROP PROCEDURE sp_LogDoctorDailySchedule;
GO

CREATE PROCEDURE sp_LogDoctorDailySchedule
AS
BEGIN
    INSERT INTO DoctorDailyScheduleLog (DoctorID, DoctorName, AppointmentDate, AppointmentTime, PatientName)
    SELECT 
        D.DoctorID,
        D.DocName,
        A.AppointmentDate,
        A.AppointmentTime,
        P.PName
    FROM Appointments A
    JOIN Doctors D ON A.DoctorID = D.DoctorID
    JOIN Patients P ON A.PatientID = P.PatientID
    WHERE CONVERT(DATE, A.AppointmentDate ) = CONVERT(DATE, GETDATE());
END;
GO

-- Step 3: Create SQL Server Agent Job to run it daily at 7:00 AM

-- Add the job
EXEC msdb.dbo.sp_add_job
    @job_name = N'Doctor_Daily_Schedule_Report',
    @enabled = 1,
    @description = N'Logs doctor appointments into a report table daily at 7:00 AM';

-- Add job step to run the stored procedure
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Doctor_Daily_Schedule_Report',
    @step_name = N'Insert Daily Schedule',
    @subsystem = N'TSQL',
    @command = N'EXEC sp_LogDoctorDailySchedule;',
    @database_name = N'HospitalDB';

-- Add the schedule
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Daily_7AM_Schedule',
    @freq_type = 4,                -- daily
    @freq_interval = 1,
    @active_start_time = 070000;  -- 7:00 AM

-- Attach the schedule to the job
EXEC msdb.dbo.sp_attach_schedule
    @job_name = N'Doctor_Daily_Schedule_Report',
    @schedule_name = N'Daily_7AM_Schedule';

-- Add the job to SQL Server Agent
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Doctor_Daily_Schedule_Report';
