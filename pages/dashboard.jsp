<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | Vijay Tech</title>

    <!-- ✅ Bootstrap & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        body {
            background-color: #f8fafc;
            font-family: "Inter", "Roboto", sans-serif;
            min-height: 100vh;
        }
        .main-content {
            margin-left: 250px; /* matches sidebar width */
            padding: 80px 25px 100px 25px; /* space for header + footer */
            transition: all 0.3s ease;
        }
        @media (max-width: 768px) {
            .main-content {
                margin-left: 0;
                padding: 80px 10px 100px 10px;
            }
        }
        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        }
    </style>
</head>

<body>

    <!-- ✅ Common Layout Includes -->
   <%--  <%@ include file="header.jsp" %> --%>
    <%@ include file="sidebar.jsp" %> 

      <!-- 🔷 Main Area -->
  <main class="main">
    <header class="topbar glass neon-border mx-3 my-3 px-3 py-2 d-flex align-items-center justify-content-between rounded-4">
      <div class="d-flex align-items-center gap-2">
        <h5 class="mb-0">Dashboard</h5>
      </div>
      <div class="d-flex align-items-center gap-2">
        <button id="themeToggle" class="btn btn-outline-light btn-sm">☀️</button>
        <span class="badge text-bg-dark-subtle glass border rounded-pill px-3 py-2">👤 admin</span>
      </div>
    </header>

    <section class="content glass rounded-4 mx-3 mb-4 p-3 p-md-4">
      <div class="row g-3">
        <div class="col-12 col-md-4">
          <div class="card card-soft h-100 p-3">
            <div class="h6">Today’s Orders</div>
            <div class="display-6 fw-bold">28</div>
          </div>
        </div>
        <div class="col-12 col-md-4">
          <div class="card card-soft h-100 p-3">
            <div class="h6">Pending Billing</div>
            <div class="display-6 fw-bold">7</div>
          </div>
        </div>
        <div class="col-12 col-md-4">
          <div class="card card-soft h-100 p-3">
            <div class="h6">Shipped</div>
            <div class="display-6 fw-bold">15</div>
          </div>
        </div>
      </div>

      <div class="mt-4">
        <div class="card card-soft p-3">
          <div class="d-flex justify-content-between align-items-center">
            <h6 class="mb-0">Recent Orders</h6>
            <button class="btn btn-sm btn-primary-gradient">New Order</button>
          </div>
          <div class="table-responsive mt-3">
            <table class="table table-hover align-middle soft-table">
              <thead>
                <tr>
                  <th>#</th><th>Customer</th><th>Item</th><th>Qty</th><th>Status</th><th></th>
                </tr>
              </thead>
              <tbody>
                <tr><td>1001</td><td>Shri Mills</td><td>Cotton Yarn</td><td>120</td><td><span class="badge bg-success">Shipped</span></td><td><button class="btn btn-sm btn-outline-light">View</button></td></tr>
                <tr><td>1002</td><td>A1 Textiles</td><td>Dyed Fabric</td><td>60</td><td><span class="badge bg-warning text-dark">Pending</span></td><td><button class="btn btn-sm btn-outline-light">View</button></td></tr>
                <tr><td>1003</td><td>RK Traders</td><td>Grey Fabric</td><td>90</td><td><span class="badge bg-info text-dark">Processing</span></td><td><button class="btn btn-sm btn-outline-light">View</button></td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>
  </main>

    <%@ include file="footer.jsp" %>

</body>
</html>
