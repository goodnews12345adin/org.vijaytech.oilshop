<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Stock Report | Vijay Tech Orbit</title>

<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>

<!-- Icons -->
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- PDF Libraries (jsPDF & AutoTable) -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.29/jspdf.plugin.autotable.min.js"></script>

<style>
/* ✅ SAME UI AS PROFIT & LOSS */
:root {
  --header-height: 75px;
  --accent: #15a0c6;
  --bg-dark: #0a1220;
  --card-bg: #ffffff;
  --text-main: #1e293b;
  --border-light: #e2e8f0;
  --radius-lg: 20px;
  --radius-sm: 12px;
  --shadow-card: 0 20px 40px -5px rgba(0, 0, 0, 0.1);
}

body {
  font-family: 'Plus Jakarta Sans', sans-serif;
  background-color: var(--bg-dark);
  color: var(--text-main);
  margin: 0;
  padding-top: calc(var(--header-height) + 20px);
}

/* HEADER */
.app-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: var(--header-height);
  background: rgba(10,18,32,0.9);
  backdrop-filter: blur(12px);
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding: 0 40px;
  z-index: 5000;
}

.user-name {
  color: white;
  font-weight: 700;
}

/* MAIN CARD */
.page-wrap {
  padding: 20px 40px 80px 40px;
  max-width: 1600px;
  margin: auto;
}

.main-content-card {
  background: var(--card-bg);
  border-radius: var(--radius-lg);
  padding: 35px;
  box-shadow: var(--shadow-card);
}

.card-title {
  font-size: 24px;
  font-weight: 800;
  margin-bottom: 25px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

/* FORM */
.form-control, .form-select {
  height: 52px;
  border-radius: var(--radius-sm);
}

/* SUMMARY CARDS */
.dashboard-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
  margin-bottom: 25px;
}

.stat-card {
  padding: 20px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--border-light);
  background: #f8fafc;
}

.stat-card h6 {
  font-weight: 700;
  font-size: 13px;
  text-transform: uppercase;
  color: #64748b;
}

.stat-card h3 {
  font-weight: 900;
  font-size: 22px;
  margin-top: 8px;
}

/* TABLE */
.table-responsive {
  border-radius: var(--radius-sm);
  border: 1px solid var(--border-light);
  overflow: hidden;
}

thead th {
  background: #f1f5f9;
  font-weight: 800;
  text-transform: uppercase;
  font-size: 13px;
  border-bottom: 2px solid var(--border-light);
}

tfoot td {
  background: #f8fafc;
  font-weight: 800;
  border-top: 2px solid var(--border-light);
}

/* LOADER */
#global-loader {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.7);
  z-index: 9999;
  justify-content: center;
  align-items: center;
}

.loader-content {
  color: white;
  text-align: center;
}
</style>
</head>

<body>

<!-- HEADER -->
<header class="app-header">
  <span class="user-name">Guest User</span>
</header>

<!-- SIDEBAR -->
<%@ include file="sidebar.jsp" %>

<!-- LOADER -->
<div id="global-loader">
  <div class="loader-content">
    <div class="spinner-border text-info mb-3"></div>
    <h5 class="fw-bold">Loading Stock Report...</h5>
  </div>
</div>

<!-- MAIN -->
<div class="page-wrap">
  <div class="main-content-card">

    <div class="card-title">
      <span><i class="bi bi-box-seam"></i> Stock Ledger Report</span>
      <button class="btn btn-success btn-sm" onclick="downloadPDF()" id="btnPdf" style="display:none;">
        <i class="bi bi-file-earmark-pdf"></i> Download PDF
      </button>
    </div>

    <!-- FORM -->
    <form id="reportForm" class="row g-3" onsubmit="loadReport(event)">

      <div class="col-md-3">
        <label class="form-label fw-bold">From Date</label>
        <input type="date" id="fromDate" class="form-control" required>
      </div>

      <div class="col-md-3">
        <label class="form-label fw-bold">To Date</label>
        <input type="date" id="toDate" class="form-control" required>
      </div>

      <div class="col-lg-3 col-md-6 col-12">
        <label class="form-label fw-bold">Category</label>
        <select id="category" class="form-select">
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

      <div class="col-lg-2 col-md-6 col-12">
        <label class="form-label fw-bold">Product</label>
        <select id="product" class="form-select">
            <option value="">-- All Products --</option>
        </select>
      </div>

      <div class="col-md-2 d-flex align-items-end gap-2">
        <button type="submit" class="btn btn-primary w-100">Generate</button>
        <button type="button" class="btn btn-danger w-100" onclick="resetAll()">Reset</button>
      </div>

    </form>

    <!-- SUMMARY HEADER -->
    <div class="dashboard-stats" id="dashboardStats" style="display:none;">
      <div class="stat-card">
        <h6>Total In Qty</h6>
        <h3 id="totalIn">0.00</h3>
      </div>

      <div class="stat-card">
        <h6>Total Out Qty</h6>
        <h3 id="totalOut">0.00</h3>
      </div>

      <div class="stat-card">
        <h6>Net Balance</h6>
        <h3 id="totalBalance">0.00</h3>
      </div>
    </div>

    <!-- CHART -->
    <div class="chart-wrapper mb-4" style="height: 300px; display:none;" id="chartContainer">
      <canvas id="stockChart"></canvas>
    </div>

    <!-- TABLE -->
    <div class="table-responsive">
      <table class="table table-hover mb-0" id="stockTable">
        <thead>
          <tr>
            <th>Date</th>
            <th>Code</th>
            <th>Product Name</th>
            <th>UOM</th>
            <th class="text-end">In Qty</th>
            <th class="text-end">Out Qty</th>
            <th class="text-end">Balance</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td colspan="7" class="text-center text-muted py-4">
              Please select dates and click Generate
            </td>
          </tr>
        </tbody>
        <!-- FOOTER TOTALS -->
        <tfoot id="tableFooter" style="display:none;">
          <tr>
             <td colspan="4" class="text-end fw-bold">Totals:</td>
             <td class="text-end fw-bold" id="footIn">0.00</td>
             <td class="text-end fw-bold" id="footOut">0.00</td>
             <td class="text-end fw-bold" id="footBal">0.00</td>
          </tr>
        </tfoot>
      </table>
    </div>

  </div>
