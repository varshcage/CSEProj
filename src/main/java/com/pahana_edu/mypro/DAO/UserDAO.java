package com.pahana_edu.mypro.DAO;

import com.pahana_edu.mypro.model.User;
import com.pahana_edu.mypro.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {
    private static UserDAO instance;
    private final DBConnection dbConnection;

    private UserDAO() throws SQLException {
        dbConnection = DBConnection.getInstance();
    }
    
    public static synchronized UserDAO getInstance() throws SQLException {
        if (instance == null) {
            instance = new UserDAO();
        }
        return instance;
    }

    public User authenticate(String username, String password, String role) throws SQLException {
        User user = null;
        String sql = "SELECT * FROM users WHERE username=? AND password=? AND role=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            stmt.setString(2, password);
            stmt.setString(3, role);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                user = new User(
                    rs.getInt("id"),
                    rs.getString("username"),
                    rs.getString("password"),
                    rs.getString("role")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }
}
