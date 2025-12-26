<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Purchase / Sales P&L Report</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Bootstrap -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <style>
    body { font-family: system-ui, -apple-system, "Segoe UI", Roboto, Arial; }
    .loading { min-height: 80px; display:flex; align-items:center; justify-content:center; }

    .sticky-header th { position: sticky; top: 0; background: #f8f9fa; z-index: 11; }
    .filter-row th { position: sticky; top: 46px; background: #ffffff; z-index: 10; }

    .table-responsive { overflow: auto; }
    .freeze-col td:first-child, .freeze-col th:first-child {
        position: sticky; left: 0; background: #fff; z-index: 12;
        box-shadow: 2px 0 4px rgba(0,0,0,0.05);
    }

    .sort-arrow { font-size: 0.8em; margin-left: 6px; color: #666; }
    .table-small th, .table-small td { padding: 0.45rem 0.6rem; }

    .totals-row-dark { background: #343a40; color: #fff; }

    /* NEGATIVE BALANCE */
    .negative-row {
        background-color: #fdecea !important;
        color: #a71d2a;
        font-weight: 600;
    }
  </style>
</head>

<body class="bg-light">
<%@ include file="sidebar.jsp" %>

<div class="container py-4">

  <h4 class="mb-3">Purchase & Sales — Product P&L</h4>

  <!-- FILTERS -->
  <div class="card mb-3">
    <div class="card-body">
      <form id="reportForm" class="row g-3 align-items-end" onsubmit="loadReport(event)">
        <div class="col-md-3">
          <label class="form-label">From Date</label>
          <input type="date" class="form-control form-control-sm" id="fromDate" required>
        </div>

        <div class="col-md-3">
          <label class="form-label">To Date</label>
          <input type="date" class="form-control form-control-sm" id="toDate" required>
        </div>

        <div class="col-md-3">
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

        <div class="col-md-3">
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

        <div class="col-md-3 d-flex">
          <button class="btn btn-primary btn-sm me-2" type="submit">Show</button>
          <button class="btn btn-outline-secondary btn-sm" type="button" onclick="resetAll()">Clear</button>
        </div>
      </form>
    </div>
  </div>

  <!-- EXPORT BUTTONS -->
  <div class="d-flex justify-content-end mb-2">
    <button class="btn btn-success btn-sm me-1" onclick="exportFile('csv')">Export CSV</button>
    <button class="btn btn-primary btn-sm me-1" onclick="exportFile('excel')">Export Excel</button>
    <button class="btn btn-dark btn-sm" onclick="exportFile('pdf')">Export PDF</button>
  </div>

  <!-- REPORT -->
  <div id="reportArea"></div>
</div>

<script>
const servletUrl = "<%=request.getContextPath()%>/ProfitAndLossReport";

let tableData = [];
let responseTotals = {};

/* ---------- helpers ---------- */
function num(v){ return Number(v || 0); }
function fmt(v){ return num(v).toLocaleString("en-US",{minimumFractionDigits:2}); }

/* ---------- build payload ---------- */
function buildPayload(){
  return {
    from: document.getElementById("fromDate").value,
    to: document.getElementById("toDate").value,
    category: document.getElementById("category").value || "",
    product: document.getElementById("product").value || ""
  };
}

/* ---------- load report ---------- */
function loadReport(e){
  e.preventDefault();

  $("#reportArea").html(
    "<div class='card'><div class='card-body loading'>" +
    "<div class='spinner-border'></div>&nbsp;Loading...</div></div>"
  );

  $.ajax({
    url: servletUrl,
    method: "POST",
    data: JSON.stringify(buildPayload()),
    contentType: "application/json",
    success: function(res){
      tableData = res.rows || [];
      responseTotals = res.totals || {};
      renderTable();
    },
    error: function(){
      $("#reportArea").html("<div class='alert alert-danger'>Error loading report</div>");
    }
  });
}

/* ---------- render table ---------- */
function renderTable(){

  let html = "<div class='card'><div class='card-body'>";
  html += "<div class='mb-2 text-end fw-bold'>" +
          "Sales: " + fmt(responseTotals.totalSalesAmount) +
          " | Purchase: " + fmt(responseTotals.totalPurchaseAmount) +
          " | Profit: " + fmt(responseTotals.totalProfit) +
          "</div>";

  html += "<div class='table-responsive'><table class='table table-bordered table-sm freeze-col'>";
  html += "<thead class='table-light'><tr>";
  html += "<th>Product Code</th><th>Product Name</th>";
  html += "<th class='text-end'>Sales Qty</th><th class='text-end'>Sales Amount</th>";
  html += "<th class='text-end'>Purchase Qty</th><th class='text-end'>Purchase Amount</th>";
  html += "<th class='text-end'>Balance Qty</th><th class='text-end'>Profit</th>";
  html += "</tr></thead><tbody>";

  if (tableData.length === 0) {
    html += "<tr><td colspan='8' class='text-center'>No data</td></tr>";
  } else {
    tableData.forEach(r => {
      let cls = r.negativeBalance ? "negative-row" : "";
      html += "<tr class='"+cls+"'>";
      html += "<td>"+(r.productCode||"")+"</td>";
      html += "<td>"+(r.productName||"")+"</td>";
      html += "<td class='text-end'>"+num(r.salesQty)+"</td>";
      html += "<td class='text-end'>"+fmt(r.salesAmount)+"</td>";
      html += "<td class='text-end'>"+num(r.purchaseQty)+"</td>";
      html += "<td class='text-end'>"+fmt(r.purchaseAmount)+"</td>";
      html += "<td class='text-end'>"+num(r.balanceQty)+"</td>";
      html += "<td class='text-end'>"+fmt(r.profit)+"</td>";
      html += "</tr>";
    });
  }

  html += "</tbody></table></div></div></div>";
  $("#reportArea").html(html);
}

/* ---------- exports (SERVLET BASED) ---------- */
function exportFile(type){
  let p = buildPayload();
  if (!p.from || !p.to) {
    alert("Select date range first");
    return;
  }

  fetch(servletUrl + "?export=" + type, {
    method: "POST",
    headers: { "Content-Type":"application/json" },
    body: JSON.stringify(p)
  })
  .then(r => r.blob())
  .then(b => {
    const url = URL.createObjectURL(b);
    const a = document.createElement("a");
    a.href = url;
    a.download = "PNL_Report." + (type==="excel"?"xlsx":type);
    document.body.appendChild(a);
    a.click();
    a.remove();
  });
}

/* ---------- reset ---------- */
function resetAll(){
  document.getElementById("reportForm").reset();
  $("#reportArea").html("");
}
</script>
</body>
</html>