</div>

<script>
const servletUrl = "<%=request.getContextPath()%>/StockReport";

let tableData = [];
let chartInstance = null;

/* ✅ Load Report */
function loadReport(e){
  e.preventDefault();
  
  // Basic Validation
  if($("#fromDate").val() === "" || $("#toDate").val() === ""){
      alert("Please select both From and To dates.");
      return;
  }

  $("#global-loader").css("display","flex");
  $("#dashboardStats, #chartContainer, #tableFooter, #btnPdf").hide();

  $.ajax({
    url: servletUrl,
    method: "POST",
    data: {
      fromDate: $("#fromDate").val(),
      toDate: $("#toDate").val(),
      productcatId: $("#category").val(),
      productId: $("#product").val()
    },
    success: function(res){
      $("#global-loader").fadeOut(200);

      // Expecting FLAT array: [{date:..., code:..., inQty:..., outQty:...}, ...]
      tableData = res || [];
      
      if(tableData.length > 0){
          renderTable();
          calculateTotals();
          drawChart();
          $("#dashboardStats, #chartContainer, #tableFooter, #btnPdf").fadeIn();
      } else {
          $("#stockTable tbody").html("<tr><td colspan='7' class='text-center text-muted'>No Records Found</td></tr>");
      }
    },
    error: function(){
      $("#global-loader").fadeOut(200);
      alert("Error loading stock report");
    }
  });
}

/* ✅ Render Table (Date Based Ledger View) */
function renderTable() {
  let html = "";

  tableData.forEach(row => {
      // Using standard concatenation to avoid JSP EL errors
      let displayDate = row.date || row.transDate || "-";
      
      html += "<tr>";
      html += "<td>" + displayDate + "</td>";
      html += "<td>" + (row.productCode || row.code || "") + "</td>";
      html += "<td>" + (row.productName || row.name || "") + "</td>";
      html += "<td>" + (row.uom || "") + "</td>";
      html += "<td class='text-end'>" + Number(row.inQty || 0).toFixed(2) + "</td>";
      html += "<td class='text-end'>" + Number(row.outQty || 0).toFixed(2) + "</td>";
      // For individual transactions, Balance usually reflects the running balance. 
      // Here we show the net delta for simplicity, or 0 if complex.
      html += "<td class='text-end fw-bold'>" + Number((row.inQty || 0) - (row.outQty || 0)).toFixed(2) + "</td>";
      html += "</tr>";
  });

  $("#stockTable tbody").html(html);
}


/* ✅ Totals */
function calculateTotals() {
  let totalIn = 0;
  let totalOut = 0;
  let totalBalance = 0;

  tableData.forEach(row => {
    totalIn += Number(row.inQty || 0);
    totalOut += Number(row.outQty || 0);
  });
  
  totalBalance = totalIn - totalOut;

  // Update Dashboard Cards
  $("#totalIn").text(totalIn.toFixed(2));
  $("#totalOut").text(totalOut.toFixed(2));
  $("#totalBalance").text(totalBalance.toFixed(2));

  // Update Table Footer Totals
  $("#footIn").text(totalIn.toFixed(2));
  $("#footOut").text(totalOut.toFixed(2));
  $("#footBal").text(totalBalance.toFixed(2));
}


