-- Student Attendance System Database Schema
-- MySQL Database Creation Script

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS student4;
USE student4;

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS teacher_subjects;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS teachers;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS users;

-- Table: users
-- Stores user credentials for login (Admin, Teacher, Student)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role ENUM('Admin', 'Teacher', 'Student') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: teachers
-- Stores teacher information
CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Table: subjects
-- Stores subject/course information
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: teacher_subjects
-- Maps teachers to subjects they teach and the classes they teach
CREATE TABLE teacher_subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    subject_id INT NOT NULL,
    class VARCHAR(20) NOT NULL COMMENT 'Class format: S1A to S8E (Standards 1-8, Divisions A-E)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE KEY unique_teacher_subject_class (teacher_id, subject_id, class)
);

-- Table: students
-- Stores student information
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
    INDEX idx_student_roll (student_roll)
);

-- Table: sessions
-- Stores class session information (date, subject, class number)
CREATE TABLE sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    session_date DATE NOT NULL,
    subject_id INT NOT NULL,
    session_number INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE KEY unique_session (session_date, subject_id, session_number)
);

-- Table: attendance
-- Stores attendance records for students in sessions
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    session_id INT NOT NULL,
    status ENUM('Present', 'Absent') NOT NULL DEFAULT 'Present',
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, session_id)
);

-- Insert default admin user
-- Username: admin, Password: admin123, Role: Admin
INSERT INTO users (username, password, role) VALUES ('admin', 'admin123', 'Admin');

-- Sample data for testing (optional - uncomment to use)

-- Insert sample teachers
-- INSERT INTO teachers (first_name, last_name, email, user_id) VALUES
-- ('John', 'Smith', 'john.smith@school.com', NULL),
-- ('Sarah', 'Johnson', 'sarah.johnson@school.com', NULL),
-- ('Michael', 'Williams', 'michael.williams@school.com', NULL);

-- Insert sample subjects
-- INSERT INTO subjects (subject_name) VALUES
-- ('Mathematics'),
-- ('Physics'),
-- ('Chemistry'),
-- ('English'),
-- ('Computer Science');

-- Insert sample students
-- INSERT INTO students (first_name, last_name, student_roll, class, user_id) VALUES
-- ('Alice', 'Brown', 'S001', 'S1A', NULL),
-- ('Bob', 'Davis', 'S002', 'S1A', NULL),
-- ('Charlie', 'Miller', 'S003', 'S1B', NULL),
-- ('Diana', 'Wilson', 'S004', 'S2A', NULL),
-- ('Eve', 'Moore', 'S005', 'S2B', NULL);

-- Insert sample teacher-subject-class mappings
-- Assuming teacher_id 1 teaches Mathematics to class S1A
-- INSERT INTO teacher_subjects (teacher_id, subject_id, class) VALUES
-- (1, 1, 'S1A'),
-- (1, 1, 'S1B'),
-- (2, 2, 'S2A'),
-- (2, 3, 'S2A'),
-- (3, 4, 'S3A'),
-- (3, 5, 'S3B');

-- Create views for easier querying

-- View: student_attendance_summary
-- Provides a summary of attendance for each student
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

-- View: class_attendance_summary
-- Provides a summary of attendance for each class
CREATE OR REPLACE VIEW class_attendance_summary AS
SELECT 
    s.class,
    sub.subject_name,
    se.session_date,
    COUNT(DISTINCT s.student_id) AS total_students,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
    ROUND((SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)), 2) AS attendance_percentage
FROM students s
JOIN attendance a ON s.student_id = a.student_id
JOIN sessions se ON a.session_id = se.session_id
JOIN subjects sub ON se.subject_id = sub.subject_id
GROUP BY s.class, sub.subject_name, se.session_date;

-- Indexes for performance optimization
CREATE INDEX idx_attendance_student ON attendance(student_id);
CREATE INDEX idx_attendance_session ON attendance(session_id);
CREATE INDEX idx_sessions_date ON sessions(session_date);
CREATE INDEX idx_sessions_subject ON sessions(subject_id);

-- Display schema information
SELECT 'Database schema created successfully!' AS Message;
SHOW TABLES;
