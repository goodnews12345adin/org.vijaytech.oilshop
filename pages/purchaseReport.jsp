<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Purchase / Sales Report | Vijay Tech Orbit</title>
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

        /* Dashboard Analytics Grid */
        .dashboard-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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
        }

        /* PDF/Print Icons */
        .pdf-icon { 
            cursor: pointer; 
            transition: all .2s ease; 
            margin-right: 5px;
        }
        .pdf-icon:hover { 
            transform: scale(1.2); 
            text-shadow: 0 0 10px rgba(0,0,0,0.2);
        }

        /* Table Styling */
        table.table tbody td {
            color: #1e293b !important;
            font-size: 0.9rem !important;
            vertical-align: middle;
            padding: 15px 10px;
        }
        table.table th {
            background-color: #f8fafc;
            border-bottom: 2px solid var(--border-light);
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.8rem;
            color: var(--text-muted);
            padding: 12px 10px;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 40px;
            color: var(--text-muted);
            background: #fdfdfd;
            border-radius: var(--radius-sm);
            border-bottom: 1px dashed var(--border-light);
            margin-bottom: 20px;
        }
        .empty-state i { font-size: 40px; color: #cbd5e1; margin-bottom: 15px; display: block; }

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

    <!-- TOAST NOTIFICATION (PERFECTLY CENTERED) -->
    <div class="toast-container position-fixed top-50 start-50 translate-middle" style="z-index: 6000;">
        <div id="liveToast" class="toast align-items-center text-white bg-primary border-0 shadow-lg" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body fs-6 fw-bold text-center w-100">
                    <span id="toast-title" class="d-block"></span>
                    <span id="toast-message" class="d-block opacity-75"></span>
                </div>
            </div>
        </div>
    </div>

    <%
        // Fetch Org Details passed from Servlet
        String sessionOrgName = (String) request.getAttribute("orgName");
        String sessionOrgGST = (String) request.getAttribute("orgGST");
        String sessionOrgAddress = (String) request.getAttribute("orgAddress");
        
        if(sessionOrgName == null) sessionOrgName = "Company Name";
        if(sessionOrgGST == null) sessionOrgGST = "";
        if(sessionOrgAddress == null) sessionOrgAddress = "";
    %>

    <div class="page-wrap">
        <div class="main-content-card">
            <h5 class="card-title"><i class="bi bi-file-earmark-spreadsheet"></i> Purchase & Sales Report</h5>

            <!-- Report Form -->
            <form id="reportForm" class="row g-3" onsubmit="loadReport(event)">
                
                <div class="col-lg-3 col-md-6 col-12">
                    <label class="form-label">Supplier</label>
                    <select id="supplier" class="form-select form-select-sm">
                        <option value="">--Select Supplier--</option>
                        <%
                            List<Map<String, Object>> supplierList =
                                    (List<Map<String, Object>>) request.getAttribute("supplierList");
                            if (supplierList != null) {
                                for (Map<String, Object> s : supplierList) {
                        %>
                        <option value="<%=s.get("id")%>"><%=s.get("name")%></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                
                <div class="col-lg-2 col-md-6 col-12">
                    <label class="form-label">From Date</label>
                    <input type="date" class="form-control" id="fromDate" required>
                </div>

                <div class="col-lg-2 col-md-6 col-12">
                    <label class="form-label">To Date</label>
                    <input type="date" class="form-control" id="toDate" required>
                </div>

                <div class="col-lg-2 col-md-6 col-12">
                    <label class="form-label">Type</label>
                    <select class="form-select" id="type">
                        <option value="sales">Sales</option>
                        <option value="purchase">Purchase</option>
                    </select>
                </div>

                <div class="col-lg-2 col-md-6 col-12">
                    <label class="form-label">Summary</label>
                    <select class="form-select" id="summary">
                        <option value="N">Detail</option>
                        <option value="Y">Summary</option>
                    </select>
                </div>

                <!-- Hidden input for JS pagination logic support -->
                <input type="number" class="d-none" id="page" value="1" min="1">

                <div class="col-lg-3 col-md-6 col-12 d-flex align-items-end gap-2">
                    <button class="btn btn-primary w-100" type="submit">Show Report</button>
                    <button class="btn btn-outline-danger w-100" type="button" onclick="downloadTablePdf()">
                        PDF
                    </button>
                </div>
            </form>

            <!-- Quick Date Selection -->
            <div class="d-flex gap-2 flex-wrap mb-3 mt-2">
                <label class="form-label d-block w-100 text-muted" style="font-size: 11px;">QUICK FILTERS</label>
                <button class="btn btn-sm border rounded-pill" onclick="setQuickDate(0)">Today</button>
                <button class="btn btn-sm border rounded-pill" onclick="setQuickDate(-1)">Yesterday</button>
                <button class="btn btn-sm border rounded-pill" onclick="setQuickDate(-7)">Last 7 Days</button>
                <button class="btn btn-sm border rounded-pill" onclick="setQuickDate(-30)">Last 30 Days</button>
            </div>

            <div id="reportArea" class="mt-4"></div>
        </div>
    </div>

    <!-- jsPDF + AutoTable -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.28/jspdf.plugin.autotable.min.js"></script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
    // ==============================
    //  TOAST NOTIFICATION SYSTEM (Centered, 1s)
    // ==============================
    const toastEl = document.getElementById('liveToast');
    const toast = new bootstrap.Toast(toastEl, { delay: 1000 }); // 1 second display
    
    function showToast(title, message) {
        document.getElementById("toast-title").innerText = title;
        document.getElementById("toast-message").innerText = message;
        
        // Color Logic
        if(title.includes("Error")) {
            toastEl.classList.remove('bg-primary', 'bg-success');
            toastEl.classList.add('bg-danger');
        } else {
            toastEl.classList.remove('bg-danger');
            toastEl.classList.add('bg-primary');
        }
        
        toast.show();
    }

    // ==============================
    //  BUILD JSON FOR FETCH
    // ==============================
    function buildRequestJson() {
        return {
            from: document.getElementById("fromDate").value,
            to:   document.getElementById("toDate").value,
            type: document.getElementById("type").value,
            org:  "",  
            bp:   document.getElementById("supplier").value,
            summary: document.getElementById("summary").value,
            page: parseInt(document.getElementById("page").value || "1", 10)
        };
    }

    // ==============================
    //  LOAD REPORT
    // ==============================
    function loadReport(event){
        if (event) event.preventDefault();

        // Show Loader
        $("#global-loader").css("display","flex").hide().fadeIn(200);

        var json = buildRequestJson();

        document.getElementById("reportArea").innerHTML =
            "<div class='alert alert-info text-center'>Loading Report Data...</div>";

        fetch("<%=request.getContextPath()%>/PrintPurchaseReportServlet", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(json)
        })
        .then(r => r.json())
        .then(data => {
            $("#global-loader").fadeOut(200);
            renderTable(data, json.summary);
            showToast("Success", "Data loaded successfully.");
        })
        .catch(err => {
            $("#global-loader").fadeOut(200);
            document.getElementById("reportArea").innerHTML =
                "<div class='alert alert-danger text-center'>Error loading report. Please try again.</div>";
            showToast("Error", "Failed to load report data.");
            console.error(err);
        });
    }

    // ==============================
    //  NEXT / PREV PAGINATION
    // ==============================
    function goToPage(delta) {
        var pageInput = document.getElementById("page");
        var current = parseInt(pageInput.value || "1", 10);
        var next = current + delta;
        if (next < 1) next = 1;
        pageInput.value = next;
        loadReport(null);
    }

    function backToSearch() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // ==============================
    //  RETURN ARRAY OF ROWS
    // ==============================
    function getRowsArray(data){
        if (Array.isArray(data)) return data;
        if (typeof data.data !== 'undefined') return data.data;
        return [];
    }

    // ==============================
    //  RENDER TABLE
    // ==============================
    function renderTable(data, summaryMode){
        var rows = getRowsArray(data);
        
        var totalCount = (typeof data.totalCount !== 'undefined') ? data.totalCount : rows.length;
        var rowsPerPage = 200; 
        var totalPages = Math.ceil(totalCount / rowsPerPage);
        var currentPage = parseInt(document.getElementById("page").value || "1", 10);

        if (!rows.length){
            document.getElementById("reportArea").innerHTML =
                "<div class='empty-state'><i class='bi bi-inbox'></i><p>No records found for selected criteria.</p></div>";
            return;
        }

        var docHeader = (summaryMode === "N") ? "DocumentNo" : "";

        // ============================
        // CALCULATE STATS & ANIMATE
        // ============================
        let totalAmount = 0;
        let totalQty = 0;
        rows.forEach(r => {
            totalAmount += parseFloat(r.Amount || 0);
            totalQty += parseFloat(r.Qty || 0);
        });

        var html = "";
        
        // Render Stats Cards
        html += "<div class='dashboard-stats'>";
        html += "<div class='stat-card'><div class='stat-icon bg-primary'><i class='bi bi-currency-rupee'></i></div><div class='stat-info'><h6>Total Value</h6><h3 id='stat-amount' data-target='0'>0.00</h3></div></div>";
        html += "<div class='stat-card'><div class='stat-icon bg-success'><i class='bi bi-box-seam'></i></div><div class='stat-info'><h6>Total Qty</h6><h3 id='stat-qty' data-target='0'>0</h3></div></div>";
        html += "<div class='stat-card'><div class='stat-icon bg-info'><i class='bi bi-file-earmark-text'></i></div><div class='stat-info'><h6>Transactions</h6><h3 id='stat-count' data-target='0'>0</h3></div></div>";
        html += "</div>";

        // Trigger Animation
        setTimeout(() => {
            animateValue("stat-amount", 0, totalAmount, 1500);
            animateValue("stat-qty", 0, totalQty, 1500);
            animateValue("stat-count", 0, totalCount, 1500);
        }, 100);

        // Search Bar
        html += "<div class='row mb-3'><div class='col-md-4'><input type='text' id='tableSearch' class='form-control' placeholder='Search in current list...' onkeyup='filterTable()'></div></div>";

        // Chart
        html += "<div class='chart-wrapper'><canvas id='reportChart' style='max-height:300px;'></canvas></div>";

        html += "<div class='card border-0 shadow-sm'><div class='card-body'>";
        html += "<div class='table-responsive'>";
        html += "<table class='table table-striped table-hover table-md' id='reportTable'>";
        html += "<thead><tr>";
        html += "<th>Date</th>";
        html += "<th>" + docHeader + "</th>";
        html += "<th>BPartner</th>";
        html += "<th>Product</th>";
        html += "<th class='text-end'>Qty</th>";
        html += "<th class='text-end'>Price</th>";
        html += "<th class='text-end'>Amount</th>";
        html += "<th class='text-center'>Action</th>";
        html += "</tr></thead><tbody>";

        rows.forEach(row => {
            var docNo = row.DocumentNo || "";
            html += "<tr>";
            html += "<td>" + (row.Date || "") + "</td>";
            html += "<td>" + (summaryMode === "N" ? docNo : "") + "</td>";
            html += "<td>" + row.BPartner + "</td>";
            html += "<td>" + row.Product + "</td>";
            html += "<td class='text-end'>" + row.Qty + "</td>";
            html += "<td class='text-end'>" + row.Price + "</td>";
            html += "<td class='text-end'>" + row.Amount + "</td>";

            // Actions: Print (Thermal) vs PDF (A4)
            html += "<td class='text-center'>";
            if(docNo) {
                // Print Button (Triggers Thermal)
                html += "<a href='javascript:void(0)' onclick=\"printInvoice('" + docNo + "')\" class='pdf-icon' title='Print Thermal Receipt'><i class='bi bi-printer-fill fs-4 text-primary'></i></a>";
                // Download Button (Triggers A4)
                html += "<a href='javascript:void(0)' onclick=\"openPDF('" + docNo + "')\" class='pdf-icon ms-2' title='Download A4 PDF'><i class='bi bi-file-earmark-pdf-fill fs-4 text-danger'></i></a>";
            }
            html += "</td>";

            html += "</tr>";
        });

        html += "</tbody></table></div>";

        // Pagination Control with Back Button
        html += "<div class='d-flex justify-content-between mt-3 align-items-center flex-wrap gap-2'>";
        html += "<div class='fw-bold text-muted'>Page " + currentPage + " of " + totalPages + " (Total: " + totalCount + ")</div>";
        
        html += "<div class='d-flex gap-2'>";
        html += "<button class='btn btn-sm btn-outline-secondary' onclick='backToSearch()'><i class='bi bi-arrow-up-circle'></i> Back</button>";
        html += "<button class='btn btn-sm btn-outline-secondary' onclick='goToPage(-1)'><i class='bi bi-chevron-left'></i> Prev</button>";
        html += "<button class='btn btn-sm btn-outline-secondary' onclick='goToPage(1)'>Next <i class='bi bi-chevron-right'></i></button>";
        
        // Excel Export
        html += "<button class='btn-success-outline btn-sm' onclick='exportToExcel()'><i class='bi bi-file-earmark-excel'></i> Excel</button>";
        html += "</div></div>";

        html += "</div></div>";

        document.getElementById("reportArea").innerHTML = html;

        // Render Chart
        renderChart(rows);
    }

    // ==============================
    //  ANIMATED COUNTER
    // ==============================
    function animateValue(id, start, end, duration) {
        const obj = document.getElementById(id);
        let startTimestamp = null;
        const range = end - start;
        
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            
            // Formatting numbers nicely
            obj.innerHTML = Math.floor(progress * range + start).toLocaleString('en-IN');
            
            if (progress < 1) {
                window.requestAnimationFrame(step);
            } else {
                // Ensure final value is exact for decimals
                if(id === "stat-amount") {
                     obj.innerHTML = end.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
                } else {
                     obj.innerHTML = end.toLocaleString('en-IN');
                }
            }
        };
        window.requestAnimationFrame(step);
    }

    // ==============================
    //  RENDER CHART
    // ==============================
    function renderChart(data) {
        let productMap = {};
        data.forEach(r => {
            let amt = parseFloat(r.Amount) || 0;
            if(productMap[r.Product]) productMap[r.Product] += amt;
            else productMap[r.Product] = amt;
        });

        let sortedProducts = Object.keys(productMap).sort((a,b) => productMap[b] - productMap[a]).slice(0, 5);
        let labels = sortedProducts;
        let values = sortedProducts.map(k => productMap[k]);

        const ctx = document.getElementById('reportChart').getContext('2d');
        if(window.myChart) window.myChart.destroy();

        let gradient = ctx.createLinearGradient(0, 0, 0, 300);
        gradient.addColorStop(0, 'rgba(21, 160, 198, 0.6)');
        gradient.addColorStop(1, 'rgba(21, 160, 198, 0.1)');

        window.myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Transaction Value',
                    data: values,
                    backgroundColor: gradient,
                    borderColor: '#15a0c6',
                    borderWidth: 1,
                    borderRadius: 5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true } }
            }
        });
    }

    // ==============================
    //  OPEN SINGLE INVOICE PDF (A4)
    // ==============================
    function openPDF(docNo){
        if (!docNo) {
            showToast("Error", "Document Number is missing");
            return;
        }
        window.open(
            "<%=request.getContextPath()%>/PrintPurchaseReportServlet?docNo=" 
            + encodeURIComponent(docNo),
            "_blank"
        );
    }

    // ==============================
    //  PRINT INVOICE (Thermal Receipt)
    // ==============================
    function printInvoice(docNo) {
        if (!docNo) {
            showToast("Error", "Document Number is missing");
            return;
        }
        var url = "<%=request.getContextPath()%>/PrintPurchaseReportServlet?docNo=" + encodeURIComponent(docNo) + "&format=thermal";
        var win = window.open(url, "_blank");
        
        setTimeout(function() {
            try {
                win.focus(); 
                win.print(); 
            } catch(e) {
                console.log("Printing blocked by browser");
            }
        }, 1000);
    }

    // ==============================
    //  DOWNLOAD TABLE AS PDF (List PDF)
    // ==============================
    function downloadTablePdf(){
        var table = document.getElementById("reportTable");
        if (!table) {
            showToast("Error", "No report data to download");
            return;
        }

        $("#global-loader").css("display","flex").hide().fadeIn(200);

        setTimeout(() => {
             const jsPDFObj = window.jspdf;
            var doc = new jsPDFObj.jsPDF();
            
            // Add Corporate Headers
            doc.setFontSize(18);
            doc.setTextColor(21, 160, 198); // Brand Color
            doc.text("<%=sessionOrgName%>", 14, 20);
            
            doc.setFontSize(10);
            doc.setTextColor(100);
            doc.text("<%=sessionOrgAddress%>", 14, 26);
            doc.text("GSTIN: <%=sessionOrgGST%>", 14, 32);
            
            // Report Meta Info
            doc.setFontSize(12);
            doc.setTextColor(0);
            doc.text("Purchase / Sales Report", 14, 42);
            
            doc.setFontSize(10);
            doc.setTextColor(60);
            var supplier = $("#supplier option:selected").text();
            var type = $("#type option:selected").text();
            var range = $("#fromDate").val() + " to " + $("#toDate").val();
            
            if(supplier && supplier !== "--Select Supplier--") doc.text("Supplier: " + supplier, 14, 50);
            doc.text("Type: " + type, 14, 56);
            doc.text("Date Range: " + range, 14, 62);

            // Draw Line
            doc.setLineWidth(0.5);
            doc.setDrawColor(200);
            doc.line(14, 65, 196, 65);

            // Table
            doc.autoTable({ html: '#reportTable', startY: 70, styles: { fontSize: 8 }, theme: 'grid' });
            
            // Footer
            var pageCount = doc.internal.getNumberOfPages();
            doc.setFontSize(8);
            for(let i = 1; i <= pageCount; i++) {
                 doc.setPage(i);
                 doc.text('Page ' + String(i) + ' of ' + String(pageCount), 196-20, 285, {align: 'right'});
            }
            
            doc.save("Report_List.pdf");
            
            $("#global-loader").fadeOut(200);
        }, 500);
    }

    // ==============================
    //  QUICK DATE LOGIC
    // ==============================
    function setQuickDate(days) {
        var today = new Date();
        var d = new Date(today);
        d.setDate(today.getDate() + days);
        
        document.getElementById("fromDate").value = d.toISOString().split('T')[0];
        document.getElementById("toDate").value = today.toISOString().split('T')[0];
        
        loadReport(null);
    }

    // ==============================
    //  FILTER TABLE (CLIENT SIDE)
    // ==============================
    function filterTable() {
        var input, filter, table, tr, td, i, txtValue;
        input = document.getElementById("tableSearch");
        filter = input.value.toUpperCase();
        table = document.getElementById("reportTable");
        if (!table) return;
        
        tr = table.getElementsByTagName("tr");

        for (i = 1; i < tr.length; i++) {
            var found = false;
            var tds = tr[i].getElementsByTagName("td");
            
            if (tds[0] && tds[0].textContent.toUpperCase().includes(filter)) found = true;
            if (tds[2] && tds[2].textContent.toUpperCase().includes(filter)) found = true;
            if (tds[3] && tds[3].textContent.toUpperCase().includes(filter)) found = true;

            tr[i].style.display = found ? "" : "none";
        }
    }

    // ==============================
    //  EXPORT TO EXCEL (CSV with Headers)
    // ==============================
    function exportToExcel() {
        var csv = [];
        var rows = document.querySelectorAll("table#reportTable tr");
        
        if(rows.length === 0) {
            showToast("Error", "No data available for export");
            return;
        }
        
        // 1. Add Header Information (Company Name, Address, GST)
        var supplier = $("#supplier option:selected").text();
        var type = $("#type option:selected").text();
        var range = $("#fromDate").val() + " to " + $("#toDate").val();
        
        csv.push("REPORT HEADER"); 
        csv.push("Company Name:," + "<%=sessionOrgName%>");
        csv.push("Company Address:," + "<%=sessionOrgAddress%>");
        csv.push("Company GSTIN:," + "<%=sessionOrgGST%>");
        csv.push("");
        csv.push("FILTER DETAILS");
        csv.push("Supplier:," + supplier);
        csv.push("Type:," + type);
        csv.push("Date Range:," + range);
        csv.push(""); 
        
        // 2. Add Table Data
        for (var i = 0; i < rows.length; i++) {
            var row = [], cols = rows[i].querySelectorAll("td, th");
            // Iterate until the last column before Actions (Index 7)
            for (var j = 0; j < cols.length - 1; j++) {
                row.push('"' + cols[j].innerText + '"');
            }
            csv.push(row.join(","));
        }

        var csvFile = new Blob([csv.join("\n")], {type: "text/csv"});
        var downloadLink = document.createElement("a");
        downloadLink.download = "Report_" + new Date().toISOString().slice(0,10) + ".csv";
        downloadLink.href = window.URL.createObjectURL(csvFile);
        downloadLink.style.display = "none";
        document.body.appendChild(downloadLink);
        downloadLink.click();
    }
    </script>
</body>
</html>