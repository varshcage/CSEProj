package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.DAO.BillDAO;
import com.pahana_edu.mypro.DAO.BookDAO;
import com.pahana_edu.mypro.DAO.CustomerDAO;
import com.pahana_edu.mypro.model.Bill;
import com.pahana_edu.mypro.model.BillItem;
import com.pahana_edu.mypro.model.Book;
import com.pahana_edu.mypro.model.Customer;
import com.pahana_edu.mypro.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/CreateBillServlet")
public class CreateBillServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Connection connection = DBConnection.getInstance().getConnection();

            // Get books and customers for dropdowns
            BookDAO bookDAO = new BookDAO(connection);
            CustomerDAO customerDAO = new CustomerDAO(connection);

            List<Book> books = bookDAO.getAllBooks();
            List<Customer> customers = customerDAO.getAllCustomers();

            request.setAttribute("books", books);
            request.setAttribute("customers", customers);

            request.getRequestDispatcher("Billing.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("Billing.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Connection connection = DBConnection.getInstance().getConnection();
            BillDAO billDAO = new BillDAO(connection);
            CustomerDAO customerDAO = new CustomerDAO(connection);
            BookDAO bookDAO = new BookDAO(connection);

            // Get form parameters
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            String[] bookIds = request.getParameterValues("bookId");
            String[] quantities = request.getParameterValues("quantity");

            double subtotal = Double.parseDouble(request.getParameter("subtotal"));
            double discount = Double.parseDouble(request.getParameter("discount"));
            double total = Double.parseDouble(request.getParameter("total"));
            String paymentStatus = request.getParameter("paymentStatus");
            String paymentMethod = request.getParameter("paymentMethod");
            String notes = request.getParameter("notes");

            // Validate inputs
            if (bookIds == null || bookIds.length == 0) {
                request.setAttribute("errorMessage", "Please add at least one book to the bill.");
                doGet(request, response);
                return;
            }

            // Get customer details
            Customer customer = customerDAO.getCustomerById(customerId);
            if (customer == null) {
                request.setAttribute("errorMessage", "Customer not found.");
                doGet(request, response);
                return;
            }

            // Create bill object
            Bill bill = new Bill();
            bill.setCustomerId(customerId);
            bill.setCustomerName(customer.getName());
            bill.setCustomerEmail(customer.getEmail());
            bill.setCustomerPhone(customer.getPhone());
            bill.setBillDate(LocalDateTime.now());
            bill.setSubtotal(subtotal);
            bill.setDiscount(discount);
            bill.setTotalAmount(total);
            bill.setPaymentStatus(paymentStatus != null ? paymentStatus : "UNPAID");
            bill.setPaymentMethod(paymentMethod != null ? paymentMethod : "CASH");
            bill.setNotes(notes);

            // Create bill items
            List<BillItem> billItems = new ArrayList<>();
            for (int i = 0; i < bookIds.length; i++) {
                int bookId = Integer.parseInt(bookIds[i]);
                int quantity = Integer.parseInt(quantities[i]);

                Book book = bookDAO.getBookById(bookId);
                if (book == null) {
                    request.setAttribute("errorMessage", "Book with ID " + bookId + " not found.");
                    doGet(request, response);
                    return;
                }

                // Check stock availability
                if (book.getQuantity() < quantity) {
                    request.setAttribute("errorMessage",
                            "Insufficient stock for book: " + book.getTitle() +
                                    ". Available: " + book.getQuantity() + ", Requested: " + quantity);
                    doGet(request, response);
                    return;
                }

                BillItem item = new BillItem();
                item.setBookId(bookId);
                item.setBookTitle(book.getTitle());
                item.setQuantity(quantity);
                item.setUnitPrice(book.getPrice());
                item.setSubtotal(book.getPrice() * quantity);

                billItems.add(item);
            }

            // Create bill in database
            boolean success = billDAO.createBill(bill, billItems);

            if (success) {
                request.setAttribute("successMessage",
                        "Bill " + bill.getBillNumber() + " created successfully!");
                response.sendRedirect("ViewBillServlet?id=" + bill.getId());
            } else {
                request.setAttribute("errorMessage", "Failed to create bill. Please try again.");
                doGet(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format in form data.");
            doGet(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            doGet(request, response);
        }
    }
}