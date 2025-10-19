@echo off
REM Student Attendance System - Compile and Run Script for Windows

echo ====================================
echo Student Attendance System
echo ====================================
echo.

REM Check if Java is installed
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Java is not installed or not in PATH
    echo Please install Java 17 or higher
    pause
    exit /b 1
)

where javac >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: javac is not installed or not in PATH
    echo Please install JDK 17 or higher
    pause
    exit /b 1
)

echo Java version:
java -version
echo.

REM Check if MySQL connector exists
set MYSQL_JAR=mysql-connector-j-8.0.33.jar

if not exist "%MYSQL_JAR%" (
    echo MySQL JDBC Driver not found.
    echo Please download from: https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
    echo and place it in the project root directory.
    pause
    exit /b 1
)
echo MySQL JDBC Driver found
echo.

REM Create output directory
if not exist "out" mkdir out

REM Compile
echo Compiling Java files...
javac -cp "%MYSQL_JAR%;." -d out src\*.java

if %ERRORLEVEL% NEQ 0 (
    echo Compilation failed
    pause
    exit /b 1
)

echo Compilation successful
echo.

REM Run
echo Starting Student Attendance System...
echo    Default login: username=admin, password=admin123, role=Admin
echo.
java -cp "%MYSQL_JAR%;out" Main

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Application exited with an error
    echo.
    echo Common issues:
    echo 1. MySQL server is not running
    echo 2. Database 'student4' does not exist - run the database_schema.sql file
    echo 3. Database credentials in src\DatabaseManager.java are incorrect
    pause
    exit /b 1
)
