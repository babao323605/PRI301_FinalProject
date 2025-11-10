package controller;

import dao.RequestDAO;
import model.Request;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;

/**
 * Controller tạo đơn nghỉ phép
 */
@WebServlet(name = "CreateRequestServlet", urlPatterns = {"/request/create"})
public class CreateRequestServlet extends HttpServlet {
    
    private RequestDAO requestDAO;
    private SimpleDateFormat dateFormat;
    
    @Override
    public void init() throws ServletException {
        requestDAO = new RequestDAO();
        dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    }
    
    /**
     * GET - Hiển thị form tạo đơn
     * @param request
     * @param response
     * @throws jakarta.servlet.ServletException
     * @throws java.io.IOException
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/view/create-request.jsp").forward(request, response);
    }
    
    /**
     * POST - Xử lý tạo đơn
     * @param request
     * @param response
     * @throws jakarta.servlet.ServletException
     * @throws java.io.IOException
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        String title = request.getParameter("title");
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        String reason = request.getParameter("reason");
        
        // Validate
        if (fromDateStr == null || fromDateStr.trim().isEmpty() ||
            toDateStr == null || toDateStr.trim().isEmpty() ||
            reason == null || reason.trim().isEmpty()) {
            
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin bắt buộc");
            request.setAttribute("title", title);
            request.setAttribute("fromDate", fromDateStr);
            request.setAttribute("toDate", toDateStr);
            request.setAttribute("reason", reason);
            request.getRequestDispatcher("/view/create-request.jsp").forward(request, response);
            return;
        }
        
        try {
            Date fromDate = new Date(dateFormat.parse(fromDateStr).getTime());
            Date toDate = new Date(dateFormat.parse(toDateStr).getTime());
            
            // Validate dates
            if (fromDate.after(toDate)) {
                request.setAttribute("error", "Ngày bắt đầu phải trước ngày kết thúc");
                request.setAttribute("title", title);
                request.setAttribute("fromDate", fromDateStr);
                request.setAttribute("toDate", toDateStr);
                request.setAttribute("reason", reason);
                request.getRequestDispatcher("/view/create-request.jsp").forward(request, response);
                return;
            }
            
            // Validate reason length
            if (reason.trim().length() < 10) {
                request.setAttribute("error", "Lý do phải có ít nhất 10 ký tự");
                request.setAttribute("title", title);
                request.setAttribute("fromDate", fromDateStr);
                request.setAttribute("toDate", toDateStr);
                request.setAttribute("reason", reason);
                request.getRequestDispatcher("/view/create-request.jsp").forward(request, response);
                return;
            }
            
            // Tạo request object
            Request req = new Request();
            req.setTitle(title != null ? title.trim() : null);
            req.setFromDate(fromDate);
            req.setToDate(toDate);
            req.setReason(reason.trim());
            req.setCreatedBy(user.getId());
            
            // Lưu vào database
            boolean success = requestDAO.createRequest(req);
            
            if (success) {
                session.setAttribute("success", "Tạo đơn nghỉ phép thành công");
                response.sendRedirect(request.getContextPath() + "/request/list");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra, vui lòng thử lại");
                request.setAttribute("title", title);
                request.setAttribute("fromDate", fromDateStr);
                request.setAttribute("toDate", toDateStr);
                request.setAttribute("reason", reason);
                request.getRequestDispatcher("/view/create-request.jsp").forward(request, response);
            }
            
        } catch (ParseException e) {
            request.setAttribute("error", "Định dạng ngày không hợp lệ");
            request.setAttribute("title", title);
            request.setAttribute("fromDate", fromDateStr);
            request.setAttribute("toDate", toDateStr);
            request.setAttribute("reason", reason);
            request.getRequestDispatcher("/view/create-request.jsp").forward(request, response);
        }
    }
}
