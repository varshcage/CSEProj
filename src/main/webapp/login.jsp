<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Book Haven - Admin Login</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    .bg-book-pattern {
      background-image: url('data:image/svg+xml;base64,PHN2Zy...');
    }
    .login-card {
      box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1),
      0 10px 10px -5px rgba(0, 0, 0, 0.04);
      transition: all 0.3s ease;
    }
    .login-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    }
    .input-field:focus {
      box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.3);
    }
  </style>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center bg-book-pattern">
<div class="login-card bg-white rounded-xl p-8 w-full max-w-md mx-4">
  <div class="text-center mb-8">
    <div class="flex justify-center mb-4">
      <i class="fas fa-book-open text-5xl text-indigo-600"></i>
    </div>
    <h1 class="text-3xl font-bold text-gray-800 mb-2">PahanEdu Book</h1>
    <p class="text-gray-600">Admin Login</p>
  </div>

  <%-- Error message display --%>
  <% if (request.getAttribute("error") != null) { %>
  <div class="mb-4 p-4 bg-red-50 border-l-4 border-red-500 text-red-700">
    <div class="flex items-center">
      <i class="fas fa-exclamation-circle mr-2"></i>
      <p><%= request.getAttribute("error") %></p>
    </div>
  </div>
  <% } %>

  <form id="login-form" method="post" action="LoginServlet" class="space-y-4">
    <!-- Username -->
    <div>
      <label for="username" class="block text-sm font-medium text-gray-700 mb-1">Username</label>
      <div class="relative">
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <i class="fas fa-user text-gray-400"></i>
        </div>
        <input type="text" id="username" name="username" required
               class="input-field pl-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 py-2 border"
               placeholder="Enter admin username"
               value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">
      </div>
    </div>

    <!-- Password -->
    <div>
      <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password</label>
      <div class="relative">
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <i class="fas fa-lock text-gray-400"></i>
        </div>
        <input type="password" id="password" name="password" required
               class="input-field pl-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 py-2 border"
               placeholder="Enter admin password">
        <button type="button" id="toggle-password" class="absolute inset-y-0 right-0 pr-3 flex items-center">
          <i class="fas fa-eye text-gray-400 hover:text-gray-600"></i>
        </button>
      </div>
    </div>

    <!-- Submit -->
    <div>
      <button type="submit" class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
        <i class="fas fa-sign-in-alt mr-2"></i> Sign in
      </button>
    </div>
  </form>

  <div class="mt-6 text-center text-sm text-gray-500">
    Need help? <a href="#" class="font-medium text-indigo-600 hover:text-indigo-500">Contact support</a>
  </div>
</div>

<!-- JavaScript Logic -->
<script>
  document.addEventListener('DOMContentLoaded', function() {
    const togglePassword = document.getElementById('toggle-password');
    const passwordInput = document.getElementById('password');
    const loginForm = document.getElementById('login-form');

    // Toggle password visibility
    togglePassword.addEventListener('click', function() {
      const icon = this.querySelector('i');
      if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
      } else {
        passwordInput.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
      }
    });

    // Set role as admin before submit
    loginForm.addEventListener('submit', function() {
      const existing = document.querySelector('input[name="role"]');
      if (existing) existing.remove();

      const roleInput = document.createElement('input');
      roleInput.type = 'hidden';
      roleInput.name = 'role';
      roleInput.value = 'admin';
      loginForm.appendChild(roleInput);
    });
  });
</script>
</body>
</html>