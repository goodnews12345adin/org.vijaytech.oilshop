<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Profit & Loss Report | Vijay Tech Orbit</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>

  <!-- Fonts & Icons -->
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">

  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  
  <!-- Chart.js -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    /* === ROOT VARIABLES === */
    :root {
      --sidebar-width: 260px;
      --header-height: 75px;
      --accent: #15a0c6;
      --accent-dark: #0e7d9b;
      --accent-glow: rgba(21, 160, 198, 0.3);
      --bg-dark: #0a1220;
      --card-bg: #ffffff;
      --text-main: #1e293b;
      --text-muted: #64748b;
      --border-light: #e2e8f0;
      --radius-lg: 20px;
      --radius-sm: 12px;
      --shadow-card: 0 20px 40px -5px rgba(0, 0, 0, 0.1);
      --shadow-glow: 0 0 20px var(--accent-glow);
      --transition: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    /* === GLOBAL RESETS === */
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: var(--bg-dark);
      background-image: 
        radial-gradient(circle at top right, rgba(21, 160, 198, 0.08), transparent 40%),
        radial-gradient(circle at bottom left, rgba(139, 92, 246, 0.05), transparent 40%);
      color: var(--text-main);
      margin: 0;
      padding-top: calc(var(--header-height) + 20px);
      min-height: 100vh;
      overflow-x: hidden;
    }

    /* ===========================
       HEADER UI
       =========================== */
    .app-header {
      position: fixed;
      top: 0;
      right: 0;
      left: 0;
      height: var(--header-height);
      background: rgba(10, 18, 32, 0.9);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      display: flex;
      align-items: center;
      justify-content: flex-end;
      padding: 0 40px;
      z-index: 4000;
      border-bottom: 1px solid rgba(255, 255, 255, 0.05);
      box-shadow: 0 4px 20px rgba(0,0,0,0.2);
      transition: padding 0.3s ease;
    }

    .header-user-zone {
      display: flex;
      flex-direction: column;
      align-items: flex-end;
      gap: 4px;
    }

    .version-tag {
      background: rgba(25, 182, 176, 0.15);
      color: #19b6b0;
      font-size: 10px;
      font-weight: 800;
      padding: 3px 10px;
      border-radius: 20px;
      border: 1px solid rgba(25, 182, 176, 0.3);
      text-transform: uppercase;
      letter-spacing: 1px;
    }

    .user-info {
      display: flex;
      align-items: center;
      gap: 15px;
      background: rgba(255,255,255,0.05);
      padding: 6px 16px 6px 6px;
      border-radius: 50px;
      border: 1px solid rgba(255,255,255,0.1);
    }

    .user-name {
      color: #ffffff;
      font-weight: 700;
      font-size: 14px;
      white-space: nowrap;
    }

    .btn-logout {
      background: #ff4d4d;
      color: white;
      border: none;
      width: 32px; height: 32px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: var(--transition);
      font-size: 14px;
      flex-shrink: 0;
    }
    .btn-logout:hover {
      background: #e60000;
      transform: rotate(90deg);
      box-shadow: 0 0 10px rgba(255, 77, 77, 0.5);
    }

    .status-online {
      font-size: 10px;
      color: rgba(255, 255, 255, 0.4);
      font-weight: 500;
    }

    /* ===========================
       CONTENT LAYOUT
       =========================== */
    .page-wrap {
      padding: 20px 40px 100px 40px;
      transition: var(--transition);
      max-width: 1600px;
      margin: 0 auto;
      width: 100%;
      display: flex;
      justify-content: center;
      align-items: flex-start; 
    }

    .main-content-card {
      background: var(--card-bg);
      border-radius: var(--radius-lg);
      padding: 40px;
      box-shadow: var(--shadow-card);
      border: 1px solid rgba(255,255,255,0.5);
      position: relative;
      overflow: hidden;
      width: 100%;
    }

    /* Top Decorative Line */
    .main-content-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 6px;
        background: linear-gradient(90deg, var(--accent), #8b5cf6);
    }

    .main-content-card h5.card-title {
      font-weight: 800;
      font-size: 24px;
      color: #0f172a;
      margin-bottom: 35px;
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .main-content-card h5.card-title i { color: var(--accent); font-size: 26px; }

    /* Form Controls */
    .form-label { 
        font-weight: 700; 
        color: var(--text-muted); 
        font-size: 13px; 
        margin-bottom: 8px; 
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .form-control, .form-select {
        height: 54px;
        border-radius: var(--radius-sm);
        border: 1px solid var(--border-light);
        background: #f8fafc;
        color: var(--text-main);
        font-weight: 600;
        transition: var(--transition);
        padding: 0 18px;
    }

    .form-control:focus, .form-select:focus {
        background: #fff;
        border-color: var(--accent);
        box-shadow: 0 0 0 4px rgba(21, 160, 198, 0.1);
        transform: translateY(-1px);
    }

    /* Buttons */
    .btn-primary {
        background: linear-gradient(135deg, var(--accent), #0ea5e9);
        border: none;
        padding: 12px 30px;
        font-weight: 700;
        border-radius: 50px;
        box-shadow: 0 10px 25px -5px rgba(21, 160, 198, 0.4);
        transition: var(--transition);
    }
    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px -5px rgba(21, 160, 198, 0.5);
        filter: brightness(1.1);
        color: white;
    }

    .btn-outline-danger {
        border: 2px solid #ef4444;
        color: #ef4444;
        padding: 12px 30px;
        font-weight: 700;
        border-radius: 50px;
        transition: var(--transition);
    }
    .btn-outline-danger:hover {
        background: #ef4444;
        color: white;
        transform: translateY(-2px);
    }
    
    /* NEW: Export Buttons */
    .btn-export-group {
        display: flex;
        gap: 10px;
    }
    .btn-success-outline {
        border: 2px solid #10b981;
        color: #10b981;
        padding: 12px 30px;
        font-weight: 700;
        border-radius: 50px;
        transition: var(--transition);
        background: transparent;
    }
    .btn-success-outline:hover {
        background: #10b981;
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 10px 20px -5px rgba(16, 185, 129, 0.4);
    }
    .btn-secondary-outline {
        border: 2px solid #64748b;
        color: #64748b;
        padding: 12px 30px;
        font-weight: 700;
        border-radius: 50px;
        transition: var(--transition);
        background: transparent;
    }
    .btn-secondary-outline:hover {
        background: #64748b;
        color: white;
        transform: translateY(-2px);
    }

    /* NEW: Dashboard Analytics Grid */
    .dashboard-stats {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    .stat-card {
        background: rgba(255,255,255,0.6);
        border: 1px solid rgba(255,255,255,0.8);
        border-radius: var(--radius-sm);
        padding: 20px;
        display: flex;
        align-items: center;
        gap: 15px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.03);
        backdrop-filter: blur(10px);
        animation: slideIn 0.5s ease-out forwards;
    }
    .stat-icon {
        width: 50px;
        height: 50px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        color: white;
    }
    .stat-info h6 { margin: 0; color: var(--text-muted); font-size: 0.85rem; font-weight: 700; text-transform: uppercase; }
    .stat-info h3 { margin: 5px 0 0; color: var(--text-main); font-weight: 800; font-size: 1.5rem; }

    /* Chart Container */
    .chart-wrapper {
        background: #fff;
        padding: 20px;
        border-radius: var(--radius-sm);
        border: 1px solid var(--border-light);
        margin-bottom: 30px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.02);
        max-height: 350px; /* Constrain height */
    }

    /* PDF Icon */
    .pdf-icon { 
        cursor: pointer; 
        transition: all .2s ease; 
        color: #ef4444;
    }
    .pdf-icon:hover { 
        transform: scale(1.2); 
        color: #b91c1c; 
        text-shadow: 0 0 10px rgba(239, 68, 68, 0.4);
    }

    /* === Table Styling (Adapted for Profit/Loss) === */
    .table-responsive {
        border-radius: var(--radius-sm);
        border: 1px solid var(--border-light);
        overflow: auto;
    }

    table.table {
        margin-bottom: 0;
        background: #fff;
    }

    table.table tbody td {
        color: #1e293b !important;
        font-size: 0.9rem !important;
        vertical-align: middle;
        padding: 15px 10px;
        border-bottom: 1px solid #f1f5f9;
        background: rgba(255,255,255,0.2);
    }
    table.table tbody tr:hover {
        background: #f8fafc;
    }

    /* Sticky Headers */
    .sticky-header th {
        background-color: #f1f5f9;
        color: #0f172a;
        border-bottom: 1px solid #e2e8f0;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.75rem;
        padding: 12px;
        position: sticky;
        top: 0;
        z-index: 10;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }

    /* Negative Row Styling */
    .negative-row {
        background-color: #fff5f5 !important;
        color: #ef4444 !important;
        font-weight: 700 !important;
    }

    /* Freeze Column Styling */
    .freeze-col td:first-child, .freeze-col th:first-child {
        background: #f8fafc;
        border-right: 2px solid #e2e8f0;
        position: sticky;
        left: 0;
        z-index: 20;
    }

    .freeze-col th:first-child {
        border-right: none;
    }

    /* === GLOBAL LOADER === */
    #global-loader {
        display: none;
        align-items: center;
        justify-content: center;
        position: fixed;
        inset: 0;
        z-index: 5500;
        background: rgba(10, 18, 32, 0.8);
        backdrop-filter: blur(8px);
        -webkit-backdrop-filter: blur(8px);
    }
    .loader-content {
        text-align: center;
        color: white;
    }

    /* Animation Keyframes */
    @keyframes slideIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* ===========================
       RESPONSIVE MEDIA QUERIES
       =========================== */
    @media (max-width: 992px) {
      .page-wrap { padding: 20px 30px; }
      .app-header { padding: 0 20px; }
      .main-content-card { padding: 30px; }
    }

    @media (max-width: 768px) {
      .page-wrap { padding: 15px 20px; }
      .main-content-card { padding: 25px; }
      .main-content-card h5.card-title { font-size: 20px; }
      .dashboard-stats { grid-template-columns: 1fr; }
    }

    @media (max-width: 576px) {
      .app-header { padding: 0 15px; }
      .user-name { display: none; }
      .status-online { display: none; }
      .page-wrap { padding: 10px 10px 80px 10px; }
      .main-content-card { padding: 25px 20px; }
      .form-control, .form-select { height: 50px; }
      .btn-export-group { flex-direction: column; width: 100%; }
      .btn-outline-danger, .btn-success-outline, .btn-secondary-outline { width: 100%; padding: 10px; }
    }
    
