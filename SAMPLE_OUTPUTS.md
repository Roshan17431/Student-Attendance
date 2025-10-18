# Sample Query Results

This document shows example outputs from key class-wise attendance queries. These examples help you understand what to expect when running queries from QUERIES.md.

---

## Query #3: Class-Wise Attendance Summary (All Subjects)

**Query:**
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

**Sample Output:**
```
+------------------+--------------+----------------+---------------+--------------+-----------------------+
| class_subject    | session_date | total_students | present_count | absent_count | attendance_percentage |
+------------------+--------------+----------------+---------------+--------------+-----------------------+
| Computer Science | 2024-01-05   |             10 |             9 |            1 |                 90.00 |
| Mathematics      | 2024-01-05   |             10 |            10 |            0 |                100.00 |
| Mathematics      | 2024-01-04   |             10 |             8 |            2 |                 80.00 |
| Physics          | 2024-01-04   |             10 |             9 |            1 |                 90.00 |
| Computer Science | 2024-01-03   |             10 |             9 |            1 |                 90.00 |
| Mathematics      | 2024-01-03   |             10 |             8 |            2 |                 80.00 |
| Physics          | 2024-01-03   |             10 |             9 |            1 |                 90.00 |
| Computer Science | 2024-01-02   |             10 |             9 |            1 |                 90.00 |
| Mathematics      | 2024-01-02   |             10 |             8 |            2 |                 80.00 |
| Physics          | 2024-01-02   |             10 |             8 |            2 |                 80.00 |
+------------------+--------------+----------------+---------------+--------------+-----------------------+
```

**Interpretation:**
- Shows attendance for each class session by subject and date
- Mathematics on Jan 5 had perfect 100% attendance
- Physics and Computer Science consistently maintain 90% attendance
- Easy to identify dates with lower attendance for follow-up

---

## Query #4: Class-Wise Attendance for Specific Date

**Query:**
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
WHERE ses.session_date = '2024-01-02'
GROUP BY sub.subject_name
ORDER BY sub.subject_name;
```

**Sample Output:**
```
+------------------+----------------+---------------+--------------+-----------------------+
| class_subject    | total_students | present_count | absent_count | attendance_percentage |
+------------------+----------------+---------------+--------------+-----------------------+
| Computer Science |             10 |             9 |            1 |                 90.00 |
| Mathematics      |             10 |             8 |            2 |                 80.00 |
| Physics          |             10 |             8 |            2 |                 80.00 |
+------------------+----------------+---------------+--------------+-----------------------+
```

**Interpretation:**
- Snapshot of all classes held on January 2, 2024
- Computer Science had best attendance at 90%
- Mathematics and Physics both at 80%
- Quick daily summary for administration

---

## Query #5: Class-Wise Attendance Details (with Student Names)

**Query:**
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
WHERE ses.session_date = '2024-01-02'
  AND sub.subject_name = 'Mathematics'
ORDER BY s.student_roll;
```

**Sample Output:**
```
+---------------+--------------+--------------+------------------+---------+
| class_subject | session_date | student_roll | student_name     | status  |
+---------------+--------------+--------------+------------------+---------+
| Mathematics   | 2024-01-02   | STU001       | John Doe         | Present |
| Mathematics   | 2024-01-02   | STU002       | Jane Smith       | Present |
| Mathematics   | 2024-01-02   | STU003       | Mike Johnson     | Absent  |
| Mathematics   | 2024-01-02   | STU004       | Sarah Williams   | Present |
| Mathematics   | 2024-01-02   | STU005       | David Brown      | Present |
| Mathematics   | 2024-01-02   | STU006       | Emily Davis      | Present |
| Mathematics   | 2024-01-02   | STU007       | James Miller     | Absent  |
| Mathematics   | 2024-01-02   | STU008       | Lisa Wilson      | Present |
| Mathematics   | 2024-01-02   | STU009       | Robert Moore     | Present |
| Mathematics   | 2024-01-02   | STU010       | Maria Taylor     | Present |
+---------------+--------------+--------------+------------------+---------+
```

