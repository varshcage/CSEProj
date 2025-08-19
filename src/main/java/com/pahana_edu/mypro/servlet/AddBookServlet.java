package com.pahana_edu.mypro.servlet;

import com.pahana_edu.mypro.DAO.BookDAO;
import com.pahana_edu.mypro.model.Book;
import com.pahana_edu.mypro.model.Message;
import com.pahana_edu.mypro.util.DBConnection;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.UUID;

@WebServlet("/AddBookServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 10,      // 10 MB
        maxRequestSize = 1024 * 1024 * 100   // 100 MB
)
public class AddBookServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get form data
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String isbn = request.getParameter("isbn");
        String category = request.getParameter("category");
        double price = Double.parseDouble(request.getParameter("price"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        String publisher = request.getParameter("publisher");
        String publishedDateStr = request.getParameter("publishedDate");
        String description = request.getParameter("description");

        LocalDate publishedDate = null;
        if (publishedDateStr != null && !publishedDateStr.isEmpty()) {
            publishedDate = LocalDate.parse(publishedDateStr);
        }

        // Handle file upload
        Part filePart = request.getPart("coverImage");
        String coverImagePath = null;

        if (filePart != null && filePart.getSize() > 0) {
            // Get the application's real path
            String appPath = request.getServletContext().getRealPath("");
            String uploadPath = appPath + "uploads" + File.separator + "book_covers";

            // Create the upload directory if it doesn't exist
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Generate a unique file name
            String fileName = UUID.randomUUID().toString() + "_" + getFileName(filePart);
            coverImagePath = "uploads/book_covers/" + fileName;

            // Save the file
            filePart.write(uploadPath + File.separator + fileName);
        }

        // Create book object
        Book book = new Book();
        book.setTitle(title);
        book.setAuthor(author);
        book.setIsbn(isbn);
        book.setCategory(category);
        book.setPrice(price);
        book.setQuantity(quantity);
        book.setPublisher(publisher);
        book.setPublishedDate(publishedDate);
        book.setDescription(description);
        book.setCoverImagePath(coverImagePath);

        // Add to database
        try (Connection connection = DBConnection.getInstance().getConnection()) {
            BookDAO bookDAO = new BookDAO(connection);
            boolean success = bookDAO.addBook(book);

            if (success) {
                request.getSession().setAttribute("message", new Message("Book added successfully!", "success"));
            } else {
                request.getSession().setAttribute("message", new Message("Failed to add book.", "error"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", new Message("Database error: " + e.getMessage(), "error"));
        }

    
        response.sendRedirect("BookServlet");
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
}
