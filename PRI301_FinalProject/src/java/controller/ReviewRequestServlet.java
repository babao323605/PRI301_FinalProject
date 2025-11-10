package controller;

import dao.RequestDAO;
import dao.NotificationDAO;
import model.Request;
import model.User;
import model.Notification;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Controller xét duyệt đơn nghỉ phép
 */
@WebServlet(name = "ReviewRequestServlet", urlPatterns = {"/request/review"})
public class ReviewRequestServlet extends HttpServlet {
    
    private RequestDAO requestDAO;
    private NotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        requestDAO = new RequestDAO();
        notificationDAO = new NotificationDAO();
    }
    
    /**
     * GET - Hiển thị form review
     * @param request
     * @param response
     * @throws jakarta.servlet.ServletException
     * @throws java.io.IOException
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/request/list");
            return;
        }
        
        try {
            int requestId = Integer.parseInt(idStr);
            Request req = requestDAO.getRequestById(requestId);
            
            if (req == null) {
                request.setAttribute("error", "Không tìm thấy đơn nghỉ phép");
                response.sendRedirect(request.getContextPath() + "/request/list");
                return;
            }
            
            if (!"Inprogress".equals(req.getStatus())) {
                request.setAttribute("error", "Đơn này đã được xử lý");
                response.sendRedirect(request.getContextPath() + "/request/list");
                return;
            }
            
            request.setAttribute("request", req);
            request.getRequestDispatcher("/view/review-request.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/request/list");
        }
    }
    
    /**
     * POST - Xử lý approve/reject
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
        
        String idStr = request.getParameter("id");
        String action = request.getParameter("action");
        String processReason = request.getParameter("processReason");
        
        if (idStr == null || action == null) {
            response.sendRedirect(request.getContextPath() + "/request/list");
            return;
        }
        
        try {
            int requestId = Integer.parseInt(idStr);
            String status = "Approved".equals(action) ? "Approved" : "Rejected";
            
            // Validate reason for rejection
            if ("Rejected".equals(status) && 
                (processReason == null || processReason.trim().isEmpty())) {
                
                Request req = requestDAO.getRequestById(requestId);
                request.setAttribute("error", "Vui lòng nhập lý do từ chối");
                request.setAttribute("request", req);
                request.getRequestDispatcher("/view/review-request.jsp").forward(request, response);
                return;
            }
            
            // Lấy thông tin request trước khi process
            Request req = requestDAO.getRequestById(requestId);
            
            if (req == null) {
                System.err.println("ERROR: Request not found with ID: " + requestId);
                session.setAttribute("error", "Không tìm thấy đơn nghỉ phép");
                response.sendRedirect(request.getContextPath() + "/request/list");
                return;
            }
            
            System.out.println("DEBUG: Processing request ID=" + requestId + ", createdBy=" + req.getCreatedBy() + ", status=" + status);
            
            // Process request
            boolean success = requestDAO.processRequest(
                requestId, 
                status, 
                user.getId(), 
                processReason != null ? processReason.trim() : null
            );
            
            if (success) {
                System.out.println("DEBUG: Request processed successfully");
                String message = "Approved".equals(status) ? 
                    "Đã phê duyệt đơn nghỉ phép" : "Đã từ chối đơn nghỉ phép";
                session.setAttribute("success", message);
                
                // Tạo notification cho người tạo đơn
                if (req.getCreatedBy() > 0) {
                    try {
                        String notifTitle = "Approved".equals(status) ? 
                            "✅ Đơn nghỉ phép được phê duyệt" : "❌ Đơn nghỉ phép bị từ chối";
                        
                        // Format ngày tháng đẹp hơn
                        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd/MM/yyyy");
                        String fromDateStr = dateFormat.format(req.getFromDate());
                        String toDateStr = dateFormat.format(req.getToDate());
                        
                        String notifMessage = String.format(
                            "Đơn nghỉ phép của bạn từ %s đến %s đã được %s bởi %s.",
                            fromDateStr, 
                            toDateStr,
                            "Approved".equals(status) ? "phê duyệt" : "từ chối",
                            user.getName()
                        );
                        
                        if (processReason != null && !processReason.trim().isEmpty()) {
                            notifMessage += "\nLý do: " + processReason.trim();
                        }
                        
                        System.out.println("DEBUG: Creating notification for user: " + req.getCreatedBy());
                        System.out.println("DEBUG: Notification title: " + notifTitle);
                        System.out.println("DEBUG: Notification message: " + notifMessage);
                        
                        Notification notification = new Notification(
                            req.getCreatedBy(),
                            notifTitle,
                            notifMessage,
                            "Approved".equals(status) ? "success" : "error"
                        );
                        notification.setRelatedRequestId(requestId);
                        
                        // Tạo notification và kiểm tra kết quả
                        boolean notifCreated = notificationDAO.createNotification(notification);
                        if (!notifCreated) {
                            System.err.println("ERROR: Failed to create notification for user: " + req.getCreatedBy());
                        } else {
                            System.out.println("SUCCESS: Notification created for user: " + req.getCreatedBy());
                        }
                    } catch (Exception e) {
                        System.err.println("ERROR: Exception creating notification: " + e.getMessage());
                        e.printStackTrace();
                    }
                } else {
                    System.err.println("ERROR: Cannot create notification - createdBy is invalid: " + req.getCreatedBy());
                }
            } else {
                System.err.println("ERROR: Failed to process request ID: " + requestId);
                session.setAttribute("error", "Có lỗi xảy ra, vui lòng thử lại");
            }
            
            response.sendRedirect(request.getContextPath() + "/request/list");
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/request/list");
        }
    }
}
