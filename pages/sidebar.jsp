<%@ page session="true" %>
<%-- 
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        username = "Guest";
    }
%>
--%>

<!-- ===== Sree Textiles Sidebar (Glass Neon Style) ===== -->
<div class="sidebar glass-erp d-flex flex-column flex-shrink-0 p-3 text-white shadow-lg">

  <a href="${pageContext.request.contextPath}/pages/dashboard.jsp"
     class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none sb-brand">
    <i class="bi bi-speedometer2 fs-4 me-2 text-glow"></i>
    <span class="fs-5 fw-bold text-gradient">Sree Textiles</span>
  </a>

  <hr class="border-light opacity-25">

  <ul class="nav nav-pills flex-column mb-auto sb-nav">
    <li class="nav-item">
      <a href="${pageContext.request.contextPath}/pages/dashboard.jsp" class="nav-link active text-white">
        <i class="bi bi-house-door me-2"></i> Dashboard
      </a>
    </li>

    <li>
      <a href="${pageContext.request.contextPath}/SalesServlet" class="nav-link text-white">
        <i class="bi bi-cart-check me-2"></i> Sales
      </a>
    </li>

    <li>
      <a href="${pageContext.request.contextPath}/PurchaseServlet" class="nav-link text-white">
        <i class="bi bi-basket me-2"></i> Purchase
      </a>
    </li>

    <li>
      <a href="${pageContext.request.contextPath}/pages/products.jsp" class="nav-link text-white">
        <i class="bi bi-box-seam me-2"></i> Products
      </a>
    </li>

    <li>
      <a href="${pageContext.request.contextPath}/pages/customers.jsp" class="nav-link text-white">
        <i class="bi bi-people me-2"></i> Customers
      </a>
    </li>

    <li class="nav-item">
      <a class="nav-link text-white d-flex justify-content-between align-items-center"
         data-bs-toggle="collapse" href="#reportsMenu" role="button"
         aria-expanded="false" aria-controls="reportsMenu">
        <span><i class="bi bi-bar-chart me-2"></i> Reports</span>
        <i class="bi bi-chevron-down"></i>
      </a>
      <div class="collapse ps-3" id="reportsMenu">
        <ul class="nav flex-column">
          <li class="nav-item">
            <a href="${pageContext.request.contextPath}/PrintPurchaseReportServlet" class="nav-link text-white small">Sales Report</a>
          </li>
          <li class="nav-item">
            <a href="${pageContext.request.contextPath}/pages/purchaseReport.jsp" class="nav-link text-white small">Purchase Report</a>
          </li>
        </ul>
      </div>
    </li>

    <li>
      <a href="${pageContext.request.contextPath}/pages/settings.jsp" class="nav-link text-white">
        <i class="bi bi-gear me-2"></i> Settings
      </a>
    </li>
  </ul>

  <hr class="border-light opacity-25">

  <div class="dropdown mt-auto">
    <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle"
       id="dropdownUser" data-bs-toggle="dropdown" aria-expanded="false">
      <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
           alt="user" width="32" height="32" class="rounded-circle me-2 border border-light">
      <strong><%-- <%= username %> --%></strong>
    </a>
    <ul class="dropdown-menu dropdown-menu-dark shadow" aria-labelledby="dropdownUser">
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
<link href="${pageContext.request.contextPath}/pages/css/style.css" rel="stylesheet">

<style>
  body {
    margin-left: 250px;
    font-family: 'Poppins', sans-serif;
    color: #fff;
    background: radial-gradient(ellipse at center, rgba(0,0,0,.5), rgba(0,0,0,.9)),
                url('${pageContext.request.contextPath}/pages/img/bg-textile.jpg') center/cover no-repeat fixed;
    overflow-x: hidden;
  }

  .sidebar.glass-erp {
    width: 250px;
    height: 100vh;
    background: rgba(40, 0, 15, 0.75);
    backdrop-filter: blur(14px);
    border-right: 1px solid rgba(255,255,255,0.25);
    box-shadow: inset -1px 0 0 rgba(255,255,255,0.08),
                0 0 25px rgba(255,47,109,0.4);
    position: fixed;
    top: 0;
    left: 0;
    overflow-y: auto;
    transition: all 0.4s ease;
  }

  .sb-brand {
    color: #ffe7ef !important;
    text-shadow: 0 0 8px rgba(255,47,109,0.4);
  }

  .sb-nav .nav-link {
    border-radius: 10px;
    margin: 4px 0;
    padding: 10px 12px;
    font-weight: 500;
    transition: all 0.3s ease;
    color: #ffe7ef !important;
  }

  .sb-nav .nav-link:hover {
    background: rgba(255,255,255,0.1);
    box-shadow: inset 4px 0 0 #ff2f6d;
  }

  .sb-nav .nav-link.active {
    background: rgba(255,255,255,0.18);
    box-shadow: inset 4px 0 0 #ff2f6d;
    color: #fff !important;
  }

  .text-gradient {
    background: linear-gradient(90deg, #ff2f6d, #ffd86f);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .text-glow {
    color: #ff2f6d;
    text-shadow: 0 0 12px rgba(255,47,109,0.6);
  }

  /* Responsive */
  @media (max-width: 768px) {
    body {
      margin-left: 0;
    }
    .sidebar {
      position: fixed;
      left: -250px;
      z-index: 1050;
      transition: all 0.3s ease;
    }
    .sidebar.active {
      left: 0;
    }
  }
</style>

<!-- ===== JS ===== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/pages/js/style.js"></script>
<script>
  function toggleSidebar() {
    document.querySelector('.sidebar').classList.toggle('active');
  }
</script>