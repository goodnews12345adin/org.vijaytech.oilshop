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
    <%@ include file="header.jsp" %>
    <%@ include file="sidebar.jsp" %> 

    <!-- ✅ Page Content -->
    <main class="main-content">
        <div class="container-fluid">
            <h3 class="fw-bold mb-4">Dashboard</h3>

            <div class="row g-4">
                <!-- Card 1 -->
                <div class="col-md-3">
                    <div class="card p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-muted">Total Sales</h6>
                                <h3 class="fw-semibold text-primary">₹1,24,500</h3>
                            </div>
                            <i class="bi bi-currency-rupee fs-3 text-secondary"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 2 -->
                <div class="col-md-3">
                    <div class="card p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-muted">Customers</h6>
                                <h3 class="fw-semibold text-primary">350</h3>
                            </div>
                            <i class="bi bi-people fs-3 text-secondary"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 3 -->
                <div class="col-md-3">
                    <div class="card p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-muted">Products</h6>
                                <h3 class="fw-semibold text-primary">124</h3>
                            </div>
                            <i class="bi bi-box-seam fs-3 text-secondary"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 4 -->
                <div class="col-md-3">
                    <div class="card p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-muted">Pending Orders</h6>
                                <h3 class="fw-semibold text-primary">18</h3>
                            </div>
                            <i class="bi bi-clock-history fs-3 text-secondary"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Example Table Section -->
            <div class="card mt-5">
                <div class="card-header bg-white">
                    <h6 class="fw-bold mb-0">Recent Transactions</h6>
                </div>
                <div class="card-body p-0">
                    <table class="table table-hover mb-0 align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>#</th>
                                <th>Customer</th>
                                <th>Product</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>001</td>
                                <td>John Doe</td>
                                <td>Cement Bag</td>
                                <td>₹5,000</td>
                                <td><span class="badge bg-success">Completed</span></td>
                                <td>2025-11-01</td>
                            </tr>
                            <tr>
                                <td>002</td>
                                <td>Mary Smith</td>
                                <td>Steel Rods</td>
                                <td>₹8,750</td>
                                <td><span class="badge bg-warning text-dark">Pending</span></td>
                                <td>2025-11-01</td>
                            </tr>
                            <tr>
                                <td>003</td>
                                <td>Ravi Kumar</td>
                                <td>Sand Load</td>
                                <td>₹3,200</td>
                                <td><span class="badge bg-danger">Failed</span></td>
                                <td>2025-10-31</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="footer.jsp" %>

</body>
</html>
