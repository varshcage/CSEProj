<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bill Details - PahanEdu Bookshop</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Print styles */
        @media print {
            .no-print { display: none !important; }
            body { font-size: 12px; }
            .print-break { page-break-after: always; }
        }

        /* Status badges */
        .status-paid { @apply bg-green-100 text-green-800; }
        .status-unpaid { @apply bg-red-100 text-red-800; }
        .status-partial { @apply bg-yellow-100 text-yellow-800; }
    </style>
</head>
<body class="bg-gray-50 font-sans">

<!-- Sidebar -->
<div class="fixed inset-y-0 left-0 transform -translate-x-full md:translate-x-0 transition duration-200 ease-in-out z-40 w-64 bg-indigo-800 text-white shadow-lg no-print">
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
            <a href="CreateBillServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
                <i class="fa-solid fa-money-bill mr-3"></i> Create Bill
            </a>
            <a href="BillServlet" class="flex items-center px-4 py-3 text-white bg-indigo-900 rounded-lg">
                <i class="fas fa-chart-line mr-3"></i> Reports
            </a>
        </div>
    </nav>
</div>

<!-- Main Content -->
<div class="md:ml-64 min-h-screen">
    <!-- Header -->
    <header class="bg-white shadow-sm no-print">
        <div class="flex justify-between items-center px-6 py-4">
            <h1 class="text-2xl font-semibold text-gray-800 flex items-center">
                <i class="fas fa-file-invoice text-blue-600 mr-3"></i> Bill Details
            </h1>
            <div class="flex space-x-3">
                <button onclick="window.print()" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
                    <i class="fas fa-print mr-2"></i> Print
                </button>
                <a href="BillServlet" class="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700">
                    <i class="fas fa-arrow-left mr-2"></i> Back to Bills
                </a>
            </div>
        </div>
    </header>

    <!-- Main Content Area -->
    <main class="p-6">
        <c:if test="${not empty bill}">
            <!-- Format the date in Java -->
            <%
                if (request.getAttribute("bill") != null) {
                    com.pahana_edu.mypro.model.Bill bill = (com.pahana_edu.mypro.model.Bill) request.getAttribute("bill");
                    if (bill.getBillDate() != null) {
                        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm");
                        String formattedDate = bill.getBillDate().format(formatter);
                        request.setAttribute("formattedBillDate", formattedDate);
                    }
                }
            %>

            <!-- Bill Header -->
            <div class="bg-white rounded-lg shadow mb-6 p-6" id="printable-bill">
                <!-- Company Header -->
                <div class="text-center mb-6 border-b pb-4">
                    <h1 class="text-3xl font-bold text-indigo-800 mb-2">PahanEdu Bookshop</h1>
                    <p class="text-gray-600">123 Main Street, Colombo 07, Sri Lanka</p>
                    <p class="text-gray-600">Phone: +94 11 234 5678 | Email: info@pahanedubookshop.com</p>
                </div>

                <!-- Bill Info Grid -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    <!-- Bill Details -->
                    <div>
                        <h2 class="text-lg font-semibold mb-3 text-gray-800">Bill Information</h2>
                        <div class="space-y-2">
                            <div class="flex justify-between">
                                <span class="font-medium">Bill Number:</span>
                                <span class="text-indigo-600 font-semibold">${bill.billNumber}</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="font-medium">Bill Date:</span>
                                <span>${formattedBillDate}</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="font-medium">Payment Status:</span>
                                <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full
                                    ${bill.paymentStatus == 'PAID' ? 'status-paid' :
                                      bill.paymentStatus == 'UNPAID' ? 'status-unpaid' : 'status-partial'}">
                                        ${bill.paymentStatus}
                                </span>
                            </div>
                            <div class="flex justify-between">
                                <span class="font-medium">Payment Method:</span>
                                <span>${bill.paymentMethod}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Customer Details -->
                    <div>
                        <h2 class="text-lg font-semibold mb-3 text-gray-800">Customer Information</h2>
                        <div class="bg-gray-50 p-4 rounded-lg">
                            <p class="font-medium text-lg">${bill.customerName}</p>
                            <c:if test="${not empty bill.customerEmail}">
                                <p class="text-gray-600"><i class="fas fa-envelope mr-2"></i>${bill.customerEmail}</p>
                            </c:if>
                            <c:if test="${not empty bill.customerPhone}">
                                <p class="text-gray-600"><i class="fas fa-phone mr-2"></i>${bill.customerPhone}</p>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Bill Items Table -->
                <div class="mb-6">
                    <h2 class="text-lg font-semibold mb-3 text-gray-800">Items</h2>
                    <div class="overflow-x-auto">
                        <table class="w-full border-collapse border border-gray-200">
                            <thead>
                            <tr class="bg-gray-100">
                                <th class="border border-gray-200 px-4 py-3 text-left">Book Title</th>
                                <th class="border border-gray-200 px-4 py-3 text-center">Quantity</th>
                                <th class="border border-gray-200 px-4 py-3 text-right">Unit Price</th>
                                <th class="border border-gray-200 px-4 py-3 text-right">Subtotal</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:choose>
                                <c:when test="${not empty bill.billItems}">
                                    <c:forEach var="item" items="${bill.billItems}">
                                        <tr class="hover:bg-gray-50">
                                            <td class="border border-gray-200 px-4 py-3">${item.bookTitle}</td>
                                            <td class="border border-gray-200 px-4 py-3 text-center">${item.quantity}</td>
                                            <td class="border border-gray-200 px-4 py-3 text-right">
                                                Rs. <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0.00"/>
                                            </td>
                                            <td class="border border-gray-200 px-4 py-3 text-right">
                                                Rs. <fmt:formatNumber value="${item.subtotal}" pattern="#,##0.00"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4" class="border border-gray-200 px-4 py-6 text-center text-gray-500">
                                            <i class="fas fa-inbox text-2xl mb-2 text-gray-300"></i>
                                            <p>No items found for this bill</p>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Bill Summary -->
                <div class="flex justify-end mb-6">
                    <div class="w-full max-w-md">
                        <div class="bg-gray-50 p-4 rounded-lg space-y-2">
                            <div class="flex justify-between">
                                <span class="font-medium">Subtotal:</span>
                                <span>Rs. <fmt:formatNumber value="${bill.subtotal}" pattern="#,##0.00"/></span>
                            </div>
                            <c:if test="${bill.discount > 0}">
                                <div class="flex justify-between text-green-600">
                                    <span class="font-medium">Discount:</span>
                                    <span>- Rs. <fmt:formatNumber value="${bill.discount}" pattern="#,##0.00"/></span>
                                </div>
                            </c:if>
                            <div class="flex justify-between text-xl font-bold border-t pt-2">
                                <span>Total Amount:</span>
                                <span class="text-indigo-600">Rs. <fmt:formatNumber value="${bill.totalAmount}" pattern="#,##0.00"/></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Notes -->
                <c:if test="${not empty bill.notes}">
                    <div class="mb-6">
                        <h3 class="text-lg font-semibold mb-2 text-gray-800">Notes</h3>
                        <p class="bg-gray-50 p-3 rounded-lg">${bill.notes}</p>
                    </div>
                </c:if>

                <!-- Footer -->
                <div class="text-center text-gray-500 text-sm border-t pt-4">
                    <p>Thank you for your business!</p>
                    <p>This is a computer-generated bill.</p>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="bg-white rounded-lg shadow p-6 no-print">
                <div class="flex flex-wrap gap-3 justify-center">
                    <a href="BillServlet" class="bg-gray-600 text-white px-6 py-2 rounded-lg hover:bg-gray-700">
                        <i class="fas fa-arrow-left mr-2"></i> Back to Bills
                    </a>

                    <c:if test="${bill.paymentStatus != 'PAID'}">
                        <button onclick="showPaymentModal()" class="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700">
                            <i class="fas fa-dollar-sign mr-2"></i> Update Payment
                        </button>
                    </c:if>

                    <button onclick="window.print()" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                        <i class="fas fa-print mr-2"></i> Print Bill
                    </button>

                    <a href="CreateBillServlet" class="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700">
                        <i class="fas fa-plus mr-2"></i> New Bill
                    </a>
                </div>
            </div>

        </c:if>

        <c:if test="${empty bill}">
            <div class="bg-white rounded-lg shadow p-12 text-center">
                <i class="fas fa-file-invoice text-6xl text-gray-300 mb-4"></i>
                <h2 class="text-2xl font-semibold text-gray-700 mb-2">Bill Not Found</h2>
                <p class="text-gray-500 mb-6">The requested bill could not be found.</p>
                <a href="BillServlet" class="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700">
                    <i class="fas fa-arrow-left mr-2"></i> Back to Bills
                </a>
            </div>
        </c:if>
    </main>
