-- ====================================================
-- Student Attendance Management System
-- Database Setup Script
-- ====================================================
-- This script creates the database and all required tables
-- for the Student Attendance Management System
-- ====================================================

-- Create Database
DROP DATABASE IF EXISTS student3;
CREATE DATABASE student3;
USE student3;

-- ====================================================
-- Table 1: Users
-- Stores user authentication and role information
-- ====================================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL COMMENT 'Plain text for demo - use hashing in production',
    role ENUM('Admin', 'Teacher', 'Student') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================
-- Table 2: Students
-- Stores student information
-- ====================================================
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    student_roll VARCHAR(20) NOT NULL UNIQUE,
    user_id INT DEFAULT NULL COMMENT 'Link to user account if student has login access',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_student_roll (student_roll),
    INDEX idx_name (first_name, last_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================
-- Table 3: Teachers
-- Stores teacher information
-- ====================================================
CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    user_id INT DEFAULT NULL COMMENT 'Link to user account if teacher has login access',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_email (email),
    INDEX idx_name (first_name, last_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================
-- Table 4: Subjects
-- Stores subject/class information
-- ====================================================
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_subject_name (subject_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================
-- Table 5: Sessions
-- Represents a class/lecture held on a specific date for a subject
-- ====================================================
CREATE TABLE sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    session_date DATE NOT NULL,
    subject_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE KEY unique_session (session_date, subject_id),
    INDEX idx_session_date (session_date),
    INDEX idx_subject_id (subject_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================
-- Table 6: Attendance
-- Stores attendance records for students in sessions
-- ====================================================
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    session_id INT NOT NULL,
    status ENUM('Present', 'Absent') NOT NULL,
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, session_id),
    INDEX idx_student_id (student_id),
    INDEX idx_session_id (session_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================
-- Insert Sample Data
-- ====================================================

-- Sample Users
INSERT INTO users (username, password, role) VALUES
    ('admin', 'admin123', 'Admin'),
    ('teacher1', 'teacher123', 'Teacher'),
    ('teacher2', 'teacher123', 'Teacher'),
    ('student1', 'student123', 'Student'),
    ('student2', 'student123', 'Student'),
    ('student3', 'student123', 'Student');

-- Sample Subjects (Classes)
INSERT INTO subjects (subject_name) VALUES
    ('Mathematics'),
    ('Physics'),
    ('Chemistry'),
    ('Computer Science'),
    ('English'),
    ('Biology'),
    ('History'),
    ('Geography');

-- Sample Students
INSERT INTO students (first_name, last_name, student_roll, user_id) VALUES
    ('John', 'Doe', 'STU001', 4),
    ('Jane', 'Smith', 'STU002', 5),
    ('Mike', 'Johnson', 'STU003', 6),
    ('Sarah', 'Williams', 'STU004', NULL),
    ('David', 'Brown', 'STU005', NULL),
    ('Emily', 'Davis', 'STU006', NULL),
    ('James', 'Miller', 'STU007', NULL),
    ('Lisa', 'Wilson', 'STU008', NULL),
    ('Robert', 'Moore', 'STU009', NULL),
    ('Maria', 'Taylor', 'STU010', NULL);

-- Sample Teachers
INSERT INTO teachers (first_name, last_name, email, user_id) VALUES
    ('Robert', 'Brown', 'robert.brown@school.com', 2),
    ('Patricia', 'Garcia', 'patricia.garcia@school.com', 3),
    ('Michael', 'Martinez', 'michael.martinez@school.com', NULL),
    ('Linda', 'Anderson', 'linda.anderson@school.com', NULL);

-- Sample Sessions (Classes held)
-- Mathematics classes
INSERT INTO sessions (session_date, subject_id) VALUES
    ('2024-01-02', (SELECT subject_id FROM subjects WHERE subject_name = 'Mathematics')),
    ('2024-01-03', (SELECT subject_id FROM subjects WHERE subject_name = 'Mathematics')),
    ('2024-01-04', (SELECT subject_id FROM subjects WHERE subject_name = 'Mathematics')),
    ('2024-01-05', (SELECT subject_id FROM subjects WHERE subject_name = 'Mathematics')),
    ('2024-01-08', (SELECT subject_id FROM subjects WHERE subject_name = 'Mathematics'));

-- Physics classes
INSERT INTO sessions (session_date, subject_id) VALUES
    ('2024-01-02', (SELECT subject_id FROM subjects WHERE subject_name = 'Physics')),
    ('2024-01-03', (SELECT subject_id FROM subjects WHERE subject_name = 'Physics')),
    ('2024-01-04', (SELECT subject_id FROM subjects WHERE subject_name = 'Physics'));

-- Computer Science classes
INSERT INTO sessions (session_date, subject_id) VALUES
    ('2024-01-02', (SELECT subject_id FROM subjects WHERE subject_name = 'Computer Science')),
    ('2024-01-03', (SELECT subject_id FROM subjects WHERE subject_name = 'Computer Science')),
    ('2024-01-05', (SELECT subject_id FROM subjects WHERE subject_name = 'Computer Science'));

-- Sample Attendance Data
-- Math attendance - Jan 2, 2024
INSERT INTO attendance (student_id, session_id, status) VALUES
    (1, 1, 'Present'),
    (2, 1, 'Present'),
    (3, 1, 'Absent'),
    (4, 1, 'Present'),
    (5, 1, 'Present'),
    (6, 1, 'Present'),
    (7, 1, 'Absent'),
    (8, 1, 'Present'),
    (9, 1, 'Present'),
    (10, 1, 'Present');

-- Math attendance - Jan 3, 2024
INSERT INTO attendance (student_id, session_id, status) VALUES
    (1, 2, 'Present'),
    (2, 2, 'Present'),
    (3, 2, 'Present'),
    (4, 2, 'Absent'),
    (5, 2, 'Present'),
    (6, 2, 'Present'),
    (7, 2, 'Present'),
    (8, 2, 'Present'),
    (9, 2, 'Absent'),
    (10, 2, 'Present');

-- Math attendance - Jan 4, 2024
INSERT INTO attendance (student_id, session_id, status) VALUES
    (1, 3, 'Present'),
    (2, 3, 'Present'),
    (3, 3, 'Absent'),
    (4, 3, 'Present'),
    (5, 3, 'Present'),
    (6, 3, 'Absent'),
    (7, 3, 'Present'),
    (8, 3, 'Present'),
    (9, 3, 'Present'),
    (10, 3, 'Present');

-- Physics attendance - Jan 2, 2024
INSERT INTO attendance (student_id, session_id, status) VALUES
    (1, 6, 'Present'),
    (2, 6, 'Present'),
    (3, 6, 'Present'),
    (4, 6, 'Present'),
    (5, 6, 'Absent'),
    (6, 6, 'Present'),
    (7, 6, 'Present'),
    (8, 6, 'Absent'),
    (9, 6, 'Present'),
    (10, 6, 'Present');

-- Computer Science attendance - Jan 2, 2024
INSERT INTO attendance (student_id, session_id, status) VALUES
    (1, 9, 'Present'),
    (2, 9, 'Present'),
    (3, 9, 'Present'),
    (4, 9, 'Present'),
    (5, 9, 'Present'),
    (6, 9, 'Present'),
    (7, 9, 'Present'),
    (8, 9, 'Present'),
    (9, 9, 'Present'),
    (10, 9, 'Absent');

-- ====================================================
-- Create Views for Common Queries
-- ====================================================

-- View: Class-wise attendance summary
CREATE VIEW v_class_attendance_summary AS
SELECT 
    sub.subject_name,
    ses.session_date,
    COUNT(DISTINCT s.student_id) AS total_students,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(DISTINCT s.student_id), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY sub.subject_name, ses.session_date;

-- View: Student attendance overview
CREATE VIEW v_student_attendance_overview AS
SELECT 
    s.student_id,
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    sub.subject_name,
    COUNT(*) AS total_classes,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS classes_attended,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS classes_missed,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY s.student_id, sub.subject_name;

-- ====================================================
-- Verification Queries
-- ====================================================

-- Show all tables
SHOW TABLES;

-- Show record counts
SELECT 'users' AS table_name, COUNT(*) AS record_count FROM users
UNION ALL
SELECT 'students', COUNT(*) FROM students
UNION ALL
SELECT 'teachers', COUNT(*) FROM teachers
UNION ALL
SELECT 'subjects', COUNT(*) FROM subjects
UNION ALL
SELECT 'sessions', COUNT(*) FROM sessions
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance;

-- Show sample class attendance summary
SELECT * FROM v_class_attendance_summary ORDER BY session_date DESC, subject_name;

-- Show sample student attendance overview
SELECT * FROM v_student_attendance_overview ORDER BY student_roll, subject_name;

-- ====================================================
-- End of Script
-- ====================================================
DELIMITER //
CREATE PROCEDURE show_database_info()
BEGIN
    SELECT 'Database setup completed successfully!' AS message;
    SELECT 'Default Admin Login:' AS info, 'Username: admin, Password: admin123' AS credentials
    UNION ALL
    SELECT 'Default Teacher Login:', 'Username: teacher1, Password: teacher123'
    UNION ALL
    SELECT 'Default Student Login:', 'Username: student1, Password: student123';
END //
DELIMITER ;

-- Display setup information
CALL show_database_info();
