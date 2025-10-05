package controller;

import dao.NotificationDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Controller xử lý notifications
 */
@WebServlet(name = "NotificationServlet", urlPatterns = {"/notification/mark-all-read"})
public class NotificationServlet extends HttpServlet {
    
    private NotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        notificationDAO = new NotificationDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Đánh dấu tất cả notification đã đọc
        notificationDAO.markAllAsRead(user.getId());
        
        // Redirect về trang trước đó
        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
