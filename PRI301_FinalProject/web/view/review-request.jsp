<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xét duyệt đơn nghỉ phép</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="components/header.jsp" />
    
    <div class="container">
        <div class="form-container">
            <h1 class="form-title">✅ Xét duyệt đơn nghỉ phép</h1>
            
            <c:if test="${not empty error}">
                <div class="error-message">${error}</div>
            </c:if>
            
            <!-- Thông tin đơn -->
            <div style="background: #f5f7fa; padding: 20px; border-radius: 10px; margin-bottom: 30px;">
                <h3 style="color: #667eea; margin-bottom: 15px;">Thông tin đơn</h3>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                    <div>
                        <p><strong>Người tạo:</strong></p>
                        <p>${request.createdByName}</p>
                    </div>
                    
                    <div>
                        <p><strong>Ngày tạo:</strong></p>
                        <p><fmt:formatDate value="${request.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                    </div>
                    
                    <div>
                        <p><strong>Từ ngày:</strong></p>
                        <p><fmt:formatDate value="${request.fromDate}" pattern="dd/MM/yyyy"/></p>
                    </div>
                    
                    <div>
                        <p><strong>Đến ngày:</strong></p>
                        <p><fmt:formatDate value="${request.toDate}" pattern="dd/MM/yyyy"/></p>
                    </div>
                </div>
                
                <div style="margin-top: 15px;">
                    <p><strong>Tiêu đề:</strong></p>
                    <p>${request.title != null ? request.title : '(Không có tiêu đề)'}</p>
                </div>
                
                <div style="margin-top: 15px;">
                    <p><strong>Lý do:</strong></p>
                    <p style="background: white; padding: 15px; border-radius: 8px; margin-top: 8px;">
                        ${request.reason}
                    </p>
                </div>
            </div>
            
            <!-- Form xét duyệt -->
            <form action="${pageContext.request.contextPath}/request/review" method="post" id="reviewForm">
                <input type="hidden" name="id" value="${request.id}">
                <input type="hidden" name="action" id="action" value="">
                
                <div class="form-group">
                    <label for="processReason">Lý do xử lý (Bắt buộc nếu từ chối)</label>
                    <textarea id="processReason" 
                              name="processReason" 
                              placeholder="Nhập lý do phê duyệt hoặc từ chối"></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="button" 
                            class="btn btn-success" 
                            onclick="submitForm('Approved')">
                        ✅ Phê duyệt
                    </button>
                    <button type="button" 
                            class="btn btn-danger" 
                            onclick="submitForm('Rejected')">
                        ❌ Từ chối
                    </button>
                    <a href="${pageContext.request.contextPath}/request/list" 
                       class="btn btn-secondary">
                        Quay lại
                    </a>
                </div>
            </form>
        </div>
    </div>
    
    <jsp:include page="components/footer.jsp" />
    
    <script>
        function submitForm(action) {
            const processReason = document.getElementById('processReason').value.trim();
            
            if (action === 'Rejected' && processReason === '') {
                alert('Vui lòng nhập lý do từ chối!');
                return;
            }
            
            if (confirm('Bạn có chắc chắn muốn ' + (action === 'Approved' ? 'phê duyệt' : 'từ chối') + ' đơn này?')) {
                document.getElementById('action').value = action;
                document.getElementById('reviewForm').submit();
            }
        }
    </script>
</body>
</html>
