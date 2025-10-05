package model;

import java.sql.Timestamp;

/**
 * User entity - Người dùng trong hệ thống
 */
public class User {
    private int id;
    private String username;
    private String password;
    private String name;
    private String email;
    private int departmentId;
    private Integer managerId; // Nullable - quản lý trực tiếp
    private Timestamp createdAt;
    
    // Constructor
    public User() {
    }
    
    public User(int id, String username, String name, String email, int departmentId, Integer managerId) {
        this.id = id;
        this.username = username;
        this.name = name;
        this.email = email;
        this.departmentId = departmentId;
        this.managerId = managerId;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;
    }

    public Integer getManagerId() {
        return managerId;
    }

    public void setManagerId(Integer managerId) {
        this.managerId = managerId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", departmentId=" + departmentId +
                ", managerId=" + managerId +
                '}';
    }
}
