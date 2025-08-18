package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.model.Book;
import com.pahana_edu.mypro.util.DBConnection;
import com.pahana_edu.mypro.DAO.BookDAO;
import com.pahana_edu.mypro.model.Message;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/BookServlet")
public class BookServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try (Connection connection = DBConnection.getInstance().getConnection()) {
            BookDAO bookDAO = new BookDAO(connection);
            List<Book> books = bookDAO.getAllBooks();

            request.setAttribute("books", books);
            request.getRequestDispatcher("Book.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("BookServlet").forward(request, response);
        }
    }
}