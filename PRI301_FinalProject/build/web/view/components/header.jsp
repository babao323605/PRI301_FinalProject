<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="dao.NotificationDAO, dao.RoleDAO, model.Notification, java.util.List" %>
<%
    // Lấy notifications cho user hiện tại
    model.User currentUser = (model.User) session.getAttribute("user");
    if (currentUser != null) {
        NotificationDAO notifDAO = new NotificationDAO();
        List<Notification> notifications = notifDAO.getNotificationsByUser(currentUser.getId(), 5);
        int unreadCount = notifDAO.countUnreadNotifications(currentUser.getId());
        request.setAttribute("notifications", notifications);
        request.setAttribute("unreadCount", unreadCount);
        
        // Kiểm tra quyền truy cập agenda
        RoleDAO roleDAO = new RoleDAO();
        boolean hasAgendaAccess = roleDAO.hasFeature(currentUser.getId(), "/request/agenda");
        request.setAttribute("hasAgendaAccess", hasAgendaAccess);
    }
%>
<header class="header">
    <div class="header-container">
        <div class="logo">
            <h2>🏢 Leave Management</h2>
        </div>
        
        <nav class="nav-menu">
            <a href="${pageContext.request.contextPath}/home" class="nav-link">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/request/create" class="nav-link">Tạo đơn</a>
            <a href="${pageContext.request.contextPath}/request/list" class="nav-link">Danh sách đơn</a>
            <c:if test="${hasAgendaAccess}">
                <a href="${pageContext.request.contextPath}/request/agenda" class="nav-link">Agenda tình hình lao động</a>
            </c:if>
        </nav>
        
        <div class="user-menu">
            <!-- Notification Bell -->
            <div class="notification-container">
                <button class="notification-bell" onclick="toggleNotifications()">
                    🔔
                    <c:if test="${unreadCount > 0}">
                        <span class="notification-badge">${unreadCount}</span>
                    </c:if>
                </button>
                
                <div class="notification-dropdown" id="notificationDropdown">
                    <div class="notification-header">
                        <h4>Thông báo</h4>
                        <c:if test="${unreadCount > 0}">
                            <a href="${pageContext.request.contextPath}/notification/mark-all-read" class="mark-all-read">Đánh dấu đã đọc</a>
                        </c:if>
                    </div>
                    
                    <div class="notification-list">
                        <c:choose>
                            <c:when test="${empty notifications}">
                                <div class="notification-empty">
                                    <p>Không có thông báo mới</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="notif" items="${notifications}">
                                    <div class="notification-item ${notif.read ? '' : 'unread'}">
                                        <div class="notification-content">
                                            <h5>${notif.title}</h5>
                                            <p>${notif.message}</p>
                                            <small>${notif.createdAt}</small>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            
            <span class="user-name">${sessionScope.user.name}</span>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
        </div>
    </div>
</header>

<script>
function toggleNotifications() {
    const dropdown = document.getElementById('notificationDropdown');
    dropdown.classList.toggle('show');
}

// Đóng dropdown khi click bên ngoài
window.onclick = function(event) {
    if (!event.target.matches('.notification-bell') && !event.target.matches('.notification-bell *')) {
        const dropdown = document.getElementById('notificationDropdown');
        if (dropdown.classList.contains('show')) {
            dropdown.classList.remove('show');
        }
    }
}
</script>
