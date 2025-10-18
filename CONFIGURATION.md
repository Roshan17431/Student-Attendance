# Configuration Guide

This guide covers different configuration scenarios for the Student Attendance Management System.

## Table of Contents
1. [Database Configuration](#database-configuration)
2. [Custom Database Names](#custom-database-names)
3. [Remote MySQL Server](#remote-mysql-server)
4. [Different MySQL Versions](#different-mysql-versions)
5. [Port Configuration](#port-configuration)
6. [SSL Configuration](#ssl-configuration)
7. [Production Deployment](#production-deployment)

---

## Database Configuration

### Standard Configuration

Edit `src/DatabaseManager.java`:

```java
public class DatabaseManager {
    private static final String URL = "jdbc:mysql://localhost:3306/student3";
    private static final String USER = "root";
    private static final String PASSWORD = "your_password";

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

---

## Custom Database Names

If you want to use a different database name:

### Step 1: Create Database with Custom Name

```sql
CREATE DATABASE my_attendance_system;
USE my_attendance_system;
-- Then run all table creation scripts from database_setup.sql
```

### Step 2: Update DatabaseManager.java

```java
private static final String URL = "jdbc:mysql://localhost:3306/my_attendance_system";
```

---

## Remote MySQL Server

To connect to a remote MySQL server:

### Step 1: Update Connection URL

```java
private static final String URL = "jdbc:mysql://192.168.1.100:3306/student3";
// Or using domain name
private static final String URL = "jdbc:mysql://mysql.example.com:3306/student3";
```

### Step 2: Configure MySQL Server for Remote Access

On the MySQL server:

```bash
# Edit MySQL configuration
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

# Change bind-address
bind-address = 0.0.0.0  # Allow connections from any IP
# Or specify your server's IP
bind-address = 192.168.1.100

# Restart MySQL
sudo service mysql restart
```

### Step 3: Grant Remote Access

```sql
-- Create user with remote access
CREATE USER 'attendance_user'@'%' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON student3.* TO 'attendance_user'@'%';
FLUSH PRIVILEGES;

-- Or for specific IP only
CREATE USER 'attendance_user'@'192.168.1.50' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON student3.* TO 'attendance_user'@'192.168.1.50';
FLUSH PRIVILEGES;
```

### Step 4: Update Application Configuration

```java
private static final String USER = "attendance_user";
private static final String PASSWORD = "secure_password";
```

---

## Different MySQL Versions

### MySQL 8.0+ Configuration

For MySQL 8.0 and above (default configuration):

```java
private static final String URL = "jdbc:mysql://localhost:3306/student3?useSSL=false&serverTimezone=UTC";
```

### MySQL 5.7 Configuration

For MySQL 5.7:

```java
private static final String URL = "jdbc:mysql://localhost:3306/student3?useSSL=false";
```

### MySQL 5.6 and Earlier

For older versions:

```java
private static final String URL = "jdbc:mysql://localhost:3306/student3";
```

**JDBC Driver Compatibility:**
- MySQL 8.0+ → mysql-connector-j-8.x.x.jar
- MySQL 5.7 → mysql-connector-java-5.1.49.jar or newer
- MySQL 5.6 → mysql-connector-java-5.1.49.jar

---

## Port Configuration

### Custom MySQL Port

If MySQL is running on a non-standard port:

```java
// Example: MySQL on port 3307
private static final String URL = "jdbc:mysql://localhost:3307/student3";
```

### Check Current MySQL Port

```bash
# Linux/macOS
mysql -u root -p -e "SHOW VARIABLES LIKE 'port';"

# Or check in MySQL
mysql -u root -p
mysql> SHOW VARIABLES LIKE 'port';
```

---

## SSL Configuration

### Enable SSL Connection

For secure connections (recommended for production):

```java
private static final String URL = "jdbc:mysql://localhost:3306/student3" +
    "?useSSL=true" +
    "&requireSSL=true" +
    "&verifyServerCertificate=true";
```

### With Custom Keystore

```java
private static final String URL = "jdbc:mysql://localhost:3306/student3" +
    "?useSSL=true" +
    "&requireSSL=true" +
    "&clientCertificateKeyStoreUrl=file:///path/to/keystore.jks" +
    "&clientCertificateKeyStorePassword=password" +
    "&trustCertificateKeyStoreUrl=file:///path/to/truststore.jks" +
    "&trustCertificateKeyStorePassword=password";
```

### Setup MySQL SSL

```sql
-- Check if SSL is enabled
SHOW VARIABLES LIKE '%ssl%';

-- Require SSL for specific user
ALTER USER 'attendance_user'@'%' REQUIRE SSL;
```

---

## Production Deployment

### Recommended Production Configuration

```java
public class DatabaseManager {
    // Use environment variables for security
    private static final String URL = System.getenv("DB_URL") != null 
        ? System.getenv("DB_URL") 
        : "jdbc:mysql://localhost:3306/student3?useSSL=true&serverTimezone=UTC";
    
    private static final String USER = System.getenv("DB_USER") != null 
        ? System.getenv("DB_USER") 
        : "root";
    
    private static final String PASSWORD = System.getenv("DB_PASSWORD") != null 
        ? System.getenv("DB_PASSWORD") 
        : "";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("JDBC Driver not found.");
            e.printStackTrace();
            throw new SQLException("JDBC Driver not found", e);
        }
        
        // Connection with timeout settings
        Properties props = new Properties();
        props.setProperty("user", USER);
        props.setProperty("password", PASSWORD);
        props.setProperty("connectTimeout", "10000"); // 10 seconds
        props.setProperty("socketTimeout", "30000");   // 30 seconds
        props.setProperty("useSSL", "true");
        props.setProperty("requireSSL", "true");
        
        return DriverManager.getConnection(URL, props);
    }
}
```

### Set Environment Variables

**Linux/macOS:**

```bash
# Add to ~/.bashrc or ~/.bash_profile
export DB_URL="jdbc:mysql://production-server:3306/student3?useSSL=true&serverTimezone=UTC"
export DB_USER="attendance_user"
export DB_PASSWORD="secure_production_password"

# Apply changes
source ~/.bashrc
```

**Windows:**

```cmd
# Set environment variables
setx DB_URL "jdbc:mysql://production-server:3306/student3?useSSL=true&serverTimezone=UTC"
setx DB_USER "attendance_user"
setx DB_PASSWORD "secure_production_password"
```

### Production Database User

Create a dedicated user with limited privileges:

```sql
-- Create production user
CREATE USER 'attendance_app'@'app-server-ip' IDENTIFIED BY 'strong_random_password';

-- Grant only necessary privileges
GRANT SELECT, INSERT, UPDATE ON student3.* TO 'attendance_app'@'app-server-ip';
GRANT DELETE ON student3.attendance TO 'attendance_app'@'app-server-ip';
GRANT DELETE ON student3.sessions TO 'attendance_app'@'app-server-ip';

FLUSH PRIVILEGES;
```

### Connection Pooling (Advanced)

For better performance with multiple concurrent users, implement connection pooling:

**Add HikariCP dependency** (if using Maven):

```xml
<dependency>
    <groupId>com.zaxxer</groupId>
    <artifactId>HikariCP</artifactId>
    <version>5.0.1</version>
</dependency>
```

**Update DatabaseManager.java:**

```java
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DatabaseManager {
    private static HikariDataSource dataSource;

    static {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:mysql://localhost:3306/student3");
        config.setUsername("root");
        config.setPassword("password");
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(2);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        
        dataSource = new HikariDataSource(config);
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
    
    public static void closeDataSource() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}
```

---

## Timezone Configuration

### Set Timezone in Connection URL

```java
// UTC (Recommended for consistency)
private static final String URL = "jdbc:mysql://localhost:3306/student3?serverTimezone=UTC";

// Or specific timezone
private static final String URL = "jdbc:mysql://localhost:3306/student3?serverTimezone=Asia/Kolkata";
private static final String URL = "jdbc:mysql://localhost:3306/student3?serverTimezone=America/New_York";
```

### MySQL Server Timezone

```sql
-- Check current timezone
SELECT @@global.time_zone, @@session.time_zone;

-- Set timezone
SET GLOBAL time_zone = '+05:30';  -- For IST
SET GLOBAL time_zone = 'UTC';      -- For UTC
```

---

## Advanced Connection Parameters

### Full URL with All Options

```java
private static final String URL = "jdbc:mysql://localhost:3306/student3" +
    "?useSSL=true" +                          // Enable SSL
    "&serverTimezone=UTC" +                    // Set timezone
    "&characterEncoding=utf8mb4" +            // Character encoding
    "&useUnicode=true" +                      // Enable Unicode
    "&autoReconnect=true" +                   // Auto reconnect on connection loss
    "&maxReconnects=3" +                      // Max reconnection attempts
    "&cachePrepStmts=true" +                  // Cache prepared statements
    "&prepStmtCacheSize=250" +               // Cache size
    "&prepStmtCacheSqlLimit=2048" +          // SQL limit for caching
    "&useServerPrepStmts=true" +             // Use server-side prepared statements
    "&rewriteBatchedStatements=true" +       // Optimize batch operations
    "&connectTimeout=10000" +                 // Connection timeout (ms)
    "&socketTimeout=30000";                   // Socket timeout (ms)
```

---

## Configuration File Approach

### Create config.properties

Create a file `config.properties` in the project root:

```properties
# Database Configuration
db.url=jdbc:mysql://localhost:3306/student3
db.username=root
db.password=your_password
db.driver=com.mysql.cj.jdbc.Driver

# Connection Pool Settings
db.pool.maxSize=10
db.pool.minSize=2
db.pool.timeout=30000

# SSL Settings
db.ssl.enabled=false
db.ssl.requireSSL=false
```

### Load Configuration in Java

```java
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class DatabaseManager {
    private static Properties config = new Properties();
    
    static {
        try (FileInputStream fis = new FileInputStream("config.properties")) {
            config.load(fis);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    private static final String URL = config.getProperty("db.url");
    private static final String USER = config.getProperty("db.username");
    private static final String PASSWORD = config.getProperty("db.password");
    
    // ... rest of the code
}
```

---

## Testing Configurations

### Test Database Connection

Create a simple test class:

```java
public class TestConnection {
    public static void main(String[] args) {
        try (Connection conn = DatabaseManager.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("✅ Database connection successful!");
                System.out.println("Database: " + conn.getCatalog());
                System.out.println("Driver: " + conn.getMetaData().getDriverName());
                System.out.println("Version: " + conn.getMetaData().getDriverVersion());
            }
        } catch (SQLException e) {
            System.err.println("❌ Database connection failed!");
            e.printStackTrace();
        }
    }
}
```

### Verify Tables

```java
public class VerifyTables {
    public static void main(String[] args) {
        try (Connection conn = DatabaseManager.getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet rs = meta.getTables(null, null, "%", new String[]{"TABLE"});
            
            System.out.println("Tables in database:");
            while (rs.next()) {
                System.out.println("- " + rs.getString("TABLE_NAME"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

---

## Troubleshooting Connection Issues

### Common Connection String Issues

```java
// ❌ Wrong - missing protocol
"mysql://localhost:3306/student3"

// ✅ Correct
"jdbc:mysql://localhost:3306/student3"

// ❌ Wrong - double slashes
"jdbc:mysql:///localhost:3306/student3"

// ✅ Correct
"jdbc:mysql://localhost:3306/student3"
```

### Debug Connection Issues

Add debug logging:

```java
public static Connection getConnection() throws SQLException {
    System.out.println("Attempting connection to: " + URL);
    System.out.println("User: " + USER);
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        System.out.println("JDBC Driver loaded successfully");
    } catch (ClassNotFoundException e) {
        System.err.println("JDBC Driver not found.");
        e.printStackTrace();
        throw new SQLException("Driver not found", e);
    }
    
    Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
    System.out.println("✅ Connection established!");
    return conn;
}
```

---

## Summary

Choose the appropriate configuration based on your deployment:

- **Development**: Use localhost with simple configuration
- **Testing**: Use separate test database
- **Production**: Use environment variables, SSL, connection pooling, and dedicated user

For additional security and performance considerations, refer to the main README.md documentation.
