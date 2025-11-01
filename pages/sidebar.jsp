<%@ page session="true" %>
<%-- <%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        username = "Guest";
    }
%> --%>

<!-- ===== Sidebar ===== -->
<div class="sidebar d-flex flex-column flex-shrink-0 p-3 text-white">
  <a href="dashboard.jsp" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none">
    <i class="bi bi-speedometer2 fs-4 me-2"></i>
    <span class="fs-5 fw-semibold">MyApp</span>
  </a>
  <hr>
  <ul class="nav nav-pills flex-column mb-auto">
    <li class="nav-item">
      <a href="dashboard.jsp" class="nav-link text-white active" aria-current="page">
        <i class="bi bi-house-door me-2"></i> Dashboard
      </a>
    </li>
    <li>
      <a href="sales.jsp" class="nav-link text-white">
        <i class="bi bi-cart3 me-2"></i> Sales
      </a>
    </li>
    <li>
      <a href="products.jsp" class="nav-link text-white">
        <i class="bi bi-box-seam me-2"></i> Products
      </a>
    </li>
    <li>
      <a href="customers.jsp" class="nav-link text-white">
        <i class="bi bi-people me-2"></i> Customers
      </a>
    </li>
    <li>
      <a href="reports.jsp" class="nav-link text-white">
        <i class="bi bi-bar-chart me-2"></i> Reports
      </a>
    </li>
    <li>
      <a href="settings.jsp" class="nav-link text-white">
        <i class="bi bi-gear me-2"></i> Settings
      </a>
    </li>
  </ul>
  <hr>
  <div class="dropdown">
    <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle" id="dropdownUser"
       data-bs-toggle="dropdown" aria-expanded="false">
      <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png" alt="" width="32" height="32" class="rounded-circle me-2">
      <strong><%= username %></strong>
    </a>
    <ul class="dropdown-menu dropdown-menu-dark text-small shadow" aria-labelledby="dropdownUser">
      <li><a class="dropdown-item" href="profile.jsp">Profile</a></li>
      <li><a class="dropdown-item" href="settings.jsp">Settings</a></li>
      <li><hr class="dropdown-divider"></li>
      <li><a class="dropdown-item" href="logout.jsp">Sign out</a></li>
    </ul>
  </div>
</div>

<!-- ===== Styles ===== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>
  .sidebar {
    width: 250px;
    height: 100vh;
    background-color: #1f2937;
    position: fixed;
    top: 0;
    left: 0;
    overflow-y: auto;
  }

  .sidebar .nav-link {
    border-radius: 8px;
    margin: 3px 0;
    font-weight: 500;
  }

  .sidebar .nav-link:hover,
  .sidebar .nav-link.active {
    background-color: #2563eb;
  }

  body {
    margin-left: 250px;
    background-color: #f8fafc;
    font-family: "Inter", "Roboto", sans-serif;
  }

  @media (max-width: 768px) {
    .sidebar {
      position: fixed;
      left: -250px;
      transition: all 0.3s ease;
      z-index: 1050;
    }
    .sidebar.active {
      left: 0;
    }
    body {
      margin-left: 0;
    }
  }
</style>

<!-- ===== Script for Sidebar Toggle (Mobile) ===== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function toggleSidebar() {
    document.querySelector('.sidebar').classList.toggle('active');
  }
</script>
