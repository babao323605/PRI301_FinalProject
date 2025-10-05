# 🔧 Hướng dẫn sửa lỗi và cập nhật

## ✅ Các vấn đề đã sửa

### 1. **Team Leader không vào được trang Create (403/404)**
**Nguyên nhân**: Team Leader không có quyền `/request/create`

**Giải pháp**: Đã cập nhật `database/sample-data.sql` để thêm quyền create cho Team Leader

```sql
-- Chạy lại phần này hoặc update trực tiếp trong database
INSERT INTO Role_Feature (role_id, feature_id) VALUES
-- IT Team Leader (thêm feature_id = 2 là /request/create)
(2, 1), (2, 2), (2, 3), (2, 4),
-- QA Team Leader
(5, 1), (5, 2), (5, 3), (5, 4),
-- Sale Team Leader
(8, 1), (8, 2), (8, 3), (8, 4);
```

### 2. **Division Leader không thấy đơn của tất cả cấp dưới**
**Nguyên nhân**: Query chỉ lấy subordinates trực tiếp, không lấy recursive (ví dụ: Leader → Manager → Employee)

**Giải pháp**: Đã sửa `UserDAO.getSubordinates()` để dùng CTE (Common Table Expression) lấy toàn bộ cây phân cấp

**File đã sửa**: `src/java/dao/UserDAO.java`

### 3. **Thêm hệ thống Notification**
**Tính năng mới**: Thông báo khi đơn được duyệt/từ chối

**Các file mới**:
- `database/notification-schema.sql` - Schema cho bảng Notification
- `src/java/model/Notification.java` - Model
- `src/java/dao/NotificationDAO.java` - DAO
- `src/java/controller/NotificationServlet.java` - Controller
- Cập nhật `ReviewRequestServlet.java` - Tạo notification khi duyệt
- Cập nhật `header.jsp` - UI notification bell
- Cập nhật `style.css` - CSS cho notification

---

## 📋 Các bước cập nhật

### Bước 1: Cập nhật Database

```sql
-- 1. Chạy file tạo bảng Notification
USE LeaveManagement;
GO

-- Chạy file: database/notification-schema.sql
-- Hoặc copy-paste SQL này:

CREATE TABLE Notification (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    title NVARCHAR(200) NOT NULL,
    message NVARCHAR(1000) NOT NULL,
    type NVARCHAR(20) NOT NULL,
    is_read BIT DEFAULT 0,
    related_request_id INT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Notification_User FOREIGN KEY (user_id) 
        REFERENCES [User](id) ON DELETE CASCADE,
    CONSTRAINT FK_Notification_Request FOREIGN KEY (related_request_id) 
        REFERENCES Request(id) ON DELETE SET NULL
);

CREATE INDEX IDX_Notification_User ON Notification(user_id, is_read);
CREATE INDEX IDX_Notification_CreatedAt ON Notification(created_at DESC);
GO

-- 2. Cập nhật quyền cho Team Leader
UPDATE Role_Feature SET role_id = 2, feature_id = 2 
WHERE NOT EXISTS (
    SELECT 1 FROM Role_Feature WHERE role_id = 2 AND feature_id = 2
);

INSERT INTO Role_Feature (role_id, feature_id) 
SELECT 2, 2 WHERE NOT EXISTS (SELECT 1 FROM Role_Feature WHERE role_id = 2 AND feature_id = 2)
UNION ALL
SELECT 5, 2 WHERE NOT EXISTS (SELECT 1 FROM Role_Feature WHERE role_id = 5 AND feature_id = 2)
UNION ALL
SELECT 8, 2 WHERE NOT EXISTS (SELECT 1 FROM Role_Feature WHERE role_id = 8 AND feature_id = 2);
GO
```

### Bước 2: Clean and Build Project

1. Trong NetBeans: **Clean and Build** (Shift + F11)
2. Kiểm tra không có lỗi compile

### Bước 3: Restart Server

