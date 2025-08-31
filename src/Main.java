import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.sql.*;

public class Main {
    // Labels and input fields
    private static JTextField nameField, totalField, attendedField;
    private static JComboBox<String> subjectBox;
    private static JTextArea outputArea;

    public static void main(String[] args) {
        // ... (GUI setup from your original code) ...
        JFrame frame = new JFrame("Attendance System");
        frame.setSize(500, 300);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLayout(new GridLayout(6, 2, 10, 10));

        nameField = new JTextField();
        subjectBox = new JComboBox<>(new String[]{"Physics", "Chemistry", "Maths"});
        totalField = new JTextField();
        attendedField = new JTextField();
        JButton addButton = new JButton("Add Record");
        JButton updateButton = new JButton("Update Record");
        outputArea = new JTextArea();
        outputArea.setEditable(false);

        frame.add(new JLabel("Student Name:")); frame.add(nameField);
        frame.add(new JLabel("Subject:")); frame.add(subjectBox);
        frame.add(new JLabel("Total Classes:")); frame.add(totalField);
        frame.add(new JLabel("Classes Attended:")); frame.add(attendedField);
        frame.add(addButton); frame.add(updateButton);
        frame.add(new JLabel("Records:")); frame.add(new JScrollPane(outputArea));

        addButton.addActionListener(e -> addRecord());
        updateButton.addActionListener(e -> updateRecord());

        // Initial fetch and display of all records
        loadRecords();

        frame.setVisible(true);
    }

    private static void addRecord() {
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                     "INSERT INTO records (name, subject, total_classes, attended) VALUES (?, ?, ?, ?)"
             )) {

            pstmt.setString(1, nameField.getText());
            pstmt.setString(2, subjectBox.getSelectedItem().toString());
            pstmt.setInt(3, Integer.parseInt(totalField.getText()));
            pstmt.setInt(4, Integer.parseInt(attendedField.getText()));

            pstmt.executeUpdate();
            JOptionPane.showMessageDialog(null, "Record Added Successfully!");
            loadRecords(); // Refresh the display
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(null, "Please enter valid input: " + ex.getMessage());
        }
    }

    private static void updateRecord() {
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                     "UPDATE records SET total_classes = ?, attended = ? WHERE name = ? AND subject = ?"
             )) {

            pstmt.setInt(1, Integer.parseInt(totalField.getText()));
            pstmt.setInt(2, Integer.parseInt(attendedField.getText()));
            pstmt.setString(3, nameField.getText());
            pstmt.setString(4, subjectBox.getSelectedItem().toString());

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                JOptionPane.showMessageDialog(null, "Record Updated Successfully!");
            } else {
                JOptionPane.showMessageDialog(null, "No record found for update!");
            }
            loadRecords(); // Refresh the display
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(null, "Invalid input: " + ex.getMessage());
        }
    }

    private static void loadRecords() {
        outputArea.setText(""); // Clear existing text
        try (Connection conn = DatabaseManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM records")) {

            while (rs.next()) {
                String name = rs.getString("name");
                String subject = rs.getString("subject");
                int total = rs.getInt("total_classes");
                int attended = rs.getInt("attended");
                double percentage = (total > 0) ? (attended * 100.0) / total : 0;
                outputArea.append(name + " | " + subject + " | " + percentage + "%\n");
            }
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(null, "Error loading records: " + ex.getMessage());
        }
    }
}