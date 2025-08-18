
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard - PahanEdu Bookshop</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    ::-webkit-scrollbar {
      width: 8px;
    }
    ::-webkit-scrollbar-track {
      background: #f1f1f1;
    }
    ::-webkit-scrollbar-thumb {
      background: #888;
      border-radius: 4px;
    }
    ::-webkit-scrollbar-thumb:hover {
      background: #555;
    }

    .notification {
      animation: slideIn 0.3s ease-out, fadeOut 0.5s ease 3s forwards;
    }

    @keyframes slideIn {
      from { transform: translateX(100%); }
      to { transform: translateX(0); }
    }

    @keyframes fadeOut {
      from { opacity: 1; }
      to { opacity: 0; }
    }
  </style>
</head>
<body class="bg-gray-50 font-sans">
<!-- Notification Area -->
<div id="notification-area" class="fixed top-4 right-4 z-50 space-y-2">
  <c:if test="${not empty message}">
    <div class="notification px-4 py-3 rounded-md shadow-md flex items-center
                ${message.type == 'success' ? 'bg-green-100 text-green-800' :
                  message.type == 'error' ? 'bg-red-100 text-red-800' :
                  'bg-blue-100 text-blue-800'}">
      <i class="fas ${message.type == 'success' ? 'fa-check-circle' :
                               message.type == 'error' ? 'fa-exclamation-circle' :
                               'fa-info-circle'} mr-2"></i>
        ${message.text}
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
      <a href="AdminDashboardServlet" class="flex items-center px-4 py-3 text-white bg-indigo-900 rounded-lg">
        <i class="fas fa-tachometer-alt mr-3"></i>
        Dashboard
      </a>
      <a href="BookServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
        <i class="fas fa-book mr-3"></i>
        Books
      </a>
      <a href="CustomerServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
        <i class="fas fa-users mr-3"></i>
        Customers
      </a>
      <a href="CreateBillServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
        <i class="fa-solid fa-money-bill mr-3"></i>
        Billing
      </a>
      <a href="BillServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
        <i class="fas fa-chart-line mr-3"></i>
        Reports
      </a>
    </div>
  </nav>
  <div class="absolute bottom-0 w-full p-4 border-t border-indigo-700">
    <div class="flex items-center">
      <img class="w-10 h-10 rounded-full bg-gray-200" src="" alt="Profile">
      <div class="ml-3">
        <p class="text-sm font-medium">Admin</p>
        <p class="text-xs text-indigo-300">Administrator</p>
      </div>
    </div>
  </div>
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
      <h1 class="text-2xl font-semibold text-gray-800">Dashboard</h1>
      <div class="flex items-center space-x-4">
        <div class="relative">
          <button class="p-2 rounded-full hover:bg-gray-100">
            <i class="fas fa-bell text-gray-600"></i>
            <span class="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full"></span>
          </button>
        </div>
        <div class="relative">
          <input type="text" placeholder="Search..." class="pl-10 pr-4 py-2 border rounded-full focus:outline-none focus:ring-2 focus:ring-indigo-500">
          <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
        </div>
      </div>
    </div>
  </header>

  <!-- Main Content Area -->
  <main class="p-6">
    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
      <div class="bg-white p-6 rounded-lg shadow">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-indigo-100 text-indigo-600">
            <i class="fas fa-book text-xl"></i>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">Total Books</p>
            <p class="text-2xl font-semibold text-gray-800">${totalBooks}</p>
          </div>
        </div>
        <div class="mt-4">
          <span class="text-green-500 text-sm font-medium">+12% from last month</span>
        </div>
      </div>

      <div class="bg-white p-6 rounded-lg shadow">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-green-100 text-green-600">
            <i class="fas fa-users text-xl"></i>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">Total Customers</p>
            <p class="text-2xl font-semibold text-gray-800">${totalCustomers}</p>
          </div>
        </div>
        <div class="mt-4">
          <span class="text-green-500 text-sm font-medium">+8% from last month</span>
        </div>
      </div>

      <div class="bg-white p-6 rounded-lg shadow">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-blue-100 text-blue-600">
            <i class="fas fa-shopping-cart text-xl"></i>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">Monthly Sales</p>
            <p class="text-2xl font-semibold text-gray-800">$24,560</p>
          </div>
        </div>
        <div class="mt-4">
          <span class="text-green-500 text-sm font-medium">+15% from last month</span>
        </div>
      </div>
    </div>

    <div class="mt-10 bg-white p-6 rounded-lg shadow">
      <h2 class="text-lg font-semibold text-gray-800 mb-4">Recent Customers</h2>
      <table class="w-full text-left table-auto border-collapse">
        <thead>
        <tr class="bg-gray-100">
          <th class="px-4 py-2">Name</th>
          <th class="px-4 py-2">Email</th>
          <th class="px-4 py-2">Phone</th>
          <th class="px-4 py-2">Country</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="customer" items="${topCustomers}">
          <tr class="border-b">
            <td class="px-4 py-2 flex items-center space-x-3">
              <div class="relative w-10 h-10">
                <img src="${pageContext.request.contextPath}/${customer.photoPath}" alt="Photo"
                     class="w-10 h-10 rounded-full object-cover border border-gray-300"
                     onerror="this.style.display='none'; this.nextElementSibling.style.display='inline-block';">
                <!-- Hidden icon by default -->
                <i class="fas fa-user-circle text-gray-400 text-2xl absolute top-0 left-0" style="display:none;"></i>
              </div>
              <span>${customer.name}</span>
            </td>


            <td class="px-4 py-2">${customer.email}</td>
            <td class="px-4 py-2">${customer.phone}</td>
            <td class="px-4 py-2">${customer.country}</td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>



    <div class="mt-6 bg-white p-6 rounded-lg shadow">
      <h2 class="text-lg font-semibold text-gray-800 mb-4">Recent Books</h2>
      <table class="w-full text-left table-auto border-collapse">
        <thead>
        <tr class="bg-gray-100">
          <th class="px-4 py-2">Title</th>
          <th class="px-4 py-2">Author</th>
          <th class="px-4 py-2">ISBN</th>
          <th class="px-4 py-2">Category</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="book" items="${topBooks}">
          <tr class="border-b">
            <td class="px-4 py-2 flex items-center space-x-3">
              <div class="relative w-10 h-14">
                <img src="${pageContext.request.contextPath}/${book.coverImagePath}" alt="Cover"
                     class="w-10 h-14 object-cover border border-gray-300 rounded"
                     onerror="this.style.display='none'; this.nextElementSibling.style.display='inline-block';">
                <!-- Hidden icon by default -->
                <i class="fas fa-book text-gray-400 text-2xl absolute top-0 left-0" style="display:none;"></i>
              </div>
              <span>${book.title}</span>
            </td>


            <td class="px-4 py-2">${book.author}</td>
            <td class="px-4 py-2">${book.isbn}</td>
            <td class="px-4 py-2">${book.category}</td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>

    <!-- Billing Info Chart -->
