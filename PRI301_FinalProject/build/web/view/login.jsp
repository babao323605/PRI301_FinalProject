<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Hệ thống quản lý nghỉ phép</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .login-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            width: 100%;
            max-width: 400px;
        }
        
        .login-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        
        .login-header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .login-header p {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .login-body {
            padding: 40px 30px;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .error-message {
            background: #fee;
            color: #c33;
            padding: 12px 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 14px;
            border-left: 4px solid #c33;
        }
        
        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }
        
        .btn-login:active {
            transform: translateY(0);
        }
        
        .login-footer {
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 13px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>Chào mừng trở lại</h1>
            <p>Hệ thống quản lý nghỉ phép</p>
        </div>
        
        <div class="login-body">
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="form-group">
                    <label for="username">Tên đăng nhập</label>
                    <input type="text" 
                           id="username" 
                           name="username" 
                           value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                           placeholder="Nhập tên đăng nhập" 
                           required 
                           autofocus>
                </div>
                
                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <input type="password" 
                           id="password" 
                           name="password" 
                           placeholder="Nhập mật khẩu" 
                           required>
                </div>
                
                <button type="submit" class="btn-login">Đăng nhập</button>
            </form>
            
            <div class="login-footer">
                <p>© 2025 Leave Management System</p>
            </div>
        </div>
    </div>
</body>
</html>
