<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo đơn nghỉ phép</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="components/header.jsp" />
    
    <div class="container">
        <div class="form-container">
            <h1 class="form-title">📝 Tạo đơn xin nghỉ phép</h1>
            
            <c:if test="${not empty error}">
                <div class="error-message">${error}</div>
            </c:if>
            
            <form action="${pageContext.request.contextPath}/request/create" method="post">
                <div class="form-group">
                    <label for="title">Tiêu đề (Tùy chọn)</label>
                    <input type="text" 
                           id="title" 
                           name="title" 
                           value="${title}"
                           placeholder="Ví dụ: Nghỉ phép năm">
                </div>
                
                <div class="form-group">
                    <label for="fromDate">Từ ngày <span style="color: red;">*</span></label>
                    <input type="date" 
                           id="fromDate" 
                           name="fromDate" 
                           value="${fromDate}"
                           required>
                </div>
                
                <div class="form-group">
                    <label for="toDate">Đến ngày <span style="color: red;">*</span></label>
                    <input type="date" 
                           id="toDate" 
                           name="toDate" 
                           value="${toDate}"
                           required>
                </div>
                
                <div class="form-group">
                    <label for="reason">Lý do <span style="color: red;">*</span></label>
                    <textarea id="reason" 
                              name="reason" 
                              placeholder="Nhập lý do xin nghỉ phép (tối thiểu 10 ký tự)" 
                              required>${reason}</textarea>
                    <small style="color: #777;">Tối thiểu 10 ký tự</small>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Gửi đơn</button>
                    <a href="${pageContext.request.contextPath}/request/list" class="btn btn-secondary">Hủy</a>
                </div>
            </form>
        </div>
    </div>
    
    <jsp:include page="components/footer.jsp" />
    
    <script>
        // Set min date to today
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('fromDate').setAttribute('min', today);
        document.getElementById('toDate').setAttribute('min', today);
        
        // Update toDate min when fromDate changes
        document.getElementById('fromDate').addEventListener('change', function() {
            document.getElementById('toDate').setAttribute('min', this.value);
        });
    </script>
</body>
</html>
