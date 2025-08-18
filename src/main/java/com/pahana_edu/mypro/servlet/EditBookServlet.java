package com.pahana_edu.mypro.servlet;


import com.pahana_edu.mypro.model.Book;
import com.pahana_edu.mypro.util.DBConnection;
import com.pahana_edu.mypro.DAO.BookDAO;

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

@WebServlet("/EditBookServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
        maxFileSize = 1024 * 1024 * 10,       // 10 MB
        maxRequestSize = 1024 * 1024 * 100    // 100 MB
)
public class EditBookServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int bookId = Integer.parseInt(request.getParameter("id"));

        try (Connection connection = DBConnection.getInstance().getConnection()) {
            BookDAO bookDAO = new BookDAO(connection);
            Book book = bookDAO.getBookById(bookId);

            if (book != null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                String jsonResponse = String.format(
                        "{\"id\":%d,\"title\":\"%s\",\"author\":\"%s\",\"isbn\":\"%s\",\"category\":\"%s\"," +
                                "\"price\":%.2f,\"quantity\":%d,\"publisher\":\"%s\",\"publishedDate\":\"%s\"," +
                                "\"description\":\"%s\",\"coverImagePath\":\"%s\"}",
                        book.getId(),
                        escapeJson(book.getTitle()),
                        escapeJson(book.getAuthor()),
                        escapeJson(book.getIsbn()),
                        escapeJson(book.getCategory()),
                        book.getPrice(),
                        book.getQuantity(),
                        escapeJson(book.getPublisher()),
                        book.getPublishedDate(),
                        escapeJson(book.getDescription()),
                        escapeJson(book.getCoverImagePath())
                );

                PrintWriter out = response.getWriter();
                out.print(jsonResponse);
                out.flush();
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Book not found");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int bookId = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String isbn = request.getParameter("isbn");
        String category = request.getParameter("category");
        double price = Double.parseDouble(request.getParameter("price"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        String publisher = request.getParameter("publisher");
        String publishedDateStr = request.getParameter("publishedDate");
        String description = request.getParameter("description");
        String existingCoverPath = request.getParameter("existingCoverPath");

        LocalDate publishedDate = null;
        if (publishedDateStr != null && !publishedDateStr.isEmpty()) {
            publishedDate = LocalDate.parse(publishedDateStr);
        }

        // Handle file upload
        Part filePart = request.getPart("coverImage");
        String coverImagePath = existingCoverPath;

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
        book.setId(bookId);
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

        // Update in database
        try (Connection connection = DBConnection.getInstance().getConnection()) {
            BookDAO bookDAO = new BookDAO(connection);
            boolean success = bookDAO.updateBook(book);

            if (success) {
                request.getSession().setAttribute("successMessage", "Book updated successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to update book.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Database error: " + e.getMessage());
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
