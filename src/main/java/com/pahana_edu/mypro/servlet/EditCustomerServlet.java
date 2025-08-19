package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.DAO.CustomerDAO;
import com.pahana_edu.mypro.model.Customer;
import com.pahana_edu.mypro.util.DBConnection;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.UUID;

@WebServlet("/EditCustomerServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
        maxFileSize = 1024 * 1024 * 10,       // 10 MB
        maxRequestSize = 1024 * 1024 * 100    // 100 MB
)
public class EditCustomerServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int customerId = Integer.parseInt(request.getParameter("id"));

        try (Connection connection = DBConnection.getInstance().getConnection()) {
            CustomerDAO customerDAO = new CustomerDAO(connection);
            Customer customer = customerDAO.getCustomerById(customerId);

            if (customer != null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                String jsonResponse = String.format(
                        "{\"id\":%d,\"name\":\"%s\",\"email\":\"%s\",\"phone\":\"%s\",\"dob\":\"%s\"," +
                                "\"address\":\"%s\",\"city\":\"%s\",\"country\":\"%s\",\"status\":%b," +
                                "\"notes\":\"%s\",\"photoPath\":\"%s\"}",
                        customer.getId(),
                        escapeJson(customer.getName()),
                        escapeJson(customer.getEmail()),
                        escapeJson(customer.getPhone()),
                        customer.getDob() != null ? customer.getDob().toString() : "",
                        escapeJson(customer.getAddress()),
                        escapeJson(customer.getCity()),
                        escapeJson(customer.getCountry()),
                        customer.isActive(),
                        escapeJson(customer.getNotes()),
                        escapeJson(customer.getPhotoPath())
                );

                PrintWriter out = response.getWriter();
                out.print(jsonResponse);
                out.flush();
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer not found");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get customer ID
        int customerId = Integer.parseInt(request.getParameter("id"));

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
        String existingPhotoPath = request.getParameter("existingPhotoPath");

        LocalDate dob = null;
        if (dobStr != null && !dobStr.isEmpty()) {
            dob = LocalDate.parse(dobStr);
        }

        // Handle file upload
        Part filePart = request.getPart("photo");
        String photoPath = existingPhotoPath;

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

            // Optionally: Delete old photo file if it exists
            if (existingPhotoPath != null && !existingPhotoPath.isEmpty()) {
                File oldPhoto = new File(appPath + existingPhotoPath);
                if (oldPhoto.exists()) {
                    oldPhoto.delete();
                }
            }
        }

        // Create customer object
        Customer customer = new Customer();
        customer.setId(customerId);
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

        // Update in database
        try (Connection connection = DBConnection.getInstance().getConnection()) {
            CustomerDAO customerDAO = new CustomerDAO(connection);
            boolean success = customerDAO.updateCustomer(customer);

            if (success) {
                request.getSession().setAttribute("successMessage", "Customer updated successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to update customer.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Database error: " + e.getMessage());
        }

        response.sendRedirect("CustomerServlet");
    }

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

    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}