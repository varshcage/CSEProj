<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Management - PahanEdu Bookshop</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
        <c:remove var="message" scope="session" />
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
                <i class="fas fa-tachometer-alt mr-3"></i>
                Dashboard
            </a>
            <a href="BookServlet" class="flex items-center px-4 py-3 text-indigo-200 hover:text-white hover:bg-indigo-700 rounded-lg">
                <i class="fas fa-book mr-3"></i>
                Books
            </a>
            <a href="CustomerServlet" class="flex items-center px-4 py-3 text-white bg-indigo-900 rounded-lg">
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
            <h1 class="text-2xl font-semibold text-gray-800">Customer Management</h1>
            <div class="flex items-center space-x-4">
                <div class="relative">
                    <button class="p-2 rounded-full hover:bg-gray-100">
                        <i class="fas fa-bell text-gray-600"></i>
                        <span class="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full"></span>
                    </button>
                </div>
                <div class="relative">
                    <input type="text" placeholder="Search customers..." class="pl-10 pr-4 py-2 border rounded-full focus:outline-none focus:ring-2 focus:ring-indigo-500">
                    <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content Area -->
    <main class="p-6">
        <!-- Action Bar -->
        <div class="flex justify-between items-center mb-6">
            <div>
                <button id="filter-btn" class="px-4 py-2 border rounded-md text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                    <i class="fas fa-filter mr-2"></i>Filter
                </button>
                <div id="filter-dropdown" class="hidden absolute mt-2 w-48 bg-white rounded-md shadow-lg z-10">
                    <div class="py-1">
                        <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">All Customers</a>
                        <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">Active</a>
                        <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">Inactive</a>
                        <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">By Location</a>
                    </div>
                </div>
            </div>
            <button id="add-customer-btn" class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                <i class="fas fa-plus mr-2"></i>Add Customer
            </button>
        </div>

        <!-- Customers Table -->
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200 bg-indigo-600 text-white">
                <h3 class="text-lg font-medium">Customer List</h3>
            </div>
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                    <tr>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Photo</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Phone</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Address</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                    </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                    <c:forEach var="customer" items="${customers}">
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap">
                                <c:if test="${not empty customer.photoPath}">
                                    <img src="${pageContext.request.contextPath}/${customer.photoPath}" alt="Customer Photo" class="h-10 w-10 rounded-full object-cover">
                                </c:if>
                                <c:if test="${empty customer.photoPath}">
                                    <div class="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                                        <i class="fas fa-user text-gray-400"></i>
                                    </div>
                                </c:if>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm font-medium text-gray-900">${customer.name}</div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm text-gray-500">${customer.email}</div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm text-gray-500">${customer.phone}</div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="text-sm text-gray-500">${customer.address}</div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full
                   ${customer.active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}">
                        ${customer.active ? 'Active' : 'Inactive'}
                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                <button onclick="openEditModal(${customer.id})" class="text-indigo-600 hover:text-indigo-900 mr-3" data-toggle="tooltip" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button onclick="confirmDelete(${customer.id})" class="text-red-600 hover:text-red-900" data-toggle="tooltip" title="Delete">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
            <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex items-center justify-between">
                <div class="text-sm text-gray-500">
                    Showing <span class="font-medium">1</span> to <span class="font-medium">10</span> of <span class="font-medium">${customers.size()}</span> customers
                </div>
                <div class="flex space-x-2">
                    <button class="px-3 py-1 border rounded-md text-gray-700 bg-gray-50 hover:bg-gray-100">Previous</button>
                    <button class="px-3 py-1 border rounded-md bg-indigo-600 text-white hover:bg-indigo-700">1</button>
                    <button class="px-3 py-1 border rounded-md text-gray-700 bg-gray-50 hover:bg-gray-100">2</button>
                    <button class="px-3 py-1 border rounded-md text-gray-700 bg-gray-50 hover:bg-gray-100">3</button>
                    <button class="px-3 py-1 border rounded-md text-gray-700 bg-gray-50 hover:bg-gray-100">Next</button>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Add Customer Modal -->
