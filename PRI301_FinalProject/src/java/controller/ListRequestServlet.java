package controller;

import dao.RequestDAO;
import dao.RoleDAO;
import dao.UserDAO;
import model.Request;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Controller xem danh sách đơn nghỉ phép
 */
@WebServlet(name = "ListRequestServlet", urlPatterns = {"/request/list"})
public class ListRequestServlet extends HttpServlet {
    
    private RequestDAO requestDAO;
    private UserDAO userDAO;
    private RoleDAO roleDAO;
    
    @Override
    public void init() throws ServletException {
        requestDAO = new RequestDAO();
        userDAO = new UserDAO();
        roleDAO = new RoleDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Get filter parameters
        String statusFilter = request.getParameter("status");
        String searchQuery = request.getParameter("search");
        String pageStr = request.getParameter("page");
        
        // Pagination settings
        int pageSize = 10;
        int currentPage = 1;
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageStr);
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }
        
        List<Request> requests = new ArrayList<>();
        List<Request> allSubordinateRequests = new ArrayList<>();
        
        // Kiểm tra quyền xem đơn của subordinates
        boolean canReview = roleDAO.hasFeature(user.getId(), "/request/review");
        
        if (canReview) {
            // Lấy đơn của subordinates
            List<User> subordinates = userDAO.getSubordinates(user.getId());
            List<Integer> subordinateIds = new ArrayList<>();
            for (User sub : subordinates) {
                subordinateIds.add(sub.getId());
            }
            
            if (!subordinateIds.isEmpty()) {
                allSubordinateRequests = requestDAO.getRequestsBySubordinates(subordinateIds);
                
                // Apply filters
                requests = filterRequests(allSubordinateRequests, statusFilter, searchQuery);
                
                request.setAttribute("viewMode", "subordinates");
            }
        }
        
        // Lấy đơn của bản thân
        List<Request> allOwnRequests = requestDAO.getRequestsByUser(user.getId());
        List<Request> ownRequests = filterRequests(allOwnRequests, statusFilter, searchQuery);
        
        // Pagination for subordinate requests
        int totalSubordinateRequests = requests.size();
        int totalPages = (int) Math.ceil((double) totalSubordinateRequests / pageSize);
        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
        }
        
        int startIndex = (currentPage - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalSubordinateRequests);
        
        List<Request> paginatedRequests = new ArrayList<>();
        if (startIndex < totalSubordinateRequests) {
            paginatedRequests = requests.subList(startIndex, endIndex);
        }
        
        // Hiển thị success message nếu có
        String success = (String) session.getAttribute("success");
        if (success != null) {
            request.setAttribute("success", success);
            session.removeAttribute("success");
        }
        
        request.setAttribute("requests", paginatedRequests);
        request.setAttribute("ownRequests", ownRequests);
        request.setAttribute("canReview", canReview);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalSubordinateRequests", totalSubordinateRequests);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "");
        request.setAttribute("searchQuery", searchQuery != null ? searchQuery : "");
        
        request.getRequestDispatcher("/view/list-request.jsp").forward(request, response);
    }
    
    /**
     * Filter requests based on status and search query
     */
    private List<Request> filterRequests(List<Request> requests, String statusFilter, String searchQuery) {
        List<Request> filtered = new ArrayList<>(requests);
        
        // Filter by status
        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
            filtered.removeIf(req -> !statusFilter.equals(req.getStatus()));
        }
        
        // Filter by search query (search in title, reason, creator name)
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            String query = searchQuery.trim().toLowerCase();
            filtered.removeIf(req -> {
                boolean matchTitle = req.getTitle() != null && req.getTitle().toLowerCase().contains(query);
                boolean matchReason = req.getReason() != null && req.getReason().toLowerCase().contains(query);
                boolean matchCreator = req.getCreatedByName() != null && req.getCreatedByName().toLowerCase().contains(query);
                return !matchTitle && !matchReason && !matchCreator;
            });
        }
        
        return filtered;
    }
}
