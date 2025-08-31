import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Main extends JFrame {

    private JTabbedPane tabbedPane;
    private JPanel studentPanel, attendancePanel, reportPanel;

    // Student Management Components
    private JTextField studentNameField, studentRollField, searchField;
    private JTable studentTable;
    private JButton addStudentBtn, updateStudentBtn, deleteStudentBtn, searchStudentBtn, refreshStudentBtn;

    // Attendance Management Components
    private JTable attendanceTable;
    private JButton markAttendanceBtn;
    private JCheckBox[] attendanceCheckBoxes;

    // Attendance Reporting Components
    private JTextField reportStudentIdField;
    private JTextArea reportArea;
    private JButton generateReportBtn;

    public Main() {
        setTitle("Student Attendance System");
        setSize(800, 600);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        tabbedPane = new JTabbedPane();

        // Initialize panels and components
        studentPanel = createStudentPanel();
        attendancePanel = createAttendancePanel();
        reportPanel = createReportPanel();

        tabbedPane.addTab("Student Management", studentPanel);
        tabbedPane.addTab("Attendance", attendancePanel);
        tabbedPane.addTab("Attendance Reporting", reportPanel);

        add(tabbedPane);
        setVisible(true);

        loadStudents();
        populateAttendanceTable();
    }

    private JPanel createStudentPanel() {
        JPanel panel = new JPanel(new BorderLayout());

        // Form
        JPanel formPanel = new JPanel(new GridLayout(4, 2, 10, 10));
        studentNameField = new JTextField();
        studentRollField = new JTextField();
        addStudentBtn = new JButton("Add Student");
        updateStudentBtn = new JButton("Update Student");
        deleteStudentBtn = new JButton("Delete Student");

        formPanel.add(new JLabel("Student Name:"));
        formPanel.add(studentNameField);
        formPanel.add(new JLabel("Student Roll:"));
        formPanel.add(studentRollField);
        formPanel.add(addStudentBtn);
        formPanel.add(updateStudentBtn);
        formPanel.add(deleteStudentBtn);

        addStudentBtn.addActionListener(e -> addStudent());

        panel.add(formPanel, BorderLayout.NORTH);

        return panel;
    }

    private JPanel createAttendancePanel() {
        JPanel panel = new JPanel(new BorderLayout());
        markAttendanceBtn = new JButton("Mark Attendance for Today");

        // This table will be populated dynamically
        attendanceTable = new JTable();
        JScrollPane scrollPane = new JScrollPane(attendanceTable);

        markAttendanceBtn.addActionListener(e -> markAttendance());

        panel.add(scrollPane, BorderLayout.CENTER);
        panel.add(markAttendanceBtn, BorderLayout.SOUTH);

        return panel;
    }

    private JPanel createReportPanel() {
        JPanel panel = new JPanel(new BorderLayout());

        // Form
        JPanel formPanel = new JPanel(new FlowLayout());
        reportStudentIdField = new JTextField(15);
        generateReportBtn = new JButton("Generate Report");
        formPanel.add(new JLabel("Enter Student ID:"));
        formPanel.add(reportStudentIdField);
        formPanel.add(generateReportBtn);

        reportArea = new JTextArea();
        reportArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(reportArea);

        generateReportBtn.addActionListener(e -> generateReport());

        panel.add(formPanel, BorderLayout.NORTH);
        panel.add(scrollPane, BorderLayout.CENTER);

        return panel;
    }

    // --- Student Management Logic ---
    private void addStudent() {
        String name = studentNameField.getText();
        String roll = studentRollField.getText();

        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                     "INSERT INTO students (first_name, student_roll) VALUES (?, ?)"
             )) {
            pstmt.setString(1, name);
            pstmt.setString(2, roll);
            pstmt.executeUpdate();
            JOptionPane.showMessageDialog(this, "Student added successfully!");
            loadStudents();
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(this, "Error: " + ex.getMessage());
        }
    }

    private void loadStudents() {
        // Method to load students into the studentTable
    }

    // --- Attendance Management Logic ---
    private void populateAttendanceTable() {
        // Method to populate a table with all students to mark attendance
    }

    private void markAttendance() {
        // Method to save attendance status to the database
    }

    // --- Attendance Reporting Logic ---
    private void generateReport() {
        // Method to get attendance history and percentage from the database
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new Main());
    }
}