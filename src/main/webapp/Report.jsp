<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bills Report - PahanEdu Bookshop</title>
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

        /* Print styles */
        @media print {
            .no-print { display: none !important; }
            body { font-size: 12px; }
            .print-break { page-break-after: always; }
            .expandable-content { display: block !important; }
        }

        /* Status badges */
        .status-paid { @apply bg-green-100 text-green-800; }
        .status-unpaid { @apply bg-red-100 text-red-800; }
        .status-partial { @apply bg-yellow-100 text-yellow-800; }

        /* Expandable rows */
        .bill-details {
            transition: all 0.3s ease;
            max-height: 0;
            overflow: hidden;
        }
        .bill-details.expanded {
            max-height: 1000px;
        }

        .expand-icon {
            transition: transform 0.3s ease;
        }
        .expand-icon.expanded {
            transform: rotate(180deg);
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
            <a href="CreateBillServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
                <i class="fa-solid fa-money-bill mr-3"></i>Bill
            </a>
            <a href="BillServlet" class="flex items-center px-4 py-3 text-white bg-indigo-900 rounded-lg">
                <i class="fas fa-chart-line mr-3"></i>Report
            </a>
        </div>
    </nav>
</div>

<!-- Mobile sidebar toggle -->
<div class="md:hidden fixed top-4 left-4 z-40 no-print">
    <button id="sidebar-toggle" class="p-2 rounded-md bg-indigo-800 text-white focus:outline-none">
        <i class="fas fa-bars"></i>
    </button>
</div>

<!-- Main Content -->
<div class="md:ml-64 min-h-screen">
    <!-- Header -->
    <header class="bg-white shadow-sm no-print">
        <div class="flex justify-between items-center px-6 py-4">
            <h1 class="text-2xl font-semibold text-gray-800 flex items-center">
                <i class="fas fa-chart-line text-blue-600 mr-3"></i> Bills Report
            </h1>
            <div class="flex space-x-3">
                <button onclick="expandAll()" class="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700">
                    <i class="fas fa-expand mr-2"></i> Expand All
                </button>
                <button onclick="collapseAll()" class="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700">
                    <i class="fas fa-compress mr-2"></i> Collapse All
                </button>
                <button onclick="window.print()" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
                    <i class="fas fa-print mr-2"></i> Print Report
                </button>
                <a href="CreateBillServlet" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700">
                    <i class="fas fa-plus mr-2"></i> New Bill
                </a>
            </div>
        </div>
    </header>

    <!-- Main Content Area -->
    <main class="p-6">
        <!-- Summary Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="p-3 rounded-full bg-blue-100 text-blue-600">
                        <i class="fas fa-file-invoice text-xl"></i>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-600">Total Bills</p>
                        <p class="text-2xl font-semibold text-gray-900">${totalBills != null ? totalBills : 0}</p>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="p-3 rounded-full bg-green-100 text-green-600">
                        <i class="fas fa-check-circle text-xl"></i>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-600">Paid Bills</p>
                        <p class="text-2xl font-semibold text-gray-900">${paidBills != null ? paidBills : 0}</p>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="p-3 rounded-full bg-red-100 text-red-600">
                        <i class="fas fa-exclamation-circle text-xl"></i>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-600">Unpaid Bills</p>
                        <p class="text-2xl font-semibold text-gray-900">${unpaidBills != null ? unpaidBills : 0}</p>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="p-3 rounded-full bg-yellow-100 text-yellow-600">
                        <i class="fas fa-dollar-sign text-xl"></i>
                    </div>
                    <div class="ml-4">
                        <p class="text-sm font-medium text-gray-600">Total Sales</p>
                        <p class="text-2xl font-semibold text-gray-900">Rs. <fmt:formatNumber value="${totalSales != null ? totalSales : 0}" pattern="#,##0.00"/></p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="bg-white rounded-lg shadow mb-6 p-6 no-print">
            <h2 class="text-lg font-semibold mb-4 flex items-center">
                <i class="fas fa-filter mr-2 text-indigo-600"></i> Filters
            </h2>
            <form action="BillServlet" method="get" class="grid grid-cols-1 md:grid-cols-5 gap-4">
                <div>
                    <label class="block text-sm font-medium mb-1">Payment Status</label>
                    <select name="paymentStatus" class="w-full border border-gray-300 rounded-lg p-2">
                        <option value="">All Status</option>
                        <option value="PAID" ${param.paymentStatus == 'PAID' ? 'selected' : ''}>Paid</option>
                        <option value="UNPAID" ${param.paymentStatus == 'UNPAID' ? 'selected' : ''}>Unpaid</option>
                        <option value="PARTIAL" ${param.paymentStatus == 'PARTIAL' ? 'selected' : ''}>Partial</option>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium mb-1">Payment Method</label>
                    <select name="paymentMethod" class="w-full border border-gray-300 rounded-lg p-2">
                        <option value="">All Methods</option>
                        <option value="CASH" ${param.paymentMethod == 'CASH' ? 'selected' : ''}>Cash</option>
                        <option value="CARD" ${param.paymentMethod == 'CARD' ? 'selected' : ''}>Card</option>
                        <option value="ONLINE" ${param.paymentMethod == 'ONLINE' ? 'selected' : ''}>Online</option>
                        <option value="CHEQUE" ${param.paymentMethod == 'CHEQUE' ? 'selected' : ''}>Cheque</option>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium mb-1">From Date</label>
                    <input type="date" name="fromDate" value="${param.fromDate}"
                           class="w-full border border-gray-300 rounded-lg p-2">
                </div>
                <div>
                    <label class="block text-sm font-medium mb-1">To Date</label>
                    <input type="date" name="toDate" value="${param.toDate}"
                           class="w-full border border-gray-300 rounded-lg p-2">
                </div>
                <div class="flex items-end">
                    <button type="submit" class="w-full bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700">
                        <i class="fas fa-search mr-2"></i> Filter
                    </button>
                </div>
            </form>
        </div>

        <!-- Search -->
        <div class="bg-white rounded-lg shadow mb-6 p-6 no-print">
            <div class="flex gap-4">
                <div class="flex-1">
                    <input type="text" id="search-input" placeholder="Search by Bill Number, Customer Name, Email, or Phone..."
                           class="w-full border border-gray-300 rounded-lg p-3 focus:ring-2 focus:ring-indigo-500">
                </div>
                <button onclick="clearSearch()" class="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600">
                    <i class="fas fa-times mr-2"></i> Clear
                </button>
            </div>
        </div>

        <!-- Debug Information (Remove in production) -->
        <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-6">
            <h3 class="text-sm font-medium text-yellow-800">Debug Info:</h3>
            <p class="text-sm text-yellow-700">Bills count: ${fn:length(bills)}</p>
            <p class="text-sm text-yellow-700">Bills empty: ${empty bills}</p>
        </div>

        <!-- Bills Table with Expandable Details -->
        <div class="bg-white rounded-lg shadow">
            <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-lg font-semibold flex items-center">
                    <i class="fas fa-list mr-2 text-indigo-600"></i> Bills List with Full Details
                    <span class="ml-2 text-sm text-gray-500">
                        (${fn:length(bills)} bills found)
                    </span>
                </h2>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            <i class="fas fa-chevron-down mr-1"></i> Bill Details
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Customer
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Date
                        </th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Amount
                        </th>
                        <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Payment
                        </th>
                        <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider no-print">
                            Actions
                        </th>
                    </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200" id="bills-table">
                    <c:choose>
                        <c:when test="${empty bills}">
                            <tr>
                                <td colspan="6" class="px-6 py-12 text-center text-gray-500">
                                    <i class="fas fa-inbox text-4xl mb-4 text-gray-300"></i>
                                    <p class="text-lg">No bills found</p>
                                    <p class="text-sm">Try adjusting your filters or create a new bill</p>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="bill" items="${bills}" varStatus="status">
                                <!-- Main Bill Row -->
                                <tr class="hover:bg-gray-50 searchable-row cursor-pointer bill-row"
                                    data-search="${bill.billNumber} ${bill.customerName} ${bill.customerEmail} ${bill.customerPhone}"
                                    data-index="${status.index}">
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="flex items-center">
                                            <i class="fas fa-chevron-right expand-icon mr-3 text-gray-400 transition-transform"
                                               id="icon-${status.index}"></i>
                                            <div class="flex flex-col">
                                                <div class="text-sm font-medium text-gray-900">${bill.billNumber}</div>
                                                <div class="text-sm text-gray-500">ID: ${bill.id}</div>
                                                <div class="text-xs text-blue-600">${fn:length(bill.billItems)} items</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="flex flex-col">
                                            <div class="text-sm font-medium text-gray-900">${bill.customerName}</div>
                                            <div class="text-sm text-gray-500">${bill.customerEmail}</div>
                                            <div class="text-sm text-gray-500">${bill.customerPhone}</div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <div class="text-sm text-gray-900">
                                                ${bill.billDate.toLocalDate()}
                                        </div>
                                        <div class="text-sm text-gray-500">
                                                ${bill.billDate.toLocalTime()}
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-right">
                                        <div class="text-sm font-medium text-gray-900">
                                            Rs. <fmt:formatNumber value="${bill.totalAmount}" pattern="#,##0.00"/>
                                        </div>
                                        <c:if test="${bill.discount > 0}">
                                            <div class="text-xs text-green-600">
                                                Discount: Rs. <fmt:formatNumber value="${bill.discount}" pattern="#,##0.00"/>
                                            </div>
                                        </c:if>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-center">
                                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full
                                                ${bill.paymentStatus == 'PAID' ? 'status-paid' :
                                                  bill.paymentStatus == 'UNPAID' ? 'status-unpaid' : 'status-partial'}">
                                                    ${bill.paymentStatus}
                                            </span>
                                        <div class="text-xs text-gray-500 mt-1">${bill.paymentMethod}</div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-center no-print">
                                        <div class="flex justify-center space-x-2">
                                            <a href="ViewBillServlet?id=${bill.id}"
                                               class="text-blue-600 hover:text-blue-900 px-2 py-1 rounded"
                                               onclick="event.stopPropagation()">
                                                <i class="fas fa-eye" title="View Details"></i>
                                            </a>
                                            <c:if test="${bill.paymentStatus != 'PAID'}">
                                                <button onclick="updatePaymentStatus(${bill.id}, '${bill.billNumber}'); event.stopPropagation();"
                                                        class="text-green-600 hover:text-green-900 px-2 py-1 rounded">
                                                    <i class="fas fa-dollar-sign" title="Update Payment"></i>
                                                </button>
                                            </c:if>

                                        </div>
                                    </td>
                                </tr>

                                <!-- Expandable Bill Details Row -->
                                <tr class="bill-details expandable-content" id="details-${status.index}">
                                    <td colspan="6" class="px-6 py-0">
                                        <div class="bg-gray-50 rounded-lg p-4 m-2">
                                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                                <!-- Bill Information -->
                                                <div class="bg-white rounded-lg p-4">
                                                    <h4 class="font-semibold text-gray-900 mb-3 flex items-center">
                                                        <i class="fas fa-info-circle mr-2 text-blue-600"></i>
                                                        Bill Information
                                                    </h4>
                                                    <div class="space-y-2 text-sm">
                                                        <div class="flex justify-between">
                                                            <span class="text-gray-600">Subtotal:</span>
                                                            <span class="font-medium">Rs. <fmt:formatNumber value="${bill.subtotal}" pattern="#,##0.00"/></span>
                                                        </div>
                                                        <div class="flex justify-between">
                                                            <span class="text-gray-600">Discount:</span>
                                                            <span class="font-medium text-green-600">Rs. <fmt:formatNumber value="${bill.discount}" pattern="#,##0.00"/></span>
                                                        </div>
                                                        <div class="flex justify-between border-t pt-2">
                                                            <span class="text-gray-900 font-semibold">Total Amount:</span>
                                                            <span class="font-bold text-lg">Rs. <fmt:formatNumber value="${bill.totalAmount}" pattern="#,##0.00"/></span>
                                                        </div>
                                                        <c:if test="${not empty bill.notes}">
                                                            <div class="mt-3 p-2 bg-yellow-50 rounded border-l-4 border-yellow-400">
                                                                <span class="text-gray-600 text-xs">Notes:</span>
                                                                <p class="text-sm text-gray-700">${bill.notes}</p>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                </div>

                                                <!-- Bill Items -->
                                                <div class="bg-white rounded-lg p-4">
                                                    <h4 class="font-semibold text-gray-900 mb-3 flex items-center">
                                                        <i class="fas fa-shopping-cart mr-2 text-green-600"></i>
                                                        Items Purchased (${fn:length(bill.billItems)})
                                                    </h4>
                                                    <c:choose>
                                                        <c:when test="${not empty bill.billItems}">
                                                            <div class="space-y-2 max-h-64 overflow-y-auto">
                                                                <c:forEach var="item" items="${bill.billItems}">
                                                                    <div class="flex justify-between items-center p-2 bg-gray-50 rounded border">
                                                                        <div class="flex-1">
                                                                            <div class="font-medium text-sm text-gray-900">${item.bookTitle}</div>
                                                                            <div class="text-xs text-gray-500">Book ID: ${item.bookId}</div>
                                                                        </div>
                                                                        <div class="text-right text-sm">
                                                                            <div class="font-medium">
                                                                                    ${item.quantity} × Rs. <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0.00"/>
                                                                            </div>
                                                                            <div class="text-gray-600">
                                                                                = Rs. <fmt:formatNumber value="${item.subtotal}" pattern="#,##0.00"/>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </c:forEach>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <p class="text-sm text-gray-500 italic">No items found for this bill</p>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- Payment Update Modal -->
<div id="payment-modal" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden z-50">
    <div class="flex items-center justify-center min-h-screen p-4">
        <div class="bg-white rounded-lg max-w-md w-full p-6">
            <h3 class="text-lg font-medium mb-4">Update Payment Status</h3>
            <form id="payment-form" method="post" action="ViewBillServlet">
                <input type="hidden" name="action" value="updatePayment">
                <input type="hidden" name="billId" id="modal-bill-id">

                <div class="mb-4">
                    <label class="block text-sm font-medium mb-2">Payment Status</label>
                    <select name="paymentStatus" id="modal-payment-status" class="w-full border border-gray-300 rounded-lg p-2">
                        <option value="PAID">Paid</option>
                        <option value="UNPAID">Unpaid</option>
                        <option value="PARTIAL">Partial</option>
                    </select>
                </div>

                <div class="mb-4">
                    <label class="block text-sm font-medium mb-2">Payment Method</label>
                    <select name="paymentMethod" id="modal-payment-method" class="w-full border border-gray-300 rounded-lg p-2">
                        <option value="CASH">Cash</option>
                        <option value="CARD">Card</option>
                        <option value="ONLINE">Online</option>
                        <option value="CHEQUE">Cheque</option>
                    </select>
                </div>

                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="closePaymentModal()"
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

<!-- Scripts -->
<script>
    // Document ready function
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Document loaded');
        console.log('Bills found:', document.querySelectorAll('.bill-row').length);

        // Add click event listeners to bill rows
        addBillRowListeners();

        // Initialize search functionality
        initializeSearch();
    });

    // Add event listeners to bill rows
    function addBillRowListeners() {
        const billRows = document.querySelectorAll('.bill-row');
        console.log('Adding listeners to', billRows.length, 'rows');

        billRows.forEach(row => {
            row.addEventListener('click', function(e) {
                // Don't toggle if clicking on action buttons
                if (e.target.closest('.no-print')) {
                    return;
                }

                const index = this.getAttribute('data-index');
                console.log('Toggling bill details for index:', index);
                toggleBillDetails(index);
            });
        });
    }

    // Initialize search functionality
    function initializeSearch() {
        const searchInput = document.getElementById('search-input');
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                const searchTerm = this.value.toLowerCase();
                const rows = document.querySelectorAll('.searchable-row');
                console.log('Searching for:', searchTerm);

                rows.forEach(row => {
                    const searchData = row.getAttribute('data-search').toLowerCase();
                    const detailsRow = row.nextElementSibling;

                    if (searchData.includes(searchTerm)) {
                        row.style.display = '';
                        if (detailsRow && detailsRow.classList.contains('bill-details')) {
                            detailsRow.style.display = '';
                        }
                    } else {
                        row.style.display = 'none';
                        if (detailsRow && detailsRow.classList.contains('bill-details')) {
                            detailsRow.style.display = 'none';
                        }
                    }
                });
            });
        }
    }

    // Clear search
    function clearSearch() {
        const searchInput = document.getElementById('search-input');
        if (searchInput) {
            searchInput.value = '';
            document.querySelectorAll('.searchable-row').forEach(row => {
                row.style.display = '';
                const detailsRow = row.nextElementSibling;
                if (detailsRow && detailsRow.classList.contains('bill-details')) {
                    detailsRow.style.display = '';
                }
            });
        }
    }

    // Toggle bill details
    function toggleBillDetails(index) {
        const detailsRow = document.getElementById(`details-${index}`);
        const icon = document.getElementById(`icon-${index}`);

        console.log('Toggling details for index:', index);
        console.log('Details row:', detailsRow);
        console.log('Icon:', icon);

        if (detailsRow && icon) {
            if (detailsRow.classList.contains('expanded')) {
                detailsRow.classList.remove('expanded');
                icon.classList.remove('expanded');
                icon.classList.replace('fa-chevron-down', 'fa-chevron-right');
                console.log('Collapsed row', index);
            } else {
                detailsRow.classList.add('expanded');
                icon.classList.add('expanded');
                icon.classList.replace('fa-chevron-right', 'fa-chevron-down');
                console.log('Expanded row', index);
            }
        } else {
            console.error('Could not find elements for index:', index);
        }
    }

    // Expand all bills
    function expandAll() {
        console.log('Expanding all bills');
        document.querySelectorAll('.bill-details').forEach(details => {
            details.classList.add('expanded');
        });
        document.querySelectorAll('.expand-icon').forEach(icon => {
            icon.classList.add('expanded');
            icon.classList.replace('fa-chevron-right', 'fa-chevron-down');
        });
    }

    // Collapse all bills
    function collapseAll() {
        console.log('Collapsing all bills');
        document.querySelectorAll('.bill-details').forEach(details => {
            details.classList.remove('expanded');
        });
        document.querySelectorAll('.expand-icon').forEach(icon => {
            icon.classList.remove('expanded');
            icon.classList.replace('fa-chevron-down', 'fa-chevron-right');
        });
    }

    // Payment status update
    function updatePaymentStatus(billId, billNumber) {
        console.log('Updating payment status for bill:', billNumber);
        document.getElementById('modal-bill-id').value = billId;
        document.getElementById('payment-modal').classList.remove('hidden');
    }

    function closePaymentModal() {
        document.getElementById('payment-modal').classList.add('hidden');
    }

    // Delete bill
    function deleteBill(billId, billNumber) {
        if (confirm(`Are you sure you want to delete bill ${billNumber}? This action cannot be undone.`)) {
            window.location.href = `BillServlet?action=delete&id=${billId}`;
        }
    }

    // Mobile sidebar toggle
    const sidebarToggle = document.getElementById('sidebar-toggle');
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function() {
            const sidebar = document.querySelector('.fixed.inset-y-0.left-0');
            if (sidebar) {
                sidebar.classList.toggle('-translate-x-full');
            }
        });
    }

    // Auto-hide notifications
    setTimeout(() => {
        document.querySelectorAll('.notification').forEach(el => el.remove());
    }, 5000);

    // Print functionality enhancement
    window.addEventListener('beforeprint', function() {
        // Expand all details for printing
        expandAll();
    });

    // Error handling for missing elements
    window.addEventListener('error', function(e) {
        console.error('JavaScript error:', e.error);
    });

    // Debug function to check bill data
    function debugBillData() {
        const billRows = document.querySelectorAll('.bill-row');
        console.log('Total bill rows found:', billRows.length);

        billRows.forEach((row, index) => {
            const billNumber = row.querySelector('.text-gray-900').textContent;
            const detailsRow = document.getElementById(`details-${index}`);
            console.log(`Row ${index}: ${billNumber}, Details row exists:`, !!detailsRow);
        });
    }

    // Call debug function in console if needed
    // debugBillData();
</script>

</body>
</html>