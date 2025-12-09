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
      <a href="${pageContext.request.contextPath}/pages/productCategory.jsp" class="nav-link text-white">
        <i class="bi bi-box-seam me-2"></i> Product category
      </a>
    </li>
    <li>
      <a href="${pageContext.request.contextPath}/Product" class="nav-link text-white">
        <i class="bi bi-box-seam me-2"></i> Products
      </a>
    </li>
    

    <%-- <li>
      <a href="${pageContext.request.contextPath}/pages/customers.jsp" class="nav-link text-white">
        <i class="bi bi-people me-2"></i> Customers
      </a>
    </li> --%>

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
<%--             <a href="${pageContext.request.contextPath}/PrintPurchaseReportServlet" class="nav-link text-white small">Sales Report</a>
 --%>          </li>
          <li class="nav-item">
            <a href="${pageContext.request.contextPath}/PrintPurchaseReportServlet" class="nav-link text-white small">Purchase Report</a>
          </li>
          <li class="nav-item">
            <a href="${pageContext.request.contextPath}/ProfitAndLossReport" class="nav-link text-white small">Profit-Loss Report</a>
          </li>
        </ul>
      </div>
    </li>

    <%-- <li>
      <a href="${pageContext.request.contextPath}/pages/settings.jsp" class="nav-link text-white">
        <i class="bi bi-gear me-2"></i> Settings
      </a>
    </li> --%>
  </ul>

<!--   <hr class="border-light opacity-25">
 -->
<%--   <div class="dropdown mt-auto">
    <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle"
       id="dropdownUser" data-bs-toggle="dropdown" aria-expanded="false">
      <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
           alt="user" width="32" height="32" class="rounded-circle me-2 border border-light">
      <strong><%= username %></strong>
    </a>
    <ul class="dropdown-menu dropdown-menu-dark shadow" aria-labelledby="dropdownUser">
      <li><a class="dropdown-item" href="profile.jsp">Profile</a></li>
      <li><a class="dropdown-item" href="settings.jsp">Settings</a></li>
      <li><hr class="dropdown-divider"></li>
      <li><a class="dropdown-item" href="logout.jsp">Sign out</a></li>
    </ul>
  </div> --%>
</div>

<!-- ===== Styles ===== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/pages/css/style.css" rel="stylesheet">

<style>
  /* Vijaytechorbitsolutions color variables (canonical) */
  :root{
    --outer-frame:#c7c6dc;
    --bg-1: #f3f4f6;
    --bg-2: #eef2f6;
    --panel-dark: #08143a;
    --panel-dark-2: #09184b;
    --accent-a: #19b6b0;   /* primary mint-teal */
    --accent-b: #15a0c6;   /* secondary blue */
    --accent-c: #3bd0c3;   /* tertiary */
    --muted-light: rgba(255,255,255,0.76);
    --muted: #9aa6c3;
    --card-radius: 14px;
    --outer-radius: 18px;
  }

  body {
    margin-left: 250px;
    font-family: 'Poppins', sans-serif;
    color: #000;
    background: radial-gradient(ellipse at center, rgba(8,20,58,0.6), rgba(3,10,28,0.9)),
                url('${pageContext.request.contextPath}/pages/img/bg-textile.jpg') center/cover no-repeat fixed;
    overflow-x: hidden;
  }

  .sidebar.glass-erp {
    width: 250px;
    height: 100vh;
    background: linear-gradient(180deg, rgba(8,20,58,0.88), rgba(9,24,75,0.85));
    backdrop-filter: blur(14px);
    border-right: 1px solid rgba(255,255,255,0.04);
    box-shadow: inset -1px 0 0 rgba(255,255,255,0.02),
                0 0 25px rgba(27,184,169,0.12);
    position: fixed;
    top: 0;
    left: 0;
    overflow-y: auto;
    transition: all 0.4s ease;
  }

  .sb-brand {
    color: var(--muted-light) !important;
    text-shadow: 0 0 8px rgba(25,182,176,0.18);
  }

  .sb-nav .nav-link {
    border-radius: 10px;
    margin: 4px 0;
    padding: 10px 12px;
    font-weight: 500;
    transition: all 0.3s ease;
    color: var(--muted-light) !important;
  }

  .sb-nav .nav-link:hover {
    background: rgba(255,255,255,0.03);
    box-shadow: inset 4px 0 0 var(--accent-a);
  }

  .sb-nav .nav-link.active {
    background: rgba(255,255,255,0.04);
    box-shadow: inset 4px 0 0 var(--accent-a);
    color: #fff !important;
  }

  .text-gradient {
    background: linear-gradient(90deg, var(--accent-a), var(--accent-b));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .text-glow {
    color: var(--accent-a);
    text-shadow: 0 0 12px rgba(25,182,176,0.22);
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