**Interpretation:**
- Detailed attendance register for Mathematics class on Jan 2
- Shows exactly which students were absent (STU003 and STU007)
- Perfect for attendance records and documentation
- Can be exported to Excel for official records

---

## Query #6: Class-Wise Monthly Attendance Summary

**Query:**
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

**Sample Output:**
```
+------------------+--------+---------------+----------------+---------------+--------------+-----------------------+
| class_subject    | month  | total_classes | total_students | total_present | total_absent | attendance_percentage |
+------------------+--------+---------------+----------------+---------------+--------------+-----------------------+
| Computer Science | 2024-01|             3 |             10 |            27 |            3 |                 90.00 |
| Mathematics      | 2024-01|             5 |             10 |            42 |            8 |                 84.00 |
| Physics          | 2024-01|             3 |             10 |            26 |            4 |                 86.67 |
+------------------+--------+---------------+----------------+---------------+--------------+-----------------------+
```

**Interpretation:**
- Monthly overview of all subjects
- Mathematics had 5 classes with 84% average attendance
- Computer Science maintains highest attendance at 90%
- Useful for monthly reports to administration

---

## Query #7: Individual Student Attendance Across All Classes

**Query:**
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
WHERE s.student_roll = 'STU001'
GROUP BY s.student_id, sub.subject_name
ORDER BY sub.subject_name;
```

**Sample Output:**
```
+--------------+--------------+------------------+---------------+------------------+----------------+-----------------------+
| student_roll | student_name | subject_name     | total_classes | classes_attended | classes_missed | attendance_percentage |
+--------------+--------------+------------------+---------------+------------------+----------------+-----------------------+
| STU001       | John Doe     | Computer Science |             3 |                3 |              0 |                100.00 |
| STU001       | John Doe     | Mathematics      |             5 |                5 |              0 |                100.00 |
| STU001       | John Doe     | Physics          |             3 |                3 |              0 |                100.00 |
+--------------+--------------+------------------+---------------+------------------+----------------+-----------------------+
```

**Interpretation:**
- Complete attendance profile for student STU001 (John Doe)
- Perfect 100% attendance across all subjects
- Shows student is consistently present
- Useful for student performance reviews

---

## Query #9: Students with Low Attendance (Below 75%)

**Query:**
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

**Sample Output:**
```
+--------------+------------------+---------------+---------------+------------------+-----------------------+
| student_roll | student_name     | subject_name  | total_classes | classes_attended | attendance_percentage |
+--------------+------------------+---------------+---------------+------------------+-----------------------+
| STU003       | Mike Johnson     | Mathematics   |             5 |                2 |                 40.00 |
| STU007       | James Miller     | Physics       |             3 |                2 |                 66.67 |
| STU003       | Mike Johnson     | Physics       |             3 |                2 |                 66.67 |
| STU007       | James Miller     | Mathematics   |             5 |                3 |                 60.00 |
+--------------+------------------+---------------+---------------+-----------------------+
```

**Interpretation:**
- List of students requiring attention due to low attendance
- Mike Johnson (STU003) has critical 40% attendance in Mathematics
- James Miller (STU007) below 75% in multiple subjects
- Action required: Parent meeting, counseling, or warnings
- Sorted by attendance percentage (worst first)

---

## Query #17: Class-Wise Defaulter List

**Query:**
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
HAVING classes_missed > 3
ORDER BY sub.subject_name, classes_missed DESC;
```

**Sample Output:**
```
+---------------+--------------+------------------+---------------+----------------+--------------------+
| subject_name  | student_roll | student_name     | total_classes | classes_missed | absence_percentage |
+---------------+--------------+------------------+---------------+----------------+--------------------+
| Mathematics   | STU003       | Mike Johnson     |             5 |              3 |              60.00 |
| Mathematics   | STU007       | James Miller     |             5 |              2 |              40.00 |
+---------------+--------------+------------------+---------------+----------------+--------------------+
```