<%--    <div class="bg-white rounded-lg shadow overflow-hidden">--%>
<%--      <div class="px-6 py-4 border-b border-gray-200 bg-blue-600 text-white">--%>
<%--        <h3 class="text-lg font-medium">Monthly Sales</h3>--%>
<%--      </div>--%>
<%--      <div class="p-6">--%>
<%--        <canvas id="billingChart" height="100"></canvas>--%>
<%--      </div>--%>
<%--    </div>--%>
<%--  </main>--%>
<%--</div>--%>



<!-- Scripts -->
<script>
  // Toggle sidebar on mobile
  document.getElementById('sidebar-toggle').addEventListener('click', function() {
    document.querySelector('.fixed.inset-y-0.left-0').classList.toggle('-translate-x-full');
  });

  // Initialize chart
  const bookLabels = [<c:forEach var="e" items="${booksPerDay}" varStatus="s">${s.index > 0 ? ',' : '' }'${e.key}'</c:forEach>];
  const bookData = [<c:forEach var="e" items="${booksPerDay}" varStatus="s">${s.index > 0 ? ',' : '' }${e.value}</c:forEach>];

  const customerLabels = [<c:forEach var="e" items="${customersPerDay}" varStatus="s">${s.index > 0 ? ',' : '' }'${e.key}'</c:forEach>];
  const customerData = [<c:forEach var="e" items="${customersPerDay}" varStatus="s">${s.index > 0 ? ',' : '' }${e.value}</c:forEach>];

  const booksCtx = document.getElementById('booksChart').getContext('2d');
  new Chart(booksCtx, {
    type: 'bar',
    data: {
      labels: bookLabels,
      datasets: [{
        label: 'Books Added',
        data: bookData,
        backgroundColor: 'rgba(99, 102, 241, 0.6)',
        borderColor: 'rgba(99, 102, 241, 1)',
        borderWidth: 1
      }]
    },
    options: {
      scales: { y: { beginAtZero: true } }
    }
  });

  const customersCtx = document.getElementById('customersChart').getContext('2d');
  new Chart(customersCtx, {
    type: 'bar',
    data: {
      labels: customerLabels,
      datasets: [{
        label: 'Customers Added',
        data: customerData,
        backgroundColor: 'rgba(16, 185, 129, 0.6)',
        borderColor: 'rgba(16, 185, 129, 1)',
        borderWidth: 1
      }]
    },
    options: {
      scales: { y: { beginAtZero: true } }
    }
  });
</script>
</body>
</html>