<div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden" id="addCustomerModal">
    <div class="relative top-20 mx-auto p-5 border w-11/12 md:w-2/3 lg:w-1/2 shadow-lg rounded-md bg-white">
        <div class="flex justify-between items-center pb-3 border-b">
            <h3 class="text-xl font-semibold text-gray-900">Add New Customer</h3>
            <button type="button" class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center" onclick="closeModal('addCustomerModal')">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <form id="customerForm" class="mt-4" action="AddCustomerServlet" method="POST" enctype="multipart/form-data">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <!-- Left Column -->
                <div class="space-y-4">
                    <div>
                        <label for="name" class="block text-sm font-medium text-gray-700">Full Name *</label>
                        <input type="text" id="name" name="name" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="email" class="block text-sm font-medium text-gray-700">Email *</label>
                        <input type="email" id="email" name="email" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="phone" class="block text-sm font-medium text-gray-700">Phone Number *</label>
                        <input type="tel" id="phone" name="phone" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="dob" class="block text-sm font-medium text-gray-700">Date of Birth</label>
                        <input type="date" id="dob" name="dob" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>
                </div>

                <!-- Right Column -->
                <div class="space-y-4">
                    <div>
                        <label for="address" class="block text-sm font-medium text-gray-700">Address</label>
                        <input type="text" id="address" name="address" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="city" class="block text-sm font-medium text-gray-700">City</label>
                        <input type="text" id="city" name="city" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="country" class="block text-sm font-medium text-gray-700">Country</label>
                        <input type="text" id="country" name="country" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="status" class="block text-sm font-medium text-gray-700">Status *</label>
                        <select id="status" name="status" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                            <option value="true">Active</option>
                            <option value="false">Inactive</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Full width fields -->
            <div class="mt-4">
                <label for="notes" class="block text-sm font-medium text-gray-700">Notes</label>
                <textarea id="notes" name="notes" rows="2" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border"></textarea>
            </div>

            <div class="mt-4">
                <label class="block text-sm font-medium text-gray-700">Customer Photo</label>
                <div class="mt-1 flex items-center">
          <span class="inline-block h-20 w-20 rounded-full overflow-hidden bg-gray-100 mr-4" id="photoPreview">
            <svg class="h-full w-full text-gray-300" fill="currentColor" viewBox="0 0 24 24">
              <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
          </span>
                    <input type="file" id="photo" name="photo" accept="image/*" class="hidden" onchange="previewPhoto(this)">
                    <button type="button" onclick="document.getElementById('photo').click()" class="px-3 py-1 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                        Choose Photo
                    </button>
                </div>
            </div>

            <div class="mt-6 flex justify-end space-x-3">
                <button type="button" onclick="closeModal('addCustomerModal')" class="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                    Cancel
                </button>
                <button type="submit" class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                    Add Customer
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden" id="deleteModal">
    <div class="relative top-20 mx-auto p-5 border w-11/12 md:w-1/3 shadow-lg rounded-md bg-white">
        <div class="flex justify-between items-center pb-3 border-b">
            <h3 class="text-xl font-semibold text-gray-900">Confirm Deletion</h3>
            <button type="button" class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center" onclick="closeModal('deleteModal')">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <div class="mt-4">
            <p class="text-gray-700">Are you sure you want to delete this customer? This action cannot be undone.</p>
            <form id="deleteForm" method="POST" action="DeleteCustomerServlet">
                <input type="hidden" id="customerIdToDelete" name="customerId">
            </form>
        </div>

        <div class="mt-6 flex justify-end space-x-3">
            <button type="button" onclick="closeModal('deleteModal')" class="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                Cancel
            </button>
            <button type="button" onclick="document.getElementById('deleteForm').submit()" class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500">
                Delete
            </button>
        </div>
    </div>
</div>

