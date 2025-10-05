<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách đơn nghỉ phép</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="components/header.jsp" />
    
    <div class="container">
        <h1 style="color: #667eea; margin-bottom: 30px;">📋 Danh sách đơn nghỉ phép</h1>
        
        <c:if test="${not empty success}">
            <div class="success-message">${success}</div>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="error-message">${error}</div>
        </c:if>
        
        <!-- Đơn của bản thân -->
        <div class="table-container" style="margin-bottom: 30px;">
            <h2 style="color: #667eea; margin-bottom: 20px;">Đơn của tôi</h2>
            
            <c:if test="${empty ownRequests}">
                <p style="text-align: center; color: #777; padding: 30px;">
                    Bạn chưa có đơn nào. 
                    <a href="${pageContext.request.contextPath}/request/create" style="color: #667eea;">Tạo đơn mới</a>
                </p>
            </c:if>
            
            <c:if test="${not empty ownRequests}">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tiêu đề</th>
                            <th>Từ ngày</th>
                            <th>Đến ngày</th>
                            <th>Lý do</th>
                            <th>Trạng thái</th>
                            <th>Người duyệt</th>
                            <th>Lời phê duyệt</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="req" items="${ownRequests}">
                            <tr data-request-id="${req.id}"
                                data-title="<c:out value='${req.title != null ? req.title : "-"}'/>"
                                data-from-date="<fmt:formatDate value='${req.fromDate}' pattern='dd/MM/yyyy'/>"
                                data-to-date="<fmt:formatDate value='${req.toDate}' pattern='dd/MM/yyyy'/>"
                                data-reason="<c:out value='${req.reason != null ? req.reason : "-"}'/>"
                                data-status="${req.status}"
                                data-processed-by="<c:out value='${req.processedByName != null ? req.processedByName : "-"}'/>"
                                data-process-reason="<c:out value='${req.processReason != null ? req.processReason : ""}'/>"
                                data-created-at="<fmt:formatDate value='${req.createdAt}' pattern='dd/MM/yyyy HH:mm'/>">
                                <td>${req.id}</td>
                                <td>${req.title != null ? req.title : '-'}</td>
                                <td><fmt:formatDate value="${req.fromDate}" pattern="dd/MM/yyyy"/></td>
                                <td><fmt:formatDate value="${req.toDate}" pattern="dd/MM/yyyy"/></td>
                                <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" 
                                    title="${req.reason}">${req.reason}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${req.status == 'Inprogress'}">
                                            <span class="status-badge status-inprogress">Chờ duyệt</span>
                                        </c:when>
                                        <c:when test="${req.status == 'Approved'}">
                                            <span class="status-badge status-approved">Đã duyệt</span>
                                        </c:when>
                                        <c:when test="${req.status == 'Rejected'}">
                                            <span class="status-badge status-rejected">Từ chối</span>
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>${req.processedByName != null ? req.processedByName : '-'}</td>
                                <td style="max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                    <c:choose>
                                        <c:when test="${req.status != 'Inprogress' && req.processReason != null && !empty req.processReason}">
                                            <span title="${req.processReason}">${req.processReason}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #999;">-</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:if test="${req.status != 'Inprogress'}">
                                        <button onclick="showRequestDetail(${req.id})" 
                                                class="btn btn-secondary" 
                                                style="padding: 6px 12px; font-size: 13px; cursor: pointer;">
                                            Xem chi tiết
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>
        
        <!-- Đơn của cấp dưới (nếu có quyền review) -->
        <c:if test="${canReview}">
            <div class="table-container">
                <h2 style="color: #667eea; margin-bottom: 20px;">Đơn của cấp dưới</h2>
                
                <!-- Filter and Search Section -->
                <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                    <form action="${pageContext.request.contextPath}/request/list" method="get" id="filterForm">
                        <div style="display: flex; gap: 15px; flex-wrap: wrap; align-items: flex-end;">
                            <div style="flex: 1; min-width: 200px;">
                                <label for="search" style="display: block; margin-bottom: 8px; font-weight: 500; color: #333;">
                                    🔍 Tìm kiếm
                                </label>
                                <input type="text" 
                                       id="search" 
                                       name="search" 
                                       value="${searchQuery}"
                                       placeholder="Tìm theo tiêu đề, lý do, người tạo..."
                                       style="width: 100%; padding: 10px; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 14px;">
                            </div>
                            <div style="flex: 0 0 180px;">
                                <label for="status" style="display: block; margin-bottom: 8px; font-weight: 500; color: #333;">
                                    📊 Trạng thái
                                </label>
                                <select id="status" 
                                        name="status"
                                        style="width: 100%; padding: 10px; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 14px;">
                                    <option value="all" ${statusFilter == '' || statusFilter == 'all' ? 'selected' : ''}>Tất cả</option>
                                    <option value="Inprogress" ${statusFilter == 'Inprogress' ? 'selected' : ''}>Chờ duyệt</option>
                                    <option value="Approved" ${statusFilter == 'Approved' ? 'selected' : ''}>Đã duyệt</option>
                                    <option value="Rejected" ${statusFilter == 'Rejected' ? 'selected' : ''}>Từ chối</option>
                                </select>
                            </div>
                            <div>
                                <button type="submit" 
                                        style="padding: 10px 25px; background: #667eea; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 500;">
                                    🔍 Lọc
                                </button>
                            </div>
                            <div>
                                <button type="button" 
                                        onclick="resetFilter()"
                                        style="padding: 10px 25px; background: #6c757d; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 500;">
                                    🔄 Đặt lại
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
                
                <!-- Results count -->
                <c:if test="${totalSubordinateRequests > 0}">
                    <p style="color: #666; margin-bottom: 15px;">
                        Tìm thấy <strong>${totalSubordinateRequests}</strong> đơn
                    </p>
                </c:if>
                
                <c:if test="${empty requests}">
                    <p style="text-align: center; color: #777; padding: 30px;">
                        Không có đơn nào cần xử lý.
                    </p>
                </c:if>
                
                <c:if test="${not empty requests}">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Người tạo</th>
                                <th>Tiêu đề</th>
                                <th>Từ ngày</th>
                                <th>Đến ngày</th>
                                <th>Lý do</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="req" items="${requests}">
                                <tr>
                                    <td>${req.id}</td>
                                    <td>${req.createdByName}</td>
                                    <td>${req.title != null ? req.title : '-'}</td>
                                    <td><fmt:formatDate value="${req.fromDate}" pattern="dd/MM/yyyy"/></td>
                                    <td><fmt:formatDate value="${req.toDate}" pattern="dd/MM/yyyy"/></td>
                                    <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" 
                                        title="${req.reason}">${req.reason}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${req.status == 'Inprogress'}">
                                                <span class="status-badge status-inprogress">Chờ duyệt</span>
                                            </c:when>
                                            <c:when test="${req.status == 'Approved'}">
                                                <span class="status-badge status-approved">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${req.status == 'Rejected'}">
                                                <span class="status-badge status-rejected">Từ chối</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${req.status == 'Inprogress'}">
                                            <a href="${pageContext.request.contextPath}/request/review?id=${req.id}" 
                                               class="btn btn-primary" 
                                               style="padding: 6px 12px; font-size: 13px;">
                                                Xét duyệt
                                            </a>
                                        </c:if>
                                        <c:if test="${req.status != 'Inprogress'}">
                                            <span style="color: #999;">Đã xử lý</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    
                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <div style="display: flex; justify-content: center; align-items: center; gap: 10px; margin-top: 25px; padding: 20px;">
                            <c:if test="${currentPage > 1}">
                                <a href="?page=${currentPage - 1}&status=${statusFilter}&search=${searchQuery}" 
                                   style="padding: 8px 15px; background: #667eea; color: white; text-decoration: none; border-radius: 6px; font-size: 14px;">
                                    « Trước
                                </a>
                            </c:if>
                            
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <c:choose>
                                    <c:when test="${i == currentPage}">
                                        <span style="padding: 8px 15px; background: #667eea; color: white; border-radius: 6px; font-weight: bold; font-size: 14px;">
                                            ${i}
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="?page=${i}&status=${statusFilter}&search=${searchQuery}" 
                                           style="padding: 8px 15px; background: #e9ecef; color: #333; text-decoration: none; border-radius: 6px; font-size: 14px;">
                                            ${i}
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                            
                            <c:if test="${currentPage < totalPages}">
                                <a href="?page=${currentPage + 1}&status=${statusFilter}&search=${searchQuery}" 
                                   style="padding: 8px 15px; background: #667eea; color: white; text-decoration: none; border-radius: 6px; font-size: 14px;">
                                    Sau »
                                </a>
                            </c:if>
                        </div>
                    </c:if>
                </c:if>
            </div>
        </c:if>
    </div>
    
    <!-- Modal hiển thị chi tiết đơn -->
    <div id="requestDetailModal" class="modal" style="display: none;">
        <div class="modal-content" style="max-width: 600px;">
            <span class="close" onclick="closeRequestDetail()">&times;</span>
            <h2 style="color: #667eea; margin-bottom: 20px;">Chi tiết đơn nghỉ phép</h2>
            <div id="requestDetailContent">
                <!-- Nội dung sẽ được load bằng JavaScript -->
            </div>
        </div>
    </div>
    
    <style>
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.5);
        }
        
        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 30px;
            border: 1px solid #888;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        
        .close:hover,
        .close:focus {
            color: #000;
        }
        
        .detail-row {
            margin-bottom: 15px;
            padding: 10px;
            border-bottom: 1px solid #eee;
        }
        
        .detail-label {
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }
        
        .detail-value {
            color: #333;
            padding-left: 10px;
        }
        
        .process-reason-box {
            background-color: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #667eea;
            margin-top: 10px;
        }
    </style>
    
    <script>
        // Lưu trữ dữ liệu request để hiển thị trong modal - sử dụng data attributes thay vì JavaScript object
        function showRequestDetail(requestId) {
            // Lấy dữ liệu từ server bằng cách tạo một request detail endpoint hoặc sử dụng data đã có
            // Tạm thời sử dụng cách đơn giản: lấy từ table
            const row = document.querySelector('tr[data-request-id="' + requestId + '"]');
            if (!row) {
                alert('Không tìm thấy thông tin đơn');
                return;
            }
            
            // Tạo HTML từ data attributes
            const title = row.getAttribute('data-title') || '-';
            const fromDate = row.getAttribute('data-from-date') || '-';
            const toDate = row.getAttribute('data-to-date') || '-';
            const reason = row.getAttribute('data-reason') || '-';
            const status = row.getAttribute('data-status') || 'Inprogress';
            const processedByName = row.getAttribute('data-processed-by') || '-';
            const processReason = row.getAttribute('data-process-reason') || '';
            const createdAt = row.getAttribute('data-created-at') || '-';
            
            const statusText = status === 'Approved' ? 'Đã duyệt' : 
                             status === 'Rejected' ? 'Từ chối' : 'Chờ duyệt';
            const statusClass = status === 'Approved' ? 'status-approved' : 
                              status === 'Rejected' ? 'status-rejected' : 'status-inprogress';
            
            let html = '<div class="detail-row">';
            html += '<div class="detail-label">ID đơn:</div>';
            html += '<div class="detail-value">' + requestId + '</div>';
            html += '</div>';
            
            html += '<div class="detail-row">';
            html += '<div class="detail-label">Tiêu đề:</div>';
            html += '<div class="detail-value">' + escapeHtml(title) + '</div>';
            html += '</div>';
            
            html += '<div class="detail-row">';
            html += '<div class="detail-label">Từ ngày:</div>';
            html += '<div class="detail-value">' + fromDate + '</div>';
            html += '</div>';
            
            html += '<div class="detail-row">';
            html += '<div class="detail-label">Đến ngày:</div>';
            html += '<div class="detail-value">' + toDate + '</div>';
            html += '</div>';
            
            html += '<div class="detail-row">';
            html += '<div class="detail-label">Lý do nghỉ:</div>';
            html += '<div class="detail-value">' + escapeHtml(reason) + '</div>';
            html += '</div>';
            
            html += '<div class="detail-row">';
            html += '<div class="detail-label">Trạng thái:</div>';
            html += '<div class="detail-value"><span class="status-badge ' + statusClass + '">' + statusText + '</span></div>';
            html += '</div>';
            
            html += '<div class="detail-row">';
            html += '<div class="detail-label">Người duyệt:</div>';
            html += '<div class="detail-value">' + escapeHtml(processedByName) + '</div>';
            html += '</div>';
            
            if (status !== 'Inprogress' && processReason && processReason !== '' && processReason !== '-') {
                html += '<div class="detail-row">';
                html += '<div class="detail-label">Lời phê duyệt:</div>';
                html += '<div class="process-reason-box">' + escapeHtml(processReason).replace(/\n/g, '<br>') + '</div>';
                html += '</div>';
            }
            
            html += '<div class="detail-row">';
            html += '<div class="detail-label">Ngày tạo:</div>';
            html += '<div class="detail-value">' + createdAt + '</div>';
            html += '</div>';
            
            document.getElementById('requestDetailContent').innerHTML = html;
            document.getElementById('requestDetailModal').style.display = 'block';
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
        
        function closeRequestDetail() {
            document.getElementById('requestDetailModal').style.display = 'none';
        }
        
        // Đóng modal khi click bên ngoài
        window.onclick = function(event) {
            const modal = document.getElementById('requestDetailModal');
            if (event.target == modal) {
                closeRequestDetail();
            }
        }
        
        // Reset filter function
        function resetFilter() {
            window.location.href = '${pageContext.request.contextPath}/request/list';
        }
    </script>
    
    <jsp:include page="components/footer.jsp" />
</body>
</html>
