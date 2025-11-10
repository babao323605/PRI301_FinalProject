package controller;

import dao.DepartmentDAO;
import dao.RequestDAO;
import dao.UserDAO;
import model.Department;
import model.Request;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Controller xem agenda tình hình lao động
 */
@WebServlet(name = "AgendaServlet", urlPatterns = {"/request/agenda"})
public class AgendaServlet extends HttpServlet {
    private RequestDAO requestDAO;
    private UserDAO userDAO;
    private SimpleDateFormat dateFormat;
    
    @Override
    public void init() throws ServletException {
        requestDAO = new RequestDAO();
        userDAO = new UserDAO();
        dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
            // Lấy date range từ parameter (mặc định: tháng hiện tại)
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        
        Calendar cal = Calendar.getInstance();
        Date fromDate, toDate;
        
        try {
            if (fromDateStr != null && !fromDateStr.isEmpty() &&
                toDateStr != null && !toDateStr.isEmpty()) {
                
                fromDate = new Date(dateFormat.parse(fromDateStr).getTime());
                toDate = new Date(dateFormat.parse(toDateStr).getTime());
                
                // Validate: fromDate <= toDate
                if (fromDate.after(toDate)) {
                    request.setAttribute("error", "Ngày bắt đầu phải nhỏ hơn hoặc bằng ngày kết thúc");
                    // Reset về tháng hiện tại
                    cal = Calendar.getInstance();
                    cal.set(Calendar.DAY_OF_MONTH, 1); // Ngày đầu tháng
                    fromDate = new Date(cal.getTimeInMillis());
                    cal.add(Calendar.MONTH, 1);
                    cal.add(Calendar.DAY_OF_MONTH, -1); // Ngày cuối tháng
                    toDate = new Date(cal.getTimeInMillis());
                }
            } else {
                // Mặc định: tháng hiện tại
                cal.set(Calendar.DAY_OF_MONTH, 1); // Ngày đầu tháng
                fromDate = new Date(cal.getTimeInMillis());
                cal.add(Calendar.MONTH, 1);
                cal.add(Calendar.DAY_OF_MONTH, -1); // Ngày cuối tháng
                toDate = new Date(cal.getTimeInMillis());
            }
            
            // Lấy department filter từ parameter (mặc định: department của user)
            String departmentIdStr = request.getParameter("departmentId");
            int selectedDepartmentId = user.getDepartmentId(); // Mặc định
            
            if (departmentIdStr != null && !departmentIdStr.isEmpty()) {
                try {
                    selectedDepartmentId = Integer.parseInt(departmentIdStr);
                } catch (NumberFormatException e) {
                    selectedDepartmentId = user.getDepartmentId();
                }
            }
            
            // Lấy thông tin department
            DepartmentDAO departmentDAO = new DepartmentDAO();
            Department department = departmentDAO.getDepartmentById(selectedDepartmentId);
            List<Department> allDepartments = departmentDAO.getAllDepartments();
            
            // Lấy tất cả users trong department (sắp xếp theo tên)
            List<User> employees = userDAO.getUsersByDepartment(selectedDepartmentId);
            employees.sort((u1, u2) -> u1.getName().compareToIgnoreCase(u2.getName()));
            
            // Lấy tất cả requests approved trong khoảng thời gian
            List<Request> approvedRequests = requestDAO.getApprovedRequestsByDateRange(
                selectedDepartmentId, fromDate, toDate
            );
            
            // Tạo map: userId -> List<Request> và date -> List<Request> để dễ query
            Map<Integer, List<Request>> requestMapByUser = new HashMap<>();
            Map<String, List<Request>> requestMapByDate = new HashMap<>();
            
            for (Request req : approvedRequests) {
                // Map by user
                requestMapByUser.computeIfAbsent(req.getCreatedBy(), k -> new ArrayList<>()).add(req);
                
                // Map by date (tất cả các ngày trong khoảng từ from_date đến to_date)
                Calendar reqCal = Calendar.getInstance();
                reqCal.setTime(req.getFromDate());
                while (!reqCal.getTime().after(req.getToDate())) {
                    Date reqDate = new Date(reqCal.getTimeInMillis());
                    String dateKey = dateFormat.format(reqDate);
                    requestMapByDate.computeIfAbsent(dateKey, k -> new ArrayList<>()).add(req);
                    reqCal.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            
            // Tạo danh sách dates trong khoảng thời gian
            List<Date> dates = new ArrayList<>();
            cal.setTime(fromDate);
            while (!cal.getTime().after(toDate)) {
                dates.add(new Date(cal.getTimeInMillis()));
                cal.add(Calendar.DAY_OF_MONTH, 1);
            }
            
            // Tính toán thống kê
            int totalEmployees = employees.size();
            long totalLeaveDays = approvedRequests.stream()
                .mapToLong(req -> {
                    long diff = req.getToDate().getTime() - req.getFromDate().getTime();
                    return (diff / (1000 * 60 * 60 * 24)) + 1; // +1 để bao gồm cả ngày cuối
                })
                .sum();
            
            request.setAttribute("department", department);
            request.setAttribute("allDepartments", allDepartments);
            request.setAttribute("selectedDepartmentId", selectedDepartmentId);
            request.setAttribute("employees", employees);
            request.setAttribute("dates", dates);
            request.setAttribute("requestMapByUser", requestMapByUser);
            request.setAttribute("requestMapByDate", requestMapByDate);
            request.setAttribute("approvedRequests", approvedRequests);
            request.setAttribute("fromDate", dateFormat.format(fromDate));
            request.setAttribute("toDate", dateFormat.format(toDate));
            request.setAttribute("totalEmployees", totalEmployees);
            request.setAttribute("totalLeaveDays", totalLeaveDays);
            
            request.getRequestDispatcher("/view/agenda.jsp").forward(request, response);
            
        } catch (ParseException e) {
            request.setAttribute("error", "Định dạng ngày không hợp lệ: " + e.getMessage());
            request.getRequestDispatcher("/view/agenda.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/view/agenda.jsp").forward(request, response);
        }
    }
}
