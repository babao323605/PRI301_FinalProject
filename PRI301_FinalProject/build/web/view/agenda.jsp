<%@page import="java.util.Calendar"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agenda - Tình hình lao động</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .agenda-container {
            background: #f8f9fa;
            min-height: 100vh;
            padding: 20px 0;
        }
        
        .agenda-header-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        
        .agenda-header-section h1 {
            margin: 0 0 10px 0;
            font-size: 32px;
            color: white;
        }
        
        .agenda-header-section .department-info {
            font-size: 18px;
            opacity: 0.95;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-box {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            text-align: center;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .stat-box:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }
        
        .stat-icon {
            font-size: 36px;
            margin-bottom: 10px;
        }
        
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
            margin: 10px 0;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .filter-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            margin-bottom: 25px;
        }
        
        .filter-row {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        
        .filter-group {
            flex: 1;
            min-width: 200px;
        }
        
        .filter-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
        }
        
        .filter-group input {
            width: 100%;
            padding: 10px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .filter-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .btn-filter {
            padding: 10px 25px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: background 0.3s;
        }
        
        .btn-filter:hover {
            background: #5568d3;
        }
        
        .btn-month {
            padding: 10px 25px;
            background: #6c757d;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: background 0.3s;
        }
        
        .btn-month:hover {
            background: #5a6268;
        }
        
        .agenda-table-wrapper {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            overflow: hidden;
            overflow-x: auto;
        }
        
        .agenda-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 800px;
        }
        
        .agenda-table thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .agenda-table th {
            padding: 15px 12px;
            text-align: center;
            font-weight: 600;
            position: sticky;
            top: 0;
            z-index: 10;
            white-space: nowrap;
        }
        
        .agenda-table th:first-child {
            position: sticky;
            left: 0;
            z-index: 11;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-width: 180px;
            text-align: left;
            padding-left: 20px;
        }
        
        .agenda-table th.weekend {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        
        .agenda-table th .date-day {
            font-size: 16px;
            font-weight: 600;
        }
        
        .agenda-table th .date-dow {
            font-size: 11px;
            font-weight: normal;
            opacity: 0.9;
            margin-top: 4px;
        }
        
        .agenda-table td {
            padding: 12px;
            text-align: center;
            border: 1px solid #e8e9ea;
            min-width: 70px;
            position: relative;
        }
        
        .agenda-table td.employee-cell {
            background: #f8f9fa;
            font-weight: 500;
            text-align: left;
            padding-left: 20px;
            position: sticky;
            left: 0;
            z-index: 5;
            border-right: 2px solid #dee2e6;
        }
        
        .agenda-table td.present {
            background: #d1e7dd;
            color: #0f5132;
        }
        
        .agenda-table td.absent {
            background: #f8d7da;
            color: #842029;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .agenda-table td.absent:hover {
            background: #f5c2c7;
            transform: scale(1.1);
            z-index: 20;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
        
        .agenda-table td.weekend {
            background: #fff3cd !important;
            color: #856404;
        }
        
        .agenda-table td.weekend.absent {
            background: #f8d7da !important;
            color: #842029;
        }
        
        .status-icon {
            font-size: 18px;
            font-weight: bold;
        }
        
        .legend-container {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin-top: 25px;
            padding: 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            flex-wrap: wrap;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .legend-color {
            width: 28px;
            height: 28px;
            border-radius: 6px;
            border: 2px solid #ddd;
        }
        
        .legend-text {
            color: #333;
            font-size: 14px;
        }
        
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 2000;
            animation: fadeIn 0.3s;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .modal-dialog {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            border-radius: 15px;
            padding: 0;
            max-width: 650px;
            width: 90%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            animation: slideDown 0.3s;
        }
        
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translate(-50%, -60%);
            }
            to {
                opacity: 1;
                transform: translate(-50%, -50%);
            }
        }
        
        .modal-header {
            padding: 25px 30px;
            border-bottom: 2px solid #e8e9ea;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 15px 15px 0 0;
        }
        
        .modal-header h2 {
            margin: 0;
            color: white;
            font-size: 24px;
        }
        
        .modal-close {
            background: rgba(255,255,255,0.2);
            border: none;
            color: white;
            font-size: 28px;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.3s;
        }
        
        .modal-close:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .modal-body {
            padding: 30px;
        }
        
        .detail-section {
            margin-bottom: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        
        .detail-label {
            font-weight: 600;
            color: #667eea;
            margin-bottom: 8px;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .detail-value {
            color: #333;
            font-size: 16px;
        }
        
        .request-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .request-item {
            padding: 12px;
            margin-bottom: 10px;
            background: white;
            border-radius: 6px;
            border-left: 3px solid #667eea;
        }
        
        .request-title {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        
        .request-info {
            color: #666;
            font-size: 13px;
            margin: 3px 0;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        
        .empty-state-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }
        
        .empty-state-text {
            font-size: 18px;
        }
    </style>
</head>
<body>
    <jsp:include page="components/header.jsp" />
    
    <div class="agenda-container">
        <div class="container">
            <!-- Header Section -->
            <div class="agenda-header-section">
                <h1>📅 Agenda - Tình hình lao động</h1>
                <div class="department-info">
                    <strong>Phòng ban:</strong> ${department != null ? department.name : 'N/A'}
                    <c:if test="${department != null && department.description != null}">
                        - ${department.description}
                    </c:if>
                </div>
            </div>
            
            <c:if test="${not empty error}">
                <div class="error-message" style="margin-bottom: 20px;">${error}</div>
            </c:if>
            
            <!-- Statistics -->
            <c:if test="${totalEmployees > 0}">
                <div class="stats-grid">
                    <div class="stat-box">
                        <div class="stat-icon">👥</div>
                        <div class="stat-number">${totalEmployees}</div>
                        <div class="stat-label">Tổng nhân viên</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-icon">📊</div>
                        <div class="stat-number">${totalLeaveDays}</div>
                        <div class="stat-label">Tổng ngày nghỉ</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-icon">📋</div>
                        <div class="stat-number">${approvedRequests != null ? approvedRequests.size() : 0}</div>
                        <div class="stat-label">Đơn đã duyệt</div>
                    </div>
                </div>
            </c:if>
            
            <!-- Filter Section -->
            <div class="filter-card">
                <form action="${pageContext.request.contextPath}/request/agenda" method="get" id="filterForm">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="departmentId">🏢 Phòng ban</label>
                            <select id="departmentId" 
                                    name="departmentId" 
                                    style="width: 100%; padding: 10px; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 14px;">
                                <c:forEach var="dept" items="${allDepartments}">
                                    <option value="${dept.id}" ${dept.id == selectedDepartmentId ? 'selected' : ''}>
                                        ${dept.name}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="fromDate">📅 Từ ngày</label>
                            <input type="date" 
                                   id="fromDate" 
                                   name="fromDate" 
                                   value="${fromDate}"
                                   required>
                        </div>
                        <div class="filter-group">
                            <label for="toDate">📅 Đến ngày</label>
                            <input type="date" 
                                   id="toDate" 
                                   name="toDate" 
                                   value="${toDate}"
                                   required>
                        </div>
                        <div>
                            <button type="submit" class="btn-filter">🔍 Xem</button>
                        </div>
                        <div>
                            <button type="button" onclick="setCurrentMonth()" class="btn-month">📆 Tháng này</button>
                        </div>
                    </div>
                </form>
            </div>
            
            <!-- Agenda Table -->
            <c:if test="${not empty employees && not empty dates}">
                <div class="agenda-table-wrapper">
                    <table class="agenda-table">
                        <thead>
                            <tr>
                                <th>Nhân viên</th>
                                <c:forEach var="date" items="${dates}">
                                    <%
                                        // Kiểm tra weekend
                                        java.sql.Date dateObj = (java.sql.Date)pageContext.getAttribute("date");
                                        java.util.Calendar cal = java.util.Calendar.getInstance();
                                        cal.setTime(dateObj);
                                        int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
                                        boolean isWeekend = (dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY);
                                        pageContext.setAttribute("isWeekendHeader", isWeekend);
                                    %>
                                    <th class="${isWeekendHeader ? 'weekend' : ''}">
                                        <div class="date-day">
                                            <fmt:formatDate value="${date}" pattern="dd/MM"/>
                                        </div>
                                        <div class="date-dow">
                                            <fmt:formatDate value="${date}" pattern="EEE"/>
                                        </div>
                                    </th>
                                </c:forEach>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="employee" items="${employees}">
                                <tr>
                                    <td class="employee-cell">${employee.name}</td>
                                    <c:forEach var="date" items="${dates}">
                                        <fmt:formatDate value="${date}" pattern="yyyy-MM-dd" var="dateKey" />
                                        
                                        <c:set var="employeeRequests" value="" />
                                        <c:set var="hasLeave" value="false" />
                                        
                                        <c:if test="${requestMapByUser != null && requestMapByUser.containsKey(employee.id)}">
                                            <c:forEach var="req" items="${requestMapByUser[employee.id]}">
                                                <c:if test="${req.fromDate <= date && req.toDate >= date}">
                                                    <c:set var="hasLeave" value="true" />
                                                    <fmt:formatDate value="${req.fromDate}" pattern="yyyy-MM-dd" var="reqFromDateStr" />
                                                    <fmt:formatDate value="${req.toDate}" pattern="yyyy-MM-dd" var="reqToDateStr" />
                                                    <c:set var="reqTitle" value="${req.title != null && req.title != '' ? req.title : 'Nghỉ phép'}" />
                                                    <c:set var="reqReason" value="${req.reason != null ? req.reason : ''}" />
                                                    <c:set var="reqProcessReason" value="${req.processReason != null ? req.processReason : ''}" />
                                                    <c:set var="employeeRequests" 
                                                           value="${employeeRequests}${reqTitle}|${reqReason}|${reqFromDateStr}|${reqToDateStr}|${reqProcessReason};" />
                                                </c:if>
                                            </c:forEach>
                                        </c:if>
                                        
                                        <%
                                            // Kiểm tra weekend
                                            java.sql.Date cellDate = (java.sql.Date)pageContext.getAttribute("date");
                                            java.util.Calendar cellCal = java.util.Calendar.getInstance();
                                            cellCal.setTime(cellDate);
                                            int cellDayOfWeek = cellCal.get(Calendar.DAY_OF_WEEK);
                                            boolean cellIsWeekend = (cellDayOfWeek == Calendar.SATURDAY || cellDayOfWeek == Calendar.SUNDAY);
                                            pageContext.setAttribute("cellIsWeekend", cellIsWeekend);
                                        %>
                                        
                                        <td class="${hasLeave ? 'absent' : 'present'} ${cellIsWeekend ? 'weekend' : ''}"
                                            data-employee-name="${employee.name}"
                                            data-date="${dateKey}"
                                            data-requests="${employeeRequests}"
                                            <c:if test="${hasLeave}">
                                            style="cursor: pointer;"
                                            onclick="showLeaveDetails(this)"
                                            </c:if>
                                            title="${hasLeave ? 'Click để xem chi tiết đơn nghỉ' : 'Có mặt'}">
                                            <span class="status-icon">${hasLeave ? '❌' : '✅'}</span>
                                        </td>
                                    </c:forEach>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                
                <!-- Legend -->
                <div class="legend-container">
                    <div class="legend-item">
                        <div class="legend-color" style="background: #d1e7dd;"></div>
                        <span class="legend-text">✅ Có mặt</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-color" style="background: #f8d7da;"></div>
                        <span class="legend-text">❌ Nghỉ phép</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-color" style="background: #fff3cd;"></div>
                        <span class="legend-text">📅 Cuối tuần</span>
                    </div>
                </div>
            </c:if>
            
            <c:if test="${empty employees}">
                <div class="empty-state">
                    <div class="empty-state-icon">👥</div>
                    <div class="empty-state-text">Không có nhân viên trong phòng ban</div>
                </div>
            </c:if>
            
            <c:if test="${empty dates}">
                <div class="empty-state">
                    <div class="empty-state-icon">📅</div>
                    <div class="empty-state-text">Vui lòng chọn khoảng thời gian để xem</div>
                </div>
            </c:if>
        </div>
    </div>
    
    <!-- Modal Detail -->
    <div id="leaveDetailModal" class="modal-overlay" onclick="closeModal(event)">
        <div class="modal-dialog" onclick="event.stopPropagation()">
            <div class="modal-header">
                <h2>📋 Chi tiết nghỉ phép</h2>
                <button class="modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-body" id="modalContent">
                <!-- Content will be loaded here -->
            </div>
        </div>
    </div>
    
    <jsp:include page="components/footer.jsp" />
    
    <script>
        function setCurrentMonth() {
            const now = new Date();
            const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
            const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0);
            
            document.getElementById('fromDate').value = formatDate(firstDay);
            document.getElementById('toDate').value = formatDate(lastDay);
            document.getElementById('filterForm').submit();
        }
        
        function formatDate(date) {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        }
        
        function showLeaveDetails(cell) {
            const employeeName = cell.getAttribute('data-employee-name');
            const date = cell.getAttribute('data-date');
            const requestsStr = cell.getAttribute('data-requests');
            
            if (!requestsStr || requestsStr.trim() === '') {
                return;
            }
            
            const requests = requestsStr.split(';').filter(r => r.trim() !== '');
            
            let html = '';
            html += '<div class="detail-section">';
            html += '<div class="detail-label">Nhân viên</div>';
            html += '<div class="detail-value">' + escapeHtml(employeeName) + '</div>';
            html += '</div>';
            
            html += '<div class="detail-section">';
            html += '<div class="detail-label">Ngày</div>';
            html += '<div class="detail-value">' + formatDateDisplay(date) + '</div>';
            html += '</div>';
            
            if (requests.length > 0) {
                html += '<div class="detail-section">';
                html += '<div class="detail-label">Đơn nghỉ phép</div>';
                html += '<ul class="request-list">';
                
                requests.forEach(function(requestStr) {
                    if (requestStr.trim() === '') return;
                    const parts = requestStr.split('|');
                    const title = parts[0] || 'Nghỉ phép';
                    const reason = parts[1] || '';
                    const fromDate = parts[2] || '';
                    const toDate = parts[3] || '';
                    const processReason = parts[4] || '';
                    
                    html += '<li class="request-item">';
                    html += '<div class="request-title">' + escapeHtml(title) + '</div>';
                    if (reason) {
                        html += '<div class="request-info"><strong>Lý do:</strong> ' + escapeHtml(reason) + '</div>';
                    }
                    if (fromDate && toDate) {
                        html += '<div class="request-info"><strong>Thời gian:</strong> ' + formatDateDisplay(fromDate) + ' - ' + formatDateDisplay(toDate) + '</div>';
                    }
                    if (processReason) {
                        html += '<div class="request-info" style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #eee;"><strong>Lời phê duyệt:</strong><br>' + escapeHtml(processReason).replace(/\n/g, '<br>') + '</div>';
                    }
                    html += '</li>';
                });
                
                html += '</ul>';
                html += '</div>';
            }
            
            document.getElementById('modalContent').innerHTML = html;
            document.getElementById('leaveDetailModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal(event) {
            if (event && event.target !== event.currentTarget) {
                return;
            }
            document.getElementById('leaveDetailModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        
        function formatDateDisplay(dateStr) {
            if (!dateStr) return '';
            const date = new Date(dateStr + 'T00:00:00');
            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const year = date.getFullYear();
            const dayNames = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
            const dayName = dayNames[date.getDay()];
            return `${dayName}, ${day}/${month}/${year}`;
        }
        
        function escapeHtml(text) {
            if (!text) return '';
            const map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return text.replace(/[&<>"']/g, function(m) { return map[m]; });
        }
        
        // Close modal on ESC key
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                closeModal();
            }
        });
    </script>
</body>
</html>

