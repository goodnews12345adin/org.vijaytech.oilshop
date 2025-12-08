<%@ page session="true" %>

<!-- ================= MOBILE HAMBURGER ================= -->
<button class="sidebar-toggle-btn d-md-none"
        onclick="toggleSidebar()">
    <i class="bi bi-list"></i>
</button>

<!-- ================= SIDEBAR ================= -->
<div id="sidebar" class="sidebar glass-erp">

  <a href="${pageContext.request.contextPath}/pages/dashboard.jsp"
     class="sidebar-brand">
      <i class="bi bi-speedometer2 me-2"></i>
      <span>Sree Textiles</span>
  </a>

  <hr>

  <ul class="nav flex-column sidebar-menu">

      <li>
        <a href="${pageContext.request.contextPath}/pages/dashboard.jsp" class="nav-link">
          <i class="bi bi-house-door me-2"></i> Dashboard
        </a>
      </li>

      <li>
        <a href="${pageContext.request.contextPath}/SalesServlet" class="nav-link">
          <i class="bi bi-cart-check me-2"></i> Sales
        </a>
      </li>

      <li>
        <a href="${pageContext.request.contextPath}/PurchaseServlet" class="nav-link">
          <i class="bi bi-basket me-2"></i> Purchase
        </a>
      </li>

      <li>
        <a href="${pageContext.request.contextPath}/pages/productCategory.jsp" class="nav-link">
          <i class="bi bi-box-seam me-2"></i> Product Category
        </a>
      </li>

      <li>
        <a href="${pageContext.request.contextPath}/Product" class="nav-link">
          <i class="bi bi-box me-2"></i> Products
        </a>
      </li>

      <li>
        <a class="nav-link d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#reportsMenu">
          <span><i class="bi bi-bar-chart me-2"></i> Reports</span>
          <i class="bi bi-chevron-down"></i>
        </a>

        <div class="collapse ps-3" id="reportsMenu">
          <a href="${pageContext.request.contextPath}/PrintPurchaseReportServlet"
             class="nav-link small">Purchase Report</a>

          <a href="${pageContext.request.contextPath}/ProfitAndLossReport"
             class="nav-link small">Profit-Loss Report</a>
        </div>
      </li>

  </ul>
</div>

<!-- ================== CSS ================== -->
<style>

:root{
  --sidebar-width: 260px;
}

/* Sidebar Container */
.sidebar{
  width: var(--sidebar-width);
  height: 100vh;
  background: linear-gradient(180deg,#08143a,#09184b);
  color:#d9e6f0;
  padding:20px 16px;
  position:fixed;
  top:0;
  left:0;
  z-index:2000;
  transition: all .3s ease-in-out;
  overflow-y:auto;
}

.sidebar hr{
  border-color: rgba(255,255,255,0.1);
}

.sidebar-brand{
  color:#d9e6f0;
  text-decoration:none;
  font-size:20px;
  font-weight:600;
  display:flex;
  align-items:center;
  margin-bottom:10px;
}

.sidebar-menu .nav-link{
  padding:10px 12px;
  display:flex;
  align-items:center;
  color:#d9e6f0;
  border-radius:10px;
  margin-bottom:4px;
  transition:0.2s;
}

.sidebar-menu .nav-link:hover{
  background:rgba(255,255,255,0.08);
}

/* MOBILE — Sidebar hidden */
@media(max-width:1024px){
  .sidebar{
    left:-270px;
  }
  .sidebar.active{
    left:0;
  }
}

/* Desktop layout */
@media(min-width:1025px){
  body{
    margin-left:var(--sidebar-width);
  }
}

/* Hamburger Button */
.sidebar-toggle-btn{
  position:fixed;
  top:14px;
  left:14px;
  z-index:3000;
  width:46px;
  height:46px;
  border:none;
  border-radius:8px;
  background:rgba(0,0,0,0.45);
  backdrop-filter:blur(6px);
  color:white;
  font-size:22px;
  display:flex;
  justify-content:center;
  align-items:center;
}

@media(min-width:1025px){
  .sidebar-toggle-btn{
    display:none;
  }
}

</style>

<!-- ================== JS ================== -->
<script>
function toggleSidebar(){
    document.getElementById("sidebar").classList.toggle("active");
}
</script>