/* ===============================
   ✅ MODERN DATATABLE STYLE
   Like Invoice List Screenshot
   =============================== */

/* Table Wrapper */
.table-responsive {
    border-radius: 14px;
    overflow: hidden;
    border: 1px solid #e2e8f0;
    background: white;
}

/* Table Base */
#profitTable {
    width: 100%;
    border-collapse: collapse !important;
    background: white;
    font-size: 14px;
}

/* Header Style */
#profitTable thead th {
    background: #f8fafc;
    color: #334155;
    font-weight: 800;
    font-size: 13px;
    text-transform: uppercase;
    padding: 16px 14px;
    border-bottom: 2px solid #e2e8f0;
}

/* Body Rows */
#profitTable tbody tr {
    background: white;
    transition: 0.2s ease;
}

/* Hover Effect */
#profitTable tbody tr:hover {
    background: #f1f5f9;
}

/* Cell Styling */
#profitTable tbody td {
    padding: 16px 14px;
    border-bottom: 1px solid #e2e8f0;
    color: #0f172a;
    font-weight: 600;
    vertical-align: middle;
}

/* Footer Border */
#profitTable tbody tr:last-child td {
    border-bottom: 2px solid #cbd5e1;
}

/* Profit Column Bold */
#profitTable td.fw-bold {
    font-weight: 800 !important;
}

