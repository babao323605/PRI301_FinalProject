package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database Access Layer - Quản lý kết nối database
 */
public class DBContext {
    
    // Cấu hình database - Thay đổi theo môi trường của bạn
    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=LeaveManagement;encrypt=true;trustServerCertificate=true;";
    private static final String DB_USER = "sa";
    private static final String DB_PASSWORD = "12345";
    /**
     * Lấy kết nối đến database
     */
    public Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("SQL Server JDBC Driver not found", e);
        }
    }
    
    /**
     * Đóng kết nối
     */
    public void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Test kết nối database
     */
    public static void main(String[] args) {
        DBContext db = new DBContext();
        try {
            Connection conn = db.getConnection();
            if (conn != null) {
                System.out.println("Kết nối database thành công!");
                db.closeConnection(conn);
            }
        } catch (SQLException e) {
            System.out.println("Lỗi kết nối database: " + e.getMessage());
        }
    }
}