/* ✅ Chart (Daily In/Out) */
function drawChart() {

  if (chartInstance) {
    chartInstance.destroy();
  }

  // Group data by Date for the chart
  let dateGroups = {};
  
  tableData.forEach(row => {
      let d = row.date || row.transDate;
      if(!dateGroups[d]){
          dateGroups[d] = { in: 0, out: 0 };
      }
      dateGroups[d].in += Number(row.inQty || 0);
      dateGroups[d].out += Number(row.outQty || 0);
  });

  // Sort dates
  let sortedDates = Object.keys(dateGroups).sort();
  let inData = sortedDates.map(function(d) { return dateGroups[d].in; });
  let outData = sortedDates.map(function(d) { return dateGroups[d].out; });

  chartInstance = new Chart(document.getElementById("stockChart"), {
    type: "bar",
    data: {
      labels: sortedDates,
      datasets: [
        {
          label: "Stock In",
          data: inData,
          backgroundColor: '#15a0c6'
        },
        {
          label: "Stock Out",
          data: outData,
          backgroundColor: '#ef4444'
        }
      ]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
            y: { beginAtZero: true }
        }
    }
  });
}

/* ✅ ATTRACTIVE & TRENDING PDF FORMAT */
function downloadPDF() {
    var jsPDF = window.jspdf.jsPDF;
    var doc = new jsPDF('l', 'mm', 'a4');

    // ----------------------------------------------------
    // 1. MODERN HEADER SECTION
    // ----------------------------------------------------
    
    // Store Name (Brand Color Accent)
    doc.setFontSize(20);
    doc.setFont("helvetica", "bold");
    doc.setTextColor(21, 160, 198); // --accent color
    doc.text("THIRU SENTHILATHIPATHI OIL STORE", 14, 20);

    // Address (Professional Gray)
    doc.setFontSize(10);
    doc.setFont("helvetica", "normal");
    doc.setTextColor(80, 80, 80); 
    doc.text("No.42, Krishna Moorthi Bavanam, Madakulam Main Road,", 14, 27);
    doc.text("Palanganatham, Madurai – 625003", 14, 32);
    
    // GST (Smaller, lighter)
    doc.setFontSize(9);
    doc.setTextColor(120, 120, 120);
    doc.text("GST: 29ABCDE1234F1Z5", 14, 37);

    // Decorative Line Separator
    doc.setDrawColor(21, 160, 198); // Accent Color Line
    doc.setLineWidth(0.5);
    doc.line(14, 42, 287, 42); // Line across the width

    // Report Title (High Contrast)
    doc.setFontSize(16);
    doc.setFont("helvetica", "bold");
    doc.setTextColor(0, 0, 0);
    doc.text("Stock Ledger Report", 14, 52);

    // Date Range Info
    doc.setFontSize(10);
    doc.setFont("helvetica", "italic");
    doc.setTextColor(100, 100, 100);
    var dateRangeText = "Period: " + $("#fromDate").val() + "  to  " + $("#toDate").val();
    doc.text(dateRangeText, 14, 58);

    // ----------------------------------------------------
    // 2. MODERN TABLE DESIGN
    // ----------------------------------------------------
    
    doc.autoTable({
        html: '#stockTable',
        startY: 65,
        
        // Modern Striped Theme
        theme: 'striped', 
        
        // Header Styling (Dark Premium Blue)
        headStyles: { 
            fillColor: [10, 18, 32], // Dark Navy (--bg-dark)
            textColor: 255,
            fontStyle: 'bold',
            halign: 'center',
            fontSize: 10
        },
        
        // Body Styling
        styles: { 
            fontSize: 9, 
            cellPadding: 3,
            lineColor: [230, 230, 230], // Very light borders
            lineWidth: 0.1
        },
        
        // Alternating Row Colors (Subtle Tint)
        alternateRowStyles: {
            fillColor: [248, 250, 252] // Very light tint
        },

        // Column Specific Styles
        columnStyles: {
            0: { cellWidth: 32 }, // Date
            1: { cellWidth: 25 }, // Code
            2: { cellWidth: 'auto' }, // Product
            3: { cellWidth: 20 }, // UOM
            4: { cellWidth: 35, halign: 'right' }, // In
            5: { cellWidth: 35, halign: 'right' }, // Out
            6: { cellWidth: 35, halign: 'right', fontStyle: 'bold' }  // Bal
        },
        
        // Footer Styling (Highlight Totals)
        footStyles: { 
            fillColor: [21, 160, 198], // Brand Color
            textColor: 255, 
            fontStyle: 'bold',
            halign: 'right'
        }
    });

    // ----------------------------------------------------
    
    doc.save('Stock_Ledger_' + $("#toDate").val() + '.pdf');
}

/* ✅ Reset */
function resetAll(){
  document.getElementById("reportForm").reset();
  $("#stockTable tbody").html("<tr><td colspan='7' class='text-center text-muted py-4'>Please select dates and click Generate</td></tr>");
  
  $("#dashboardStats, #chartContainer, #tableFooter, #btnPdf").hide();
  
  $("#totalIn, #totalOut, #totalBalance").text("0.00");
  $("#footIn, #footOut, #footBal").text("0.00");

  if(chartInstance){
    chartInstance.destroy();
  }

  tableData = [];
}
</script>

</body>
</html>