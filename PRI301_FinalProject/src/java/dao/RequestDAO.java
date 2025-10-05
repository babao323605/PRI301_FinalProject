package dao;

import dal.DBContext;
import model.Request;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho Request - Xử lý các thao tác với đơn nghỉ phép
 */
public class RequestDAO extends DBContext {
    
    /**
     * Tạo đơn nghỉ phép mới
     */
    public boolean createRequest(Request request) {
        String sql = "INSERT INTO Request (title, from_date, to_date, reason, status, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, request.getTitle());
            ps.setDate(2, request.getFromDate());
            ps.setDate(3, request.getToDate());
            ps.setString(4, request.getReason());
            ps.setString(5, "Inprogress"); // Trạng thái mặc định
            ps.setInt(6, request.getCreatedBy());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Lấy tất cả đơn của một user
     */
    public List<Request> getRequestsByUser(int userId) {
        List<Request> requests = new ArrayList<>();
        String sql = "SELECT r.*, u1.name as created_by_name, u2.name as processed_by_name " +
                     "FROM Request r " +
                     "LEFT JOIN [User] u1 ON r.created_by = u1.id " +
                     "LEFT JOIN [User] u2 ON r.processed_by = u2.id " +
                     "WHERE r.created_by = ? " +
                     "ORDER BY r.created_at DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                requests.add(extractRequest(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }
    
    /**
     * Lấy tất cả đơn của subordinates (cấp dưới)
     */
    public List<Request> getRequestsBySubordinates(List<Integer> subordinateIds) {
        if (subordinateIds == null || subordinateIds.isEmpty()) {
            return new ArrayList<>();
        }
        
        List<Request> requests = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT r.*, u1.name as created_by_name, u2.name as processed_by_name " +
            "FROM Request r " +
            "LEFT JOIN [User] u1 ON r.created_by = u1.id " +
            "LEFT JOIN [User] u2 ON r.processed_by = u2.id " +
            "WHERE r.created_by IN ("
        );
        
        for (int i = 0; i < subordinateIds.size(); i++) {
            sql.append("?");
            if (i < subordinateIds.size() - 1) {
                sql.append(",");
            }
        }
        sql.append(") ORDER BY r.created_at DESC");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < subordinateIds.size(); i++) {
                ps.setInt(i + 1, subordinateIds.get(i));
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                requests.add(extractRequest(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }
    
    /**
     * Lấy đơn theo ID
     */
    public Request getRequestById(int id) {
        String sql = "SELECT r.*, u1.name as created_by_name, u2.name as processed_by_name " +
                     "FROM Request r " +
                     "LEFT JOIN [User] u1 ON r.created_by = u1.id " +
                     "LEFT JOIN [User] u2 ON r.processed_by = u2.id " +
                     "WHERE r.id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return extractRequest(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Approve hoặc Reject đơn
     */
    public boolean processRequest(int requestId, String status, int processedBy, String processReason) {
        String sql = "UPDATE Request SET status = ?, processed_by = ?, process_reason = ?, " +
                     "updated_at = GETDATE() WHERE id = ? AND status = 'Inprogress'";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, processedBy);
            ps.setString(3, processReason);
            ps.setInt(4, requestId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Lấy đơn đã approved trong khoảng thời gian (cho agenda)
     * Logic: Tìm các request có khoảng thời gian overlap với fromDate và toDate
     * Overlap khi: request.from_date <= toDate AND request.to_date >= fromDate
     */
    public List<Request> getApprovedRequestsByDateRange(int departmentId, Date fromDate, Date toDate) {
        List<Request> requests = new ArrayList<>();
        String sql = "SELECT r.*, u1.name as created_by_name, u2.name as processed_by_name " +
                     "FROM Request r " +
                     "INNER JOIN [User] u1 ON r.created_by = u1.id " +
                     "LEFT JOIN [User] u2 ON r.processed_by = u2.id " +
                     "WHERE r.status = 'Approved' " +
                     "AND u1.department_id = ? " +
                     "AND r.from_date <= ? " +
                     "AND r.to_date >= ? " +
                     "ORDER BY r.from_date, u1.name";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, departmentId);
            ps.setDate(2, toDate);      // r.from_date <= toDate
            ps.setDate(3, fromDate);    // r.to_date >= fromDate
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                requests.add(extractRequest(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }
    
    /**
     * Cập nhật đơn (chỉ khi còn Inprogress)
     */
    public boolean updateRequest(Request request) {
        String sql = "UPDATE Request SET title = ?, from_date = ?, to_date = ?, reason = ?, " +
                     "updated_at = GETDATE() WHERE id = ? AND status = 'Inprogress'";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, request.getTitle());
            ps.setDate(2, request.getFromDate());
            ps.setDate(3, request.getToDate());
            ps.setString(4, request.getReason());
            ps.setInt(5, request.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Extract Request từ ResultSet
     */
    private Request extractRequest(ResultSet rs) throws SQLException {
        Request request = new Request();
        request.setId(rs.getInt("id"));
        request.setTitle(rs.getString("title"));
        request.setFromDate(rs.getDate("from_date"));
        request.setToDate(rs.getDate("to_date"));
        request.setReason(rs.getString("reason"));
        request.setStatus(rs.getString("status"));
        request.setCreatedBy(rs.getInt("created_by"));
        
        int processedBy = rs.getInt("processed_by");
        if (!rs.wasNull()) {
            request.setProcessedBy(processedBy);
        }
        
        request.setProcessReason(rs.getString("process_reason"));
        request.setCreatedAt(rs.getTimestamp("created_at"));
        request.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        // Thông tin bổ sung
        request.setCreatedByName(rs.getString("created_by_name"));
        request.setProcessedByName(rs.getString("processed_by_name"));
        
        return request;
    }
}
