<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>

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
      <a href="Home.jsp" class="flex items-center px-4 py-3 text-white bg-indigo-900 rounded-lg">
        <i class="fas fa-tachometer-alt mr-3"></i>
        Dashboard
      </a>
      <a href="Book.jsp" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
        <i class="fas fa-book mr-3"></i>
        Books
      </a>
      <a href="Customer.jsp" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
        <i class="fas fa-users mr-3"></i>
        Customers
      </a>
      <a href="Bill.jsp" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
        <i class="fa-solid fa-money-bill mr-3"></i>
        Billing
      </a>
      <a href="#" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
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
            <p class="text-2xl font-semibold text-gray-800">1,248</p>
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
            <p class="text-2xl font-semibold text-gray-800">856</p>
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

    <!-- Dashboard Sections -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
      <!-- Customer List -->
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 bg-indigo-600 text-white">
          <h3 class="text-lg font-medium">Customer List</h3>
        </div>
        <ul class="divide-y divide-gray-200">
          <li class="px-6 py-4 hover:bg-gray-50">
            <div class="flex items-center">
              <img class="h-10 w-10 rounded-full" src="https://randomuser.me/api/portraits/men/1.jpg" alt="">
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">John Doe</p>
                <p class="text-sm text-gray-500">john@example.com</p>
              </div>
            </div>
          </li>
          <li class="px-6 py-4 hover:bg-gray-50">
            <div class="flex items-center">
              <img class="h-10 w-10 rounded-full" src="https://randomuser.me/api/portraits/women/2.jpg" alt="">
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">Jane Smith</p>
                <p class="text-sm text-gray-500">jane@example.com</p>
              </div>
            </div>
          </li>
          <li class="px-6 py-4 hover:bg-gray-50">
            <div class="flex items-center">
              <img class="h-10 w-10 rounded-full" src="https://randomuser.me/api/portraits/men/3.jpg" alt="">
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">David Johnson</p>
                <p class="text-sm text-gray-500">david@example.com</p>
              </div>
            </div>
          </li>
        </ul>
        <div class="px-6 py-4 border-t border-gray-200 bg-gray-50">
          <a href="#" class="text-indigo-600 hover:text-indigo-900 text-sm font-medium">View all customers</a>
        </div>
      </div>

      <!-- Recently Added Books -->
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 bg-green-600 text-white">
          <h3 class="text-lg font-medium">Recently Added Books</h3>
        </div>
        <ul class="divide-y divide-gray-200">
          <li class="px-6 py-4 hover:bg-gray-50">
            <div class="flex items-center">
              <img class="h-12 w-10 rounded object-cover" src="https://m.media-amazon.com/images/I/41f6Rd6ZEPL._SY425_.jpg" alt="Intro to Java">
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">Intro to Java</p>
                <p class="text-sm text-gray-500">Programming</p>
                <div class="mt-1">
                  <span class="text-xs font-medium px-2 py-1 bg-blue-100 text-blue-800 rounded-full">New</span>
                </div>
              </div>
            </div>
          </li>
          <li class="px-6 py-4 hover:bg-gray-50">
            <div class="flex items-center">
              <img class="h-12 w-10 rounded object-cover" src="https://m.media-amazon.com/images/I/51xwGSNX-EL._SY425_.jpg" alt="Advanced Python">
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">Advanced Python</p>
                <p class="text-sm text-gray-500">Programming</p>
                <div class="mt-1">
                  <span class="text-xs font-medium px-2 py-1 bg-blue-100 text-blue-800 rounded-full">New</span>
                </div>
              </div>
            </div>
          </li>
          <li class="px-6 py-4 hover:bg-gray-50">
            <div class="flex items-center">
              <img class="h-12 w-10 rounded object-cover" src="https://m.media-amazon.com/images/I/51WS36aA2BL._SY425_.jpg" alt="Web Dev 101">
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">Web Dev 101</p>
                <p class="text-sm text-gray-500">Web Development</p>
                <div class="mt-1">
                  <span class="text-xs font-medium px-2 py-1 bg-blue-100 text-blue-800 rounded-full">New</span>
                </div>
              </div>
            </div>
          </li>
        </ul>
        <div class="px-6 py-4 border-t border-gray-200 bg-gray-50">
          <a href="#" class="text-indigo-600 hover:text-indigo-900 text-sm font-medium">View all books</a>
        </div>
      </div>

      <!-- Most Purchased Books -->
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 bg-yellow-500 text-white">
          <h3 class="text-lg font-medium">Most Purchased Books</h3>
        </div>
        <ul class="divide-y divide-gray-200">
          <li class="px-6 py-4 hover:bg-gray-50">
            <div class="flex items-center">
              <span class="text-lg font-bold text-indigo-600 mr-4">1</span>
              <img class="h-12 w-10 rounded object-cover" src="https://m.media-amazon.com/images/I/51S8VRHA2FL._SY425_.jpg" alt="Java Basics">
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">Java Basics</p>
                <p class="text-sm text-gray-500">42 purchases</p>
              </div>
            </div>
          </li>
          <li class="px-6 py-4 hover:bg-gray-50">
            <div class="flex items-center">
              <span class="text-lg font-bold text-indigo-600 mr-4">2</span>
              <img class="h-12 w-10 rounded object-cover" src="https://m.media-amazon.com/images/I/51VXgNZFIoL._SY425_.jpg" alt="Spring Boot in Action">
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">Spring Boot in Action</p>
                <p class="text-sm text-gray-500">38 purchases</p>
              </div>
            </div>
          </li>
          <li class="px-6 py-4 hover:bg-gray-50">
            <div class="flex items-center">
              <span class="text-lg font-bold text-indigo-600 mr-4">3</span>
              <img class="h-12 w-10 rounded object-cover" src="https://m.media-amazon.com/images/I/51gP9mXEqWL._SY425_.jpg" alt="Learning SQL">
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">Learning SQL</p>
                <p class="text-sm text-gray-500">35 purchases</p>
              </div>
            </div>
          </li>
        </ul>
        <div class="px-6 py-4 border-t border-gray-200 bg-gray-50">
          <a href="#" class="text-indigo-600 hover:text-indigo-900 text-sm font-medium">View all bestsellers</a>
        </div>
      </div>
    </div>

    <!-- Billing Info Chart -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-200 bg-blue-600 text-white">
        <h3 class="text-lg font-medium">Monthly Sales</h3>
      </div>
      <div class="p-6">
        <canvas id="billingChart" height="100"></canvas>
      </div>
    </div>
  </main>
