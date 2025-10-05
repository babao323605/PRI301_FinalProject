package dao;

import dal.DBContext;
import model.Role;
import model.Feature;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho Role và Feature - Xử lý RBAC
 */
public class RoleDAO extends DBContext {
    
    /**
     * Lấy tất cả roles của một user
     */
    public List<Role> getRolesByUser(int userId) {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT r.* FROM Role r " +
                     "INNER JOIN User_Role ur ON r.id = ur.role_id " +
                     "WHERE ur.user_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                roles.add(extractRole(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return roles;
    }
    
    /**
     * Lấy tất cả features của một user (thông qua roles)
     */
    public List<Feature> getFeaturesByUser(int userId) {
        List<Feature> features = new ArrayList<>();
        String sql = "SELECT DISTINCT f.* FROM Feature f " +
                     "INNER JOIN Role_Feature rf ON f.id = rf.feature_id " +
                     "INNER JOIN User_Role ur ON rf.role_id = ur.role_id " +
                     "WHERE ur.user_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                features.add(extractFeature(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return features;
    }
    
    /**
     * Kiểm tra user có quyền truy cập feature không
     */
    public boolean hasFeature(int userId, String featureName) {
        String sql = "SELECT COUNT(*) as count FROM Feature f " +
                     "INNER JOIN Role_Feature rf ON f.id = rf.feature_id " +
                     "INNER JOIN User_Role ur ON rf.role_id = ur.role_id " +
                     "WHERE ur.user_id = ? AND f.name = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setString(2, featureName);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Gán role cho user
     */
    public boolean assignRoleToUser(int userId, int roleId) {
        String sql = "INSERT INTO User_Role (user_id, role_id) VALUES (?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, roleId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Xóa role khỏi user
     */
    public boolean removeRoleFromUser(int userId, int roleId) {
        String sql = "DELETE FROM User_Role WHERE user_id = ? AND role_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, roleId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Extract Role từ ResultSet
     */
    private Role extractRole(ResultSet rs) throws SQLException {
        Role role = new Role();
        role.setId(rs.getInt("id"));
        role.setName(rs.getString("name"));
        role.setDepartmentId(rs.getInt("department_id"));
        role.setDescription(rs.getString("description"));
        return role;
    }
    
    /**
     * Extract Feature từ ResultSet
     */
    private Feature extractFeature(ResultSet rs) throws SQLException {
        Feature feature = new Feature();
        feature.setId(rs.getInt("id"));
        feature.setName(rs.getString("name"));
        feature.setDescription(rs.getString("description"));
        return feature;
    }
}
