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
    body { font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial; }
    .loading { min-height: 80px; display:flex; align-items:center; justify-content:center; }
    /* Sticky header */
    .sticky-header th { position: sticky; top: 0; background: #f8f9fa; z-index: 11; }
    /* Sticky filter row below header */
    .filter-row th { position: sticky; top: 46px; background: #ffffff; z-index: 10; }
    /* Freeze first column */
    .table-responsive { overflow: auto; }
    .freeze-col td:first-child, .freeze-col th:first-child {
        position: sticky; left: 0; background: #fff; z-index: 12;
        box-shadow: 2px 0 4px rgba(0,0,0,0.05);
    }
    /* Sort arrow */
    .sort-arrow { font-size: 0.8em; margin-left: 6px; color: #666; }
    .table-small th, .table-small td { padding: 0.45rem 0.6rem; }
    .controls-row { gap: .5rem; }
    .export-buttons .btn { margin-right:.25rem; }
    .totals-row-dark { background: #343a40; color: #fff; }
    .text-nowrap { white-space: nowrap; }
  </style>
</head>
<body class="bg-light">

<%@ include file="sidebar.jsp" %>

<div class="container py-4">
  <div class="row mb-2">
    <div class="col-12">
      <h4>Purchase & Sales — Product P&L</h4>
    </div>
  </div>

  <!-- Filter Card -->
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
              List<Map<String, Object>> catList =
                (List<Map<String, Object>>) request.getAttribute("categoryList");
              if (catList != null) {
                  for (Map<String,Object> c : catList) {
            %>
            <option value="<%= c.get("id") %>"><%= c.get("name") %></option>
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
              List<Map<String, Object>> prodList =
                (List<Map<String, Object>>) request.getAttribute("productList");
              if (prodList != null) {
                  for (Map<String,Object> p : prodList) {
            %>
            <option value="<%= p.get("id") %>" data-category="<%= p.get("categoryId") %>"><%= p.get("name") %></option>
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

  <!-- Controls row -->
  <div class="row mb-2 align-items-center">
    <div class="col-md-4">
      <input id="tableSearch" class="form-control form-control-sm" placeholder="Global search (Product code / name)">
    </div>

    <div class="col-md-2">
      <select id="rowsPerPage" class="form-select form-select-sm">
        <option value="10">10 rows</option>
        <option value="25">25 rows</option>
        <option value="50">50 rows</option>
        <option value="0">Show All</option>
      </select>
    </div>

    <div class="col-md-6 text-md-end export-buttons">
      <button class="btn btn-success btn-sm" onclick="exportCSV()">Export CSV</button>
      <button class="btn btn-primary btn-sm" onclick="exportExcel()">Export Excel</button>
      <button class="btn btn-dark btn-sm" onclick="exportPDF()">Export PDF</button>
    </div>
  </div>

  <!-- Report area -->
  <div id="reportArea" class="mt-2"></div>

</div>

<script>
/* =======================
   GLOBAL STATE
   ======================= */
var tableData = [];        // all rows returned from server
var filteredData = [];     // filtered by search & column filters
var currentPage = 1;
var rowsPerPage = 10;
var responseTotals = {};   // grand totals from server
var sortColumn = null;
var sortDirection = 1; // 1 asc, -1 desc

/* =======================
   UTIL HELPERS
   ======================= */
function safe(v){ return v === null || v === undefined ? "" : String(v); }
function num(v){ return v === null || v === undefined ? 0 : Number(v); }
function format(v){
    v = Number(v || 0);
    return v.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

/* =======================
   RESET FORM
   ======================= */
function resetAll(){
    document.getElementById("reportForm").reset();
    document.getElementById("tableSearch").value = "";
    document.getElementById("rowsPerPage").value = "10";
    rowsPerPage = 10;
    tableData = [];
    filteredData = [];
    currentPage = 1;
    sortColumn = null;
    sortDirection = 1;
    responseTotals = {};
    document.getElementById("reportArea").innerHTML = "";
}

/* =======================
   CATEGORY -> PRODUCT DEPENDENT (client-side)
   ======================= */
document.getElementById("category").addEventListener("change", function(){
    var cat = this.value;
    var prodSelect = document.getElementById("product");
    // keep selected value if belongs to category; otherwise reset
    var prev = prodSelect.value;
    prodSelect.innerHTML = "<option value=''>-- All Products --</option>";
    var options = <% 
        // We will output productList as JSON literal for client use here to allow filtering easily
        org.json.JSONArray prodJson = (org.json.JSONArray) request.getAttribute("productJson"); // optional
        // If your servlet doesn't provide productJson, we will generate it from productList attribute
    %> [];
    // However easiest: read options originally rendered with data-category attributes
    Array.from(document.querySelectorAll("#product option")).forEach(function(opt){
        var catId = opt.getAttribute("data-category");
        if (!cat || cat === "") {
            // append all (skip the placeholder which we already have)
            if (opt.value) prodSelect.innerHTML += "<option value='" + opt.value + "' data-category='" + (catId||"") + "'>" + opt.text + "</option>";
        } else {
            if (catId === cat) {
                prodSelect.innerHTML += "<option value='" + opt.value + "' data-category='" + catId + "'>" + opt.text + "</option>";
            }
        }
    });
    // restore prev if still exists
    if (prev && document.querySelector("#product option[value='" + prev + "']")) {
        prodSelect.value = prev;
    } else {
        prodSelect.value = "";
    }
});

/* =======================
   LOAD REPORT (AJAX POST)
   ======================= */
function loadReport(event){
    event.preventDefault();

    const servletPath = "<%=request.getContextPath()%>/ProfitAndLossReport";

    let payload = {
        from: document.getElementById("fromDate").value,
        to: document.getElementById("toDate").value,
        product: document.getElementById("product").value || "",
        category: document.getElementById("category").value || ""
    };

    document.getElementById("reportArea").innerHTML =
        "<div class='card'><div class='card-body loading'><div class='spinner-border'></div> Loading...</div></div>";

    $.ajax({
        url: servletPath,
        type: "POST",
        data: JSON.stringify(payload),
        contentType: "application/json",
        success: function(data){
            renderTable(data);
        },
        error: function(xhr){
            console.error(xhr);
            document.getElementById("reportArea").innerHTML =
                "<div class='alert alert-danger'>Error loading report</div>";
        }
    });
}

/* =======================
   Render Table (entry)
   ======================= */
function renderTable(response){
    tableData = Array.isArray(response.rows) ? response.rows : [];
    filteredData = tableData.slice();
    responseTotals = response.totals || {};
    currentPage = 1;
    sortColumn = null; sortDirection = 1;
    // clear filter inputs if any
    generateTablePage();
}

/* =======================
   GLOBAL SEARCH / PAGE SIZE
   ======================= */
$("#tableSearch").on("keyup", function () {
    applyGlobalSearch();
});
$("#rowsPerPage").on("change", function () {
    rowsPerPage = parseInt(this.value);
    currentPage = 1;
    generateTablePage();
});

/* =======================
   GLOBAL SEARCH
   ======================= */
function applyGlobalSearch(){
    var q = (document.getElementById("tableSearch").value || "").toLowerCase().trim();

    filteredData = tableData.filter(function(r){
        var matchGlobal = !q || (String(r.productCode || "").toLowerCase().indexOf(q) !== -1)
            || (String(r.productName || "").toLowerCase().indexOf(q) !== -1);
        return matchGlobal;
    });

    // Apply column filters on top of global
    applyColumnFilters(true);
}

/* =======================
   COLUMN FILTERS
   ======================= */
function applyColumnFilters(useExistingFiltered){
    var base = useExistingFiltered ? filteredData.slice() : tableData.slice();

    var inputs = document.querySelectorAll(".filter-row input");
    if (!inputs || inputs.length === 0) {
        filteredData = base;
        currentPage = 1;
        generateTablePage();
        return;
    }

    filteredData = base.filter(function(row){
        var keep = true;
        inputs.forEach(function(inp){
            var col = inp.getAttribute("data-col");
            var v = (inp.value || "").toString().toLowerCase().trim();
            if (v !== "") {
                var cell = (row[col] === null || row[col] === undefined) ? "" : String(row[col]).toLowerCase();
                if (cell.indexOf(v) === -1) keep = false;
            }
        });
        return keep;
    });

    currentPage = 1;
    generateTablePage();
}

/* =======================
   SORTING
   ======================= */
function getSortArrow(column) {
    if (sortColumn !== column) return "<span class='sort-arrow'>▲▼</span>";
    return sortDirection === 1 ? "<span class='sort-arrow'>▲</span>" : "<span class='sort-arrow'>▼</span>";
}

function sortTable(column) {
    if (!column) return;
    if (sortColumn === column) sortDirection = -sortDirection;
    else { sortColumn = column; sortDirection = 1; }

    filteredData.sort(function(a,b){
        var x = a[column], y = b[column];
        var nx = Number(x), ny = Number(y);
        if (!isNaN(nx) && !isNaN(ny)) return (nx - ny) * sortDirection;
        x = (x===null||x===undefined) ? "" : String(x).toLowerCase();
        y = (y===null||y===undefined) ? "" : String(y).toLowerCase();
        if (x < y) return -1 * sortDirection;
        if (x > y) return 1 * sortDirection;
        return 0;
    });

    currentPage = 1;
    generateTablePage();
}

/* =======================
   PAGE TOTAL calculator
   ======================= */
function calculatePageTotals(pageData) {
    let totals = { salesAmount:0, purchaseAmount:0, profit:0 };
    pageData.forEach(r => {
        totals.salesAmount += Number(r.salesAmount || 0);
        totals.purchaseAmount += Number(r.purchaseAmount || 0);
        totals.profit += Number(r.profit || 0);
    });
    return totals;
}

/* =======================
   PAGINATION + TABLE BUILD
   ======================= */
function generateTablePage(){
    var data = filteredData || [];
    var totalRows = data.length;

    var start = rowsPerPage === 0 ? 0 : (currentPage - 1) * rowsPerPage;
    var end = rowsPerPage === 0 ? totalRows : start + rowsPerPage;
    var pageData = data.slice(start, end);

    var t = responseTotals || {};

    var html = "";
    html += "<div class='card'><div class='card-body'>";

    // summary + totals summary at top
    html += "<div class='d-flex justify-content-between align-items-center mb-2'>";
    html += "<div>Showing <strong>" + (totalRows === 0 ? 0 : (start + 1)) + "</strong> to <strong>" + (Math.min(end, totalRows)) + "</strong> of <strong>" + totalRows + "</strong> rows</div>";
    html += "<div class='text-nowrap'>Total Sales: <strong>" + format(t.totalSalesAmount || 0) + "</strong> &nbsp; Total Purchase: <strong>" + format(t.totalPurchaseAmount || 0) + "</strong> &nbsp; Profit: <strong>" + format(t.totalProfit || 0) + "</strong></div>";
    html += "</div>";

    html += "<div class='table-responsive'><table class='table table-bordered table-striped table-sm table-small freeze-col'>";

    // header + filter row
    html += "<thead class='table-light sticky-header'>";
    html += "<tr>";
    html += "<th onclick='sortTable(\"productCode\")' style='cursor:pointer'>Product Code " + getSortArrow("productCode") + "</th>";
    html += "<th onclick='sortTable(\"productName\")' style='cursor:pointer'>Product Name " + getSortArrow("productName") + "</th>";
    html += "<th class='text-end' onclick='sortTable(\"salesQty\")' style='cursor:pointer'>Sales Qty " + getSortArrow("salesQty") + "</th>";
    html += "<th class='text-end' onclick='sortTable(\"salesAmount\")' style='cursor:pointer'>Sales Amount " + getSortArrow("salesAmount") + "</th>";
    html += "<th class='text-end' onclick='sortTable(\"purchaseQty\")' style='cursor:pointer'>Purchase Qty " + getSortArrow("purchaseQty") + "</th>";
    html += "<th class='text-end' onclick='sortTable(\"purchaseAmount\")' style='cursor:pointer'>Purchase Amount " + getSortArrow("purchaseAmount") + "</th>";
    html += "<th class='text-end' onclick='sortTable(\"profit\")' style='cursor:pointer'>Profit " + getSortArrow("profit") + "</th>";
    html += "</tr>";

    // filter inputs row
    html += "<tr class='filter-row'>";
    html += "<th><input type='text' class='form-control form-control-sm' data-col='productCode' onkeyup='applyColumnFilters(true)'></th>";
    html += "<th><input type='text' class='form-control form-control-sm' data-col='productName' onkeyup='applyColumnFilters(true)'></th>";
    html += "<th><input type='text' class='form-control form-control-sm text-end' data-col='salesQty' onkeyup='applyColumnFilters(true)'></th>";
    html += "<th><input type='text' class='form-control form-control-sm text-end' data-col='salesAmount' onkeyup='applyColumnFilters(true)'></th>";
    html += "<th><input type='text' class='form-control form-control-sm text-end' data-col='purchaseQty' onkeyup='applyColumnFilters(true)'></th>";
    html += "<th><input type='text' class='form-control form-control-sm text-end' data-col='purchaseAmount' onkeyup='applyColumnFilters(true)'></th>";
    html += "<th><input type='text' class='form-control form-control-sm text-end' data-col='profit' onkeyup='applyColumnFilters(true)'></th>";
    html += "</tr>";

    html += "</thead><tbody>";

    // rows
    if (pageData.length === 0) {
        html += "<tr><td colspan='7' class='text-center py-4'>No data available</td></tr>";
    } else {
        pageData.forEach(function(r){
            html += "<tr>";
            html += "<td>" + safe(r.productCode) + "</td>";
            html += "<td>" + safe(r.productName) + "</td>";
            html += "<td class='text-end'>" + num(r.salesQty) + "</td>";
            html += "<td class='text-end'>" + format(r.salesAmount) + "</td>";
            html += "<td class='text-end'>" + num(r.purchaseQty) + "</td>";
            html += "<td class='text-end'>" + format(r.purchaseAmount) + "</td>";
            html += "<td class='text-end'>" + format(r.profit) + "</td>";
            html += "</tr>";
        });
    }

    // PAGE TOTALS
    var pt = calculatePageTotals(pageData);
    html += "<tr class='table-secondary fw-bold'>";
    html += "<td colspan='3'>PAGE TOTAL</td>";
    html += "<td class='text-end'>" + format(pt.salesAmount) + "</td>";
    html += "<td></td>";
    html += "<td class='text-end'>" + format(pt.purchaseAmount) + "</td>";
    html += "<td class='text-end'>" + format(pt.profit) + "</td>";
    html += "</tr>";

    // GRAND TOTAL (server)
    html += "<tr class='totals-row-dark fw-bold'>";
    html += "<td colspan='3'>GRAND TOTAL</td>";
    html += "<td class='text-end'>" + format(t.totalSalesAmount || 0) + "</td>";
    html += "<td></td>";
    html += "<td class='text-end'>" + format(t.totalPurchaseAmount || 0) + "</td>";
    html += "<td class='text-end'>" + format(t.totalProfit || 0) + "</td>";
    html += "</tr>";

    html += "</tbody></table></div>"; // close table

    // pagination bar
    if (rowsPerPage !== 0) {
        var totalPages = Math.ceil(totalRows / rowsPerPage) || 1;
        if (totalPages > 1) {
            html += "<nav><ul class='pagination justify-content-center mt-2'>";
            html += "<li class='page-item " + (currentPage <= 1 ? "disabled" : "") + "'><a class='page-link' href='javascript:void(0)' onclick='gotoPage(" + (currentPage - 1) + ")'>Prev</a></li>";
            var startPage = Math.max(1, currentPage - 3);
            var endPage = Math.min(totalPages, currentPage + 3);
            if (startPage > 1) html += "<li class='page-item'><span class='page-link'>...</span></li>";
            for (var p = startPage; p <= endPage; p++) {
                html += "<li class='page-item " + (p === currentPage ? "active" : "") + "'><a class='page-link' href='javascript:void(0)' onclick='gotoPage(" + p + ")'>" + p + "</a></li>";
            }
            if (endPage < totalPages) html += "<li class='page-item'><span class='page-link'>...</span></li>";
            html += "<li class='page-item " + (currentPage >= totalPages ? "disabled" : "") + "'><a class='page-link' href='javascript:void(0)' onclick='gotoPage(" + (currentPage + 1) + ")'>Next</a></li>";
            html += "</ul></nav>";
        }
    }

    html += "</div></div>";
    document.getElementById("reportArea").innerHTML = html;
}

/* goto page */
function gotoPage(page) {
    if (page < 1) page = 1;
    var totalRows = filteredData.length;
    var totalPages = rowsPerPage === 0 ? 1 : Math.ceil(totalRows / rowsPerPage) || 1;
    if (page > totalPages) page = totalPages;
    currentPage = page;
    generateTablePage();
}

/* =======================
   EXPORTS
   ======================= */
   function exportCSV() {
	    var rows = filteredData;
	    if (!rows || rows.length === 0) { alert("No data to export"); return; }

	    var csv = "Product Code,Product Name,Sales Qty,Sales Amount,Purchase Qty,Purchase Amount,Profit\n";

	    rows.forEach(function(r){
	        var line = [
	            '"' + safe(r.productCode).replace(/"/g,'""') + '"',
	            '"' + safe(r.productName).replace(/"/g,'""') + '"',
	            num(r.salesQty),
	            '"' + format(r.salesAmount) + '"',
	            num(r.purchaseQty),
	            '"' + format(r.purchaseAmount) + '"',
	            '"' + format(r.profit) + '"'
	        ].join(",");
	        csv += line + "\n";
	    });

	    // PAGE TOTAL
	    let pt = calculatePageTotals(rows);
	    csv += "\nPAGE TOTAL,,," + format(pt.salesAmount) + ",," + format(pt.purchaseAmount) + "," + format(pt.profit) + "\n";

	    // GRAND TOTAL
	    csv += "GRAND TOTAL,,," 
	          + format(responseTotals.totalSalesAmount) + ",,"
	          + format(responseTotals.totalPurchaseAmount) + ","
	          + format(responseTotals.totalProfit) + "\n";

	    var blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
	    var url = URL.createObjectURL(blob);
	    var a = document.createElement("a");
	    a.href = url;
	    a.download = "P&L_Report.csv";
	    document.body.appendChild(a);
	    a.click();
	    a.remove();
	}

   function exportExcel() {
	    var rows = filteredData;
	    if (!rows || rows.length === 0) { alert("No data to export"); return; }

	    var table = "<table border='1'><tr><th>Product Code</th><th>Product Name</th><th>Sales Qty</th><th>Sales Amount</th><th>Purchase Qty</th><th>Purchase Amount</th><th>Profit</th></tr>";

	    rows.forEach(function(r){
	        table += "<tr>";
	        table += "<td>" + safe(r.productCode) + "</td>";
	        table += "<td>" + safe(r.productName) + "</td>";
	        table += "<td>" + num(r.salesQty) + "</td>";
	        table += "<td>" + format(r.salesAmount) + "</td>";
	        table += "<td>" + num(r.purchaseQty) + "</td>";
	        table += "<td>" + format(r.purchaseAmount) + "</td>";
	        table += "<td>" + format(r.profit) + "</td>";
	        table += "</tr>";
	    });

	    // PAGE TOTAL
	   /*  let pt = calculatePageTotals(rows);
	    table += "<tr style='font-weight:bold;background:#f2f2f2;'>";
	    table += "<td colspan='3'>PAGE TOTAL</td>";
	    table += "<td>" + format(pt.salesAmount) + "</td>";
	    table += "<td></td>";
	    table += "<td>" + format(pt.purchaseAmount) + "</td>";
	    table += "<td>" + format(pt.profit) + "</td>";
	    table += "</tr>"; */

	    // GRAND TOTAL
	    table += "<tr style='font-weight:bold;background:#d1d1d1;'>";
	    table += "<td colspan='3'>GRAND TOTAL</td>";
	    table += "<td>" + format(responseTotals.totalSalesAmount) + "</td>";
	    table += "<td></td>";
	    table += "<td>" + format(responseTotals.totalPurchaseAmount) + "</td>";
	    table += "<td>" + format(responseTotals.totalProfit) + "</td>";
	    table += "</tr>";

	    table += "</table>";

	    var blob = new Blob([table], { type: "application/vnd.ms-excel" });
	    var url = URL.createObjectURL(blob);
	    var a = document.createElement("a");
	    a.href = url;
	    a.download = "P&L_Report.xls";
	    document.body.appendChild(a);
	    a.click();
	    a.remove();
	}


   function exportPDF() {
	    var rows = filteredData;
	    if (!rows || rows.length === 0) { alert("No data to export"); return; }

	    var html = "<html><head><title>P&L Report</title>";
	    html += "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css' rel='stylesheet'>";
	    html += "<style>table{width:100%;border-collapse:collapse}th,td{border:1px solid #777;padding:6px;font-size:12px}th{background:#f1f1f1}</style>";
	    html += "</head><body>";
	    html += "<h5>P&L Report</h5>";
	    html += "<table><thead><tr><th>Product Code</th><th>Product Name</th><th>Sales Qty</th><th>Sales Amount</th><th>Purchase Qty</th><th>Purchase Amount</th><th>Profit</th></tr></thead><tbody>";

	    rows.forEach(function(r){
	        html += "<tr>";
	        html += "<td>" + safe(r.productCode) + "</td>";
	        html += "<td>" + safe(r.productName) + "</td>";
	        html += "<td style='text-align:right'>" + num(r.salesQty) + "</td>";
	        html += "<td style='text-align:right'>" + format(r.salesAmount) + "</td>";
	        html += "<td style='text-align:right'>" + num(r.purchaseQty) + "</td>";
	        html += "<td style='text-align:right'>" + format(r.purchaseAmount) + "</td>";
	        html += "<td style='text-align:right'>" + format(r.profit) + "</td>";
	        html += "</tr>";
	    });

	    // PAGE TOTAL
	   /*  let pt = calculatePageTotals(rows);
	    html += "<tr style='font-weight:bold;background:#f2f2f2'>";
	    html += "<td colspan='3'>PAGE TOTAL</td>";
	    html += "<td style='text-align:right'>" + format(pt.salesAmount) + "</td>";
	    html += "<td></td>";
	    html += "<td style='text-align:right'>" + format(pt.purchaseAmount) + "</td>";
	    html += "<td style='text-align:right'>" + format(pt.profit) + "</td>";
	    html += "</tr>"; */

	    // GRAND TOTAL
	    html += "<tr style='font-weight:bold;background:#d1d1d1'>";
	    html += "<td colspan='3'>GRAND TOTAL</td>";
	    html += "<td style='text-align:right'>" + format(responseTotals.totalSalesAmount) + "</td>";
	    html += "<td></td>";
	    html += "<td style='text-align:right'>" + format(responseTotals.totalPurchaseAmount) + "</td>";
	    html += "<td style='text-align:right'>" + format(responseTotals.totalProfit) + "</td>";
	    html += "</tr>";

	    html += "</tbody></table></body></html>";

	    var w = window.open('', '_blank');
	    w.document.write(html);
	    w.document.close();
	    setTimeout(()=> w.print(), 500);
	}


</script>

</body>
</html>