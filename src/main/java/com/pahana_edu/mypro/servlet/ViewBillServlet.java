package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.DAO.BillDAO;
import com.pahana_edu.mypro.model.Bill;
import com.pahana_edu.mypro.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/ViewBillServlet")
public class ViewBillServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int billId = Integer.parseInt(request.getParameter("id"));

            Connection connection = DBConnection.getInstance().getConnection();
            BillDAO billDAO = new BillDAO(connection);

            Bill bill = billDAO.getBillById(billId);

            if (bill != null) {
                request.setAttribute("bill", bill);
                request.getRequestDispatcher("ViewBill.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Bill not found.");
                response.sendRedirect("BillServlet");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid bill ID.");
            response.sendRedirect("BillServlet");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            response.sendRedirect("BillServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("updatePayment".equals(action)) {
            updatePaymentStatus(request, response);
        } else {
            doGet(request, response);
        }
    }

    private void updatePaymentStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int billId = Integer.parseInt(request.getParameter("billId"));
            String paymentStatus = request.getParameter("paymentStatus");
            String paymentMethod = request.getParameter("paymentMethod");

            Connection connection = DBConnection.getInstance().getConnection();
            BillDAO billDAO = new BillDAO(connection);

            boolean success = billDAO.updatePaymentStatus(billId, paymentStatus, paymentMethod);

            if (success) {
                request.setAttribute("successMessage", "Payment status updated successfully!");
            } else {
                request.setAttribute("errorMessage", "Failed to update payment status.");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid bill ID.");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
        }

        // Redirect back to bills list
        response.sendRedirect("BillServlet");
    }
}