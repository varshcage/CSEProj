<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Billing - PahanEdu Bookshop</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Scrollbar styles */
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: #f1f1f1; }
        ::-webkit-scrollbar-thumb { background: #888; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #555; }

        /* Notification styles */
        .notification { animation: slideIn 0.3s ease-out, fadeOut 0.5s ease 3s forwards; }
        @keyframes slideIn { from { transform: translateX(100%); } to { transform: translateX(0); } }
        @keyframes fadeOut { from { opacity: 1; } to { opacity: 0; } }
        .hidden { display: none; }

        /* Print styles */
        @media print {
            body * { visibility: hidden; }
            #printable-bill, #printable-bill * { visibility: visible; }
            #printable-bill { position: absolute; left: 0; top: 0; width: 100%; }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body class="bg-gray-50 font-sans">

<!-- Notification Area -->
<div id="notification-area" class="fixed top-4 right-4 z-50 space-y-2">
    <c:if test="${not empty successMessage}">
        <div class="notification px-4 py-3 rounded-md shadow-md flex items-center bg-green-100 text-green-800">
            <i class="fas fa-check-circle mr-2"></i>
                ${successMessage}
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="notification px-4 py-3 rounded-md shadow-md flex items-center bg-red-100 text-red-800">
            <i class="fas fa-exclamation-circle mr-2"></i>
                ${errorMessage}
        </div>
    </c:if>
</div>

<!-- Sidebar -->
<div class="fixed inset-y-0 left-0 transform -translate-x-full md:translate-x-0 transition duration-200 ease-in-out z-40 w-64 bg-indigo-800 text-white shadow-lg">
    <div class="flex items-center justify-center h-16 px-4 border-b border-indigo-700">
        <div class="flex items-center space-x-2">
            <i class="fas fa-book-open text-2xl text-indigo-300"></i>
            <span class="text-xl font-bold">PahanEdu</span>
        </div>
    </div>
    <nav class="mt-6">
        <div class="px-4 space-y-1">
            <a href="AdminDashboardServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
                <i class="fas fa-tachometer-alt mr-3"></i> Dashboard
            </a>
            <a href="BookServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
                <i class="fas fa-book mr-3"></i> Books
            </a>
            <a href="CustomerServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
                <i class="fas fa-users mr-3"></i> Customers
            </a>
            <a href="CreateBillServlet" class="flex items-center px-4 py-3 text-white bg-indigo-900 rounded-lg">
                <i class="fa-solid fa-money-bill mr-3"></i>Bill
            </a>
            <a href="BillServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
                <i class="fas fa-chart-line mr-3"></i> Reports
            </a>
        </div>
    </nav>
</div>

<!-- Mobile sidebar toggle -->
<div class="md:hidden fixed top-4 left-4 z-40">
    <button id="sidebar-toggle" class="p-2 rounded-md bg-indigo-800 text-white focus:outline-none">
        <i class="fas fa-bars"></i>
    </button>
</div>

<!-- Main Content -->
<div class="md:ml-64 min-h-screen">
    <!-- Header -->
    <header class="bg-white shadow-sm">
        <div class="flex justify-between items-center px-6 py-4">
            <h1 class="text-2xl font-semibold text-gray-800 flex items-center">
                <i class="fas fa-shopping-cart text-blue-600 mr-3"></i> Create New Bill
            </h1>
        </div>
    </header>

    <!-- Main Content Area -->
    <main class="p-6">
        <form id="billing-form" action="CreateBillServlet" method="post">
            <!-- Hidden fields for form data -->
            <input type="hidden" name="customerId" id="customerId">
            <input type="hidden" name="subtotal" id="subtotal-hidden" value="0">
            <input type="hidden" name="discount" id="discount-hidden" value="0">
            <input type="hidden" name="total" id="total-hidden" value="0">
            <input type="hidden" name="paymentStatus" id="payment-status-hidden" value="UNPAID">
            <input type="hidden" name="paymentMethod" id="payment-method-hidden" value="CASH">
            <input type="hidden" name="notes" id="notes-hidden" value="">

            <!-- Dynamic book data container -->
            <div id="bill-data">
                <!-- Will be populated by JavaScript -->
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Customer Info Section -->
                <div class="bg-white rounded-lg shadow p-6">
                    <h2 class="text-lg font-semibold mb-4 flex items-center">
                        <i class="fas fa-user-circle mr-2 text-indigo-600"></i> Select Customer
                    </h2>
                    <select id="customer-select" class="w-full border border-gray-300 rounded-lg p-3 mb-4">
                        <option value="">-- Select Customer --</option>
                        <c:forEach var="customer" items="${customers}">
                            <option value="${customer.id}"
                                    data-name="${customer.name}"
                                    data-phone="${customer.phone}"
                                    data-email="${customer.email}"
                                    data-address="${customer.address}">
                                    ${customer.name} - ${customer.phone}
                            </option>
                        </c:forEach>
                    </select>
                    <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
                        <p id="customer-name" class="font-medium">No customer selected</p>
                        <p id="customer-phone" class="text-sm text-gray-500"></p>
                        <p id="customer-email" class="text-sm text-gray-500"></p>
                        <p id="customer-address" class="text-sm text-gray-500"></p>
                    </div>
                </div>

                <!-- Book Selection + Bill Table -->
                <div class="lg:col-span-2 bg-white rounded-lg shadow p-6">
                    <h2 class="text-lg font-semibold mb-4 flex items-center">
                        <i class="fas fa-book-open mr-2 text-indigo-600"></i> Select Books
                    </h2>
                    <div class="flex space-x-3 mb-6">
                        <select id="book-select" class="flex-1 border border-gray-300 rounded-lg p-3">
                            <option value="">-- Select Book --</option>
                            <c:forEach var="book" items="${books}">
                                <option value="${book.id}"
                                        data-price="${book.price}"
                                        data-title="${book.title}"
                                        data-stock="${book.quantity}">
                                        ${book.title} - Rs. ${book.price} (Stock: ${book.quantity})
                                </option>
                            </c:forEach>
                        </select>
                        <input type="number" id="book-qty" min="1" value="1" class="w-20 border rounded-lg p-3 text-center" placeholder="Qty">
                        <button type="button" id="add-book" class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700">
                            <i class="fas fa-plus"></i> Add
                        </button>
                    </div>

                    <!-- Bill Table -->
                    <div class="overflow-x-auto mb-6">
                        <table class="w-full text-left border-collapse border border-gray-200">
                            <thead>
                            <tr class="bg-gray-100">
                                <th class="p-3 border-b">Book</th>
                                <th class="p-3 border-b text-center">Qty</th>
                                <th class="p-3 border-b text-right">Unit Price</th>
                                <th class="p-3 border-b text-right">Subtotal</th>
                                <th class="p-3 border-b text-center">Action</th>
                            </tr>
                            </thead>
                            <tbody id="bill-items">
                            <!-- This will be populated by JavaScript -->
                            <tr id="empty-bill">
                                <td colspan="5" class="p-3 text-center text-gray-500 border-b">
                                    No items added
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Payment & Totals Section -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                        <!-- Payment Details -->
                        <div>
                            <h3 class="font-semibold mb-3">Payment Details</h3>
                            <div class="space-y-3">
                                <div>
                                    <label class="block text-sm font-medium mb-1">Payment Method</label>
                                    <select id="payment-method" class="w-full border border-gray-300 rounded-lg p-2">
                                        <option value="CASH">Cash</option>
                                        <option value="CARD">Card</option>
                                        <option value="ONLINE">Online</option>
                                        <option value="CHEQUE">Cheque</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-1">Payment Status</label>
                                    <select id="payment-status" class="w-full border border-gray-300 rounded-lg p-2">
                                        <option value="UNPAID">Unpaid</option>
                                        <option value="PAID">Paid</option>
                                        <option value="PARTIAL">Partial</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-1">Discount (%)</label>
                                    <input type="number" id="discount" value="0" min="0" max="100"
                                           class="w-full border border-gray-300 rounded-lg p-2 text-center">
                                </div>
                            </div>
                        </div>

                        <!-- Totals -->
                        <div>
                            <h3 class="font-semibold mb-3">Bill Summary</h3>
                            <div class="bg-gray-50 p-4 rounded-lg space-y-2">
                                <div class="flex justify-between">
                                    <span>Subtotal:</span>
                                    <span id="subtotal">Rs. 0.00</span>
                                </div>
                                <div class="flex justify-between">
                                    <span>Discount:</span>
                                    <span id="discount-amount">Rs. 0.00</span>
                                </div>
                                <div class="flex justify-between text-lg font-bold border-t pt-2">
                                    <span>Total:</span>
                                    <span id="total">Rs. 0.00</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Notes Section -->
                    <div class="mb-6">
                        <label class="block text-sm font-medium mb-2">Notes (Optional)</label>
                        <textarea id="notes" rows="3" placeholder="Add any additional notes here..."
                                  class="w-full border border-gray-300 rounded-lg p-3"></textarea>
                    </div>

                    <!-- Action Buttons -->
                    <div class="flex justify-between">
                        <button type="button" onclick="clearBill()" class="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600">
                            <i class="fas fa-times mr-2"></i> Clear
                        </button>
                        <div class="space-x-3">
                            <button type="button" onclick="window.location.href='BillServlet'" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                                <i class="fas fa-list mr-2"></i> View Bills
                            </button>
                            <button type="submit" id="complete-billing" class="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700">
                                <i class="fas fa-check mr-2"></i> Create Bill
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </main>
</div>

<!-- Scripts -->
<script>
    let billItems = [];

    // Customer selection handler - FIXED
    document.getElementById('customer-select').addEventListener('change', function () {
        const selected = this.options[this.selectedIndex];
        document.getElementById('customerId').value = this.value;

        // Use getAttribute instead of dataset for better compatibility
        document.getElementById('customer-name').textContent = selected.getAttribute('data-name') || 'No customer selected';
        document.getElementById('customer-phone').textContent = selected.getAttribute('data-phone') || '';
        document.getElementById('customer-email').textContent = selected.getAttribute('data-email') || '';
        document.getElementById('customer-address').textContent = selected.getAttribute('data-address') || '';
    });

    // Add book to bill - FIXED
    document.getElementById('add-book').addEventListener('click', function() {
        const bookSelect = document.getElementById('book-select');
        const qtyInput = document.getElementById('book-qty');

        if (!bookSelect.value) {
            alert('Please select a book');
            return;
        }

        const quantity = parseInt(qtyInput.value);
        if (isNaN(quantity) || quantity < 1) {
            alert('Please enter a valid quantity');
            return;
        }

        const selectedOption = bookSelect.options[bookSelect.selectedIndex];
        const bookId = bookSelect.value;

        // Use getAttribute instead of dataset for better compatibility
        const bookTitle = selectedOption.getAttribute('data-title');
        const price = parseFloat(selectedOption.getAttribute('data-price'));
        const stock = parseInt(selectedOption.getAttribute('data-stock'));

        // Debug logging - you can remove these later
        console.log('Selected book data:', {
            bookId: bookId,
            bookTitle: bookTitle,
            price: price,
            stock: stock,
            quantity: quantity
        });

        // Validate data
        if (!bookTitle || isNaN(price) || isNaN(stock)) {
            alert('Invalid book data. Please refresh the page and try again.');
            console.error('Invalid book data:', {bookTitle, price, stock});
            return;
        }

        // Check if book already exists in bill
        const existingItem = billItems.find(item => item.bookId === bookId);
        if (existingItem) {
            const newQty = existingItem.qty + quantity;
            if (newQty > stock) {
                alert(`Insufficient stock! Available: ${stock}, Total requested: ${newQty}`);
                return;
            }
            existingItem.qty = newQty;
            existingItem.subtotal = existingItem.qty * price;
        } else {
            if (quantity > stock) {
                alert(`Insufficient stock! Available: ${stock}, Requested: ${quantity}`);
                return;
            }
            billItems.push({
                bookId: bookId,
                bookTitle: bookTitle,
                qty: quantity,
                price: price,
                subtotal: price * quantity
            });
        }

        // Reset form
        bookSelect.value = '';
        qtyInput.value = '1';
        renderBill();
    });

    // Render bill table - ENHANCED
    function renderBill() {
        const tbody = document.getElementById('bill-items');
        const billDataDiv = document.getElementById('bill-data');

        tbody.innerHTML = '';
        billDataDiv.innerHTML = '';

        let subtotal = 0;

        if (billItems.length === 0) {
            tbody.innerHTML = `
            <tr id="empty-bill">
                <td colspan="5" class="p-3 text-center text-gray-500 border-b">
                    No items added
                </td>
            </tr>
        `;
        } else {
            billItems.forEach((item, index) => {
                subtotal += item.subtotal;

                // Add row to table
                const row = document.createElement('tr');
                row.className = 'border-b hover:bg-gray-50';
                row.innerHTML = `
                    <td class="p-3">${item.bookTitle}</td>
                    <td class="p-3 text-center">${item.qty}</td>
                    <td class="p-3 text-right">Rs. ${item.price.toFixed(2)}</td>
                    <td class="p-3 text-right">Rs. ${item.subtotal.toFixed(2)}</td>
                    <td class="p-3 text-center">
                        <button type="button" onclick="removeItem(${index})"
                                class="text-red-600 hover:text-red-800">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                `;
                tbody.appendChild(row);

                // Add hidden form inputs
                const bookInput = document.createElement('input');
                bookInput.type = 'hidden';
                bookInput.name = 'bookId';
                bookInput.value = item.bookId;

                const qtyInput = document.createElement('input');
                qtyInput.type = 'hidden';
                qtyInput.name = 'quantity';
                qtyInput.value = item.qty;

                billDataDiv.appendChild(bookInput);
                billDataDiv.appendChild(qtyInput);
            });
        }

        updateTotals(subtotal);
    }

    // Update totals calculation
    function updateTotals(subtotal) {
        const discountPercent = parseFloat(document.getElementById('discount').value) || 0;
        const discountAmount = subtotal * (discountPercent / 100);
        const total = subtotal - discountAmount;

        document.getElementById('subtotal').textContent = `Rs. ${subtotal.toFixed(2)}`;
        document.getElementById('discount-amount').textContent = `Rs. ${discountAmount.toFixed(2)}`;
        document.getElementById('total').textContent = `Rs. ${total.toFixed(2)}`;

        // Update hidden fields
        document.getElementById('subtotal-hidden').value = subtotal.toFixed(2);
        document.getElementById('discount-hidden').value = discountAmount.toFixed(2);
        document.getElementById('total-hidden').value = total.toFixed(2);
        document.getElementById('payment-status-hidden').value = document.getElementById('payment-status').value;
        document.getElementById('payment-method-hidden').value = document.getElementById('payment-method').value;
        document.getElementById('notes-hidden').value = document.getElementById('notes').value;
    }

    // Remove item from bill
    function removeItem(index) {
        if (confirm('Remove this item from the bill?')) {
            billItems.splice(index, 1);
            renderBill();
        }
    }

    // Clear entire bill
    function clearBill() {
        if (confirm('Are you sure you want to clear the entire bill?')) {
            billItems = [];
            document.getElementById('customer-select').value = '';
            document.getElementById('customerId').value = '';
            document.getElementById('customer-name').textContent = 'No customer selected';
            document.getElementById('customer-phone').textContent = '';
            document.getElementById('customer-email').textContent = '';
            document.getElementById('customer-address').textContent = '';
            document.getElementById('discount').value = '0';
            document.getElementById('payment-status').value = 'UNPAID';
            document.getElementById('payment-method').value = 'CASH';
            document.getElementById('notes').value = '';
            renderBill();
        }
    }

    // Update totals when discount changes
    document.getElementById('discount').addEventListener('input', function() {
        const subtotal = billItems.reduce((sum, item) => sum + item.subtotal, 0);
        updateTotals(subtotal);
    });

    // Update payment details
    document.getElementById('payment-method').addEventListener('change', function() {
        document.getElementById('payment-method-hidden').value = this.value;
    });

    document.getElementById('payment-status').addEventListener('change', function() {
        document.getElementById('payment-status-hidden').value = this.value;
    });

    document.getElementById('notes').addEventListener('input', function() {
        document.getElementById('notes-hidden').value = this.value;
    });

    // Form validation before submit
    document.getElementById('billing-form').addEventListener('submit', function(e) {
        if (!document.getElementById('customerId').value) {
            e.preventDefault();
            alert('Please select a customer');
            return false;
        }

        if (billItems.length === 0) {
            e.preventDefault();
            alert('Please add at least one book to the bill');
            return false;
        }

        // Show loading state
        const submitBtn = document.getElementById('complete-billing');
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i> Creating Bill...';

        return true;
    });

    // Mobile sidebar toggle
    document.getElementById('sidebar-toggle')?.addEventListener('click', function() {
        const sidebar = document.querySelector('.fixed.inset-y-0.left-0');
        sidebar.classList.toggle('-translate-x-full');
    });

    // Initialize page
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Billing page loaded');
        console.log('Available books:', document.querySelectorAll('#book-select option').length - 1);
        console.log('Available customers:', document.querySelectorAll('#customer-select option').length - 1);
    });
</script>

</body>
</html>