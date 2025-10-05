# 🏢 Hệ thống quản lý nghỉ phép (Leave Management System)

Hệ thống quản lý đơn xin nghỉ phép của nhân viên với kiến trúc MVC sử dụng JSP/Servlet.

## 📋 Mục lục

- [Tính năng](#tính-năng)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Cấu trúc dự án](#cấu-trúc-dự-án)
- [Cài đặt](#cài-đặt)
- [Cấu hình](#cấu-hình)
- [Chạy ứng dụng](#chạy-ứng-dụng)
- [Tài khoản test](#tài-khoản-test)

## ✨ Tính năng

### Nhân viên (Employee)
- ✅ Đăng nhập/Đăng xuất
- ✅ Tạo đơn xin nghỉ phép
- ✅ Xem danh sách đơn của bản thân
- ✅ Xem trạng thái đơn (Chờ duyệt/Đã duyệt/Từ chối)

### Quản lý trực tiếp (Team Leader)
- ✅ Tất cả tính năng của Nhân viên
- ✅ Xem danh sách đơn của cấp dưới
- ✅ Phê duyệt/Từ chối đơn nghỉ phép

### Trưởng phòng (Division Leader)
- ✅ Tất cả tính năng của Team Leader
- ✅ Xem agenda tình hình lao động toàn phòng
- ✅ Sửa đơn nghỉ phép
- ✅ Xem calendar nghỉ phép theo ngày

## 🛠 Công nghệ sử dụng

- **Backend**: Java Servlet, JSP
- **Database**: SQL Server
- **Architecture**: MVC (Model-View-Controller)
- **Frontend**: HTML5, CSS3, JavaScript
- **Server**: Apache Tomcat 9.0+
- **JDK**: Java 8+

## 📁 Cấu trúc dự án

```
PRI301_FinalProject/
├── src/java/
│   ├── model/              # Model classes (User, Request, Role, etc.)
│   ├── dao/                # Data Access Objects
│   ├── dal/                # Database Access Layer (DBContext)
│   ├── controller/         # Servlets (Controllers)
│   └── filter/             # Authentication & Authorization Filters
├── web/
│   ├── view/               # JSP Views
│   │   ├── components/     # Reusable components (header, footer)
│   │   ├── login.jsp
│   │   ├── home.jsp
│   │   ├── create-request.jsp
│   │   ├── list-request.jsp
│   │   ├── review-request.jsp
│   │   └── agenda.jsp
│   ├── css/                # Stylesheets
│   └── WEB-INF/
│       └── web.xml         # Web configuration
└── database/
    ├── schema.sql          # Database schema
    └── sample-data.sql     # Sample data
```

## 🚀 Cài đặt

### 1. Yêu cầu hệ thống

- JDK 8 trở lên
- Apache Tomcat 9.0+
- SQL Server 2016+
- NetBeans IDE (hoặc IDE tương tự)
- SQL Server JDBC Driver

### 2. Cài đặt Database

```sql
-- Chạy file schema.sql để tạo cấu trúc database
sqlcmd -S localhost -i database/schema.sql

-- Chạy file sample-data.sql để insert dữ liệu mẫu
sqlcmd -S localhost -i database/sample-data.sql
```

### 3. Cài đặt thư viện

**Thêm các thư viện sau vào project:**

1. **SQL Server JDBC Driver** (`sqljdbc42.jar` hoặc mới hơn)
   - Download từ: https://docs.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server
   - Copy vào `lib` folder của project

2. **Servlet API** (Đã có sẵn trong Tomcat)
   - `servlet-api.jar`

3. **JSTL** (JSP Standard Tag Library)
   - `jstl-1.2.jar`
   - `standard-1.1.2.jar`
   - Download từ: https://tomcat.apache.org/taglibs/standard/

**Cách thêm thư viện trong NetBeans:**
1. Right-click project → Properties
2. Libraries → Add JAR/Folder
3. Chọn các file JAR đã download

## ⚙️ Cấu hình

### 1. Cấu hình Database

Mở file `src/java/dal/DBContext.java` và cập nhật thông tin kết nối:

```java
private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=LeaveManagement";
private static final String DB_USER = "sa";
private static final String DB_PASSWORD = "your_password";
```

### 2. Cấu hình Tomcat trong NetBeans

1. Right-click project → Properties
2. Run → Server: Chọn Apache Tomcat
3. Context Path: `/PRI301_FinalProject` (hoặc tùy chỉnh)

## 🎯 Chạy ứng dụng

### Trong NetBeans:

1. Clean and Build project (Shift + F11)
2. Run project (F6)
3. Trình duyệt sẽ tự động mở: `http://localhost:8080/PRI301_FinalProject/`

### Thủ công:

1. Build project thành WAR file
2. Deploy WAR file vào Tomcat webapps folder
3. Start Tomcat server
4. Truy cập: `http://localhost:8080/PRI301_FinalProject/`

## 👥 Tài khoản test

### IT Department

| Username | Password | Role | Mô tả |
|----------|----------|------|-------|
| `it_leader` | `123456` | Division Leader | Trưởng phòng IT - Full quyền |
| `it_manager` | `123456` | Team Leader | Quản lý nhóm - Duyệt đơn |
| `it_emp1` | `123456` | Employee | Nhân viên - Tạo đơn |
| `it_emp2` | `123456` | Employee | Nhân viên - Tạo đơn |

### QA Department

| Username | Password | Role |
|----------|----------|------|
| `qa_leader` | `123456` | Division Leader |
| `qa_manager` | `123456` | Team Leader |
| `qa_emp1` | `123456` | Employee |

### Sale Department

| Username | Password | Role |
|----------|----------|------|
| `sale_leader` | `123456` | Division Leader |
| `sale_manager` | `123456` | Team Leader |
| `sale_emp1` | `123456` | Employee |

## 🔐 Phân quyền (RBAC)

### Employee
- `/home` - Trang chủ
- `/request/create` - Tạo đơn
- `/request/list` - Xem đơn của mình

### Team Leader (+ Employee)
- `/request/review` - Duyệt đơn cấp dưới

### Division Leader (+ Team Leader)
- `/request/modify` - Sửa đơn
- `/request/agenda` - Xem agenda phòng ban

## 📊 Database Schema

### Core Tables
- `User` - Thông tin người dùng
- `Department` - Phòng ban
- `Role` - Vai trò
- `Feature` - Quyền truy cập
- `Request` - Đơn nghỉ phép
- `User_Role` - Mapping User-Role
- `Role_Feature` - Mapping Role-Feature

### Relationships
- User → Department (Many-to-One)
- User → User (Self-reference: manager_id)
- User ↔ Role (Many-to-Many)
- Role ↔ Feature (Many-to-Many)
- Request → User (created_by, processed_by)

## 🎨 Giao diện

- **Design**: Modern, clean, white background
- **Responsive**: Mobile-friendly
- **Color scheme**: Purple gradient (#667eea → #764ba2)
- **Components**: Cards, badges, tables, forms

## 📝 Workflow

```
1. Employee tạo đơn → Status: Inprogress
2. Manager nhận thông báo
3. Manager xét duyệt:
   - Approve → Status: Approved
   - Reject → Status: Rejected
4. Division Leader xem agenda
```

## 🐛 Troubleshooting

### Lỗi kết nối database
- Kiểm tra SQL Server đang chạy
- Kiểm tra thông tin kết nối trong `DBContext.java`
- Kiểm tra JDBC Driver đã được thêm vào project

### Lỗi Servlet/JSP
- Kiểm tra Tomcat đã được cấu hình đúng
- Kiểm tra servlet-api.jar trong classpath
- Clean and Build lại project

### Lỗi JSTL
- Kiểm tra jstl-1.2.jar đã được thêm
- Kiểm tra taglib directive trong JSP

## 📞 Liên hệ

Nếu có vấn đề, vui lòng tạo issue hoặc liên hệ qua email.

---

**© 2025 Leave Management System - All Rights Reserved**
