package filter;

import model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Filter kiểm tra authentication - Đảm bảo user đã đăng nhập
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/request/*", "/home"})
public class AuthenticationFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Khởi tạo filter
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        // Kiểm tra session có user không
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null) {
            // Chưa đăng nhập -> redirect về login
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
        } else {
            // Đã đăng nhập -> tiếp tục
            chain.doFilter(request, response);
        }
    }
    
    @Override
    public void destroy() {
        // Cleanup
    }
}
