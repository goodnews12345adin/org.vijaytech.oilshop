<%-- <%@ page session="true" %>
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
    <!-- <div class="collapse navbar-collapse" id="navbarMenu">
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
      </ul> -->

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
  /* Vijaytechorbitsolutions palette (canonical) */
  :root{
    --outer-frame:#c7c6dc;
    --bg-1: #f3f4f6;
    --bg-2: #eef2f6;
    --panel-dark: #08143a;
    --panel-dark-2: #09184b;
    --accent-a: #19b6b0;   /* mint-teal */
    --accent-b: #15a0c6;   /* blue */
    --accent-c: #3bd0c3;   /* teal */
    --muted-light: rgba(255,255,255,0.86);
    --muted: #9aa6c3;
    --card-radius: 12px;
    --glass-border: rgba(255,255,255,0.04);
    --glass-overlay: rgba(255,255,255,0.02);
    --fg-dark: #0f172a;
    --brand-text: linear-gradient(90deg, var(--accent-a), var(--accent-b));
  }

  :root.dark{
    --bg-1: #07102a;
    --bg-2: #031028;
    --muted-light: rgba(230,238,252,0.9);
  }

  body {
    padding-top: 70px; /* Prevent content from hiding under fixed header */
    font-family: "Inter", "Roboto", sans-serif;
    /* use soft textured background derived from the saved palette */
    background: radial-gradient(ellipse at center, rgba(8,20,58,0.55), rgba(3,10,28,0.9)),
                linear-gradient(180deg, var(--bg-1), var(--bg-2));
    color: var(--muted-light);
  }

  /* Replace the default light navbar with a panel using the canonical palette */
  .navbar {
    background: linear-gradient(180deg, var(--panel-dark), var(--panel-dark-2));
    border-bottom: 1px solid rgba(255,255,255,0.03);
    box-shadow: 0 8px 30px rgba(2,6,23,0.28);
  }

  .navbar-brand {
    /* keep markup identical but apply palette */
    color: var(--muted-light) !important;
    background: none;
    display: inline-flex;
    align-items: center;
    gap: .5rem;
  }

  .navbar-brand i {
    color: var(--accent-a);
    text-shadow: 0 4px 18px rgba(25,182,176,0.08);
    margin-right: 8px;
    font-size: 1.05rem;
  }

  /* Mobile toggler - make icon visible on dark navbar */
  .navbar-toggler {
    border-color: rgba(255,255,255,0.06);
  }
  .navbar-toggler-icon {
    filter: invert(1) brightness(1.1);
  }

  /* Navbar links — keep same markup but recolor */
  .navbar .nav-link {
    color: var(--muted-light) !important;
    font-weight: 500;
  }

  .navbar .nav-link:hover {
    color: var(--accent-b) !important;
  }

  /* Right-side welcome text and logout button */
  .navbar .me-3.text-muted {
    color: rgba(255,255,255,0.78) !important;
  }

  .navbar .btn-outline-primary {
    border-radius: 20px;
    border-color: rgba(255,255,255,0.08);
    color: var(--panel-dark);
    background: linear-gradient(90deg, var(--accent-a), var(--accent-b));
    box-shadow: 0 8px 28px rgba(3,10,35,0.08);
  }
  .navbar .btn-outline-primary:hover {
    filter: brightness(1.02);
    transform: translateY(-1px);
  }

  /* Keep small visual tweaks matching the palette */
  .navbar .btn-outline-primary i {
    margin-right: 6px;
    color: rgba(255,255,255,0.95);
  }

  /* Ensure collapsed navbar area (if uncommented) uses readable bg */
  .navbar .collapse.navbar-collapse {
    background: transparent;
  }

  /* Maintain original spacing for brand icon */
  .navbar-brand i {
    margin-right: 8px;
  }

  /* Responsive: preserve original behavior */
  @media (max-width: 768px) {
    body {
      padding-top: 70px;
    }
  }
</style>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
 --%>