</div>

<!-- Payment Update Modal -->
<c:if test="${not empty bill && bill.paymentStatus != 'PAID'}">
    <div id="payment-modal" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden z-50 no-print">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg max-w-md w-full p-6">
                <h3 class="text-lg font-medium mb-4">Update Payment Status</h3>
                <form method="post" action="ViewBillServlet">
                    <input type="hidden" name="action" value="updatePayment">
                    <input type="hidden" name="billId" value="${bill.id}">

                    <div class="mb-4">
                        <label class="block text-sm font-medium mb-2">Payment Status</label>
                        <select name="paymentStatus" class="w-full border border-gray-300 rounded-lg p-2">
                            <option value="PAID" ${bill.paymentStatus == 'PAID' ? 'selected' : ''}>Paid</option>
                            <option value="UNPAID" ${bill.paymentStatus == 'UNPAID' ? 'selected' : ''}>Unpaid</option>
                            <option value="PARTIAL" ${bill.paymentStatus == 'PARTIAL' ? 'selected' : ''}>Partial</option>
                        </select>
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-medium mb-2">Payment Method</label>
                        <select name="paymentMethod" class="w-full border border-gray-300 rounded-lg p-2">
                            <option value="CASH" ${bill.paymentMethod == 'CASH' ? 'selected' : ''}>Cash</option>
                            <option value="CARD" ${bill.paymentMethod == 'CARD' ? 'selected' : ''}>Card</option>
                            <option value="ONLINE" ${bill.paymentMethod == 'ONLINE' ? 'selected' : ''}>Online</option>
                            <option value="CHEQUE" ${bill.paymentMethod == 'CHEQUE' ? 'selected' : ''}>Cheque</option>
                        </select>
                    </div>

                    <div class="flex justify-end space-x-3">
                        <button type="button" onclick="hidePaymentModal()"
                                class="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600">
                            Cancel
                        </button>
                        <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700">
                            Update
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</c:if>

<!-- Scripts -->
<script>
    function showPaymentModal() {
        document.getElementById('payment-modal').classList.remove('hidden');
    }

    function hidePaymentModal() {
        document.getElementById('payment-modal').classList.add('hidden');
    }

    // Close modal when clicking outside
    document.getElementById('payment-modal')?.addEventListener('click', function(e) {
        if (e.target === this) {
            hidePaymentModal();
        }
    });
</script>

</body>
</html>