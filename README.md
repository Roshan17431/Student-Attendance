# Student Attendance System

A comprehensive Java Swing-based student attendance management system with MySQL database backend.

## Features

- **User Management**: Support for Admin, Teacher, and Student roles
- **Student Management**: Add, update, delete, and search students
- **Teacher Management**: Manage teacher information
- **Subject Management**: Add and manage subjects
- **Class-Wise Attendance**: Track attendance for specific classes
- **Attendance Reporting**: Generate detailed attendance reports
- **Session Management**: Track multiple class sessions per day

## Recent Updates

### Fixed Issues
✅ **Fixed Class-Wise Attendance**: Added the missing `class` column to the students table, allowing proper class-based filtering of students during attendance marking.

### New Features
- Added `class` field to Student Management interface
- Students can now be assigned to specific classes (e.g., "10A", "10B", "11A", etc.)
- Teachers can be mapped to teach specific subjects to specific classes via the `teacher_subjects` table
- Attendance marking now correctly filters students based on their class assignment
- Search functionality now includes class field

## System Requirements

- Java 17 or higher
- MySQL Server 5.7 or higher
- MySQL Connector/J JDBC Driver (version 8.0.33 or higher)

## Quick Start

### 1. Database Setup

1. Install MySQL Server if not already installed
2. Update database credentials in `src/DatabaseManager.java`:
   ```java
   private static final String URL = "jdbc:mysql://localhost:3306/student4";
   private static final String USER = "root";
   private static final String PASSWORD = "your_password";
   ```

3. Run the database schema:
   ```bash
   mysql -u root -p < database_schema.sql
   ```

For detailed database setup instructions, see [DATABASE_SETUP.md](DATABASE_SETUP.md)

### 2. Compile and Run

**Option A: Using the automated script**

For Linux/macOS:
```bash
./compile_and_run.sh
```

For Windows:
```cmd
compile_and_run.bat
```

**Option B: Manual compilation**

1. Download MySQL JDBC Driver:
   ```bash
   wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
   ```

2. Compile the project:
   - Linux/macOS:
     ```bash
     javac -cp "mysql-connector-j-8.0.33.jar:." -d out src/*.java
     ```
   - Windows:
     ```cmd
     javac -cp "mysql-connector-j-8.0.33.jar;." -d out src\*.java
     ```

3. Run the application:
   - Linux/macOS:
     ```bash
     java -cp "mysql-connector-j-8.0.33.jar:out" Main
     ```
   - Windows:
     ```cmd
     java -cp "mysql-connector-j-8.0.33.jar;out" Main
     ```

### 3. Login

Default admin credentials:
- **Username**: `admin`
- **Password**: `admin123`
- **Role**: `Admin`

## User Roles and Permissions

### Admin
- Full access to all features
- Manage students, teachers, subjects, and users
- Mark and view attendance for all classes
- Generate reports for any student

### Teacher
- Mark attendance for assigned classes
- View attendance reports
- Limited to subjects and classes assigned to them

### Student
- View their own attendance only
- Generate personal attendance reports
- Cannot mark attendance

## Database Schema

The system uses the following main tables:

1. **users** - User authentication
2. **students** - Student information (including **class** field)
3. **teachers** - Teacher information
4. **subjects** - Subject/course information
5. **teacher_subjects** - Maps teachers to subjects and classes
6. **sessions** - Class session information
7. **attendance** - Attendance records

For complete schema details, see [database_schema.sql](database_schema.sql)

## Usage Guide

### Managing Students

1. Navigate to the "Student Management" tab (Admin only)
2. Fill in all required fields:
   - First Name
   - Last Name
   - Roll Number
   - **Class** (e.g., "10A", "10B", "11A")
3. Click "Add" to create a new student
4. Select a student from the table to update or delete

### Marking Attendance

1. Navigate to the "Attendance" tab
2. Select:
   - Subject from the dropdown
   - Date using the date picker
   - Class Number (session number for that day)
3. The table will populate with students from the relevant class
4. Mark each student as "Present" or "Absent"
5. Click "Save Attendance for this Session"

### Generating Reports

1. Navigate to the "Reports" tab
2. Enter:
   - Student Roll Number
   - Subject
   - Date range (From and To dates)
3. Click "Generate Report"
4. View the attendance summary including:
   - Total classes
   - Classes present
   - Attendance percentage

## Class-Wise Attendance Feature

The system now properly supports class-wise attendance tracking:

- Each student is assigned to a specific class
- Teachers can be assigned to teach specific subjects to specific classes
- When marking attendance, only students from the teacher's assigned class are shown
- This ensures teachers only mark attendance for their own classes

### Example Workflow

1. Create a student with class "10A"
2. Create a teacher
3. Assign the teacher to teach "Mathematics" to class "10A" (via teacher_subjects table)
4. When the teacher logs in and marks attendance for Mathematics, they will only see students from class "10A"

## Troubleshooting

### "JDBC Driver not found" Error
- Download the MySQL Connector/J JAR file
- Add it to your classpath when compiling and running

### Connection Errors
- Verify MySQL is running: `sudo service mysql status`
- Check credentials in `DatabaseManager.java`
- Ensure database exists: `SHOW DATABASES;`

### Compilation Errors
- Ensure you're using Java 17 or higher
- Check that all source files are in the `src/` directory
- Verify the MySQL JDBC driver is in the classpath

## Security Notes

⚠️ **Important**: This is a development/educational project. For production use:
- Implement password hashing (BCrypt, SHA-256)
- Add input validation and SQL injection prevention
- Implement proper session management
- Add audit logging
- Use prepared statements (already implemented)

## Project Structure

```
Student-Attendance/
├── src/
│   ├── Main.java           # Main application with GUI
│   └── DatabaseManager.java # Database connection management
├── database_schema.sql      # Complete database schema
├── DATABASE_SETUP.md        # Detailed database setup guide
├── README.md               # This file
└── .gitignore             # Git ignore rules
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is for educational purposes.

## Support

For issues or questions:
1. Check the [DATABASE_SETUP.md](DATABASE_SETUP.md) guide
2. Review the troubleshooting section above
3. Check the source code comments
4. Open an issue on GitHub

## Changelog

### Version 2.0 (Current)
- ✅ Fixed class-wise attendance functionality
- ✅ Added `class` field to students table and UI
- ✅ Created comprehensive database schema with all tables
- ✅ Added teacher-subject-class mapping
- ✅ Improved student search to include class field
- ✅ Created detailed documentation

### Version 1.0
- Initial release with basic attendance tracking