<!-- Edit Customer Modal -->
<div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden" id="editCustomerModal">
    <div class="relative top-20 mx-auto p-5 border w-11/12 md:w-2/3 lg:w-1/2 shadow-lg rounded-md bg-white">
        <div class="flex justify-between items-center pb-3 border-b">
            <h3 class="text-xl font-semibold text-gray-900">Edit Customer</h3>
            <button type="button" class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center" onclick="closeModal('editCustomerModal')">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <form id="editCustomerForm" class="mt-4" action="EditCustomerServlet" method="POST" enctype="multipart/form-data">
            <input type="hidden" id="editId" name="id">
            <input type="hidden" id="existingPhotoPath" name="existingPhotoPath">

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <!-- Left Column -->
                <div class="space-y-4">
                    <div>
                        <label for="editName" class="block text-sm font-medium text-gray-700">Full Name *</label>
                        <input type="text" id="editName" name="name" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="editEmail" class="block text-sm font-medium text-gray-700">Email *</label>
                        <input type="email" id="editEmail" name="email" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="editPhone" class="block text-sm font-medium text-gray-700">Phone Number *</label>
                        <input type="tel" id="editPhone" name="phone" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="editDob" class="block text-sm font-medium text-gray-700">Date of Birth</label>
                        <input type="date" id="editDob" name="dob" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>
                </div>

                <!-- Right Column -->
                <div class="space-y-4">
                    <div>
                        <label for="editAddress" class="block text-sm font-medium text-gray-700">Address</label>
                        <input type="text" id="editAddress" name="address" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="editCity" class="block text-sm font-medium text-gray-700">City</label>
                        <input type="text" id="editCity" name="city" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="editCountry" class="block text-sm font-medium text-gray-700">Country</label>
                        <input type="text" id="editCountry" name="country" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                    </div>

                    <div>
                        <label for="editStatus" class="block text-sm font-medium text-gray-700">Status *</label>
                        <select id="editStatus" name="status" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border">
                            <option value="true">Active</option>
                            <option value="false">Inactive</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Full width fields -->
            <div class="mt-4">
                <label for="editNotes" class="block text-sm font-medium text-gray-700">Notes</label>
                <textarea id="editNotes" name="notes" rows="2" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border"></textarea>
            </div>

            <div class="mt-4">
                <label class="block text-sm font-medium text-gray-700">Customer Photo</label>
                <div class="mt-1 flex items-center">
          <span class="inline-block h-20 w-20 rounded-full overflow-hidden bg-gray-100 mr-4" id="editPhotoPreview">
            <svg class="h-full w-full text-gray-300" fill="currentColor" viewBox="0 0 24 24">
              <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
          </span>
                    <input type="file" id="editPhoto" name="photo" accept="image/*" class="hidden" onchange="previewEditPhoto(this)">
                    <button type="button" onclick="document.getElementById('editPhoto').click()" class="px-3 py-1 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                        Change Photo
                    </button>
                </div>
            </div>

            <div class="mt-6 flex justify-end space-x-3">
                <button type="button" onclick="closeModal('editCustomerModal')" class="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                    Cancel
                </button>
                <button type="submit" class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                    Update Customer
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Scripts -->
<script>
    // Toggle sidebar on mobile
    document.getElementById('sidebar-toggle').addEventListener('click', function() {
        document.querySelector('.fixed.inset-y-0.left-0').classList.toggle('-translate-x-full');
    });

    // Toggle filter dropdown
    document.getElementById('filter-btn').addEventListener('click', function() {
        document.getElementById('filter-dropdown').classList.toggle('hidden');
    });

    // Show add customer modal
    document.getElementById('add-customer-btn').addEventListener('click', function() {
        document.getElementById('addCustomerModal').classList.remove('hidden');
    });

    // Close modals
    function closeModal(modalId) {
        document.getElementById(modalId).classList.add('hidden');
    }

    // Preview photo before upload
    function previewPhoto(input) {
        const preview = document.getElementById('photoPreview');
        const file = input.files[0];
        const reader = new FileReader();

        reader.onloadend = function() {
            preview.innerHTML = '';
            const img = document.createElement('img');
            img.src = reader.result;
            img.className = 'h-full w-full object-cover';
            preview.appendChild(img);
        }

        if (file) {
            reader.readAsDataURL(file);
        }
    }

    // Close dropdown when clicking outside
    document.addEventListener('click', function(event) {
        if (!event.target.closest('#filter-btn') && !event.target.closest('#filter-dropdown')) {
            document.getElementById('filter-dropdown').classList.add('hidden');
        }
    });

    // Form validation
    document.getElementById('customerForm').addEventListener('submit', function(e) {
        const requiredFields = ['name', 'email', 'phone'];
        let isValid = true;

        requiredFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (!field.value.trim()) {
                field.classList.add('border-red-500');
                isValid = false;
            } else {
                field.classList.remove('border-red-500');
            }
        });

        if (!isValid) {
            e.preventDefault();
            alert('Please fill in all required fields.');
        }
    });

    function confirmDelete(customerId) {
        document.getElementById('customerIdToDelete').value = customerId;
        document.getElementById('deleteModal').classList.remove('hidden');
    }

    function openEditModal(customerId) {
        fetch('EditCustomerServlet?id=' + customerId)
            .then(response => response.json())
            .then(customer => {
                // Populate form fields
                document.getElementById('editId').value = customer.id;
                document.getElementById('editName').value = customer.name;
                document.getElementById('editEmail').value = customer.email;
                document.getElementById('editPhone').value = customer.phone;
                document.getElementById('editDob').value = customer.dob;
                document.getElementById('editAddress').value = customer.address;
                document.getElementById('editCity').value = customer.city;
                document.getElementById('editCountry').value = customer.country;
                document.getElementById('editStatus').value = customer.active;
                document.getElementById('editNotes').value = customer.notes;
                document.getElementById('existingPhotoPath').value = customer.photoPath;

                // Set photo preview
                const preview = document.getElementById('editPhotoPreview');
                if (customer.photoPath) {
                    preview.innerHTML = `<img src="${customer.photoPath}" class="h-full w-full object-cover">`;
                } else {
                    preview.innerHTML = `<svg class="h-full w-full text-gray-300" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>`;
                }

                // Show modal
                document.getElementById('editCustomerModal').classList.remove('hidden');
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Error loading customer data');
            });
    }

    function previewEditPhoto(input) {
        const preview = document.getElementById('editPhotoPreview');
        const file = input.files[0];
        const reader = new FileReader();

        reader.onloadend = function() {
            preview.innerHTML = '';
            const img = document.createElement('img');
            img.src = reader.result;
            img.className = 'h-full w-full object-cover';
            preview.appendChild(img);
        }

        if (file) {
            reader.readAsDataURL(file);
        }
    }
    // Search functionality
    document.querySelector('input[type="text"][placeholder="Search customers..."]').addEventListener('input', function(e) {
        const searchTerm = e.target.value.toLowerCase();
        const rows = document.querySelectorAll('tbody tr');

        rows.forEach(row => {
            const name = row.querySelector('td:nth-child(2)').textContent.toLowerCase();
            const email = row.querySelector('td:nth-child(3)').textContent.toLowerCase();
            const phone = row.querySelector('td:nth-child(4)').textContent.toLowerCase();
            const address = row.querySelector('td:nth-child(5)').textContent.toLowerCase();

            if (name.includes(searchTerm) || email.includes(searchTerm) ||
                phone.includes(searchTerm) || address.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });

    // Filter functionality
    function applyCustomerFilter(filterType, value = '') {
        const rows = document.querySelectorAll('tbody tr');

        rows.forEach(row => {
            let shouldShow = true;

            switch(filterType) {
                case 'all':
                    // Show all rows
                    break;
                case 'active':
                    const statusText = row.querySelector('td:nth-child(6)').textContent.toLowerCase();
                    shouldShow = statusText.includes('active');
                    break;
                case 'inactive':
                    const inactiveStatusText = row.querySelector('td:nth-child(6)').textContent.toLowerCase();
                    shouldShow = inactiveStatusText.includes('inactive');
                    break;
                case 'location':
                    const addressText = row.querySelector('td:nth-child(5)').textContent.toLowerCase();
                    shouldShow = addressText.includes(value.toLowerCase());
                    break;
            }

            row.style.display = shouldShow ? '' : 'none';
        });
    }

    // Set up filter dropdown actions
    document.querySelectorAll('#filter-dropdown a').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const filterType = this.textContent.trim().toLowerCase();

            if (filterType === 'all customers') {
                applyCustomerFilter('all');
            } else if (filterType === 'active') {
                applyCustomerFilter('active');
            } else if (filterType === 'inactive') {
                applyCustomerFilter('inactive');
            } else if (filterType === 'by location') {
                // For location filter, you might want to show another dropdown with locations
                // For simplicity, we'll just filter by the first location found
                const firstLocation = document.querySelector('td:nth-child(5)').textContent;
                applyCustomerFilter('location', firstLocation);
            }

            // Close the dropdown after selection
            document.getElementById('filter-dropdown').classList.add('hidden');
        });
    });

    // Enhanced location filter (optional)
    // You can add this to create a more sophisticated location filter
    function setupLocationFilter() {
        const locations = new Set();
        document.querySelectorAll('td:nth-child(5)').forEach(td => {
            const location = td.textContent.trim();
            if (location) {
                locations.add(location);
            }
        });

        const locationDropdown = document.createElement('div');
        locationDropdown.className = 'py-1';
        locationDropdown.id = 'location-filter';

        locations.forEach(location => {
            const link = document.createElement('a');
            link.href = '#';
            link.className = 'block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100';
            link.textContent = location;
            link.addEventListener('click', function(e) {
                e.preventDefault();
                applyCustomerFilter('location', location);
            });
            locationDropdown.appendChild(link);
        });

        // Replace the "By Location" link with the actual locations
        const byLocationLink = document.querySelector('#filter-dropdown a:last-child');
        byLocationLink.textContent = 'By Location ▼';
        byLocationLink.addEventListener('mouseenter', function() {
            document.getElementById('location-filter').classList.toggle('hidden', false);
        });

        document.getElementById('filter-dropdown').appendChild(locationDropdown);
        document.getElementById('location-filter').classList.add('hidden');
    }

    // Initialize the enhanced location filter (optional)
    // setupLocationFilter();

    // Close dropdowns when clicking outside
    document.addEventListener('click', function(event) {
        if (!event.target.closest('#filter-btn') && !event.target.closest('#filter-dropdown')) {
            document.getElementById('filter-dropdown').classList.add('hidden');
        }
    });
</script>
</body>
</html>