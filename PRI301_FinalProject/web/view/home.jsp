<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ - Hệ thống quản lý nghỉ phép</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="components/header.jsp" />
    
    <div class="container">
        <div class="welcome-section">
            <h1>Xin chào, ${sessionScope.user.name}!</h1>
            <p class="subtitle">Chào mừng bạn đến với hệ thống quản lý nghỉ phép</p>
        </div>
        
        <div class="info-cards">
            <div class="info-card">
                <div class="card-icon">👤</div>
                <div class="card-content">
                    <h3>Thông tin cá nhân</h3>
                    <p><strong>Tên:</strong> ${sessionScope.user.name}</p>
                    <p><strong>Email:</strong> ${sessionScope.user.email}</p>
                    <p><strong>Phòng ban:</strong> ${department.name}</p>
                </div>
            </div>
            
            <div class="info-card">
                <div class="card-icon">🎭</div>
                <div class="card-content">
                    <h3>Vai trò của bạn</h3>
                    <c:forEach var="role" items="${roles}">
                        <span class="badge">${role.name}</span>
                    </c:forEach>
                </div>
            </div>
            
            <div class="info-card">
                <div class="card-icon">🔑</div>
                <div class="card-content">
                    <h3>Quyền truy cập</h3>
                    <ul class="feature-list">
                        <c:forEach var="feature" items="${features}">
                            <li>${feature.description != null ? feature.description : feature.name}</li>
                        </c:forEach>
                    </ul>
                </div>
            </div>
        </div>
        
        <div class="quick-actions">
            <h2>Thao tác nhanh</h2>
            <div class="action-buttons">
                <c:forEach var="feature" items="${features}">
                    <c:if test="${feature.name == '/request/create'}">
                        <a href="${pageContext.request.contextPath}/request/create" class="action-btn primary">
                            📝 Tạo đơn nghỉ phép
                        </a>
                    </c:if>
                    <c:if test="${feature.name == '/request/list'}">
                        <a href="${pageContext.request.contextPath}/request/list" class="action-btn">
                            📋 Xem danh sách đơn
                        </a>
                    </c:if>
                    <c:if test="${feature.name == '/request/review'}">
                        <a href="${pageContext.request.contextPath}/request/list" class="action-btn">
                            ✅ Duyệt đơn
                        </a>
                    </c:if>
                </c:forEach>
            </div>
        </div>
    </div>
    
    <jsp:include page="components/footer.jsp" />
</body>
</html>
