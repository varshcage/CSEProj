package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.DAO.BookDAO;
import com.pahana_edu.mypro.DAO.CustomerDAO;
import com.pahana_edu.mypro.util.DBConnection;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;

@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp?message=Please login first");
            return;
        }


        try (Connection conn = DBConnection.getInstance().getConnection()) {
            CustomerDAO customerDAO = new CustomerDAO(conn);
            BookDAO bookDAO = new BookDAO(conn);


            int totalCustomers = customerDAO.countAllCustomers();
            int activeCustomers = customerDAO.countActiveCustomers();
            int totalBooks = bookDAO.countAllBooks();


            request.setAttribute("topCustomers", customerDAO.getTopCustomers(5));
            request.setAttribute("topBooks", bookDAO.getTopBooks(5));

          request.setAttribute("totalCustomers", totalCustomers);
           request.setAttribute("activeCustomers", activeCustomers);
       request.setAttribute("totalBooks", totalBooks);

            request.getRequestDispatcher("admin-dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load dashboard data.");
        }
    }
}
