package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.model.Customer;
import com.pahana_edu.mypro.util.DBConnection;
import com.pahana_edu.mypro.DAO.CustomerDAO;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/DeleteCustomerServlet")
public class DeleteCustomerServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int customerId = Integer.parseInt(request.getParameter("customerId"));

        try (Connection connection = DBConnection.getInstance().getConnection()) {
            CustomerDAO customerDAO = new CustomerDAO(connection);
            boolean success = customerDAO.deleteCustomer(customerId);

            if (success) {
                request.getSession().setAttribute("successMessage", "Customer deleted successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to delete customer.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Database error: " + e.getMessage());
        }

        response.sendRedirect("CustomerServlet");
    }
}