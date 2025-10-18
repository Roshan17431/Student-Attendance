# SQL Queries for Class-Wise Attendance

This document contains SQL queries for retrieving and analyzing class-wise attendance data from the Student Attendance Management System.

## Table of Contents
1. [Basic Attendance Queries](#basic-attendance-queries)
2. [Class-Wise Attendance Reports](#class-wise-attendance-reports)
3. [Student-Specific Queries](#student-specific-queries)
4. [Subject-Wise Queries](#subject-wise-queries)
5. [Date Range Queries](#date-range-queries)
6. [Statistical Queries](#statistical-queries)
7. [Advanced Analytics](#advanced-analytics)

---

## Basic Attendance Queries

### 1. View All Attendance Records
```sql
SELECT 
    a.attendance_id,
    s.first_name,
    s.last_name,
    s.student_roll,
    sub.subject_name,
    ses.session_date,
    a.status,
    a.marked_at
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
ORDER BY ses.session_date DESC, s.student_roll;
```

### 2. View Today's Attendance
```sql
SELECT 
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    sub.subject_name,
    a.status
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
WHERE ses.session_date = CURDATE()
ORDER BY sub.subject_name, s.student_roll;
```

---

## Class-Wise Attendance Reports

### 3. Class-Wise Attendance Summary (All Subjects)
```sql
SELECT 
    sub.subject_name AS class_subject,
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
GROUP BY sub.subject_name, ses.session_date
ORDER BY ses.session_date DESC, sub.subject_name;
```

### 4. Class-Wise Attendance for Specific Date
```sql
SELECT 
    sub.subject_name AS class_subject,
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
WHERE ses.session_date = '2024-01-15'  -- Replace with desired date
GROUP BY sub.subject_name
ORDER BY sub.subject_name;
```

### 5. Class-Wise Attendance Details (with Student Names)
```sql
SELECT 
    sub.subject_name AS class_subject,
    ses.session_date,
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    a.status
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
WHERE ses.session_date = '2024-01-15'  -- Replace with desired date
  AND sub.subject_name = 'Mathematics'  -- Replace with desired subject
ORDER BY s.student_roll;
```

### 6. Class-Wise Monthly Attendance Summary
```sql
SELECT 
    sub.subject_name AS class_subject,
    DATE_FORMAT(ses.session_date, '%Y-%m') AS month,
    COUNT(DISTINCT ses.session_id) AS total_classes,
    COUNT(DISTINCT s.student_id) AS total_students,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS total_present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS total_absent,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY sub.subject_name, DATE_FORMAT(ses.session_date, '%Y-%m')
ORDER BY month DESC, sub.subject_name;
```

---

## Student-Specific Queries

### 7. Individual Student Attendance Across All Classes
```sql
SELECT 
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    sub.subject_name,
    COUNT(DISTINCT ses.session_id) AS total_classes,
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
WHERE s.student_roll = 'STU001'  -- Replace with desired student roll number
GROUP BY s.student_id, sub.subject_name
ORDER BY sub.subject_name;
```

### 8. Student Attendance for Specific Subject and Date Range
```sql
SELECT 
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    sub.subject_name,
    ses.session_date,
    a.status
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
WHERE s.student_roll = 'STU001'  -- Replace with student roll number
  AND sub.subject_name = 'Mathematics'  -- Replace with subject name
  AND ses.session_date BETWEEN '2024-01-01' AND '2024-01-31'  -- Replace with date range
ORDER BY ses.session_date;
```

### 9. Students with Low Attendance (Below 75%)
```sql
SELECT 
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    sub.subject_name,
    COUNT(*) AS total_classes,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS classes_attended,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY s.student_id, sub.subject_name
HAVING attendance_percentage < 75
ORDER BY attendance_percentage ASC;
```

---

## Subject-Wise Queries

### 10. Overall Subject-Wise Attendance Statistics
```sql
SELECT 
    sub.subject_name,
    COUNT(DISTINCT ses.session_id) AS total_sessions,
    COUNT(DISTINCT s.student_id) AS total_students,
    COUNT(*) AS total_attendance_records,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS total_present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS total_absent,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS overall_attendance_percentage
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY sub.subject_name
ORDER BY overall_attendance_percentage DESC;
```

### 11. Subject-Wise Student Performance
```sql
SELECT 
    sub.subject_name,
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    COUNT(*) AS total_classes,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS attended,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
WHERE sub.subject_name = 'Mathematics'  -- Replace with desired subject
GROUP BY s.student_id
ORDER BY attendance_percentage DESC;
```

---

## Date Range Queries

### 12. Attendance Between Specific Dates
```sql
SELECT 
    ses.session_date,
    sub.subject_name,
    COUNT(DISTINCT s.student_id) AS total_students,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
WHERE ses.session_date BETWEEN '2024-01-01' AND '2024-01-31'  -- Replace with date range
GROUP BY ses.session_date, sub.subject_name
ORDER BY ses.session_date DESC, sub.subject_name;
```

### 13. Weekly Attendance Report
```sql
SELECT 
    YEARWEEK(ses.session_date) AS year_week,
    DATE(MIN(ses.session_date)) AS week_start,
    DATE(MAX(ses.session_date)) AS week_end,
    sub.subject_name,
    COUNT(DISTINCT ses.session_id) AS classes_held,
    COUNT(*) AS total_records,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY YEARWEEK(ses.session_date), sub.subject_name
ORDER BY year_week DESC, sub.subject_name;
```

---

## Statistical Queries

### 14. Average Attendance by Day of Week
```sql
SELECT 
    DAYNAME(ses.session_date) AS day_of_week,
    sub.subject_name,
    COUNT(*) AS total_sessions,
    ROUND(
        AVG(CASE WHEN a.status = 'Present' THEN 100 ELSE 0 END), 
        2
    ) AS avg_attendance_percentage
FROM attendance a
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY DAYNAME(ses.session_date), sub.subject_name
ORDER BY 
    FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    sub.subject_name;
```

### 15. Attendance Trends (Monthly Comparison)
```sql
SELECT 
    DATE_FORMAT(ses.session_date, '%Y-%m') AS month,
    sub.subject_name,
    COUNT(DISTINCT ses.session_id) AS classes_held,
    ROUND(
        AVG(CASE WHEN a.status = 'Present' THEN 100 ELSE 0 END), 
        2
    ) AS avg_attendance_percentage
FROM attendance a
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY DATE_FORMAT(ses.session_date, '%Y-%m'), sub.subject_name
ORDER BY month DESC, sub.subject_name;
```

### 16. Most and Least Attended Classes
```sql
-- Most Attended
SELECT 
    sub.subject_name,
    ses.session_date,
    COUNT(*) AS total_students,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY ses.session_id
ORDER BY attendance_percentage DESC
LIMIT 5;

-- Least Attended
SELECT 
    sub.subject_name,
    ses.session_date,
    COUNT(*) AS total_students,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY ses.session_id
ORDER BY attendance_percentage ASC
LIMIT 5;
```

---

## Advanced Analytics

### 17. Class-Wise Defaulter List (Students Missing Multiple Classes)
```sql
SELECT 
    sub.subject_name,
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    COUNT(*) AS total_classes,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS classes_missed,
    ROUND(
        (SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS absence_percentage
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY sub.subject_name, s.student_id
HAVING classes_missed > 3  -- Students who missed more than 3 classes
ORDER BY sub.subject_name, classes_missed DESC;
```

### 18. Consecutive Absences Detection
```sql
SELECT 
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    sub.subject_name,
    ses.session_date,
    a.status,
    LAG(a.status) OVER (PARTITION BY s.student_id, sub.subject_id ORDER BY ses.session_date) AS prev_status,
    LAG(ses.session_date) OVER (PARTITION BY s.student_id, sub.subject_id ORDER BY ses.session_date) AS prev_date
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
WHERE a.status = 'Absent'
ORDER BY s.student_roll, sub.subject_name, ses.session_date;
```

### 19. Class-Wise Perfect Attendance Students
```sql
SELECT 
    sub.subject_name,
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    COUNT(*) AS total_classes_attended
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
WHERE a.status = 'Present'
GROUP BY sub.subject_name, s.student_id
HAVING COUNT(*) = (
    SELECT COUNT(DISTINCT session_id)
    FROM sessions
    WHERE subject_id = ses.subject_id
)
ORDER BY sub.subject_name, s.student_roll;
```

### 20. Comprehensive Student Attendance Dashboard
```sql
SELECT 
    s.student_roll,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    COUNT(DISTINCT sub.subject_id) AS subjects_enrolled,
    COUNT(DISTINCT ses.session_id) AS total_classes,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS total_present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS total_absent,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    ) AS overall_attendance_percentage,
    CASE 
        WHEN (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) >= 90 THEN 'Excellent'
        WHEN (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) >= 75 THEN 'Good'
        WHEN (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) >= 60 THEN 'Average'
        ELSE 'Poor'
    END AS attendance_grade
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
GROUP BY s.student_id
ORDER BY overall_attendance_percentage DESC;
```

---

## Export Queries for Reports

### 21. Full Attendance Register for a Class (Excel Export Format)
```sql
SELECT 
    s.student_roll AS 'Roll Number',
    CONCAT(s.first_name, ' ', s.last_name) AS 'Student Name',
    sub.subject_name AS 'Subject',
    ses.session_date AS 'Date',
    a.status AS 'Status',
    a.marked_at AS 'Marked At'
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
WHERE sub.subject_name = 'Mathematics'  -- Replace with subject
  AND ses.session_date BETWEEN '2024-01-01' AND '2024-12-31'  -- Replace with date range
ORDER BY ses.session_date, s.student_roll;
```

### 22. Attendance Summary Report for Administration
```sql
SELECT 
    'Total Students' AS metric,
    COUNT(DISTINCT s.student_id) AS value
FROM students s
UNION ALL
SELECT 
    'Total Subjects',
    COUNT(DISTINCT sub.subject_id)
FROM subjects sub
UNION ALL
SELECT 
    'Total Classes Held',
    COUNT(DISTINCT ses.session_id)
FROM sessions ses
UNION ALL
SELECT 
    'Total Attendance Records',
    COUNT(*)
FROM attendance
UNION ALL
SELECT 
    'Overall Attendance Percentage',
    ROUND(
        (SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(*), 
        2
    )
FROM attendance;
```

---

## Notes

- Replace placeholder values (dates, student rolls, subject names) with actual values as needed
- All percentage calculations are rounded to 2 decimal places
- Date format used: `YYYY-MM-DD` (e.g., 2024-01-15)
- For better performance with large datasets, consider adding appropriate indexes
- These queries assume the database schema as defined in README.md

## Performance Tips

1. **Add Indexes** for frequently queried columns:
```sql
CREATE INDEX idx_session_date ON sessions(session_date);
CREATE INDEX idx_student_roll ON students(student_roll);
CREATE INDEX idx_subject_name ON subjects(subject_name);
CREATE INDEX idx_attendance_status ON attendance(status);
```

2. **Use Date Ranges** wisely to limit result sets
3. **Limit Results** for large datasets using `LIMIT` clause
4. **Use Prepared Statements** in application code to prevent SQL injection

## Query Optimization Example

For frequently used queries, consider creating views:

```sql
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

-- Then use the view:
SELECT * FROM v_class_attendance_summary
WHERE session_date = CURDATE();
```

---

**Last Updated**: 2024
**Version**: 1.0
**Maintained by**: Student Attendance System Team
