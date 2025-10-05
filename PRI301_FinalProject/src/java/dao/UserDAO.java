package dao;

import dal.DBContext;
import model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho User - Xử lý các thao tác CRUD với bảng User
 */
public class UserDAO extends DBContext {
    
    /**
     * Xác thực đăng nhập
     */
    public User authenticate(String username, String password) {
        String sql = "SELECT * FROM [User] WHERE username = ? AND password = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ps.setString(2, password); // Trong thực tế nên hash password
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return extractUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy user theo ID
     */
    public User getUserById(int id) {
        String sql = "SELECT * FROM [User] WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return extractUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy tất cả subordinates (cấp dưới) của một manager - RECURSIVE
     * Bao gồm cả subordinates của subordinates (toàn bộ cây phân cấp)
     */
    public List<User> getSubordinates(int managerId) {
        List<User> subordinates = new ArrayList<>();
        String sql = "WITH RECURSIVE Subordinates AS ( " +
                     "  SELECT * FROM [User] WHERE manager_id = ? " +
                     "  UNION ALL " +
                     "  SELECT u.* FROM [User] u " +
                     "  INNER JOIN Subordinates s ON u.manager_id = s.id " +
                     ") " +
                     "SELECT * FROM Subordinates";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, managerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                subordinates.add(extractUser(rs));
            }
        } catch (SQLException e) {
            // SQL Server không hỗ trợ RECURSIVE, dùng CTE thay thế
            subordinates = getSubordinatesNonRecursive(managerId);
        }
        return subordinates;
    }
    
    /**
     * Lấy subordinates bằng CTE cho SQL Server
     */
    private List<User> getSubordinatesNonRecursive(int managerId) {
        List<User> subordinates = new ArrayList<>();
        String sql = "WITH SubordinatesCTE AS ( " +
                     "  SELECT id, username, password, name, email, department_id, manager_id, created_at " +
                     "  FROM [User] WHERE manager_id = ? " +
                     "  UNION ALL " +
                     "  SELECT u.id, u.username, u.password, u.name, u.email, u.department_id, u.manager_id, u.created_at " +
                     "  FROM [User] u " +
                     "  INNER JOIN SubordinatesCTE s ON u.manager_id = s.id " +
                     ") " +
                     "SELECT * FROM SubordinatesCTE";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, managerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                subordinates.add(extractUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return subordinates;
    }
    
    /**
     * Lấy tất cả users trong một department
     */
    public List<User> getUsersByDepartment(int departmentId) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM [User] WHERE department_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, departmentId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                users.add(extractUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    
    /**
     * Thêm user mới
     */
    public boolean insertUser(User user) {
        String sql = "INSERT INTO [User] (username, password, name, email, department_id, manager_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getName());
            ps.setString(4, user.getEmail());
            ps.setInt(5, user.getDepartmentId());
            
            if (user.getManagerId() != null) {
                ps.setInt(6, user.getManagerId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Cập nhật thông tin user
     */
    public boolean updateUser(User user) {
        String sql = "UPDATE [User] SET name = ?, email = ?, department_id = ?, manager_id = ? " +
                     "WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setInt(3, user.getDepartmentId());
            
            if (user.getManagerId() != null) {
                ps.setInt(4, user.getManagerId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            
            ps.setInt(5, user.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Xóa user
     */
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM [User] WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Extract User từ ResultSet
     */
    private User extractUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setName(rs.getString("name"));
        user.setEmail(rs.getString("email"));
        user.setDepartmentId(rs.getInt("department_id"));
        
        int managerId = rs.getInt("manager_id");
        if (!rs.wasNull()) {
            user.setManagerId(managerId);
        }
        
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }
}
