# 🏥 Hospital Management System - SQL Project

[![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/en-us/sql-server)
[![Author](https://img.shields.io/badge/Author-Samir-blue)](#)

## 📘 Overview
A complete hospital management system implemented in **Microsoft SQL Server**, demonstrating:
- Normalized relational schema (1NF → 3NF)
- Full use of DDL, DML, DQL, DCL, TCL
- Views, Stored Procedures, Functions, Triggers
- SQL Server Agent Job for scheduling

---

## 🖼️ ERD & Logical Mapping

| Image | Description |
|-------|-------------|
| ![ERD](Hospital%20Project%20DB-ERD.png) | Full Entity-Relationship Diagram |
| ![Mapping](HospitalDB_Table_Entity_Mapping.png) | Mapping for ERD (Entities ↔ Tables) |

---

## 📂 Folder Contents

| File Name                                          | Description                                |
|----------------------------------------------------|--------------------------------------------|
| `HospitalDB_Create_Quiries.sql`                    | Database schema  (DDL)                     |
| `HospitalDB_Sample_data_insertion.sql`             | Inserts data in tables                     |
| `Views_triggers_procedures_functions_quiereis.sql` | All views, triggers, procedures, functions |
| `HospitalDB_SQL_Server_Job.sql`                    | SQL Server Agent Job script                |

---

## 🛠 Features

- ✅ Normalized schema with all constraints
- ✅ Doctors and Patients with multivalued contact tables
- ✅ MedicalRecords auto-created via trigger
- ✅ Role-based security (DoctorUser, AdminUser)
- ✅ Transaction-safe billing and admission
- ✅ Scheduled job to log doctor appointments daily

---

## 🧪 Testing

To test the database:
1. Run `HospitalDB_Create_Quiries.sql`
2. Run `HospitalDB_Sample_data_insertion.sql`
3. Execute `Views_triggers_procedures_functions_quiereis.sql`
4. Run and explore queries in `Views_triggers_procedures_functions_quiereis.sql`
5. Execute `HospitalDB_SQL_Server_Job.sql` in SQL Server Agent

---

## 📅 SQL Job: Doctor Daily Schedule Report

**Job Name**: `Doctor_Daily_Schedule_Report`  
**Schedule**: Daily at 7:00 AM  
**Task**: Runs stored procedure `sp_LogDoctorDailySchedule` to log doctor appointments into `DoctorDailyScheduleLog`

---
