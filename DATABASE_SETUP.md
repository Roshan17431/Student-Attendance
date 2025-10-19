# Database Setup Guide

## Prerequisites
- MySQL Server installed (version 5.7 or higher)
- MySQL Connector/J JDBC Driver

## Setup Instructions

### 1. Install MySQL Server
If you haven't already, install MySQL Server on your system.

### 2. Configure Database Connection
Update the database connection settings in `src/DatabaseManager.java`:
- **Database URL**: `jdbc:mysql://localhost:3306/student4`
- **Username**: `root` (or your MySQL username)
- **Password**: `roshan17` (or your MySQL password)

```java
private static final String URL = "jdbc:mysql://localhost:3306/student4";
private static final String USER = "root";
private static final String PASSWORD = "roshan17";
```

### 3. Create Database and Tables
Run the SQL script to create the database schema:

```bash
mysql -u root -p < database_schema.sql
```

Or manually execute the script:
1. Open MySQL command line or MySQL Workbench
2. Copy and paste the contents of `database_schema.sql`
3. Execute the script

### 4. Default Admin Credentials
After running the script, a default admin user will be created:
- **Username**: `admin`
- **Password**: `admin123`
- **Role**: `Admin`

### 5. Download MySQL JDBC Driver
Download the MySQL Connector/J JDBC Driver from:
https://dev.mysql.com/downloads/connector/j/

Add the JAR file to your project's classpath.

## Database Schema Overview

### Tables

1. **users** - User authentication
   - `user_id` (PK)
   - `username`
   - `password`
   - `role` (Admin, Teacher, Student)

2. **teachers** - Teacher information
   - `teacher_id` (PK)
   - `first_name`, `last_name`, `email`
   - `user_id` (FK to users)

3. **students** - Student information
   - `student_id` (PK)
   - `first_name`, `last_name`, `student_roll`
   - `class` - **Format: S1A to S8E (Standards 1-8, Divisions A-E)**
   - `user_id` (FK to users)

4. **subjects** - Course/subject information
   - `subject_id` (PK)
   - `subject_name`

5. **teacher_subjects** - Maps teachers to subjects and classes
   - `teacher_id` (FK to teachers)
   - `subject_id` (FK to subjects)
   - `class` - The class where this teacher teaches this subject (Format: S1A to S8E)

6. **sessions** - Class session information
   - `session_id` (PK)
   - `session_date`
   - `subject_id` (FK to subjects)
   - `session_number` - The class number for that day

7. **attendance** - Attendance records
   - `attendance_id` (PK)
   - `student_id` (FK to students)
   - `session_id` (FK to sessions)
   - `status` (Present, Absent)

## Key Features

### Class-Wise Attendance
The system now properly supports **class-wise attendance** with standardized class format:
- Class format: **S1A to S8E** (Standards 1-8, Divisions A-E)
- Each student belongs to a specific class using a dropdown selector
- Teachers can filter students by class when marking attendance
- The attendance panel includes a "Filter by Class" dropdown
- Teachers can mark attendance for any class
- All subjects are available to teachers for marking attendance

### Views
Two database views are created for easy reporting:
1. **student_attendance_summary** - Attendance summary per student
2. **class_attendance_summary** - Attendance summary per class

## Troubleshooting

### Connection Error
If you get a connection error:
1. Verify MySQL is running: `sudo service mysql status`
2. Check username and password in `DatabaseManager.java`
3. Ensure database `student4` exists: `SHOW DATABASES;`

### JDBC Driver Not Found
If you see "JDBC Driver not found":
1. Download MySQL Connector/J
2. Add the JAR to your project's build path
3. In IntelliJ IDEA: File → Project Structure → Libraries → Add JAR

### Table Already Exists
If tables already exist, the script will drop and recreate them. **Warning**: This will delete all existing data.

## Sample Data
To add sample data for testing, uncomment the INSERT statements at the bottom of `database_schema.sql`.

## Security Note
⚠️ **Important**: The current implementation stores passwords in plain text. For production use, implement proper password hashing (e.g., BCrypt, SHA-256).
