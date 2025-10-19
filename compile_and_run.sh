#!/bin/bash

# Student Attendance System - Compile and Run Script

echo "===================================="
echo "Student Attendance System"
echo "===================================="
echo ""

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Error: Java is not installed or not in PATH"
    echo "Please install Java 17 or higher"
    exit 1
fi

if ! command -v javac &> /dev/null; then
    echo "❌ Error: javac is not installed or not in PATH"
    echo "Please install JDK 17 or higher"
    exit 1
fi

echo "✅ Java version:"
java -version
echo ""

# Check if MySQL connector exists
MYSQL_JAR="mysql-connector-j-8.0.33.jar"

if [ ! -f "$MYSQL_JAR" ]; then
    echo "📥 MySQL JDBC Driver not found. Downloading..."
    wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar
    if [ $? -ne 0 ]; then
        echo "❌ Failed to download MySQL JDBC Driver"
        exit 1
    fi
    echo "✅ MySQL JDBC Driver downloaded"
else
    echo "✅ MySQL JDBC Driver found"
fi
echo ""

# Create output directory
mkdir -p out

# Compile
echo "🔨 Compiling Java files..."
javac -cp "$MYSQL_JAR:." -d out src/*.java

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed"
    exit 1
fi

echo "✅ Compilation successful"
echo ""

# Run
echo "🚀 Starting Student Attendance System..."
echo "   Default login: username=admin, password=admin123, role=Admin"
echo ""
java -cp "$MYSQL_JAR:out" Main

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Application exited with an error"
    echo ""
    echo "Common issues:"
    echo "1. MySQL server is not running"
    echo "2. Database 'student4' does not exist - run: mysql -u root -p < database_schema.sql"
    echo "3. Database credentials in src/DatabaseManager.java are incorrect"
    exit 1
fi
