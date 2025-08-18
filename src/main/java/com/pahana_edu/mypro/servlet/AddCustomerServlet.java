package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.model.Customer;
import com.pahana_edu.mypro.util.DBConnection;
import com.pahana_edu.mypro.DAO.CustomerDAO;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.UUID;

@WebServlet("/AddCustomerServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 10,      // 10 MB
        maxRequestSize = 1024 * 1024 * 100   // 100 MB
)
public class AddCustomerServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get form data
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dobStr = request.getParameter("dob");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String country = request.getParameter("country");
        boolean status = Boolean.parseBoolean(request.getParameter("status"));
        String notes = request.getParameter("notes");

        LocalDate dob = null;
        if (dobStr != null && !dobStr.isEmpty()) {
            dob = LocalDate.parse(dobStr);
        }

        // Handle file upload
        Part filePart = request.getPart("photo");
        String photoPath = null;

        if (filePart != null && filePart.getSize() > 0) {
            // Get the application's real path
            String appPath = request.getServletContext().getRealPath("");
            String uploadPath = appPath + "uploads" + File.separator + "customer_photos";

            // Create the upload directory if it doesn't exist
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Generate a unique file name
            String fileName = UUID.randomUUID().toString() + "_" + getFileName(filePart);
            photoPath = "uploads/customer_photos/" + fileName;

            // Save the file
            filePart.write(uploadPath + File.separator + fileName);
        }

        // Create customer object
        Customer customer = new Customer();
        customer.setName(name);
        customer.setEmail(email);
        customer.setPhone(phone);
        customer.setDob(dob);
        customer.setAddress(address);
        customer.setCity(city);
        customer.setCountry(country);
        customer.setActive(status);
        customer.setNotes(notes);
        customer.setPhotoPath(photoPath);

        // Add to database
        try (Connection connection = DBConnection.getInstance().getConnection()) {
            CustomerDAO customerDAO = new CustomerDAO(connection);
            boolean success = customerDAO.addCustomer(customer);

            if (success) {
                request.getSession().setAttribute("successMessage", "Customer added successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to add customer.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Database error: " + e.getMessage());
        }

        // Redirect back to customer page
        response.sendRedirect("CustomerServlet");
    }

    // Helper method to get file name from part
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] items = contentDisposition.split(";");
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                return item.substring(item.indexOf("=") + 2, item.length() - 1);
            }
        }
        return "";
    }
}