/* Negative Profit Highlight */
.negative-row td {
    background: #fff5f5 !important;
    color: #dc2626 !important;
    font-weight: 800;
}

/* Rounded Header Corners */
#profitTable thead th:first-child {
    border-top-left-radius: 14px;
}
#profitTable thead th:last-child {
    border-top-right-radius: 14px;
}

#profitTable tfoot td {
    padding: 16px 14px;
    background: #f8fafc;
    font-weight: 800;
    border-top: 2px solid #e2e8f0;
}

    
  </style>
</head>
<body>

    <!-- HEADER -->
    <header class="app-header">
        <div class="header-user-zone">
          <span class="version-tag">v44.1</span>
          <div class="user-info">
            <span class="user-name">Guest User</span>
            <div class="btn-logout" onclick="location.href='logout.jsp'" title="Logout">
              <i class="bi bi-power"></i>
            </div>
          </div>
          <span class="status-online">Status: Online</span>
        </div>
    </header>

    <!-- SIDEBAR -->
    <%@ include file="sidebar.jsp" %>

    <!-- GLOBAL LOADER -->
    <div id="global-loader">
        <div class="loader-content">
            <div class="spinner-border text-info mb-3" role="status" style="width: 3rem; height: 3rem;"></div>
            <h5 class="fw-bold">Processing...</h5>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="page-wrap">
        <div class="main-content-card">
            <h5 class="card-title"><i class="bi bi-graph-up-arrow"></i> Profit & Loss Report</h5>

            <!-- Report Form -->
            <form id="reportForm" class="row g-3" onsubmit="loadReport(event)">
                
                <div class="col-lg-3 col-md-6 col-12">
                    <label class="form-label">From Date</label>
                    <input type="date" class="form-control form-control-sm" id="fromDate" required>
                </div>

                <div class="col-lg-3 col-md-6 col-12">
                    <label class="form-label">To Date</label>
                    <input type="date" class="form-control form-control-sm" id="toDate" required>
                </div>

                <div class="col-lg-3 col-md-6 col-12">
                    <label class="form-label">Category</label>
                    <select id="category" class="form-select form-select-sm">
                        <option value="">-- All Categories --</option>
                        <%
                            List<Map<String,Object>> catList =
                                    (List<Map<String,Object>>) request.getAttribute("categoryList");
                            if (catList != null) {
                                for (Map<String,Object> c : catList) {
                        %>
                        <option value="<%=c.get("id")%>"><%=c.get("name")%></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>

                <div class="col-lg-3 col-md-6 col-12">
                    <label class="form-label">Product</label>
                    <select id="product" class="form-select form-select-sm">
                        <option value="">-- All Products --</option>
                        <%
                            List<Map<String,Object>> prodList =
                                    (List<Map<String,Object>>) request.getAttribute("productList");
                            if (prodList != null) {
                                for (Map<String,Object> p : prodList) {
                        %>
                        <option value="<%=p.get("id")%>"><%=p.get("name")%></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>

                <div class="col-lg-3 col-md-6 col-12 d-flex align-items-end gap-2">
                    <button class="btn btn-primary flex-grow-1" type="submit">Analyze</button>
                    <button type="button" class="btn btn-outline-danger" onclick="resetAll()">Reset</button>
                </div>
            </form>

            <!-- EXPORT BUTTONS -->
            <div class="d-flex justify-content-end mb-4 btn-export-group">
                <button class="btn-success-outline" onclick="exportFile('csv')">Export CSV</button>
                <button class="btn-success-outline" onclick="exportFile('excel')">Export Excel</button>
                <button class="btn-secondary-outline" onclick="exportFile('pdf')">Export PDF</button>
            </div>

            <!-- DASHBOARD STATS -->
            <div class="dashboard-stats" id="dashboard-stats">
                <div class="stat-card">
                    <div class="stat-icon bg-primary"><i class="bi bi-currency-rupee"></i></div>
                    <div class="stat-info">
                        <h6>Total Profit</h6>
                        <h3 id="stat-profit" data-target="0" class="animate-value">0.00</h3>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon bg-danger"><i class="bi bi-cart-x"></i></div>
                    <div class="stat-info">
                        <h6>Total Purchase</h6>
                        <h3 id="stat-purchase" data-target="0" class="animate-value">0.00</h3>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon bg-info"><i class="bi bi-bag-check"></i></div>
                    <div class="stat-info">
                        <h6>Total Sales</h6>
                        <h3 id="stat-sales" data-target="0" class="animate-value">0.00</h3>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon bg-success"><i class="bi bi-balance-scale"></i></div>
                    <div class="stat-info">
                        <h6>Net Balance</h6>
                        <h3 id="stat-balance" data-target="0" class="animate-value">0.00</h3>
                    </div>
                </div>
            </div>

            <!-- CHART -->
            <div class="chart-wrapper">
                <canvas id="profitChart" style="max-height:350px;"></canvas>
            </div>

            <!-- REPORT TABLE -->
            <div class="card shadow-sm border-0">
                <div class="card-body p-0">
                    <!-- Total Summary Bar -->
                    <div class="d-flex justify-content-between align-items-center py-3 px-4 mb-3 sticky-header">
                        <div class="d-flex gap-4">
                            <div><strong>Total Sales:</strong> <span class="fw-bold text-success ms-1">$<span id="totalSalesDisplay">0.00</span></span></div>
                            <div><strong>Total Purchase:</strong> <span class="fw-bold text-danger ms-1">$<span id="totalPurchaseDisplay">0.00</span></span></div>
                        </div>
                        <div class="fw-bold">Net Profit: <span class="text-info ms-1">$<span id="netProfitDisplay">0.00</span></span></div>
                    </div>

                    <div class='table-responsive'>
                        <table class='table table-striped table-hover table-md' id="profitTable">
                            <thead class="sticky-header">
                                <tr>
                                    <th width="15%">Code</th>
                                    <th width="25%">Product</th>
                                    <th class="text-end">Sales Qty</th>
                                    <th class="text-end">Sales Amt</th>
                                    <th class="text-end">Purch. Qty</th>
                                    <th class="text-end">Purch. Amt</th>
                                    <th class="text-end">Qty</th>
                                    <th class="text-end">Profit</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Javascript will populate this -->
                            </tbody>
							<tfoot>
								<tr>
								</tr>
							</tfoot>

						</table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- jsPDF + AutoTable -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.28/jspdf.plugin.autotable.min.js"></script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

   <script>
const servletUrl = "<%=request.getContextPath()%>/ProfitAndLossReport";

let tableData = [];
let responseTotals = {};

/* ---------- helpers ---------- */
function num(v){ return Number(v) || 0; }

function fmt(v){
  return num(v).toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}

/* ---------- build payload ---------- */
function buildPayload(){
  return {
    from: document.getElementById("fromDate").value,
    to:   document.getElementById("toDate").value,
    category: document.getElementById("category").value || "",
    product: document.getElementById("product").value || ""
  };
}

/* ---------- load report ---------- */
function loadReport(e){
  e.preventDefault();

  $("#profitTable tbody").html("");
  tableData = [];
  responseTotals = {};

  $("#dashboard-stats").fadeOut(200);
  $("#profitChart").parent().hide();

  $("#global-loader").css("display","flex").hide().fadeIn(200);

  $.ajax({
    url: servletUrl,
    method: "POST",
    data: JSON.stringify(buildPayload()),
    contentType: "application/json",

    success: function(res){

      $("#global-loader").fadeOut(200);

      tableData = res.rows || [];
      responseTotals = res.totals || {};

      renderTable();
      renderStats();
      renderChart();

      $("#dashboard-stats").hide().slideDown(500);
    },

    error: function(err){
      console.error("Error loading report:", err);
      $("#global-loader").fadeOut(200);
      alert("Error loading report data. Please try again.");
    }
  });
}

/* ---------- reset all ---------- */
function resetAll(){
  document.getElementById("reportForm").reset();
  $("#profitTable tbody").html("");
  $("#dashboard-stats").fadeOut(200);
  $("#profitChart").parent().hide();
  resetDisplayValues();
}

function resetDisplayValues(){
  tableData = [];
  responseTotals = {};

  document.getElementById("totalSalesDisplay").innerText = "0.00";
  document.getElementById("totalPurchaseDisplay").innerText = "0.00";
  document.getElementById("netProfitDisplay").innerText = "0.00";

  document.getElementById("stat-profit").innerText = "0.00";
  document.getElementById("stat-purchase").innerText = "0.00";
  document.getElementById("stat-sales").innerText = "0.00";
  document.getElementById("stat-balance").innerText = "0.00";
}

/* ==========================================================
   ✅ FIXED TABLE RENDER (JSP SAFE)
   ========================================================== */
function renderTable(){

  if(tableData.length === 0){
    $("#profitTable tbody").html(
      "<tr><td colspan='9' class='text-center text-muted'>No records found.</td></tr>"
    );
    $("#dashboard-stats").fadeOut(200);
    return;
  }

  let html = "";

  tableData.forEach((row) => {

    let isNegative = num(row.profit) < 0;
    let cls = isNegative ? "negative-row" : "";

    html += `<tr class='\${cls}'>`;

    html += `<td>\${row.productCode || ""}</td>`;
    html += `<td>\${row.productName || ""}</td>`;

    html += `<td class="text-end">\${row.salesQty || 0}</td>`;
    html += `<td class="text-end">\${fmt(row.salesAmount)}</td>`;

    html += `<td class="text-end">\${row.purchaseQty || 0}</td>`;
    html += `<td class="text-end">\${fmt(row.purchaseAmount)}</td>`;

    html += `<td class="text-end">\${row.balanceQty || 0}</td>`;
    html += `<td class="text-end fw-bold">\${fmt(row.profit)}</td>`;

    html += `</tr>`;
  });

  $("#profitTable tbody").html(html);
}

/* ---------- render stats ---------- */
function renderStats(){

  const totalSales    = num(responseTotals.totalSalesAmount);
  const totalPurchase = num(responseTotals.totalPurchaseAmount);
  const totalProfit   = num(responseTotals.totalProfit);

  document.getElementById("totalSalesDisplay").innerText    = fmt(totalSales);
  document.getElementById("totalPurchaseDisplay").innerText = fmt(totalPurchase);
  document.getElementById("netProfitDisplay").innerText     = fmt(totalProfit);

  document.getElementById("stat-sales").innerText    = fmt(totalSales);
  document.getElementById("stat-purchase").innerText = fmt(totalPurchase);
  document.getElementById("stat-profit").innerText   = fmt(totalProfit);
  document.getElementById("stat-balance").innerText  = fmt(totalProfit);
}

/* ---------- render chart ---------- */
function renderChart(){

  if(tableData.length === 0) return;

  const ctx = document.getElementById("profitChart").getContext("2d");

  if(window.myProfitChart){
    window.myProfitChart.destroy();
  }

  const labels       = tableData.map(r => r.productName || r.productCode || "Unknown");
  const salesData    = tableData.map(r => num(r.salesAmount));
  const purchaseData = tableData.map(r => num(r.purchaseAmount));
  const profitData   = tableData.map(r => num(r.profit));

  window.myProfitChart = new Chart(ctx, {
    type: "bar",
    data: {
      labels: labels,
      datasets: [
        { label: "Sales",    data: salesData },
        { label: "Purchase", data: purchaseData },
        { label: "Profit",   data: profitData }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false
    }
  });

  $("#profitChart").parent().show();
}

/* ==========================================================
   ✅ FIXED EXPORT (NO TEMPLATE LITERALS)
   ========================================================== */
function exportFile(type){

  if(tableData.length === 0){
    alert("No data to export");
    return;
  }

  if(type === "pdf"){
    downloadTablePDF();
    return;
  }

  let csvContent = "";

  /* ============================
     ✅ Company Header Info
  ============================ */

  csvContent += "THIRU SENTHILATHIPATHI OIL STORE\n";
  csvContent += "No.42, Krishna Moorthi Bavanam, Madakulam Main Road,\n";
  csvContent += "Palangantham, Madurai – 625003\n";
  csvContent += "GST: 29ABCDE1234F1Z5\n\n";

  /* ============================
     ✅ Date Range (Optional)
  ============================ */

  let fromDate = document.getElementById("fromDate").value;
  let toDate   = document.getElementById("toDate").value;

  csvContent += "Profit & Loss Report\n";
  csvContent += "Period: " + fromDate + " to " + toDate + "\n\n";

  /* ============================
     ✅ Table Header Row
  ============================ */

  csvContent +=
    "Product Code,Product Name,Sales Qty,Sales Amount," +
    "Purchase Qty,Purchase Amount,Balance Qty,Profit\n";

  /* ============================
     ✅ Table Data Rows
  ============================ */

  tableData.forEach(row => {

    let pCode = (row.productCode || "").replace(/,/g, " ");
    let pName = (row.productName || "").replace(/,/g, " ");

    csvContent +=
      pCode + "," +
      pName + "," +
      (row.salesQty || 0) + "," +
      fmt(row.salesAmount) + "," +
      (row.purchaseQty || 0) + "," +
      fmt(row.purchaseAmount) + "," +
      (row.balanceQty || 0) + "," +
      fmt(row.profit) + "\n";
  });

  /* ============================
     ✅ Download CSV File
  ============================ */

  let blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });

  let link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = "PNL_Report.csv";
  link.click();
}
function downloadTablePDF() {

    if (tableData.length === 0) {
        alert("No data available to export!");
        return;
    }

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF("p", "mm", "a4");

    /* ============================
       ✅ Report Title
    ============================ */
    /* ============================
    ✅ Company Header
 ============================ */

 // Company Name
 doc.setFontSize(18);
 doc.setFont("helvetica", "bold");
 doc.text("THIRU SENTHILATHIPATHI OIL STORE", 105, 15, { align: "center" });

 // Address Line
 doc.setFontSize(10);
 doc.setFont("helvetica", "normal");
 doc.text(
   "No.42, Krishna Moorthi Bavanam, Madakulam Main Road,",
   105,
   22,
   { align: "center" }
 );

 doc.text(
   "Palangantham, Madurai – 625003",
   105,
   27,
   { align: "center" }
 );

 // GST Line
 doc.setFontSize(10);
 doc.setFont("helvetica", "bold");
 doc.text("GST: 29ABCDE1234F1Z5", 105, 32, { align: "center" });
 /* ============================
 ✅ Report Title
============================ */

doc.setFontSize(16);
doc.setFont("helvetica", "bold");
doc.text("Profit & Loss Report", 14, 45);

doc.setFontSize(10);
doc.setFont("helvetica", "normal");

let fromDate = document.getElementById("fromDate").value;
let toDate   = document.getElementById("toDate").value;

doc.text("Period: " + fromDate + " to " + toDate, 14, 52);

 // Divider Line
 doc.setDrawColor(0);
 doc.line(14, 36, 196, 36);

    /* ============================
       ✅ Prepare Table Data
    ============================ */
    let bodyData = [];

    tableData.forEach(row => {
        bodyData.push([
            row.productCode || "",
            row.productName || "",
            row.salesQty || 0,
            fmt(row.salesAmount),
            row.purchaseQty || 0,
            fmt(row.purchaseAmount),
            fmt(row.profit)
        ]);
    });

    /* ============================
       ✅ Grand Totals Row
    ============================ */
    let totalSales    = fmt(responseTotals.totalSalesAmount || 0);
    let totalPurchase = fmt(responseTotals.totalPurchaseAmount || 0);
    let totalProfit   = fmt(responseTotals.totalProfit || 0);

    bodyData.push([
        "", 
        "GRAND TOTAL",
        "",
        totalSales,
        "",
        totalPurchase,
        totalProfit
    ]);

    /* ============================
       ✅ Export Table + Totals Row
    ============================ */
    doc.autoTable({
        head: [[
            "Code",
            "Product",
            "Sales Qty",
            "Sales Amt",
            "Purch Qty",
            "Purch Amt",
            "Profit"
        ]],
        body: bodyData,
        startY: 35,
        theme: "grid",
        styles: {
            fontSize: 8,
            cellPadding: 2
        },
        headStyles: {
            fontStyle: "bold"
        },

        /* ✅ Style Grand Total Row */
        didParseCell: function (data) {
            if (data.row.index === bodyData.length - 1) {
                data.cell.styles.fontStyle = "bold";
                data.cell.styles.fillColor = [240, 240, 240];
            }
        }
    });

    /* ============================
       ✅ Save PDF
    ============================ */
    doc.save("Profit_Loss_Report.pdf");
}



/* ---------- download Single Invoice ---------- */
function downloadSinglePDF(docId){

  if(!docId){
    alert("Document ID missing.");
    return;
  }

  window.open(servletUrl + "?docNo=" + docId, "_blank");
}
</script>
</body>
</html>