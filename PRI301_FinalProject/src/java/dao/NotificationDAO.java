package dao;

import dal.DBContext;
import model.Notification;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho Notification
 */
public class NotificationDAO extends DBContext {
    
    /**
     * Tạo notification mới
     */
    public boolean createNotification(Notification notification) {
        String sql = "INSERT INTO Notification (user_id, title, message, type, related_request_id) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            System.out.println("DEBUG NotificationDAO: Creating notification for user_id=" + notification.getUserId());
            System.out.println("DEBUG NotificationDAO: Title=" + notification.getTitle());
            System.out.println("DEBUG NotificationDAO: Type=" + notification.getType());
            System.out.println("DEBUG NotificationDAO: Related request ID=" + notification.getRelatedRequestId());
            
            ps.setInt(1, notification.getUserId());
            ps.setString(2, notification.getTitle());
            ps.setString(3, notification.getMessage());
            ps.setString(4, notification.getType());
            
            if (notification.getRelatedRequestId() != null) {
                ps.setInt(5, notification.getRelatedRequestId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("DEBUG NotificationDAO: Rows affected=" + rowsAffected);
            
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("ERROR NotificationDAO: SQL Exception - " + e.getMessage());
            System.err.println("ERROR NotificationDAO: SQL State - " + e.getSQLState());
            System.err.println("ERROR NotificationDAO: Error Code - " + e.getErrorCode());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Lấy tất cả notifications của user (chưa đọc trước)
     */
    public List<Notification> getNotificationsByUser(int userId, int limit) {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT TOP (?) * FROM Notification " +
                     "WHERE user_id = ? " +
                     "ORDER BY is_read ASC, created_at DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            ps.setInt(2, userId);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                notifications.add(extractNotification(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return notifications;
    }
    
    /**
     * Đếm số notification chưa đọc
     */
    public int countUnreadNotifications(int userId) {
        String sql = "SELECT COUNT(*) as count FROM Notification " +
                     "WHERE user_id = ? AND is_read = 0";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Đánh dấu notification đã đọc
     */
    public boolean markAsRead(int notificationId) {
        String sql = "UPDATE Notification SET is_read = 1 WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Đánh dấu tất cả notification của user đã đọc
     */
    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE Notification SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Xóa notification
     */
    public boolean deleteNotification(int notificationId) {
        String sql = "DELETE FROM Notification WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Extract Notification từ ResultSet
     */
    private Notification extractNotification(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        notification.setId(rs.getInt("id"));
        notification.setUserId(rs.getInt("user_id"));
        notification.setTitle(rs.getString("title"));
        notification.setMessage(rs.getString("message"));
        notification.setType(rs.getString("type"));
        notification.setRead(rs.getBoolean("is_read"));
        
        int relatedRequestId = rs.getInt("related_request_id");
        if (!rs.wasNull()) {
            notification.setRelatedRequestId(relatedRequestId);
        }
        
        notification.setCreatedAt(rs.getTimestamp("created_at"));
        return notification;
    }
}
