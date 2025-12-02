<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Purchase / Sales Report</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
      .pdf-icon { cursor:pointer; color:red; font-size:20px; }
  </style>
</head>
<body class="bg-light">

<%@ include file="sidebar.jsp" %>

<div class="container py-4">
  <div class="row justify-content-center">
    <div class="col-lg-10">

      <div class="card shadow-sm">
        <div class="card-body">
          <h5 class="card-title">Purchase & Sales Report</h5>

          <!-- Report Form -->
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
              <label class="form-label">Type</label>
              <select class="form-select" id="type">
                <option value="sales">Sales</option>
                <option value="purchase">Purchase</option>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label">Org ID</label>
              <input type="number" class="form-control" id="org">
            </div>

            <div class="col-md-3">
              <label class="form-label">Summary</label>
              <select class="form-select" id="summary">
                <option value="N">Detail</option>
                <option value="Y">Summary</option>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label">BPartner ID</label>
              <input type="number" class="form-control" id="bp">
            </div>

            <div class="col-md-2">
              <label class="form-label">Page</label>
              <input type="number" class="form-control" id="page" value="1" min="1">
            </div>

            <div class="col-md-4 d-flex align-items-end">
              <button class="btn btn-primary me-2">Show</button>
            </div>

          </form>
        </div>
      </div>

      <div id="reportArea" class="mt-4"></div>

    </div>
  </div>
</div>

<script>
// -------------------------
// Load Report (JSON → Table)
// -------------------------
function loadReport(event){
    event.preventDefault();

    let json = {
        from: document.getElementById("fromDate").value,
        to:   document.getElementById("toDate").value,
        type: document.getElementById("type").value,
        org:  document.getElementById("org").value,
        bp:   document.getElementById("bp").value,
        summary: document.getElementById("summary").value,
        page: parseInt(document.getElementById("page").value)
    };

    document.getElementById("reportArea").innerHTML =
        "<div class='alert alert-info'>Loading...</div>";

    fetch("<%=request.getContextPath()%>/PrintPurchaseReportServlet", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(json)
    })
    .then(r => {
        if (!r.ok) {
            throw new Error("HTTP " + r.status);
        }
        return r.json();
    })
    .then(data => {
        console.log("Report JSON:", data);   // <--- see in browser dev tools
        renderTable(data, json.summary);
    })
    .catch(err => {
        console.error(err);
        document.getElementById("reportArea").innerHTML =
            "<div class='alert alert-danger'>Error loading report: " + err + "</div>";
    });
}

// -------------------------
// Normalize data → rows[]
// -------------------------
function getRowsArray(data){
    if (Array.isArray(data)) {
        return data;
    }
    if (data && Array.isArray(data.rows)) {
        return data.rows;
    }
    if (data && Array.isArray(data.list)) {
        return data.list;
    }
    return [];
}

// -------------------------
// Render HTML Table
// -------------------------
function renderTable(data, summaryMode){
    if (data && data.error){
        document.getElementById("reportArea").innerHTML =
            `<div class='alert alert-danger'>${data.error}</div>`;
        return;
    }

    const rows = getRowsArray(data);

    if (!rows || rows.length === 0){
        document.getElementById("reportArea").innerHTML =
            "<div class='alert alert-warning'>No records found for selected criteria.</div>";
        return;
    }

    let html = `
    <div class='card'><div class='card-body'>
    <div class='table-responsive'>
    <table class='table table-striped table-bordered table-md'>
    <thead>
      <tr>
        <th>Date</th>
        <th id="docHeader"></th>
        <th>BPartner</th>
        <th>Product</th>
        <th class='text-end'>Qty</th>
        <th class='text-end'>Price</th>
        <th class='text-end'>Amount</th>
        <th>PDF</th>
      </tr>
    </thead>
    <tbody>
    `;

    rows.forEach(row => {
        // support both camelCase & PascalCase JSON keys
        const date      = row.Date       || row.date       || "";
        const docNo     = row.DocumentNo || row.documentNo || row.DocNo || row.docNo || "";
        const bpName    = row.BPartner   || row.bpartner   || row.bpName || row.BPName || "";
        const product   = row.Product    || row.product    || "";
        const qty       = row.Qty        ?? row.qty        ?? "";
        const price     = row.Price      ?? row.price      ?? "";
        const amount    = row.Amount     ?? row.amount     ?? "";

        html += "<tr>";
        html += `<td>${date}</td>`;

        html += summaryMode === "N"
                ? `<td>${docNo}</td>`
                : `<td></td>`;

        html += `
            <td>${bpName}</td>
            <td>${product}</td>
            <td class='text-end'>${qty}</td>
            <td class='text-end'>${price}</td>
            <td class='text-end'>${amount}</td>
            <td><span class='pdf-icon' onclick="openPDF('${docNo}')">📄</span></td>
        `;
        html += "</tr>";
    });

    html += `
    </tbody></table>
    </div>
    </div></div>
    `;

    document.getElementById("reportArea").innerHTML = html;

    // Inject header name dynamically
    if (summaryMode === "N")
        document.getElementById("docHeader").innerHTML = "DocumentNo";
    else
        document.getElementById("docHeader").innerHTML = "";
}

// -------------------------
// PDF per row
// -------------------------
function openPDF(documentNo){
    if (!documentNo){
        alert("Document No missing");
        return;
    }

    window.open(
        "<%=request.getContextPath()%>/SingleInvoicePDF?docNo=" + encodeURIComponent(documentNo),
        "_blank"
    );
}

</script>

</body>
</html>
