package model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Request entity - Đơn xin nghỉ phép
 */
public class Request {
    private int id;
    private String title;
    private Date fromDate;
    private Date toDate;
    private String reason;
    private String status; // Inprogress, Approved, Rejected
    private int createdBy;
    private Integer processedBy; // Nullable
    private String processReason;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Thông tin bổ sung (không lưu trong DB, dùng cho hiển thị)
    private String createdByName;
    private String processedByName;
    
    // Constructor
    public Request() {
    }
    
    public Request(int id, String title, Date fromDate, Date toDate, String reason, 
                   String status, int createdBy) {
        this.id = id;
        this.title = title;
        this.fromDate = fromDate;
        this.toDate = toDate;
        this.reason = reason;
        this.status = status;
        this.createdBy = createdBy;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Date getFromDate() {
        return fromDate;
    }

    public void setFromDate(Date fromDate) {
        this.fromDate = fromDate;
    }

    public Date getToDate() {
        return toDate;
    }

    public void setToDate(Date toDate) {
        this.toDate = toDate;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public Integer getProcessedBy() {
        return processedBy;
    }

    public void setProcessedBy(Integer processedBy) {
        this.processedBy = processedBy;
    }

    public String getProcessReason() {
        return processReason;
    }

    public void setProcessReason(String processReason) {
        this.processReason = processReason;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public String getProcessedByName() {
        return processedByName;
    }

    public void setProcessedByName(String processedByName) {
        this.processedByName = processedByName;
    }

    @Override
    public String toString() {
        return "Request{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", fromDate=" + fromDate +
                ", toDate=" + toDate +
                ", status='" + status + '\'' +
                ", createdBy=" + createdBy +
                ", processedBy=" + processedBy +
                '}';
    }
}
