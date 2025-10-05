-- =============================================
-- Leave Management System - Sample Data
-- =============================================

USE LeaveManagement;
GO

-- =============================================
-- 1. Insert Departments
-- =============================================
INSERT INTO Department (name, description) VALUES
(N'IT', N'Phòng Công nghệ thông tin'),
(N'QA', N'Phòng Kiểm thử chất lượng'),
(N'Sale', N'Phòng Kinh doanh');

-- =============================================
-- 2. Insert Features
-- =============================================
INSERT INTO Feature (name, description) VALUES
('/home', N'Trang chủ'),
('/request/create', N'Tạo đơn nghỉ phép'),
('/request/list', N'Xem danh sách đơn'),
('/request/review', N'Xét duyệt đơn'),
('/request/modify', N'Sửa đơn'),
('/request/agenda', N'Xem agenda phòng ban');

-- =============================================
-- 3. Insert Roles
-- =============================================
-- IT Department
INSERT INTO Role (name, department_id, description) VALUES
(N'Division Leader', 1, N'Trưởng phòng IT'),
(N'Team Leader', 1, N'Trưởng nhóm IT'),
(N'Employee', 1, N'Nhân viên IT');

-- QA Department
INSERT INTO Role (name, department_id, description) VALUES
(N'Division Leader', 2, N'Trưởng phòng QA'),
(N'Team Leader', 2, N'Trưởng nhóm QA'),
(N'Employee', 2, N'Nhân viên QA');

-- Sale Department
INSERT INTO Role (name, department_id, description) VALUES
(N'Division Leader', 3, N'Trưởng phòng Sale'),
(N'Team Leader', 3, N'Trưởng nhóm Sale'),
(N'Employee', 3, N'Nhân viên Sale');

-- =============================================
-- 4. Assign Features to Roles
-- =============================================
-- Division Leader: Full access
INSERT INTO Role_Feature (role_id, feature_id) VALUES
-- IT Division Leader
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
-- QA Division Leader
(4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6),
-- Sale Division Leader
(7, 1), (7, 2), (7, 3), (7, 4), (7, 5), (7, 6);

-- Team Leader: Review access + Create
INSERT INTO Role_Feature (role_id, feature_id) VALUES
-- IT Team Leader
(2, 1), (2, 2), (2, 3), (2, 4),
-- QA Team Leader
(5, 1), (5, 2), (5, 3), (5, 4),
-- Sale Team Leader
(8, 1), (8, 2), (8, 3), (8, 4);

-- Employee: Basic access
INSERT INTO Role_Feature (role_id, feature_id) VALUES
-- IT Employee
(3, 1), (3, 2), (3, 3),
-- QA Employee
(6, 1), (6, 2), (6, 3),
-- Sale Employee
(9, 1), (9, 2), (9, 3);

-- =============================================
-- 5. Insert Users (Password: 123456)
-- =============================================
-- IT Department
-- Division Leader
INSERT INTO [User] (username, password, name, email, department_id, manager_id) VALUES
('it_leader', '123456', N'Nguyễn Văn A', 'leader.it@company.com', 1, NULL);

-- Team Leader (reports to Division Leader)
INSERT INTO [User] (username, password, name, email, department_id, manager_id) VALUES
('it_manager', '123456', N'Trần Thị B', 'manager.it@company.com', 1, 1);

-- Employees (report to Team Leader)
INSERT INTO [User] (username, password, name, email, department_id, manager_id) VALUES
('it_emp1', '123456', N'Lê Văn C', 'emp1.it@company.com', 1, 2),
('it_emp2', '123456', N'Phạm Thị D', 'emp2.it@company.com', 1, 2);

-- QA Department
INSERT INTO [User] (username, password, name, email, department_id, manager_id) VALUES
('qa_leader', '123456', N'Hoàng Văn E', 'leader.qa@company.com', 2, NULL),
('qa_manager', '123456', N'Vũ Thị F', 'manager.qa@company.com', 2, 5),
('qa_emp1', '123456', N'Đỗ Văn G', 'emp1.qa@company.com', 2, 6);

-- Sale Department
INSERT INTO [User] (username, password, name, email, department_id, manager_id) VALUES
('sale_leader', '123456', N'Bùi Văn H', 'leader.sale@company.com', 3, NULL),
('sale_manager', '123456', N'Đinh Thị I', 'manager.sale@company.com', 3, 8),
('sale_emp1', '123456', N'Ngô Văn K', 'emp1.sale@company.com', 3, 9);

-- =============================================
-- 6. Assign Roles to Users
-- =============================================
-- IT Department
INSERT INTO User_Role (user_id, role_id) VALUES
(1, 1), -- IT Leader -> Division Leader
(2, 2), -- IT Manager -> Team Leader
(3, 3), -- IT Emp1 -> Employee
(4, 3); -- IT Emp2 -> Employee

-- QA Department
INSERT INTO User_Role (user_id, role_id) VALUES
(5, 4), -- QA Leader -> Division Leader
(6, 5), -- QA Manager -> Team Leader
(7, 6); -- QA Emp1 -> Employee

-- Sale Department
INSERT INTO User_Role (user_id, role_id) VALUES
(8, 7), -- Sale Leader -> Division Leader
(9, 8), -- Sale Manager -> Team Leader
(10, 9); -- Sale Emp1 -> Employee

-- =============================================
-- 7. Insert Sample Requests
-- =============================================
-- Inprogress requests
INSERT INTO Request (title, from_date, to_date, reason, status, created_by) VALUES
(N'Nghỉ phép năm', '2025-01-15', '2025-01-17', N'Về quê nghỉ tết', 'Inprogress', 3),
(N'Nghỉ ốm', '2025-01-20', '2025-01-21', N'Bị cảm cúm, cần nghỉ dưỡng bệnh', 'Inprogress', 4),
(N'Nghỉ việc riêng', '2025-01-25', '2025-01-26', N'Giải quyết công việc cá nhân', 'Inprogress', 7);

-- Approved requests
INSERT INTO Request (title, from_date, to_date, reason, status, created_by, processed_by, process_reason) VALUES
(N'Nghỉ phép', '2025-01-10', '2025-01-12', N'Du lịch cùng gia đình', 'Approved', 3, 2, N'Đồng ý'),
(N'Nghỉ ốm', '2025-01-08', '2025-01-09', N'Khám bệnh', 'Approved', 7, 6, N'Phê duyệt');

-- Rejected requests
INSERT INTO Request (title, from_date, to_date, reason, status, created_by, processed_by, process_reason) VALUES
(N'Nghỉ phép', '2025-01-05', '2025-01-07', N'Nghỉ việc riêng', 'Rejected', 4, 2, N'Thời gian này phòng ban bận, không thể nghỉ');

GO

PRINT 'Sample data inserted successfully!';
PRINT '';
PRINT '==============================================';
PRINT 'Test Accounts:';
PRINT '==============================================';
PRINT 'IT Division Leader: it_leader / 123456';
PRINT 'IT Team Leader: it_manager / 123456';
PRINT 'IT Employee: it_emp1 / 123456';
PRINT '';
PRINT 'QA Division Leader: qa_leader / 123456';
PRINT 'QA Team Leader: qa_manager / 123456';
PRINT 'QA Employee: qa_emp1 / 123456';
PRINT '';
PRINT 'Sale Division Leader: sale_leader / 123456';
PRINT 'Sale Team Leader: sale_manager / 123456';
PRINT 'Sale Employee: sale_emp1 / 123456';
PRINT '==============================================';
