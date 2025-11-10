package dao;

import dal.DBContext;
import model.Department;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho Department
 */
public class DepartmentDAO extends DBContext {
    
    /**
     * Lấy tất cả departments
     * @return 
     */
    public List<Department> getAllDepartments() {
        List<Department> departments = new ArrayList<>();
        String sql = "SELECT * FROM Department";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                departments.add(extractDepartment(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return departments;
    }
    
    /**
     * Lấy department theo ID
     * @param id
     * @return 
     */
    public Department getDepartmentById(int id) {
        String sql = "SELECT * FROM Department WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return extractDepartment(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Extract Department từ ResultSet
     */
    private Department extractDepartment(ResultSet rs) throws SQLException {
        Department dept = new Department();
        dept.setId(rs.getInt("id"));
        dept.setName(rs.getString("name"));
        dept.setDescription(rs.getString("description"));
        return dept;
    }
}
