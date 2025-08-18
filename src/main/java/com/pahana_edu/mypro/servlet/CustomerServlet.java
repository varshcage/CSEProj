package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.model.Customer;
import com.pahana_edu.mypro.util.DBConnection;
import com.pahana_edu.mypro.DAO.CustomerDAO;
import com.pahana_edu.mypro.model.Message;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/CustomerServlet")
public class CustomerServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try (Connection connection = DBConnection.getInstance().getConnection()) {
            CustomerDAO customerDAO = new CustomerDAO(connection);
            List<Customer> customers = customerDAO.getAllCustomers();

            request.setAttribute("customers", customers);
            request.getRequestDispatcher("Customer.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error fetching customers: " + e.getMessage());
            request.getRequestDispatcher("Customer.jsp").forward(request, response);
        }
    }
}