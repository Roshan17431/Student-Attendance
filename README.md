# Student Attendance Management System

A comprehensive Java Swing-based desktop application for managing student attendance with MySQL database support. This system provides role-based access control for Admins, Teachers, and Students with features for tracking class-wise attendance, generating reports, and managing users.

## Features

### Admin Features
- **Student Management**: Add, update, delete, and search students
- **Teacher Management**: Manage teacher records
- **Subject Management**: Add and remove subjects
- **User Management**: Create and manage user accounts with different roles
- **Attendance Tracking**: Mark and monitor attendance for all classes
- **Attendance Reports**: Generate comprehensive attendance reports
- **Class-Wise Attendance Reports**: View attendance for entire class/subject showing all students at once

### Teacher Features
- **Attendance Marking**: Mark attendance for students in their classes
- **Attendance Reports**: View and generate student attendance reports
- **Class-Wise Attendance Reports**: View attendance for entire class/subject showing all students at once

### Student Features
- **View Attendance**: Students can view their own attendance records
- **Attendance Reports**: Generate personal attendance reports by subject and date range

## Prerequisites

- Java Development Kit (JDK) 8 or higher
- MySQL Server 5.7 or higher
- MySQL JDBC Driver (Connector/J)
- IDE (IntelliJ IDEA, Eclipse, or NetBeans) - Optional but recommended

## Database Setup

### Step 1: Install MySQL

**Windows:**
1. Download MySQL Installer from [MySQL Official Website](https://dev.mysql.com/downloads/installer/)
2. Run the installer and select "Developer Default"
3. Follow the installation wizard
4. Set a root password during installation

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation
```

**macOS:**
```bash
brew install mysql
brew services start mysql
mysql_secure_installation
```

### Step 2: Create Database and Tables

1. Login to MySQL:
```bash
mysql -u root -p
```

2. Create the database:
```sql
CREATE DATABASE student3;
USE student3;
```

3. Create all required tables:
```sql
-- Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('Admin', 'Teacher', 'Student') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Students Table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    student_roll VARCHAR(20) NOT NULL UNIQUE,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Teachers Table
CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Subjects Table
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sessions Table (represents a class/lecture on a specific date for a subject)
CREATE TABLE sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    session_date DATE NOT NULL,
    subject_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE KEY unique_session (session_date, subject_id)
);

-- Attendance Table
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

4. Insert sample data for testing:
```sql
-- Create admin user
INSERT INTO users (username, password, role) 
VALUES ('admin', 'admin123', 'Admin');

-- Create teacher user
INSERT INTO users (username, password, role) 
VALUES ('teacher1', 'teacher123', 'Teacher');

-- Create student users
INSERT INTO users (username, password, role) 
VALUES ('student1', 'student123', 'Student');

-- Add sample subjects
INSERT INTO subjects (subject_name) VALUES 
    ('Mathematics'),
    ('Physics'),
    ('Chemistry'),
    ('Computer Science'),
    ('English');

-- Add sample students
INSERT INTO students (first_name, last_name, student_roll, user_id) VALUES
    ('John', 'Doe', 'STU001', 3),
    ('Jane', 'Smith', 'STU002', NULL),
    ('Mike', 'Johnson', 'STU003', NULL),
    ('Sarah', 'Williams', 'STU004', NULL);

-- Add sample teacher
INSERT INTO teachers (first_name, last_name, email, user_id) VALUES
    ('Robert', 'Brown', 'robert.brown@school.com', 2);
```

## Application Setup

### Step 1: Download/Clone the Project

```bash
git clone https://github.com/Roshan17431/Student-Attendance.git
cd Student-Attendance
```

### Step 2: Configure Database Connection

Edit `src/DatabaseManager.java` and update the database credentials:

```java
private static final String URL = "jdbc:mysql://localhost:3306/student3";
private static final String USER = "root";  // Change to your MySQL username
private static final String PASSWORD = "your_password";  // Change to your MySQL password
```

### Step 3: Add MySQL JDBC Driver

**Option 1: Using IDE (IntelliJ IDEA)**
1. Go to File → Project Structure → Libraries
2. Click the '+' button → Java
3. Navigate to and select `mysql-connector-j-8.x.x.jar`
4. Click Apply and OK

**Option 2: Using IDE (Eclipse)**
1. Right-click project → Build Path → Configure Build Path
2. Go to Libraries tab → Add External JARs
3. Select `mysql-connector-j-8.x.x.jar`
4. Click Apply and Close

