package com.pahana_edu.mypro.DAO;

import com.pahana_edu.mypro.model.Book;
import com.pahana_edu.mypro.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {
    private Connection connection;

    public BookDAO(Connection connection) {
        this.connection = connection;
    }



    // Add a new book
    public boolean addBook(Book book) throws SQLException {
        String query = "INSERT INTO books (title, author, isbn, category, price, quantity, " +
                "publisher, published_date, description, cover_image_path) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, book.getTitle());
            statement.setString(2, book.getAuthor());
            statement.setString(3, book.getIsbn());
            statement.setString(4, book.getCategory());
            statement.setDouble(5, book.getPrice());
            statement.setInt(6, book.getQuantity());
            statement.setString(7, book.getPublisher());
            statement.setDate(8, book.getPublishedDate() != null ? Date.valueOf(book.getPublishedDate()) : null);
            statement.setString(9, book.getDescription());
            statement.setString(10, book.getCoverImagePath());

            return statement.executeUpdate() > 0;
        }
    }

    // Get all books
    public List<Book> getAllBooks() throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM books";

        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {

            while (resultSet.next()) {
                Book book = new Book();
                book.setId(resultSet.getInt("id"));
                book.setTitle(resultSet.getString("title"));
                book.setAuthor(resultSet.getString("author"));
                book.setIsbn(resultSet.getString("isbn"));
                book.setCategory(resultSet.getString("category"));
                book.setPrice(resultSet.getDouble("price"));
                book.setQuantity(resultSet.getInt("quantity"));
                book.setPublisher(resultSet.getString("publisher"));
                Date publishedDate = resultSet.getDate("published_date");
                book.setPublishedDate(publishedDate != null ? publishedDate.toLocalDate() : null);
                book.setDescription(resultSet.getString("description"));
                book.setCoverImagePath(resultSet.getString("cover_image_path"));

                books.add(book);
            }
        }

        return books;
    }

    // Get book by ID
    public Book getBookById(int id) throws SQLException {
        String query = "SELECT * FROM books WHERE id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, id);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    Book book = new Book();
                    book.setId(resultSet.getInt("id"));
                    book.setTitle(resultSet.getString("title"));
                    book.setAuthor(resultSet.getString("author"));
                    book.setIsbn(resultSet.getString("isbn"));
                    book.setCategory(resultSet.getString("category"));
                    book.setPrice(resultSet.getDouble("price"));
                    book.setQuantity(resultSet.getInt("quantity"));
                    book.setPublisher(resultSet.getString("publisher"));
                    Date publishedDate = resultSet.getDate("published_date");
                    book.setPublishedDate(publishedDate != null ? publishedDate.toLocalDate() : null);
                    book.setDescription(resultSet.getString("description"));
                    book.setCoverImagePath(resultSet.getString("cover_image_path"));

                    return book;
                }
            }
        }

        return null;
    }

    // Update book
    public boolean updateBook(Book book) throws SQLException {
        String query = "UPDATE books SET title = ?, author = ?, isbn = ?, category = ?, " +
                "price = ?, quantity = ?, publisher = ?, published_date = ?, " +
                "description = ?, cover_image_path = ? WHERE id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, book.getTitle());
            statement.setString(2, book.getAuthor());
            statement.setString(3, book.getIsbn());
            statement.setString(4, book.getCategory());
            statement.setDouble(5, book.getPrice());
            statement.setInt(6, book.getQuantity());
            statement.setString(7, book.getPublisher());
            statement.setDate(8, book.getPublishedDate() != null ? Date.valueOf(book.getPublishedDate()) : null);
            statement.setString(9, book.getDescription());
            statement.setString(10, book.getCoverImagePath());
            statement.setInt(11, book.getId());

            return statement.executeUpdate() > 0;
        }
    }

    // Delete book
    public boolean deleteBook(int id) throws SQLException {
        String query = "DELETE FROM books WHERE id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        }
    }
    public int countAllBooks() throws SQLException {
        String query = "SELECT COUNT(*) FROM books";
        try (PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // Get top N books (for dashboard display)
    public List<Book> getTopBooks(int limit) throws SQLException {
        List<Book> books = new ArrayList<>();
        String query = "SELECT * FROM books ORDER BY id DESC LIMIT ?"; // Adjust order by field if needed

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, limit);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Book book = new Book();
                    book.setId(resultSet.getInt("id"));
                    book.setTitle(resultSet.getString("title"));
                    book.setAuthor(resultSet.getString("author"));
                    book.setIsbn(resultSet.getString("isbn"));
                    book.setCategory(resultSet.getString("category"));
                    book.setPrice(resultSet.getDouble("price"));
                    book.setQuantity(resultSet.getInt("quantity"));
                    book.setPublisher(resultSet.getString("publisher"));
                    Date publishedDate = resultSet.getDate("published_date");
                    book.setPublishedDate(publishedDate != null ? publishedDate.toLocalDate() : null);
                    book.setDescription(resultSet.getString("description"));
                    book.setCoverImagePath(resultSet.getString("cover_image_path"));

                    books.add(book);
                }
            }
        }
        return books;
    }
    public boolean decreaseStock(int bookId, int qty) throws SQLException {
        String sql = "UPDATE books SET quantity = quantity - ? WHERE id = ? AND quantity >= ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, qty);
            stmt.setInt(2, bookId);
            stmt.setInt(3, qty); // Ensure we don't go negative
            return stmt.executeUpdate() > 0;
        }
    }
    public boolean updateBookStock(int bookId, int quantityChange) throws SQLException {
        if (quantityChange == 0) {
            return true; // No change needed
        }

        String sql;
        if (quantityChange > 0) {
            sql = "UPDATE books SET quantity = quantity + ? WHERE id = ?";
        } else {
            // For negative changes, ensure we don't go below zero
            sql = "UPDATE books SET quantity = GREATEST(0, quantity + ?) WHERE id = ?";
        }

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, quantityChange);
            stmt.setInt(2, bookId);
            return stmt.executeUpdate() > 0;
        }
    }

}