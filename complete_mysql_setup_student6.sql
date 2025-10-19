-- =====================================================================
-- COMPLETE MYSQL DATABASE SETUP FOR STUDENT ATTENDANCE SYSTEM
-- Database Name: student6
-- =====================================================================
-- 
-- INSTRUCTIONS:
-- 1. Open MySQL command line or MySQL Workbench
-- 2. Run this entire script to create the database and all tables
-- 3. Default admin login will be created:
--    Username: admin
--    Password: admin123
--    Role: Admin
--
-- To run from command line:
-- mysql -u root -p < complete_mysql_setup_student6.sql
--
-- =====================================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS student6;
USE student6;

-- Drop existing tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS teacher_subjects;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS teachers;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS users;

-- =====================================================================
-- TABLE 1: users
-- Purpose: Store user credentials for system login
-- Roles: Admin, Teacher, Student
-- =====================================================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role ENUM('Admin', 'Teacher', 'Student') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- TABLE 2: teachers
-- Purpose: Store teacher information
-- =====================================================================
CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_teacher_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- TABLE 3: subjects
-- Purpose: Store subject/course information
-- =====================================================================
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_subject_name (subject_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- TABLE 4: teacher_subjects
-- Purpose: Map teachers to subjects and classes they teach
-- Class Format: S1A to S8E (Standards 1-8, Divisions A-E)
-- =====================================================================
CREATE TABLE teacher_subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    subject_id INT NOT NULL,
    class VARCHAR(20) NOT NULL COMMENT 'Class format: S1A to S8E (Standards 1-8, Divisions A-E)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE KEY unique_teacher_subject_class (teacher_id, subject_id, class),
    INDEX idx_teacher (teacher_id),
    INDEX idx_subject (subject_id),
    INDEX idx_class (class)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- TABLE 5: students
-- Purpose: Store student information
-- Class Format: S1A to S8E (Standards 1-8, Divisions A-E)
-- =====================================================================
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    student_roll VARCHAR(20) NOT NULL UNIQUE,
    class VARCHAR(20) NOT NULL COMMENT 'Class format: S1A to S8E (Standards 1-8, Divisions A-E)',
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_class (class),
    INDEX idx_student_roll (student_roll),
    INDEX idx_student_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- TABLE 6: sessions
-- Purpose: Store class session information (date, subject, class number)
-- =====================================================================
CREATE TABLE sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    session_date DATE NOT NULL,
    subject_id INT NOT NULL,
    session_number INT NOT NULL DEFAULT 1 COMMENT 'Class number for the day (1-10)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE KEY unique_session (session_date, subject_id, session_number),
    INDEX idx_session_date (session_date),
    INDEX idx_subject (subject_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- TABLE 7: attendance
-- Purpose: Store attendance records for students in sessions
-- =====================================================================
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    session_id INT NOT NULL,
    status ENUM('Present', 'Absent') NOT NULL DEFAULT 'Present',
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, session_id),
    INDEX idx_student (student_id),
    INDEX idx_session (session_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- DEFAULT DATA: Insert default admin user
-- =====================================================================
INSERT INTO users (username, password, role) VALUES 
('admin', 'admin123', 'Admin');

-- =====================================================================
-- VIEW 1: student_attendance_summary
-- Purpose: Provides a summary of attendance for each student by subject
-- =====================================================================
CREATE OR REPLACE VIEW student_attendance_summary AS
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.student_roll,
    s.class,
    sub.subject_name,
    COUNT(a.attendance_id) AS total_classes,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
    ROUND((SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)), 2) AS attendance_percentage
FROM students s
JOIN attendance a ON s.student_id = a.student_id
JOIN sessions se ON a.session_id = se.session_id
JOIN subjects sub ON se.subject_id = sub.subject_id
GROUP BY s.student_id, s.first_name, s.last_name, s.student_roll, s.class, sub.subject_name;

-- =====================================================================
-- VIEW 2: class_attendance_summary
-- Purpose: Provides a summary of attendance for each class by date
-- =====================================================================
CREATE OR REPLACE VIEW class_attendance_summary AS
SELECT 
    s.class,
    sub.subject_name,
    se.session_date,
    se.session_number,
    COUNT(DISTINCT s.student_id) AS total_students,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
    ROUND((SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)), 2) AS attendance_percentage
FROM students s
JOIN attendance a ON s.student_id = a.student_id
JOIN sessions se ON a.session_id = se.session_id
JOIN subjects sub ON se.subject_id = sub.subject_id
GROUP BY s.class, sub.subject_name, se.session_date, se.session_number
ORDER BY se.session_date DESC, s.class;

