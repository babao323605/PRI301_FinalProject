package model;

import java.sql.Timestamp;

/**
 * Notification entity - Thông báo cho user
 */
public class Notification {
    private int id;
    private int userId;
    private String title;
    private String message;
    private String type; // info, success, warning, error
    private boolean isRead;
    private Integer relatedRequestId;
    private Timestamp createdAt;
    
    // Constructor
    public Notification() {
    }
    
    public Notification(int userId, String title, String message, String type) {
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.type = type;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public Integer getRelatedRequestId() {
        return relatedRequestId;
    }

    public void setRelatedRequestId(Integer relatedRequestId) {
        this.relatedRequestId = relatedRequestId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Notification{" +
                "id=" + id +
                ", userId=" + userId +
                ", title='" + title + '\'' +
                ", type='" + type + '\'' +
                ", isRead=" + isRead +
                '}';
    }
}