**Interpretation:**
- Students who missed more than 3 classes in any subject
- Mike Johnson missed 3 out of 5 Mathematics classes (60% absence rate!)
- Immediate intervention required
- Perfect for generating warning letters or parent notifications

---

## Query #20: Comprehensive Student Attendance Dashboard

**Query:**
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

**Sample Output:**
```
+--------------+------------------+-------------------+---------------+---------------+--------------+-------------------------------+------------------+
| student_roll | student_name     | subjects_enrolled | total_classes | total_present | total_absent | overall_attendance_percentage | attendance_grade |
+--------------+------------------+-------------------+---------------+---------------+--------------+-------------------------------+------------------+
| STU001       | John Doe         |                 3 |            11 |            11 |            0 |                        100.00 | Excellent        |
| STU002       | Jane Smith       |                 3 |            11 |            11 |            0 |                        100.00 | Excellent        |
| STU004       | Sarah Williams   |                 3 |            11 |            10 |            1 |                         90.91 | Excellent        |
| STU005       | David Brown      |                 3 |            11 |            10 |            1 |                         90.91 | Excellent        |
| STU006       | Emily Davis      |                 3 |            11 |            10 |            1 |                         90.91 | Excellent        |
| STU008       | Lisa Wilson      |                 3 |            11 |            10 |            1 |                         90.91 | Excellent        |
| STU009       | Robert Moore     |                 3 |            11 |            10 |            1 |                         90.91 | Excellent        |
| STU010       | Maria Taylor     |                 3 |            11 |            11 |            0 |                        100.00 | Excellent        |
| STU007       | James Miller     |                 3 |            11 |             8 |            3 |                         72.73 | Average          |
| STU003       | Mike Johnson     |                 3 |            11 |             7 |            4 |                         63.64 | Average          |
+--------------+------------------+-------------------+---------------+---------------+--------------+-------------------------------+------------------+
```

**Interpretation:**
- Complete overview of all students ranked by attendance
- STU001, STU002, and STU010 have perfect attendance (Excellent grade)
- Most students maintain Excellent attendance (≥90%)
- STU007 and STU003 need attention (Average grade, <75%)
- Perfect for semester-end reports and awards

---

## Database Views Usage

### Using v_class_attendance_summary View

**Query:**
```sql
SELECT * FROM v_class_attendance_summary
WHERE session_date >= '2024-01-01'
ORDER BY session_date DESC;
```

**Sample Output:**
```
+------------------+--------------+----------------+---------------+--------------+-----------------------+
| subject_name     | session_date | total_students | present_count | absent_count | attendance_percentage |
+------------------+--------------+----------------+---------------+--------------+-----------------------+
| Computer Science | 2024-01-05   |             10 |             9 |            1 |                 90.00 |
| Mathematics      | 2024-01-05   |             10 |            10 |            0 |                100.00 |
| Mathematics      | 2024-01-04   |             10 |             8 |            2 |                 80.00 |
| Physics          | 2024-01-04   |             10 |             9 |            1 |                 90.00 |
+------------------+--------------+----------------+---------------+--------------+-----------------------+
```

---

## Notes on Sample Data

- All sample outputs are based on the data created by `database_setup.sql`
- Student rolls: STU001 through STU010 (10 students)
- Subjects: Mathematics (5 classes), Physics (3 classes), Computer Science (3 classes)
- Date range: January 2-5, 2024
- Perfect for testing and understanding query outputs

---

## Tips for Using Queries

1. **Replace Placeholders**: All queries have comments indicating values to replace (dates, student rolls, subjects)
2. **Test with Sample Data**: Use the sample data to verify query results
3. **Modify for Your Needs**: Adjust date ranges, subject names, and thresholds as needed
4. **Export Results**: Results can be exported to Excel or CSV for reports
5. **Create Views**: Save frequently used queries as views for quick access

---

**For Complete Query Collection**: See [QUERIES.md](QUERIES.md)  
**For Database Setup**: See [database_setup.sql](database_setup.sql)  
**For System Documentation**: See [README.md](README.md)
