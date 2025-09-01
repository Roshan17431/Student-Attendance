import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;

public class Main extends JFrame {
    private JTabbedPane tabbedPane;
    private JPanel studentPanel, attendancePanel, reportPanel;

    // --- Student Management ---
    private JTextField firstNameField, lastNameField, rollField, studentSearchField;
    private JButton addStudentBtn, updateStudentBtn, deleteStudentBtn, searchStudentBtn, refreshStudentBtn;
    private JTable studentTable;
    private DefaultTableModel studentTableModel;

    // --- Attendance Management ---
    private JComboBox<String> subjectComboBox;
    private JSpinner dateSpinner;
    private JTable attendanceTable;
    private JButton markAttendanceBtn;

    // --- Reporting ---
    private JTextField reportStudentRollField;
    private JTextArea reportArea;
    private JButton generateReportBtn;
    private JComboBox<String> reportSubjectComboBox;
    private JSpinner reportFromDate, reportToDate;

    public Main() {
        setTitle("Student Attendance System");
        setSize(1100, 720);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        tabbedPane = new JTabbedPane();
        studentPanel = createStudentPanel();
        attendancePanel = createAttendancePanel();
        reportPanel = createReportPanel();

        tabbedPane.addTab("Student Management", studentPanel);
        tabbedPane.addTab("Attendance", attendancePanel);
        tabbedPane.addTab("Attendance Reporting", reportPanel);
        add(tabbedPane);

        // Initial load
        loadSubjects();
        loadStudents();
        populateAttendanceTable();
        loadSubjectsForReports();

        // Row select -> fill form
        studentTable.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                int r = studentTable.getSelectedRow();
                if (r != -1) {
                    firstNameField.setText(studentTableModel.getValueAt(r, 1).toString());
                    lastNameField.setText(studentTableModel.getValueAt(r, 2).toString());
                    rollField.setText(studentTableModel.getValueAt(r, 3).toString());
                }
            }
        });

        tabbedPane.addChangeListener(e -> {
            if (tabbedPane.getSelectedComponent() == attendancePanel) {
                populateAttendanceTable();
            } else if (tabbedPane.getSelectedComponent() == reportPanel) {
                loadSubjectsForReports();
            }
        });

        setVisible(true);
    }

    // ----------------- Panels -----------------
    private JPanel createStudentPanel() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        JPanel form = new JPanel(new GridLayout(4, 2, 8, 8));

        firstNameField = new JTextField();
        lastNameField  = new JTextField();
        rollField      = new JTextField();

        addStudentBtn    = new JButton("Add");
        updateStudentBtn = new JButton("Update");
        deleteStudentBtn = new JButton("Delete");

        form.add(new JLabel("First Name:"));  form.add(firstNameField);
        form.add(new JLabel("Last Name:"));   form.add(lastNameField);
        form.add(new JLabel("Roll No:"));     form.add(rollField);
        form.add(addStudentBtn);              form.add(updateStudentBtn);

        JPanel south = new JPanel(new FlowLayout(FlowLayout.LEFT));
        studentSearchField = new JTextField(20);
        searchStudentBtn = new JButton("Search");
        refreshStudentBtn = new JButton("Refresh");
        south.add(new JLabel("Search (name or roll): "));
        south.add(studentSearchField);
        south.add(searchStudentBtn);
        south.add(refreshStudentBtn);
        south.add(deleteStudentBtn);

        studentTableModel = new DefaultTableModel(new String[]{"ID","First Name","Last Name","Roll No."}, 0) {
            public boolean isCellEditable(int r, int c) { return false; }
        };
        studentTable = new JTable(studentTableModel);

        addStudentBtn.addActionListener(e -> addStudent());
        updateStudentBtn.addActionListener(e -> updateStudent());
        deleteStudentBtn.addActionListener(e -> deleteStudent());
        searchStudentBtn.addActionListener(e -> searchStudent());
        refreshStudentBtn.addActionListener(e -> loadStudents());

        panel.add(form, BorderLayout.NORTH);
        panel.add(new JScrollPane(studentTable), BorderLayout.CENTER);
        panel.add(south, BorderLayout.SOUTH);
        return panel;
    }

    private JPanel createAttendancePanel() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        JPanel top = new JPanel(new FlowLayout(FlowLayout.LEFT));

        subjectComboBox = new JComboBox<>();
        dateSpinner = new JSpinner(new SpinnerDateModel(new Date(), null, null, java.util.Calendar.DAY_OF_MONTH));
        dateSpinner.setEditor(new JSpinner.DateEditor(dateSpinner, "yyyy-MM-dd"));
        markAttendanceBtn = new JButton("Save Attendance for this Session");

        top.add(new JLabel("Subject:")); top.add(subjectComboBox);
        top.add(new JLabel("Date:"));    top.add(dateSpinner);
        top.add(markAttendanceBtn);

        attendanceTable = new JTable(new DefaultTableModel(new String[]{"Student ID","First Name","Last Name","Roll No.","Status"}, 0) {
            public boolean isCellEditable(int r, int c) { return c == 4; }
        });
        JComboBox<String> statusCombo = new JComboBox<>(new String[]{"Present","Absent"});
        attendanceTable.getColumnModel().getColumn(4).setCellEditor(new DefaultCellEditor(statusCombo));

        markAttendanceBtn.addActionListener(e -> markAttendance());

        panel.add(top, BorderLayout.NORTH);
        panel.add(new JScrollPane(attendanceTable), BorderLayout.CENTER);
        return panel;
    }

    private JPanel createReportPanel() {
        JPanel panel = new JPanel(new BorderLayout(10,10));
        JPanel top = new JPanel(new FlowLayout(FlowLayout.LEFT));

        reportStudentRollField = new JTextField(12);
        reportSubjectComboBox  = new JComboBox<>();
        reportFromDate = new JSpinner(new SpinnerDateModel(new Date(), null, null, java.util.Calendar.DAY_OF_MONTH));
        reportToDate   = new JSpinner(new SpinnerDateModel(new Date(), null, null, java.util.Calendar.DAY_OF_MONTH));
        reportFromDate.setEditor(new JSpinner.DateEditor(reportFromDate, "yyyy-MM-dd"));
        reportToDate.setEditor(new JSpinner.DateEditor(reportToDate, "yyyy-MM-dd"));
        generateReportBtn = new JButton("Generate Report");

        top.add(new JLabel("Roll:"));        top.add(reportStudentRollField);
        top.add(new JLabel("Subject:"));     top.add(reportSubjectComboBox);
        top.add(new JLabel("From:"));        top.add(reportFromDate);
        top.add(new JLabel("To:"));          top.add(reportToDate);
        top.add(generateReportBtn);

        reportArea = new JTextArea(); reportArea.setEditable(false);
        generateReportBtn.addActionListener(e -> generateReport());

        panel.add(top, BorderLayout.NORTH);
        panel.add(new JScrollPane(reportArea), BorderLayout.CENTER);
        return panel;
    }

    // --------------- Student Logic ---------------
    private void loadStudents() {
        studentTableModel.setRowCount(0);
        String sql = "SELECT * FROM students ORDER BY student_id";
        try (Connection c = DatabaseManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                studentTableModel.addRow(new Object[]{
                        rs.getInt("student_id"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        rs.getString("student_roll")
                });
            }
        } catch (SQLException ex) {
            showError("Loading students", ex);
        }
    }

    private void addStudent() {
        String f = firstNameField.getText().trim();
        String l = lastNameField.getText().trim();
        String r = rollField.getText().trim();
        if (f.isEmpty() || l.isEmpty() || r.isEmpty()) {
            JOptionPane.showMessageDialog(this, "All fields are required."); return;
        }
        String sql = "INSERT INTO students(first_name,last_name,student_roll) VALUES(?,?,?)";
        try (Connection c = DatabaseManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, f); ps.setString(2, l); ps.setString(3, r);
            ps.executeUpdate();
            JOptionPane.showMessageDialog(this, "Student added.");
            firstNameField.setText(""); lastNameField.setText(""); rollField.setText("");
            loadStudents();
            populateAttendanceTable();
        } catch (SQLException ex) { showError("Adding student", ex); }
    }

    private void updateStudent() {
        int row = studentTable.getSelectedRow();
        if (row == -1) { JOptionPane.showMessageDialog(this, "Select a student."); return; }
        int id = (int) studentTableModel.getValueAt(row, 0);
        String f = firstNameField.getText().trim();
        String l = lastNameField.getText().trim();
        String r = rollField.getText().trim();
        if (f.isEmpty() || l.isEmpty() || r.isEmpty()) {
            JOptionPane.showMessageDialog(this, "All fields are required."); return;
        }
        String sql = "UPDATE students SET first_name=?, last_name=?, student_roll=? WHERE student_id=?";
        try (Connection c = DatabaseManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, f); ps.setString(2, l); ps.setString(3, r); ps.setInt(4, id);
            if (ps.executeUpdate() > 0) {
                JOptionPane.showMessageDialog(this, "Updated.");
                loadStudents(); populateAttendanceTable();
            }
        } catch (SQLException ex) { showError("Updating student", ex); }
    }

    private void deleteStudent() {
        int row = studentTable.getSelectedRow();
        if (row == -1) { JOptionPane.showMessageDialog(this, "Select a student."); return; }
        int id = (int) studentTableModel.getValueAt(row, 0);
        if (JOptionPane.showConfirmDialog(this, "Delete this student?", "Confirm",
                JOptionPane.YES_NO_OPTION) != JOptionPane.YES_OPTION) return;
        try (Connection c = DatabaseManager.getConnection();
             PreparedStatement ps = c.prepareStatement("DELETE FROM students WHERE student_id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
            JOptionPane.showMessageDialog(this, "Deleted.");
            loadStudents(); populateAttendanceTable();
        } catch (SQLException ex) { showError("Deleting student", ex); }
    }

    private void searchStudent() {
        String q = studentSearchField.getText().trim();
        if (q.isEmpty()) { loadStudents(); return; }
        studentTableModel.setRowCount(0);
        String sql = """
                SELECT * FROM students
                WHERE first_name LIKE ? OR last_name LIKE ? OR student_roll = ?
                """;
        try (Connection c = DatabaseManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, "%" + q + "%");
            ps.setString(2, "%" + q + "%");
            ps.setString(3, q);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    studentTableModel.addRow(new Object[]{
                            rs.getInt("student_id"),
                            rs.getString("first_name"),
                            rs.getString("last_name"),
                            rs.getString("student_roll")
                    });
                }
            }
        } catch (SQLException ex) { showError("Searching", ex); }
    }

    // --------------- Subjects ---------------
    private void loadSubjects() {
        subjectComboBox.removeAllItems();
        String sql = "SELECT subject_name FROM subjects ORDER BY subject_name";
        try (Connection c = DatabaseManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String sub = rs.getString("subject_name");
                subjectComboBox.addItem(sub);
            }
        } catch (SQLException ex) { showError("Loading subjects", ex); }
    }

    private void loadSubjectsForReports() {
        if (reportSubjectComboBox != null) {
            reportSubjectComboBox.removeAllItems();
            String sql = "SELECT subject_name FROM subjects ORDER BY subject_name";
            try (Connection c = DatabaseManager.getConnection();
                 PreparedStatement ps = c.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) reportSubjectComboBox.addItem(rs.getString("subject_name"));
            } catch (SQLException ex) { showError("Loading subjects (report)", ex); }
        }
    }

    // --------------- Attendance ---------------
    private void populateAttendanceTable() {
        DefaultTableModel m = new DefaultTableModel(new String[]{"Student ID","First Name","Last Name","Roll No.","Status"}, 0) {
            public boolean isCellEditable(int r, int c) { return c == 4; }
        };
        attendanceTable.setModel(m);
        JComboBox<String> statusCombo = new JComboBox<>(new String[]{"Present","Absent"});
        attendanceTable.getColumnModel().getColumn(4).setCellEditor(new DefaultCellEditor(statusCombo));

        String sql = "SELECT student_id, first_name, last_name, student_roll FROM students ORDER BY student_id";
        try (Connection c = DatabaseManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                m.addRow(new Object[]{
                        rs.getInt("student_id"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        rs.getString("student_roll"),
                        "Present"  // default
                });
            }
        } catch (SQLException ex) { showError("Loading students for attendance", ex); }
    }

    private void markAttendance() {
        String subjectName = (String) subjectComboBox.getSelectedItem();
        Date d = (Date) dateSpinner.getValue();
        if (subjectName == null) { JOptionPane.showMessageDialog(this, "Add subjects first."); return; }

        String findSub = "SELECT subject_id FROM subjects WHERE subject_name=?";
        String findSession = "SELECT session_id FROM sessions WHERE session_date=? AND subject_id=?";
        String insertSession = "INSERT INTO sessions(session_date, subject_id) VALUES(?,?)";
        String upsertAttendance = """
                INSERT INTO attendance(student_id, session_id, status)
                VALUES(?,?,?)
                ON DUPLICATE KEY UPDATE status = VALUES(status)
                """;

        try (Connection c = DatabaseManager.getConnection()) {
            c.setAutoCommit(false);

            int subjectId;
            try (PreparedStatement ps = c.prepareStatement(findSub)) {
                ps.setString(1, subjectName);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) throw new SQLException("Subject not found.");
                    subjectId = rs.getInt(1);
                }
            }

            int sessionId;
            java.sql.Date sqlDate = new java.sql.Date(d.getTime());
            try (PreparedStatement ps = c.prepareStatement(findSession)) {
                ps.setDate(1, sqlDate); ps.setInt(2, subjectId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) sessionId = rs.getInt(1);
                    else {
                        try (PreparedStatement ins = c.prepareStatement(insertSession, Statement.RETURN_GENERATED_KEYS)) {
                            ins.setDate(1, sqlDate); ins.setInt(2, subjectId);
                            ins.executeUpdate();
                            try (ResultSet g = ins.getGeneratedKeys()) {
                                g.next(); sessionId = g.getInt(1);
                            }
                        }
                    }
                }
            }

            try (PreparedStatement ps = c.prepareStatement(upsertAttendance)) {
                DefaultTableModel m = (DefaultTableModel) attendanceTable.getModel();
                for (int i = 0; i < m.getRowCount(); i++) {
                    int studentId = (int) m.getValueAt(i, 0);
                    String status = (String) m.getValueAt(i, 4);
                    ps.setInt(1, studentId);
                    ps.setInt(2, sessionId);
                    ps.setString(3, status);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            c.commit();
            JOptionPane.showMessageDialog(this, "Attendance saved for " + new SimpleDateFormat("yyyy-MM-dd").format(d) + " (" + subjectName + ")");
        } catch (SQLException ex) { showError("Marking attendance", ex); }
    }

    // --------------- Reporting ---------------
    private void generateReport() {
        String roll = reportStudentRollField.getText().trim();
        String subject = (String) reportSubjectComboBox.getSelectedItem();
        Date from = (Date) reportFromDate.getValue();
        Date to   = (Date) reportToDate.getValue();

        if (roll.isEmpty() || subject == null) {
            JOptionPane.showMessageDialog(this, "Enter roll and select subject."); return;
        }

        String sql = """
                SELECT s.first_name, s.last_name,
                       SUM(a.status='Present') AS present_count,
                       COUNT(*) AS total_classes
                FROM attendance a
                JOIN students s  ON s.student_id = a.student_id
                JOIN sessions se ON se.session_id = a.session_id
                JOIN subjects sb ON sb.subject_id = se.subject_id
                WHERE s.student_roll = ?
                  AND sb.subject_name = ?
                  AND se.session_date BETWEEN ? AND ?
                """;

        try (Connection c = DatabaseManager.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, roll);
            ps.setString(2, subject);
            ps.setDate(3, new java.sql.Date(from.getTime()));
            ps.setDate(4, new java.sql.Date(to.getTime()));
            try (ResultSet rs = ps.executeQuery()) {
                reportArea.setText("");
                if (rs.next()) {
                    int present = rs.getInt("present_count");
                    int total   = rs.getInt("total_classes");
                    double pct = total > 0 ? (present * 100.0 / total) : 0.0;
                    String name = rs.getString("first_name") + " " + rs.getString("last_name");

                    reportArea.append("Attendance Report\n");
                    reportArea.append("-----------------\n");
                    reportArea.append("Student: " + name + " (Roll: " + roll + ")\n");
                    reportArea.append("Subject: " + subject + "\n");
                    reportArea.append("Period : " + new SimpleDateFormat("yyyy-MM-dd").format(from)
                            + " to " + new SimpleDateFormat("yyyy-MM-dd").format(to) + "\n\n");
                    reportArea.append("Total Classes : " + total + "\n");
                    reportArea.append("Present       : " + present + "\n");
                    reportArea.append(String.format("Attendance %% : %.2f%%\n", pct));
                } else {
                    reportArea.setText("No classes found for the selected filters.");
                }
            }
        } catch (SQLException ex) { showError("Generating report", ex); }
    }

    private void showError(String where, Exception ex) {
        ex.printStackTrace();
        JOptionPane.showMessageDialog(this, "Error " + where + ":\n" + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(Main::new);
    }
}