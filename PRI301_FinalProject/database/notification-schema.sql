-- =============================================
-- Notification System - Thêm vào database
-- =============================================

USE LeaveManagement;
GO

-- Tạo bảng Notification
CREATE TABLE Notification (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    title NVARCHAR(200) NOT NULL,
    message NVARCHAR(1000) NOT NULL,
    type NVARCHAR(20) NOT NULL, -- info, success, warning, error
    is_read BIT DEFAULT 0,
    related_request_id INT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Notification_User FOREIGN KEY (user_id) 
        REFERENCES [User](id) ON DELETE CASCADE,
    CONSTRAINT FK_Notification_Request FOREIGN KEY (related_request_id) 
        REFERENCES Request(id) ON DELETE SET NULL
);

-- Index cho performance
CREATE INDEX IDX_Notification_User ON Notification(user_id, is_read);
CREATE INDEX IDX_Notification_CreatedAt ON Notification(created_at DESC);

GO

PRINT 'Notification table created successfully!';
