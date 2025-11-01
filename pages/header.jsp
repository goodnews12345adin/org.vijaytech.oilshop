<%@ page session="true" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        username = "Guest";
    }
%>

<!-- ====== Header / Navbar ====== -->
<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm fixed-top">
  <div class="container-fluid">
    <!-- Brand -->
    <a class="navbar-brand fw-bold text-primary" href="dashboard.jsp">
      <i class="bi bi-speedometer2"></i> MyApp
    </a>

    <!-- Mobile Toggle -->
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMenu"
      aria-controls="navbarMenu" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <!-- Navbar Links -->
    <div class="collapse navbar-collapse" id="navbarMenu">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item">
          <a class="nav-link" href="dashboard.jsp"><i class="bi bi-house-door"></i> Dashboard</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="sales.jsp"><i class="bi bi-cart3"></i> Sales</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="reports.jsp"><i class="bi bi-bar-chart"></i> Reports</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="settings.jsp"><i class="bi bi-gear"></i> Settings</a>
        </li>
      </ul>

      <!-- Right Side -->
      <div class="d-flex align-items-center">
        <span class="me-3 text-muted">Welcome, <strong><%= username %></strong></span>
        <a href="logout.jsp" class="btn btn-outline-primary btn-sm">
          <i class="bi bi-box-arrow-right"></i> Logout
        </a>
      </div>
    </div>
  </div>
</nav>

<!-- Bootstrap + Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<!-- Optional styling -->
<style>
  body {
    padding-top: 70px; /* Prevent content from hiding under fixed header */
    font-family: "Inter", "Roboto", sans-serif;
    background-color: #f8fafc;
  }

  .navbar-brand i {
    margin-right: 8px;
  }

  .navbar .nav-link {
    color: #333 !important;
    font-weight: 500;
  }

  .navbar .nav-link:hover {
    color: #2563eb !important;
  }

  .navbar .btn-outline-primary {
    border-radius: 20px;
  }
</style>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
