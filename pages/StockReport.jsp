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
  margin: 25px 0;
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

    <h5 class="card-title">
      <i class="bi bi-box-seam"></i> Stock Ledger Report
    </h5>

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
                <div class="invalid-feedback">Product selection is required.</div>
                <div class="col-md-2 d-flex align-items-end gap-2">
        <button type="submit" class="btn btn-primary w-100">Generate</button>
        <button type="button" class="btn btn-danger w-100" onclick="resetAll()">Reset</button>
      </div>

    </form>

    <!-- SUMMARY -->
    <div class="dashboard-stats">
      <div class="stat-card">
        <h6>Total In Qty</h6>
        <h3 id="totalIn">0.00</h3>
      </div>

      <div class="stat-card">
        <h6>Total Out Qty</h6>
        <h3 id="totalOut">0.00</h3>
      </div>

      <div class="stat-card">
        <h6>Closing Balance</h6>
        <h3 id="totalBalance">0.00</h3>
      </div>
    </div>

    <!-- CHART -->
    <div class="chart-wrapper mb-4">
      <canvas id="stockChart" height="120"></canvas>
    </div>

    <!-- TABLE -->
    <div class="table-responsive">
      <table class="table table-hover mb-0" id="stockTable">
        <thead>
          <tr>
            <th>Date</th>
            <th>Code</th>
            <th>Product</th>
            <th>UOM</th>
            <th class="text-end">In Qty</th>
            <th class="text-end">Out Qty</th>
            <th class="text-end">Balance Qty</th>
          </tr>
        </thead>
        <tbody></tbody>
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
  let productID = $("#product").val();

  // Validation removed to allow "All Products" (empty productID) selection
  // if(productID === ""){
  //     alert("Please select a Product!");
  //     $("#product").focus();
  //     return;
  // }

  $("#global-loader").css("display","flex");

  $.ajax({
    url: servletUrl,
    method: "POST",
    data: {
      fromDate: $("#fromDate").val(),
      toDate: $("#toDate").val(),
      productcatId: $("#category").val()
    },
    success: function(res){

      $("#global-loader").fadeOut(200);

      tableData = res || [];
      renderTable();
      calculateTotals();
      drawChart();
    },
    error: function(){
      $("#global-loader").fadeOut(200);
      alert("Error loading stock report");
    }
  });
}

/* ✅ Render Table */
function renderTable() {

  if (!tableData || tableData.length === 0) {
    $("#stockTable tbody").html(
      "<tr><td colspan='7' class='text-center text-muted'>No Records Found</td></tr>"
    );
    return;
  }

  let html = "";

  /* ✅ Loop Each Category */
  tableData.forEach(category => {

    /* ✅ Category Header Row */
   html += "<tr class='table-primary fw-bold'>";
html += "<td colspan='4'>📂 " + category.categoryName + "</td>";
html += "<td class='text-end'>" + Number(category.totalIn).toFixed(2) + "</td>";
html += "<td class='text-end'>" + Number(category.totalOut).toFixed(2) + "</td>";
html += "<td class='text-end'>" + Number(category.totalBalance).toFixed(2) + "</td>";
html += "</tr>";


    /* ✅ Products Under Category */
    category.products.forEach(row => {

      html += "<tr>";
      html += "<td>-</td>";   // Date not needed for grouped report
      html += "<td>" + row.productCode + "</td>";
      html += "<td>" + row.productName + "</td>";
      html += "<td>" + row.uom + "</td>";
      html += "<td class='text-end'>" + Number(row.inQty).toFixed(2) + "</td>";
      html += "<td class='text-end'>" + Number(row.outQty).toFixed(2) + "</td>";
      html += "<td class='text-end fw-bold'>" + Number(row.balanceQty).toFixed(2) + "</td>";
      html += "</tr>";

    });

  });

  $("#stockTable tbody").html(html);
}


/* ✅ Totals */
function calculateTotals() {

  let totalIn = 0;
  let totalOut = 0;
  let totalBalance = 0;
  let productCount = 0;

  tableData.forEach(category => {

    totalIn += Number(category.totalIn);
    totalOut += Number(category.totalOut);
    totalBalance += Number(category.totalBalance);

    productCount += category.products.length;
  });

  $("#totalIn").text(totalIn.toFixed(2));
  $("#totalOut").text(totalOut.toFixed(2));
  $("#totalBalance").text(totalBalance.toFixed(2));

  /* ✅ Optional Product Count Card */
  if ($("#totalProducts").length) {
    $("#totalProducts").text(productCount);
  }
}


/* ✅ Chart */
function drawChart() {

  if (chartInstance) {
    chartInstance.destroy();
  }

  let labels = tableData.map(c => c.categoryName);
  let balances = tableData.map(c => c.totalBalance);

  chartInstance = new Chart(document.getElementById("stockChart"), {
    type: "bar",
    data: {
      labels: labels,
      datasets: [
        {
          label: "Category Closing Balance",
          data: balances
        }
      ]
    }
  });
}


/* ✅ Reset */
function resetAll(){

  document.getElementById("reportForm").reset();
  $("#stockTable tbody").html("");
  $("#totalIn").text("0.00");
  $("#totalOut").text("0.00");
  $("#totalBalance").text("0.00");

  if(chartInstance){
    chartInstance.destroy();
  }

  tableData = [];
}
</script>

</body>
</html>