**Option 3: Manual Download**
1. Download MySQL Connector/J from [MySQL Website](https://dev.mysql.com/downloads/connector/j/)
2. Extract the downloaded archive
3. Add the JAR file to your project's classpath

### Step 4: Compile the Project

**Using Command Line:**
```bash
# Compile with JDBC driver in classpath
javac -cp ".:mysql-connector-j-8.0.33.jar" src/*.java

# On Windows, use semicolon instead of colon
javac -cp ".;mysql-connector-j-8.0.33.jar" src/*.java
```

**Using IDE:**
- Simply click the "Build" or "Run" button in your IDE

### Step 5: Run the Application

**Using Command Line:**
```bash
# Run with JDBC driver in classpath
java -cp ".:mysql-connector-j-8.0.33.jar:src" Main

# On Windows
java -cp ".;mysql-connector-j-8.0.33.jar;src" Main
```

**Using IDE:**
- Click "Run" button or press Shift+F10 (IntelliJ) / Ctrl+F11 (Eclipse)

## Default Login Credentials

After setting up the database with sample data, you can use these credentials:

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | admin123 |
| Teacher | teacher1 | teacher123 |
| Student | student1 | student123 |

⚠️ **Security Note**: Change these default passwords in production!

## How to Use

### For Admins

1. **Login** with admin credentials
2. **Manage Students**: 
   - Navigate to "Student Management" tab
   - Add new students with First Name, Last Name, and Roll Number
   - Edit or delete existing students
   - Search students by name or roll number
3. **Manage Teachers**: Add, edit, or delete teacher records
4. **Manage Subjects**: Add or remove subjects
5. **Manage Users**: Create user accounts for students and teachers
6. **Mark Attendance**: 
   - Go to "Attendance" tab
   - Select subject and date
   - Mark students as Present or Absent
   - Click "Save Attendance"
7. **Generate Reports**: View attendance statistics by student, subject, and date range
8. **Class-Wise Reports**: 
   - Go to "Class-Wise Reports" tab
   - Select subject and date range
   - Click "Generate Class Report"
   - View attendance for all students in that class/subject with statistics

### For Teachers

1. **Login** with teacher credentials
2. **Mark Attendance**: 
   - Select subject and date
   - Mark students as Present or Absent
   - Save the attendance
3. **View Reports**: Generate attendance reports for students
4. **Class-Wise Reports**: 
   - Go to "Class-Wise Reports" tab
   - Select subject and date range
   - View attendance for all students in that class/subject

### For Students

1. **Login** with student credentials
2. **View Attendance**: See your attendance records
3. **Generate Reports**: View your attendance percentage by subject and date range

## Class-Wise Attendance Queries

For detailed SQL queries to retrieve class-wise attendance data, see [QUERIES.md](QUERIES.md)

## Troubleshooting

### Common Issues

**Issue 1: "JDBC Driver not found"**
- **Solution**: Ensure MySQL Connector/J JAR is added to your project classpath
- Download from: https://dev.mysql.com/downloads/connector/j/

**Issue 2: "Access denied for user 'root'@'localhost'"**
- **Solution**: Check your MySQL username and password in `DatabaseManager.java`
- Verify you can login to MySQL using the same credentials

**Issue 3: "Unknown database 'student3'"**
- **Solution**: Create the database using: `CREATE DATABASE student3;`
- Run all table creation scripts

**Issue 4: "Communications link failure"**
- **Solution**: Ensure MySQL server is running
  - Linux: `sudo service mysql start`
  - Windows: Start from Services
  - macOS: `brew services start mysql`

**Issue 5: Application window doesn't appear**
- **Solution**: Check Java version compatibility: `java -version`
- Ensure JDK 8 or higher is installed

## Database Maintenance

### Backup Database
```bash
mysqldump -u root -p student3 > student_attendance_backup.sql
```

### Restore Database
```bash
mysql -u root -p student3 < student_attendance_backup.sql
```

### Reset Database
```bash
mysql -u root -p
DROP DATABASE student3;
CREATE DATABASE student3;
# Then run all table creation scripts again
```

## Security Recommendations

For production use, implement these security measures:

1. **Password Hashing**: Use BCrypt or similar to hash passwords
2. **Input Validation**: Add validation to prevent SQL injection
3. **Environment Variables**: Store database credentials in environment variables
4. **SSL Connection**: Enable SSL for database connections
5. **Role-Based Permissions**: Implement fine-grained permissions at database level
6. **Audit Logging**: Add logs for critical operations

## Project Structure

```
Student-Attendance/
├── src/
│   ├── Main.java              # Main application with GUI
│   └── DatabaseManager.java   # Database connection manager
├── README.md                   # This file
├── QUERIES.md                  # SQL queries for class-wise attendance
├── .gitignore
└── Student attendance.iml      # IntelliJ project file
```

## Technology Stack

- **Language**: Java
- **GUI Framework**: Java Swing
- **Database**: MySQL
- **JDBC Driver**: MySQL Connector/J

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is for educational purposes. Feel free to use and modify as needed.

## Support

For issues or questions:
- Create an issue on GitHub
- Check the troubleshooting section above
- Review the QUERIES.md file for database-related questions

## Future Enhancements

- Export reports to PDF/Excel
- Email notifications for low attendance
- Mobile app integration
- Cloud database support
- Biometric attendance integration
- Class schedule management
- Multi-class/section support

---

**Note**: This is a learning project. For production use, implement proper security measures and follow best practices for enterprise applications.
