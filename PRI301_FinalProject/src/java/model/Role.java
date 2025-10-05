package model;

/**
 * Role entity - Vai trò người dùng
 */
public class Role {
    private int id;
    private String name;
    private int departmentId;
    private String description;
    
    // Constructor
    public Role() {
    }
    
    public Role(int id, String name, int departmentId, String description) {
        this.id = id;
        this.name = name;
        this.departmentId = departmentId;
        this.description = description;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "Role{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", departmentId=" + departmentId +
                ", description='" + description + '\'' +
                '}';
    }
}
