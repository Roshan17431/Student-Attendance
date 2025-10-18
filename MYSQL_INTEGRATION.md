# MySQL Database Integration Guide

This document explains how the Student Attendance Management System integrates with MySQL database.

## Database Connection (DatabaseManager.java)

The `DatabaseManager.java` file handles all database connections:

```java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseManager {
    private static final String URL = "jdbc:mysql://localhost:3306/student3";
    private static final String USER = "root";
    private static final String PASSWORD = "roshan17";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("JDBC Driver not found.");
            e.printStackTrace();
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
```

### Configuration

To connect to your MySQL database, update these three values in `src/DatabaseManager.java`:

1. **URL**: `jdbc:mysql://localhost:3306/student3`
   - `localhost`: Your MySQL server hostname
   - `3306`: MySQL port (default is 3306)
   - `student3`: Database name

2. **USER**: Your MySQL username (default: `root`)

3. **PASSWORD**: Your MySQL password

## Class-Wise Attendance Implementation

### New Feature: Class-Wise Attendance Report

The application now includes a **Class-Wise Reports** tab that shows attendance for all students in a selected class/subject.

#### SQL Query Used (from Main.java)

```java
String sql = """
    SELECT 
        s.student_roll,
        CONCAT(s.first_name, ' ', s.last_name) AS student_name,
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
    WHERE sub.subject_name = ?
      AND ses.session_date BETWEEN ? AND ?
    GROUP BY s.student_id, s.student_roll, student_name
    ORDER BY s.student_roll
    """;
```

#### Method Implementation

```java
private void generateClassReport() {
    String subject = (String) classReportSubjectComboBox.getSelectedItem();
    Date from = (Date) classReportFromDate.getValue();
    Date to = (Date) classReportToDate.getValue();

    if (subject == null) {
        JOptionPane.showMessageDialog(this, "Please select a subject.");
        return;
    }

    classReportTableModel.setRowCount(0);

    try (Connection c = DatabaseManager.getConnection();
         PreparedStatement ps = c.prepareStatement(sql)) {
        ps.setString(1, subject);
        ps.setDate(2, new java.sql.Date(from.getTime()));
        ps.setDate(3, new java.sql.Date(to.getTime()));
        
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                classReportTableModel.addRow(new Object[]{
                    rs.getString("student_roll"),
                    rs.getString("student_name"),
                    rs.getInt("total_classes"),
                    rs.getInt("classes_attended"),
                    rs.getInt("classes_missed"),
                    String.format("%.2f%%", rs.getDouble("attendance_percentage"))
                });
            }
        }
    } catch (SQLException ex) {
        showError("Generating class report", ex);
    }
}
```

## Database Tables Used

### 1. students
```sql
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    student_roll VARCHAR(20) NOT NULL UNIQUE,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. subjects
```sql
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. sessions
```sql
CREATE TABLE sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    session_date DATE NOT NULL,
    subject_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE KEY unique_session (session_date, subject_id)
);
```

### 4. attendance
```sql
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    session_id INT NOT NULL,
    status ENUM('Present', 'Absent') NOT NULL,
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, session_id)
);
```

## Key Database Operations

### 1. Marking Attendance
```java
String upsertAttendance = """
    INSERT INTO attendance(student_id, session_id, status)
    VALUES(?,?,?)
    ON DUPLICATE KEY UPDATE status = VALUES(status)
    """;
```

### 2. Loading Students
```java
String sql = "SELECT * FROM students ORDER BY student_id";
```

### 3. Loading Subjects
```java
String sql = "SELECT * FROM subjects ORDER BY subject_id";
```

### 4. Individual Student Report
```java
String sql = """
    SELECT s.first_name, s.last_name,
           SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
           COUNT(*) AS total_classes
    FROM attendance a
    JOIN students s  ON s.student_id = a.student_id
    JOIN sessions se ON se.session_id = a.session_id
    JOIN subjects sb ON sb.subject_id = se.subject_id
    WHERE s.student_roll = ?
      AND sb.subject_name = ?
      AND se.session_date BETWEEN ? AND ?
    GROUP BY s.student_id
    """;
```

### 5. Class-Wise Report (NEW)
See the SQL query in the "Class-Wise Attendance Implementation" section above.

## Using the Application

### Admin/Teacher Access to Class-Wise Reports

1. **Login** to the application
2. Navigate to **"Class-Wise Reports"** tab
3. **Select Subject** from dropdown (e.g., "Mathematics")
4. **Select Date Range** using the date pickers
5. **Click "Generate Class Report"** button
6. View results in table showing:
   - Roll Number
   - Student Name
   - Total Classes
   - Present Count
   - Absent Count
   - Attendance Percentage

### Report Output

The report displays data in a table format:

```
+------------+------------------+---------------+----------+---------+----------------+
| Roll No    | Student Name     | Total Classes | Present  | Absent  | Attendance %   |
+------------+------------------+---------------+----------+---------+----------------+
| STU001     | John Doe         | 5             | 5        | 0       | 100.00%        |
| STU002     | Jane Smith       | 5             | 5        | 0       | 100.00%        |
| STU003     | Mike Johnson     | 5             | 2        | 3       | 40.00%         |
+------------+------------------+---------------+----------+---------+----------------+
```

## Additional MySQL Queries

For more advanced queries, see the **QUERIES.md** file which contains:

- Query #3: Class-wise attendance summary (all subjects)
- Query #4: Class-wise attendance for specific date
- Query #5: Detailed class attendance with student names
- Query #6: Monthly class-wise attendance summary
- Plus 18+ more queries for various reporting needs

## Database Setup

To set up the complete database with sample data, run:

```bash
mysql -u root -p < database_setup.sql
```

This creates:
- All required tables
- Sample users (admin, teachers, students)
- Sample students (10 students)
- Sample subjects (8 subjects)
- Sample attendance data

## Troubleshooting Database Connection

### Error: "JDBC Driver not found"
**Solution**: Add MySQL Connector/J JAR to your classpath

### Error: "Access denied for user"
**Solution**: Check username and password in `DatabaseManager.java`

### Error: "Unknown database 'student3'"
**Solution**: Create database first:
```sql
CREATE DATABASE student3;
```

### Error: "Communications link failure"
**Solution**: Ensure MySQL server is running:
```bash
# Linux
sudo service mysql start

# Windows
# Start from Services

# macOS
brew services start mysql
```

## Files Reference

- **src/DatabaseManager.java**: Database connection management
- **src/Main.java**: Application with class-wise attendance feature
- **database_setup.sql**: Complete database schema and sample data
- **QUERIES.md**: 22+ SQL queries for various reports
- **README.md**: Complete documentation

---

For more information, see:
- [README.md](README.md) - Complete system documentation
- [QUERIES.md](QUERIES.md) - All SQL queries with examples
- [CONFIGURATION.md](CONFIGURATION.md) - Advanced database configuration
