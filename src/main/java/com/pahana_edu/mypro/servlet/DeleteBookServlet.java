package com.pahana_edu.mypro.servlet;


import com.pahana_edu.mypro.DAO.BookDAO;
import com.pahana_edu.mypro.util.DBConnection;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/DeleteBookServlet")
public class DeleteBookServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int bookId = Integer.parseInt(request.getParameter("bookId"));

        try (Connection connection = DBConnection.getInstance().getConnection()) {
            BookDAO bookDAO = new BookDAO(connection);
            boolean success = bookDAO.deleteBook(bookId);

            if (success) {
                request.getSession().setAttribute("successMessage", "Book deleted successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to delete book.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Database error: " + e.getMessage());
        }

        response.sendRedirect("BookServlet");
    }
}