-- =====================================================================
-- SAMPLE DATA (Optional - Uncomment to use)
-- =====================================================================

-- Insert sample subjects
-- INSERT INTO subjects (subject_name) VALUES
-- ('Mathematics'),
-- ('Physics'),
-- ('Chemistry'),
-- ('English'),
-- ('Computer Science'),
-- ('Biology'),
-- ('History'),
-- ('Geography');

-- Insert sample teachers
-- INSERT INTO teachers (first_name, last_name, email, user_id) VALUES
-- ('John', 'Smith', 'john.smith@school.com', NULL),
-- ('Sarah', 'Johnson', 'sarah.johnson@school.com', NULL),
-- ('Michael', 'Williams', 'michael.williams@school.com', NULL),
-- ('Emily', 'Brown', 'emily.brown@school.com', NULL);

-- Insert sample students with S1A-S8E class format
-- INSERT INTO students (first_name, last_name, student_roll, class, user_id) VALUES
-- ('Alice', 'Anderson', 'S001', 'S1A', NULL),
-- ('Bob', 'Brown', 'S002', 'S1A', NULL),
-- ('Charlie', 'Clark', 'S003', 'S1B', NULL),
-- ('Diana', 'Davis', 'S004', 'S1B', NULL),
-- ('Eve', 'Evans', 'S005', 'S2A', NULL),
-- ('Frank', 'Foster', 'S006', 'S2A', NULL),
-- ('Grace', 'Green', 'S007', 'S2B', NULL),
-- ('Henry', 'Harris', 'S008', 'S2B', NULL),
-- ('Ivy', 'Irving', 'S009', 'S3A', NULL),
-- ('Jack', 'Jackson', 'S010', 'S3A', NULL);

-- Insert sample teacher-subject-class mappings
-- This maps teachers to subjects they teach and the classes they teach
-- INSERT INTO teacher_subjects (teacher_id, subject_id, class) VALUES
-- (1, 1, 'S1A'),  -- Teacher 1 teaches Mathematics to S1A
-- (1, 1, 'S1B'),  -- Teacher 1 teaches Mathematics to S1B
-- (2, 2, 'S2A'),  -- Teacher 2 teaches Physics to S2A
-- (2, 2, 'S2B'),  -- Teacher 2 teaches Physics to S2B
-- (3, 3, 'S3A'),  -- Teacher 3 teaches Chemistry to S3A
-- (4, 4, 'S1A');  -- Teacher 4 teaches English to S1A

-- =====================================================================
-- VERIFICATION QUERIES
-- =====================================================================

-- Show all tables
SELECT 'Database tables created successfully!' AS Status;
SHOW TABLES;

-- Show table structures
SELECT 'Table: users' AS Info;
DESCRIBE users;

SELECT 'Table: teachers' AS Info;
DESCRIBE teachers;

SELECT 'Table: subjects' AS Info;
DESCRIBE subjects;

SELECT 'Table: teacher_subjects' AS Info;
DESCRIBE teacher_subjects;

SELECT 'Table: students' AS Info;
DESCRIBE students;

SELECT 'Table: sessions' AS Info;
DESCRIBE sessions;

SELECT 'Table: attendance' AS Info;
DESCRIBE attendance;

-- Show default admin user
SELECT 'Default Admin User:' AS Info;
SELECT user_id, username, role FROM users WHERE role = 'Admin';

-- Show views
SELECT 'Database views created successfully!' AS Status;
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

-- =====================================================================
-- DATABASE SETUP COMPLETE
-- =====================================================================
SELECT '
=====================================================================
DATABASE SETUP COMPLETE!
=====================================================================
Database Name: student6
Default Admin Login:
  - Username: admin
  - Password: admin123
  - Role: Admin

Tables Created:
  1. users (User authentication)
  2. teachers (Teacher information)
  3. subjects (Subject information)
  4. teacher_subjects (Teacher-Subject-Class mapping)
  5. students (Student information with class S1A-S8E)
  6. sessions (Class session tracking)
  7. attendance (Attendance records)

Views Created:
  1. student_attendance_summary
  2. class_attendance_summary

Next Steps:
  1. Update src/DatabaseManager.java to use database: student6
  2. Compile and run the Java application
  3. Login with admin credentials
  4. Add subjects, teachers, and students
  5. Mark attendance using class-wise filtering (S1A-S8E)

Class Format:
  - Standards: S1, S2, S3, S4, S5, S6, S7, S8
  - Divisions: A, B, C, D, E
  - Total: 40 classes available
  - Examples: S1A, S2B, S5C, S8E

=====================================================================
' AS 'Setup Complete';