</div>

<!-- Login Modal -->
<div class="modal fade fixed top-0 left-0 hidden w-full h-full outline-none overflow-x-hidden overflow-y-auto" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel" aria-hidden="true"
     data-bs-backdrop="static" data-bs-keyboard="false">
  <div class="modal-dialog relative w-auto pointer-events-none">
    <div class="modal-content border-none shadow-lg relative flex flex-col w-full pointer-events-auto bg-white bg-clip-padding rounded-md outline-none text-current">
      <form method="post" action="login.jsp" class="rounded-lg">
        <div class="modal-header flex flex-shrink-0 items-center justify-between p-4 border-b border-gray-200 rounded-t-md bg-indigo-600 text-white">
          <h5 class="text-xl font-medium leading-normal" id="loginModalLabel">Login</h5>
        </div>
        <div class="modal-body relative p-4">
          <div class="mb-4">
            <label for="username" class="block text-sm font-medium text-gray-700 mb-1">Username</label>
            <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500" name="username" id="username" required>
          </div>
          <div class="mb-4">
            <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password</label>
            <input type="password" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500" name="password" id="password" required>
          </div>
        </div>
        <div class="modal-footer flex flex-shrink-0 flex-wrap items-center justify-end p-4 border-t border-gray-200 rounded-b-md">
          <button type="submit" class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500">
            Login
          </button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Scripts -->
<script>
  // Toggle sidebar on mobile
  document.getElementById('sidebar-toggle').addEventListener('click', function() {
    document.querySelector('.fixed.inset-y-0.left-0').classList.toggle('-translate-x-full');
  });

  // Initialize chart
  document.addEventListener('DOMContentLoaded', function() {
    const ctx = document.getElementById('billingChart').getContext('2d');
    const billingChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        datasets: [{
          label: 'Monthly Sales ($)',
          data: [1200, 1500, 1800, 1100, 1900, 2300],
          backgroundColor: 'rgba(79, 70, 229, 0.6)',
          borderColor: 'rgba(79, 70, 229, 1)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            grid: {
              drawBorder: false,
              color: "rgba(229, 229, 229, 0.3)"
            }
          },
          x: {
            grid: {
              display: false,
              drawBorder: false
            }
          }
        },
        plugins: {
          legend: {
            display: false
          }
        }
      }
    });

    // Initialize modal if not logged in
    <c:if test="${empty loggedIn or !loggedIn}">
    var loginModal = new bootstrap.Modal(document.getElementById('loginModal'));
    loginModal.show();
    </c:if>
  });
</script>
</body>
</html>