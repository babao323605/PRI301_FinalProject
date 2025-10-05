package filter;

import dao.RoleDAO;
import model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Filter kiểm tra authorization - Đảm bảo user có quyền truy cập
 */
@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {"/request/*"})
public class AuthorizationFilter implements Filter {
    
    private RoleDAO roleDAO;
    
    // Map URL pattern -> Feature name
    private Map<String, String> urlFeatureMap;
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        roleDAO = new RoleDAO();
        
        // Khởi tạo mapping giữa URL và Feature
        urlFeatureMap = new HashMap<>();
        urlFeatureMap.put("/request/create", "/request/create");
        urlFeatureMap.put("/request/list", "/request/list");
        urlFeatureMap.put("/request/review", "/request/review");
        urlFeatureMap.put("/request/modify", "/request/modify");
        urlFeatureMap.put("/request/agenda", "/request/agenda");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        try {
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            HttpSession session = httpRequest.getSession(false);
            
            User user = (session != null) ? (User) session.getAttribute("user") : null;
            String requestURI = httpRequest.getRequestURI();
            String contextPath = httpRequest.getContextPath();
            
            // Đảm bảo contextPath không null và requestURI hợp lệ
            if (contextPath == null) {
                contextPath = "";
            }
            
            String path = requestURI;
            if (requestURI.startsWith(contextPath)) {
                path = requestURI.substring(contextPath.length());
            }
            
            // Lấy feature name tương ứng với URL
            String featureName = getFeatureName(path);
            
            if (featureName != null) {
                // Kiểm tra user đã đăng nhập
                if (user == null) {
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
                    return;
                }
                
                // Kiểm tra quyền
                try {
                    boolean hasPermission = roleDAO.hasFeature(user.getId(), featureName);
                    
                    if (!hasPermission) {
                        // Không có quyền -> trả về 403
                        httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, 
                            "Bạn không có quyền truy cập trang này");
                        return;
                    }
                } catch (Exception e) {
                    // Nếu có lỗi khi check permission, log và tiếp tục (để servlet xử lý)
                    System.err.println("Error checking permission: " + e.getMessage());
                    e.printStackTrace();
                    // Vẫn tiếp tục để servlet xử lý
                }
            }
            
            // Có quyền hoặc không cần check -> tiếp tục
            chain.doFilter(request, response);
            
        } catch (Exception e) {
            // Nếu có lỗi nghiêm trọng, log và tiếp tục
            System.err.println("Error in AuthorizationFilter: " + e.getMessage());
            e.printStackTrace();
            // Vẫn tiếp tục để servlet xử lý
            chain.doFilter(request, response);
        }
    }
    
    /**
     * Lấy feature name từ URL path
     */
    private String getFeatureName(String path) {
        if (path == null || path.isEmpty()) {
            return null;
        }
        
        // Loại bỏ query string nếu có
        int queryIndex = path.indexOf('?');
        if (queryIndex >= 0) {
            path = path.substring(0, queryIndex);
        }
        
        // Đảm bảo path bắt đầu bằng "/"
        if (!path.startsWith("/")) {
            path = "/" + path;
        }
        
        // Kiểm tra exact match trước
        String feature = urlFeatureMap.get(path);
        if (feature != null) {
            return feature;
        }
        
        // Nếu không có exact match, kiểm tra startsWith (cho các sub-paths)
        for (Map.Entry<String, String> entry : urlFeatureMap.entrySet()) {
            String key = entry.getKey();
            if (path.equals(key) || path.startsWith(key + "/")) {
                return entry.getValue();
            }
        }
        return null;
    }
    
    @Override
    public void destroy() {
        // Cleanup
    }
}
