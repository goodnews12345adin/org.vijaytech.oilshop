<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Purchase / Sales P&L Report</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Bootstrap -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- jQuery (NEEDED for $.ajax) -->
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <style>
      .loading { min-height: 80px; display:flex; align-items:center; justify-content:center; }
  </style>
</head>
<body class="bg-light">

<%@ include file="sidebar.jsp" %>

<div class="container py-4">
  <div class="row justify-content-center">
    <div class="col-lg-10">

      <!-- Filter Card -->
      <div class="card shadow-sm">
        <div class="card-body">
          <h5 class="card-title">Purchase & Sales — Product P&L</h5>

          <form id="reportForm" class="row g-3" onsubmit="loadReport(event)">

            <div class="col-md-3">
              <label class="form-label">From Date</label>
              <input type="date" class="form-control" id="fromDate" required>
            </div>

            <div class="col-md-3">
              <label class="form-label">To Date</label>
              <input type="date" class="form-control" id="toDate" required>
            </div>
							<div class="col-md-3">
								<label class="form-label">Product</label> <select
									class="form-select" id="product">
									<option value="">-- All Products --</option>
								</select>
							</div>

							<div class="col-md-3">
								<label class="form-label">Category</label> <select
									class="form-select" id="category">
									<option value="">-- All Categories --</option>
								</select>
							</div>


							<div class="col-md-3 d-flex align-items-end">
              <button class="btn btn-primary me-2" type="submit">Show</button>
              <button class="btn btn-outline-secondary" type="button" onclick="clearForm()">Clear</button>
            </div>

          </form>
        </div>
      </div>

      <!-- Output -->
      <div id="reportArea" class="mt-4"></div>

    </div>
  </div>
</div>

<script>

// Clear form
function clearForm(){
    document.getElementById("reportForm").reset();
    document.getElementById("reportArea").innerHTML = "";
}

// Load Report
function loadReport(event){
    event.preventDefault();

    const servletPath = "<%=request.getContextPath()%>/ProfitAndLossReport";

    let payload = {
        from: document.getElementById("fromDate").value,
        to: document.getElementById("toDate").value,
        org: document.getElementById("org").value || "",
        product: document.getElementById("product").value || "",
        category: document.getElementById("category").value || ""
    };

    document.getElementById("reportArea").innerHTML =
        "<div class='card'><div class='card-body loading'><div class='spinner-border'></div> Loading...</div></div>";

    console.log("Server URL:", servletPath);

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


// Render Table
function renderTable(response){

    var data = response.rows;
    var t = response.totals;

    if (!data || data.length === 0){
        document.getElementById("reportArea").innerHTML =
            "<div class='alert alert-warning'>No data available</div>";
        return;
    }

    let html = "";
    html += "<div class='card'><div class='card-body'>";
    html += "<h6>Report Results</h6>";
    html += "<div class='table-responsive'>";
    html += "<table class='table table-bordered table-striped table-sm'>";
    html += "<thead class='table-light'><tr>" +
            "<th>Product Code</th>" +
            "<th>Product Name</th>" +
            "<th class='text-end'>Sales Qty</th>" +
            "<th class='text-end'>Sales Amount</th>" +
            "<th class='text-end'>Purchase Qty</th>" +
            "<th class='text-end'>Purchase Amount</th>" +
            "<th class='text-end'>Profit</th>" +
            "</tr></thead><tbody>";

    // Rows
    data.forEach(function(row){
        html += "<tr>";
        html += "<td>" + safe(row.productCode) + "</td>";
        html += "<td>" + safe(row.productName) + "</td>";
        html += "<td class='text-end'>" + num(row.salesQty) + "</td>";
        html += "<td class='text-end'>" + format(row.salesAmount) + "</td>";
        html += "<td class='text-end'>" + num(row.purchaseQty) + "</td>";
        html += "<td class='text-end'>" + format(row.purchaseAmount) + "</td>";
        html += "<td class='text-end'>" + format(row.profit) + "</td>";
        html += "</tr>";
    });

    // Totals Row
    html += "<tr class='table-secondary fw-bold'>";
    html += "<td colspan='3'>TOTAL</td>";
    html += "<td class='text-end'>" + format(t.totalSalesAmount) + "</td>";
    html += "<td></td>";
    html += "<td class='text-end'>" + format(t.totalPurchaseAmount) + "</td>";
    html += "<td class='text-end'>" + format(t.totalProfit) + "</td>";
    html += "</tr>";

    html += "</tbody></table></div></div></div>";

    document.getElementById("reportArea").innerHTML = html;
}


// Helper Functions
function safe(v){ return v ? String(v) : ""; }
function num(v){ return v ? Number(v) : 0; }
function format(v){
    v = Number(v || 0);
    return v.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

</script>

</body>
</html>
