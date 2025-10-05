-- =============================================
-- Leave Management System - Database Schema
-- SQL Server
-- =============================================

-- Tạo database
CREATE DATABASE LeaveManagement;
GO

USE LeaveManagement;
GO

-- =============================================
-- 1. Department Table (Phòng ban)
-- =============================================
CREATE TABLE Department (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500)
);

-- =============================================
-- 2. User Table (Người dùng)
-- =============================================
CREATE TABLE [User] (
    id INT PRIMARY KEY IDENTITY(1,1),
    username NVARCHAR(50) NOT NULL UNIQUE,
    password NVARCHAR(255) NOT NULL,
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100),
    department_id INT NOT NULL,
    manager_id INT NULL, -- Self-reference cho hierarchy
    created_at DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_User_Department FOREIGN KEY (department_id) 
        REFERENCES Department(id),
    CONSTRAINT FK_User_Manager FOREIGN KEY (manager_id) 
        REFERENCES [User](id)
);

-- =============================================
-- 3. Role Table (Vai trò)
-- =============================================
CREATE TABLE Role (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    description NVARCHAR(500),
    
    CONSTRAINT FK_Role_Department FOREIGN KEY (department_id) 
        REFERENCES Department(id)
);

-- =============================================
-- 4. Feature Table (Quyền/Tính năng)
-- =============================================
CREATE TABLE Feature (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500)
);

-- =============================================
-- 5. User_Role Table (Many-to-Many)
-- =============================================
CREATE TABLE User_Role (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT FK_UserRole_User FOREIGN KEY (user_id) 
        REFERENCES [User](id) ON DELETE CASCADE,
    CONSTRAINT FK_UserRole_Role FOREIGN KEY (role_id) 
        REFERENCES Role(id) ON DELETE CASCADE
);

-- =============================================
-- 6. Role_Feature Table (Many-to-Many)
-- =============================================
CREATE TABLE Role_Feature (
    role_id INT NOT NULL,
    feature_id INT NOT NULL,
    
    PRIMARY KEY (role_id, feature_id),
    CONSTRAINT FK_RoleFeature_Role FOREIGN KEY (role_id) 
        REFERENCES Role(id) ON DELETE CASCADE,
    CONSTRAINT FK_RoleFeature_Feature FOREIGN KEY (feature_id) 
        REFERENCES Feature(id) ON DELETE CASCADE
);

-- =============================================
-- 7. Request Table (Đơn nghỉ phép)
-- =============================================
CREATE TABLE Request (
    id INT PRIMARY KEY IDENTITY(1,1),
    title NVARCHAR(200),
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    reason NVARCHAR(1000) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'Inprogress', -- Inprogress, Approved, Rejected
    created_by INT NOT NULL,
    processed_by INT NULL,
    process_reason NVARCHAR(1000),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Request_CreatedBy FOREIGN KEY (created_by) 
        REFERENCES [User](id),
    CONSTRAINT FK_Request_ProcessedBy FOREIGN KEY (processed_by) 
        REFERENCES [User](id),
    CONSTRAINT CHK_Request_Status CHECK (status IN ('Inprogress', 'Approved', 'Rejected')),
    CONSTRAINT CHK_Request_Dates CHECK (from_date <= to_date)
);

-- =============================================
-- Indexes for Performance
-- =============================================
CREATE INDEX IDX_User_Department ON [User](department_id);
CREATE INDEX IDX_User_Manager ON [User](manager_id);
CREATE INDEX IDX_Request_CreatedBy ON Request(created_by);
CREATE INDEX IDX_Request_Status ON Request(status);
CREATE INDEX IDX_Request_Dates ON Request(from_date, to_date);

GO

PRINT 'Database schema created successfully!';
