# Quick Start Guide - Student Attendance Management System

This guide will help you get the Student Attendance Management System up and running in just a few minutes.

## Prerequisites Checklist

Before you begin, ensure you have:

- [ ] Java JDK 8 or higher installed
- [ ] MySQL Server installed and running
- [ ] MySQL JDBC Driver (mysql-connector-j-8.x.x.jar)
- [ ] Git (to clone the repository)

## Quick Setup (5 Steps)

### Step 1: Clone the Repository

```bash
git clone https://github.com/Roshan17431/Student-Attendance.git
cd Student-Attendance
```

### Step 2: Setup the Database

**Option A: Using the SQL Script (Recommended)**

```bash
# Login to MySQL
mysql -u root -p

# Inside MySQL, run:
source database_setup.sql
# Or on Windows:
\. database_setup.sql

# Exit MySQL
exit
```

**Option B: Manual Setup**

1. Open `database_setup.sql` in any text editor
2. Copy all the SQL commands
3. Paste and execute in MySQL Workbench or your MySQL client

### Step 3: Configure Database Connection

Edit `src/DatabaseManager.java`:

```java
private static final String URL = "jdbc:mysql://localhost:3306/student3";
private static final String USER = "root";           // Your MySQL username
private static final String PASSWORD = "your_password";  // Your MySQL password
```

### Step 4: Add MySQL JDBC Driver

Download the driver from [MySQL Downloads](https://dev.mysql.com/downloads/connector/j/) and add it to your project.

**For IntelliJ IDEA:**
1. File → Project Structure → Libraries
2. Click '+' → Java → Select the JAR file
3. Apply and OK

**For Eclipse:**
1. Right-click project → Build Path → Configure Build Path
2. Libraries → Add External JARs → Select the JAR file
3. Apply and Close

**For Command Line:**
- Place the JAR file in your project directory

### Step 5: Run the Application

**Using IDE:**
- Click the Run button or press Shift+F10 (IntelliJ) / Ctrl+F11 (Eclipse)

**Using Command Line:**

```bash
# Compile
javac -cp ".:mysql-connector-j-8.0.33.jar" src/*.java

# Run
java -cp ".:mysql-connector-j-8.0.33.jar:src" Main

# On Windows, use semicolon (;) instead of colon (:)
javac -cp ".;mysql-connector-j-8.0.33.jar" src\*.java
java -cp ".;mysql-connector-j-8.0.33.jar;src" Main
```

## Default Login Credentials

After setup, login with these default credentials:

| Role | Username | Password |
|------|----------|----------|
| **Admin** | admin | admin123 |
| **Teacher** | teacher1 | teacher123 |
| **Student** | student1 | student123 |

## First Steps After Login

### As Admin:
1. Go to **Student Management** → Add your students
2. Go to **Subject Management** → Add your subjects
3. Go to **Teacher Management** → Add your teachers
4. Go to **User Management** → Create user accounts
5. Go to **Attendance** → Start marking attendance

### As Teacher:
1. Go to **Attendance** tab
2. Select a subject and date
3. Mark students as Present or Absent
4. Click "Save Attendance"

### As Student:
1. Go to **My Attendance** tab
2. Select subject and date range
3. Click "Generate Report" to view your attendance

## Verify Installation

To verify everything is working correctly:

1. **Login as admin** with credentials: `admin` / `admin123`
2. **Check Student Management** - You should see sample students (STU001-STU010)
3. **Check Subjects** - You should see 8 subjects (Mathematics, Physics, etc.)
4. **Check Reports** - Generate a report for student roll "STU001" for Mathematics

## Sample Data

The database setup script includes:
- ✅ 6 sample users (1 admin, 2 teachers, 3 students)
- ✅ 10 sample students
- ✅ 4 sample teachers
- ✅ 8 sample subjects
- ✅ Multiple class sessions with attendance records

## Using Class-Wise Attendance Queries

For advanced reporting and analytics, refer to `QUERIES.md` which contains 22+ SQL queries for:
- Class-wise attendance summaries
- Student performance reports
- Subject-wise statistics
- Date range analysis
- Defaulter lists and more

**Example: Get today's class attendance**

```sql
SELECT 
    sub.subject_name,
    COUNT(*) AS total_students,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present,
    ROUND(
        (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS attendance_percentage
FROM attendance a
JOIN sessions ses ON a.session_id = ses.session_id
JOIN subjects sub ON ses.subject_id = sub.subject_id
WHERE ses.session_date = CURDATE()
GROUP BY sub.subject_name;
```

## Troubleshooting

### "JDBC Driver not found"
**Solution:** Make sure the MySQL Connector JAR is added to your classpath

### "Access denied for user"
**Solution:** Check your MySQL credentials in `DatabaseManager.java`

### "Communications link failure"
**Solution:** Ensure MySQL server is running:
- Linux: `sudo service mysql start`
- Windows: Check Services → MySQL
- macOS: `brew services start mysql`

### "Unknown database 'student3'"
**Solution:** Run the `database_setup.sql` script to create the database

## Next Steps

- Read the full [README.md](README.md) for comprehensive documentation
- Explore [QUERIES.md](QUERIES.md) for all SQL queries
- Customize the application for your institution's needs
- Change default passwords for security

## Getting Help

- **Documentation**: Check README.md for detailed information
- **SQL Queries**: Refer to QUERIES.md for database queries
- **Issues**: Report problems on GitHub Issues
- **Database Schema**: See database_setup.sql for complete schema

## Security Notes

⚠️ **Important for Production Use:**

1. **Change all default passwords** immediately
2. **Use password hashing** (BCrypt, SHA-256) instead of plain text
3. **Enable MySQL SSL** connections
4. **Restrict database user permissions**
5. **Regular backups**: `mysqldump -u root -p student3 > backup.sql`

## Key Features Overview

✅ **Role-Based Access Control** - Admin, Teacher, Student roles
✅ **Student Management** - CRUD operations for students
✅ **Teacher Management** - Manage teacher records
✅ **Subject Management** - Add/remove subjects
✅ **Attendance Tracking** - Mark daily attendance
✅ **Comprehensive Reports** - View attendance statistics
✅ **Search & Filter** - Easy data retrieval
✅ **User Management** - Create and manage user accounts

## System Requirements

**Minimum:**
- Java JDK 8+
- MySQL 5.7+
- 2GB RAM
- 500MB disk space

**Recommended:**
- Java JDK 11+
- MySQL 8.0+
- 4GB RAM
- 1GB disk space

## Quick Commands Reference

```bash
# Check Java version
java -version

# Check MySQL status
sudo service mysql status       # Linux
mysql.server status             # macOS

# Connect to MySQL
mysql -u root -p

# Create database backup
mysqldump -u root -p student3 > backup_$(date +%Y%m%d).sql

# Restore database
mysql -u root -p student3 < backup.sql
```

## Success!

If you've completed all steps and can login successfully, you're ready to use the Student Attendance Management System! 🎉

For detailed usage instructions, advanced queries, and configuration options, refer to:
- **README.md** - Complete documentation
- **QUERIES.md** - SQL queries for reporting
- **database_setup.sql** - Database schema reference

---

**Happy Tracking! 📚✅**
