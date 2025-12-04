<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Purchase / Sales Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .pdf-icon { cursor: pointer; font-size: 20px; }

        /* Make sure table text is visible */
        table.table tbody td {
            color: #000 !important;
            font-size: 0.9rem !important;
        }
    </style>
</head>
<body class="bg-light">

<%@ include file="sidebar.jsp" %>

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-10">

            <div class="card shadow-sm">
                <div class="card-body">
                    <h5 class="card-title">Purchase &amp; Sales Report</h5>

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
                            <button class="btn btn-primary me-2" type="submit">Show</button>
                        </div>

                    </form>
                </div>
            </div>

            <div id="reportArea" class="mt-4"></div>

        </div>
    </div>
</div>

<script>
// ==============================
//  LOAD REPORT (fetch → JSON)
// ==============================
function loadReport(event){
    event.preventDefault();

    var json = {
        from: document.getElementById("fromDate").value,
        to:   document.getElementById("toDate").value,
        type: document.getElementById("type").value,
        org:  document.getElementById("org").value,
        bp:   document.getElementById("bp").value,
        summary: document.getElementById("summary").value,
        page: parseInt(document.getElementById("page").value || "1", 10)
    };

    document.getElementById("reportArea").innerHTML =
        "<div class='alert alert-info'>Loading...</div>";

    fetch("<%=request.getContextPath()%>/PrintPurchaseReportServlet", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(json)
    })
    .then(function (r) {
        if (!r.ok) {
            throw new Error("HTTP " + r.status);
        }
        return r.json();
    })
    .then(function (data) {
        console.log("Report JSON:", data);       // should log Array(132)
        renderTable(data, json.summary);
    })
    .catch(function (err) {
        console.error(err);
        document.getElementById("reportArea").innerHTML =
            "<div class='alert alert-danger'>Error loading report: " + err + "</div>";
    });
}

// ==============================
//  GET ROWS ARRAY
//  (your case: data is already [])
// ==============================
function getRowsArray(data){
    if (Array.isArray(data)) return data;
    if (data && Array.isArray(data.rows)) return data.rows;
    if (data && Array.isArray(data.list)) return data.list;
    if (data && Array.isArray(data.data)) return data.data;
    return [];
}

// ==============================
//  RENDER TABLE
// ==============================
function renderTable(data, summaryMode){
    var rows = getRowsArray(data);
    console.log("Rows to render:", rows.length);

    if (!rows || rows.length === 0){
        document.getElementById("reportArea").innerHTML =
            "<div class='alert alert-warning'>No records found for selected criteria.</div>";
        return;
    }

    var docHeader = (summaryMode === "N") ? "DocumentNo" : "";

    var html = "";
    html += "<div class='card'><div class='card-body'>";
    html += "<div class='table-responsive'>";
    html += "<table class='table table-striped table-bordered table-md'>";
    html += "<thead><tr>";
    html += "<th>Date</th>";
    html += "<th>" + docHeader + "</th>";
    html += "<th>BPartner</th>";
    html += "<th>Product</th>";
    html += "<th class='text-end'>Qty</th>";
    html += "<th class='text-end'>Price</th>";
    html += "<th class='text-end'>Amount</th>";
    html += "<th>PDF</th>";
    html += "</tr></thead><tbody>";

    rows.forEach(function (row, index) {
        // exactly your JSON property names:
        var date    = row.Date       || "";
        var docNo   = row.DocumentNo || "";
        var bpName  = row.BPartner   || "";
        var product = row.Product    || "";
        var qty     = row.Qty        || "";
        var price   = row.Price      || "";
        var amount  = row.Amount     || "";

        console.log("Row", index, row);   // you can see each row in console

        html += "<tr>";
        html += "<td>" + date + "</td>";
        if (summaryMode === "N") {
            html += "<td>" + docNo + "</td>";
        } else {
            html += "<td></td>";
        }
        html += "<td>" + bpName   + "</td>";
        html += "<td>" + product  + "</td>";
        html += "<td class='text-end'>" + qty    + "</td>";
        html += "<td class='text-end'>" + price  + "</td>";
        html += "<td class='text-end'>" + amount + "</td>";
        html += "<td><span class='pdf-icon' onclick=\"openPDF('" + encodeURIComponent(docNo) + "')\">📄</span></td>";
        html += "</tr>";
    });

    html += "</tbody></table></div></div></div>";

    console.log("Generated HTML:", html); // you can check if text is inside cells

    document.getElementById("reportArea").innerHTML = html;
}

// ==============================
//  OPEN SINGLE INVOICE PDF
// ==============================
function openPDF(documentNo){
    if (!documentNo){
        alert("Document No missing");
        return;
    }

    window.open(
        "<%=request.getContextPath()%>/SingleInvoicePDF?docNo=" + documentNo,
        "_blank"
    );
}
</script>

</body>
</html>
