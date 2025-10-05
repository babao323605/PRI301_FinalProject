package controller;

import dao.DepartmentDAO;
import dao.RoleDAO;
import model.Department;
import model.Feature;
import model.Role;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * Controller cho trang chủ
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {
    
    private RoleDAO roleDAO;
    private DepartmentDAO departmentDAO;
    
    @Override
    public void init() throws ServletException {
        roleDAO = new RoleDAO();
        departmentDAO = new DepartmentDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Lấy thông tin roles và features
        List<Role> roles = roleDAO.getRolesByUser(user.getId());
        List<Feature> features = roleDAO.getFeaturesByUser(user.getId());
        Department department = departmentDAO.getDepartmentById(user.getDepartmentId());
        
        // Set attributes
        request.setAttribute("roles", roles);
        request.setAttribute("features", features);
        request.setAttribute("department", department);
        
        request.getRequestDispatcher("/view/home.jsp").forward(request, response);
    }
}