1. Stop Tomcat server
2. Start lại Tomcat
3. Truy cập: `http://localhost:8080/PRI301_FinalProject/`

---

## 🎯 Kiểm tra các tính năng

### Test Case 1: Team Leader tạo đơn
1. Đăng nhập: `it_manager / 123456`
2. Click "Tạo đơn" → **Phải vào được** (không còn 403)
3. Tạo đơn thành công

### Test Case 2: Division Leader xem đơn cấp dưới
1. Đăng nhập: `it_leader / 123456`
2. Vào "Danh sách đơn"
3. Phần "Đơn của cấp dưới" → **Phải hiển thị đơn của it_emp1, it_emp2** (không chỉ it_manager)

### Test Case 3: Notification
1. Đăng nhập: `it_emp1 / 123456`
2. Tạo đơn nghỉ phép
3. Đăng xuất, đăng nhập: `it_manager / 123456`
4. Duyệt/Từ chối đơn
5. Đăng xuất, đăng nhập lại: `it_emp1 / 123456`
6. Kiểm tra **icon chuông 🔔** trên header → Phải có badge số thông báo
7. Click chuông → Xem notification

---

## 🎨 Giao diện Notification

### Notification Bell
- **Vị trí**: Header, bên trái tên user
- **Icon**: 🔔 với badge đỏ hiển thị số thông báo chưa đọc
- **Dropdown**: Click vào chuông để xem danh sách

### Notification Item
- **Chưa đọc**: Nền xanh nhạt (#e3f2fd)
- **Đã đọc**: Nền trắng
- **Nội dung**: 
  - Tiêu đề (✅ Approved / ❌ Rejected)
  - Thông tin đơn (từ ngày, đến ngày)
  - Người duyệt
  - Lý do (nếu có)
  - Thời gian

### Actions
- **Đánh dấu tất cả đã đọc**: Link ở header của dropdown
- **Auto-close**: Click bên ngoài dropdown để đóng

---

## 📝 Notes

### Lỗi Servlet API
Các lỗi `javax.servlet cannot be resolved` là do thiếu thư viện. Đảm bảo đã thêm:
- `servlet-api.jar` (có sẵn trong Tomcat)
- `jstl-1.2.jar`
- `sqljdbc42.jar`

### Performance
- Notification được cache trong header (load mỗi lần refresh)
- Chỉ hiển thị 5 notification gần nhất
- Index được tạo cho query nhanh

### Security
- Notification chỉ hiển thị cho user sở hữu
- Không thể xem notification của người khác
- Filter authentication bảo vệ endpoint

---

## 🚀 Tính năng Notification

### Khi nào tạo notification?
- ✅ Đơn được **Approved**
- ❌ Đơn bị **Rejected**

### Nội dung notification
- **Title**: "✅ Đơn nghỉ phép được phê duyệt" hoặc "❌ Đơn nghỉ phép bị từ chối"
- **Message**: 
  - Thông tin đơn (từ ngày, đến ngày)
  - Người xử lý
  - Lý do (nếu có)
- **Type**: `success` (approved) hoặc `error` (rejected)
- **Link**: Có thể click vào notification để xem chi tiết đơn (tùy chọn)

### API Endpoints
- `GET /notification/mark-all-read` - Đánh dấu tất cả đã đọc

---

## ✨ Tổng kết

**3 vấn đề đã được sửa hoàn toàn:**

1. ✅ **Team Leader vào được trang Create**
   - Thêm quyền `/request/create` vào Role_Feature

2. ✅ **Division Leader thấy tất cả đơn cấp dưới**
   - Sử dụng CTE recursive trong UserDAO

3. ✅ **Hệ thống Notification hoàn chỉnh**
   - Bảng Notification trong database
   - NotificationDAO với CRUD operations
   - UI notification bell với dropdown
   - Auto-create notification khi duyệt đơn

**Chúc bạn code vui vẻ! 🎉**
