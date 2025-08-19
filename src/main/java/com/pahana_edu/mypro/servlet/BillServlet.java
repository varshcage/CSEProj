package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.DAO.BillDAO;
import com.pahana_edu.mypro.model.Bill;
import com.pahana_edu.mypro.model.BillItem;
import com.pahana_edu.mypro.util.DBConnection;
      
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/BillServlet")
public class BillServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            deleteBill(request, response);
            return;
        }

        try {
            Connection connection = DBConnection.getInstance().getConnection();
            BillDAO billDAO = new BillDAO(connection);
  
            // Get filter parameters
            String paymentStatus = request.getParameter("paymentStatus");
            String paymentMethod = request.getParameter("paymentMethod");
            String fromDate = request.getParameter("fromDate");
            String toDate = request.getParameter("toDate");

            // Get bills based on filters
            List<Bill> bills;
            if (paymentStatus != null || paymentMethod != null || fromDate != null || toDate != null) {
                bills = billDAO.getBillsWithFilters(paymentStatus, paymentMethod, fromDate, toDate);
            } else {
                bills = billDAO.getAllBills();
            }

            // Load bill items for each bill to show complete details
            for (Bill bill : bills) {
                List<BillItem> billItems = billDAO.getBillItems(bill.getId());
                bill.setBillItems(billItems);
            }

            // Get statistics
            int totalBills = billDAO.getTotalBillsCount();
            int paidBills = billDAO.getPaidBillsCount();
            int unpaidBills = billDAO.getUnpaidBillsCount();
            double totalSales = billDAO.getTotalSales();

            // Set attributes
            request.setAttribute("bills", bills);
            request.setAttribute("totalBills", totalBills);
            request.setAttribute("paidBills", paidBills);
            request.setAttribute("unpaidBills", unpaidBills);
            request.setAttribute("totalSales", totalSales);

            request.getRequestDispatcher("Report.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("Report.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void deleteBill(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int billId = Integer.parseInt(request.getParameter("id"));

            Connection connection = DBConnection.getInstance().getConnection();
            BillDAO billDAO = new BillDAO(connection);

            boolean success = billDAO.deleteBill(billId);

            if (success) {
                request.setAttribute("successMessage", "Bill deleted successfully!");
            } else {
                request.setAttribute("errorMessage", "Failed to delete bill.");
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
