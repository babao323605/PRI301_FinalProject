package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Controller xử lý đăng xuất
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Hủy session
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        // Redirect về login
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
