package com.pahana_edu.mypro.DAO;

import com.pahana_edu.mypro.model.Bill;
import com.pahana_edu.mypro.model.BillItem;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class BillDAO {
    private Connection connection;

    public BillDAO(Connection connection) {
        this.connection = connection;
    } 

    // Generate bill number
    private String generateBillNumber() throws SQLException {
        String query = "SELECT COUNT(*) FROM bills";
        try (PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                int count = rs.getInt(1) + 1;
                return "BILL" + String.format("%06d", count);
            }
        }
        return "BILL000001";
    }

    // Create new bill with items
    public boolean createBill(Bill bill, List<BillItem> items) throws SQLException {
        connection.setAutoCommit(false);
        try {
            // Generate bill number
            bill.setBillNumber(generateBillNumber());

            // Insert bill
            String billQuery = "INSERT INTO bills (bill_number, customer_id, customer_name, customer_email, " +
                    "customer_phone, bill_date, subtotal, discount, total_amount, payment_status, " +
                    "payment_method, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            int billId;
            try (PreparedStatement stmt = connection.prepareStatement(billQuery, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, bill.getBillNumber());
                stmt.setInt(2, bill.getCustomerId());
                stmt.setString(3, bill.getCustomerName());
                stmt.setString(4, bill.getCustomerEmail());
                stmt.setString(5, bill.getCustomerPhone());
                stmt.setTimestamp(6, Timestamp.valueOf(bill.getBillDate()));
                stmt.setDouble(7, bill.getSubtotal());
                stmt.setDouble(8, bill.getDiscount());
                stmt.setDouble(9, bill.getTotalAmount());
                stmt.setString(10, bill.getPaymentStatus());
                stmt.setString(11, bill.getPaymentMethod());
                stmt.setString(12, bill.getNotes());

                int result = stmt.executeUpdate();
                if (result == 0) {
                    connection.rollback();
                    return false;
                }

                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        billId = keys.getInt(1);
                        bill.setId(billId);
                    } else {
                        connection.rollback();
                        return false;
                    }
                }
            }

            // Insert bill items
            String itemQuery = "INSERT INTO bill_items (bill_id, book_id, book_title, quantity, unit_price, subtotal) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = connection.prepareStatement(itemQuery)) {
                for (BillItem item : items) {
                    stmt.setInt(1, billId);
                    stmt.setInt(2, item.getBookId());
                    stmt.setString(3, item.getBookTitle());
                    stmt.setInt(4, item.getQuantity());
                    stmt.setDouble(5, item.getUnitPrice());
                    stmt.setDouble(6, item.getSubtotal());
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }

            // Update book quantities
            BookDAO bookDAO = new BookDAO(connection);
            for (BillItem item : items) {
                boolean success = bookDAO.decreaseStock(item.getBookId(), item.getQuantity());
                if (!success) {
                    connection.rollback();
                    return false;
                }
            }

            connection.commit();
            return true;

        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    // Get all bills
    public List<Bill> getAllBills() throws SQLException {
        List<Bill> bills = new ArrayList<>();
        String query = "SELECT * FROM bills ORDER BY bill_date DESC";

        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                Bill bill = mapResultSetToBill(rs);
                bills.add(bill);
            }
        }
        return bills;
    }

    // Get bills with filters
    public List<Bill> getBillsWithFilters(String paymentStatus, String paymentMethod,
                                          String fromDate, String toDate) throws SQLException {
        List<Bill> bills = new ArrayList<>();
        StringBuilder query = new StringBuilder("SELECT * FROM bills WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
            query.append(" AND payment_status = ?");
            params.add(paymentStatus);
        }

        if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
            query.append(" AND payment_method = ?");
            params.add(paymentMethod);
        }

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            query.append(" AND DATE(bill_date) >= ?");
            params.add(fromDate);
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            query.append(" AND DATE(bill_date) <= ?");
            params.add(toDate);
        }

        query.append(" ORDER BY bill_date DESC");

        try (PreparedStatement stmt = connection.prepareStatement(query.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Bill bill = mapResultSetToBill(rs);
                    bills.add(bill);
                }
            }
        }
        return bills;
    }

    // Get bill by ID with items
    public Bill getBillById(int id) throws SQLException {
        String query = "SELECT * FROM bills WHERE id = ?";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Bill bill = mapResultSetToBill(rs);
                    // Get bill items
                    bill.setBillItems(getBillItems(id));
                    return bill;
                }
            }
        }
        return null;
    }

    // Get bill items
    public List<BillItem> getBillItems(int billId) throws SQLException {
        List<BillItem> items = new ArrayList<>();
        String query = "SELECT * FROM bill_items WHERE bill_id = ?";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setInt(1, billId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    BillItem item = new BillItem();
                    item.setId(rs.getInt("id"));
                    item.setBillId(rs.getInt("bill_id"));
                    item.setBookId(rs.getInt("book_id"));
                    item.setBookTitle(rs.getString("book_title"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getDouble("unit_price"));
                    item.setSubtotal(rs.getDouble("subtotal"));
                    items.add(item);
                }
            }
        }
        return items;
    }

    // Update payment status
    public boolean updatePaymentStatus(int billId, String paymentStatus, String paymentMethod) throws SQLException {
        String query = "UPDATE bills SET payment_status = ?, payment_method = ? WHERE id = ?";

        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, paymentStatus);
            stmt.setString(2, paymentMethod);
            stmt.setInt(3, billId);

            return stmt.executeUpdate() > 0;
        }
    }

    // Delete bill
    public boolean deleteBill(int billId) throws SQLException {
        connection.setAutoCommit(false);
        try {
            // First get bill items to restore stock
            List<BillItem> items = getBillItems(billId);

            // Delete bill items
            String deleteItemsQuery = "DELETE FROM bill_items WHERE bill_id = ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteItemsQuery)) {
                stmt.setInt(1, billId);
                stmt.executeUpdate();
            }

            // Delete bill
            String deleteBillQuery = "DELETE FROM bills WHERE id = ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteBillQuery)) {
                stmt.setInt(1, billId);
                int result = stmt.executeUpdate();

                if (result > 0) {
                    // Restore book quantities
                    BookDAO bookDAO = new BookDAO(connection);
                    for (BillItem item : items) {
                        bookDAO.updateBookStock(item.getBookId(), item.getQuantity()); // Add back quantity
                    }

                    connection.commit();
                    return true;
                }
            }

            connection.rollback();
            return false;

        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    // Get statistics
    public int getTotalBillsCount() throws SQLException {
        String query = "SELECT COUNT(*) FROM bills";
        try (PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getPaidBillsCount() throws SQLException {
        String query = "SELECT COUNT(*) FROM bills WHERE payment_status = 'PAID'";
        try (PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getUnpaidBillsCount() throws SQLException {
        String query = "SELECT COUNT(*) FROM bills WHERE payment_status = 'UNPAID'";
        try (PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public double getTotalSales() throws SQLException {
        String query = "SELECT SUM(total_amount) FROM bills WHERE payment_status = 'PAID'";
        try (PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        }
        return 0.0;
    }

    // Helper method to map ResultSet to Bill
    private Bill mapResultSetToBill(ResultSet rs) throws SQLException {
        Bill bill = new Bill();
        bill.setId(rs.getInt("id"));
        bill.setBillNumber(rs.getString("bill_number"));
        bill.setCustomerId(rs.getInt("customer_id"));
        bill.setCustomerName(rs.getString("customer_name"));
        bill.setCustomerEmail(rs.getString("customer_email"));
        bill.setCustomerPhone(rs.getString("customer_phone"));
        bill.setBillDate(rs.getTimestamp("bill_date").toLocalDateTime());
        bill.setSubtotal(rs.getDouble("subtotal"));
        bill.setDiscount(rs.getDouble("discount"));
        bill.setTotalAmount(rs.getDouble("total_amount"));
        bill.setPaymentStatus(rs.getString("payment_status"));
        bill.setPaymentMethod(rs.getString("payment_method"));
        bill.setNotes(rs.getString("notes"));
        return bill;
    }
}
