<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Purchase / Sales Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        .pdf-icon { cursor: pointer; transition: all .2s ease; }
        .pdf-icon:hover { transform: scale(1.2); color: #b30000; }

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
						
						   <div class="col-md-4">
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
                            <label class="form-label">Summary</label>
                            <select class="form-select" id="summary">
                                <option value="N">Detail</option>
                                <option value="Y">Summary</option>
                            </select>
                        </div>

                     
<!-- 
                        <div class="col-md-2">
                            <label class="form-label">Page</label>
                            <input type="number" class="form-control" id="page" value="1" min="1">
                        </div> -->

                        <div class="col-md-6 d-flex align-items-end">
                            <button class="btn btn-primary me-2" type="submit">Show</button>

                            <button class="btn btn-outline-danger" type="button" onclick="downloadTablePdf()">
                                Download Table PDF
                            </button>
                        </div>

                    </form>
                </div>
            </div>

            <div id="reportArea" class="mt-4"></div>

        </div>
    </div>
</div>

<!-- jsPDF + AutoTable -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.28/jspdf.plugin.autotable.min.js"></script>

<script>
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
      /*   page: parseInt(document.getElementById("page").value || "1", 10) */
    };
}

// ==============================
//  LOAD REPORT
// ==============================
function loadReport(event){
    if (event) event.preventDefault();

    var json = buildRequestJson();

    document.getElementById("reportArea").innerHTML =
        "<div class='alert alert-info'>Loading...</div>";

    fetch("<%=request.getContextPath()%>/PrintPurchaseReportServlet", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(json)
    })
    .then(r => r.json())
    .then(data => renderTable(data, json.summary))
    .catch(err => {
        document.getElementById("reportArea").innerHTML =
            "<div class='alert alert-danger'>Error loading report</div>";
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

// ==============================
//  RETURN ARRAY OF ROWS
// ==============================
function getRowsArray(data){
    if (Array.isArray(data)) return data;
    return [];
}

// ==============================
//  RENDER TABLE
// ==============================
function renderTable(data, summaryMode){
    var rows = getRowsArray(data);

    if (!rows.length){
        document.getElementById("reportArea").innerHTML =
            "<div class='alert alert-warning'>No records found.</div>";
        return;
    }

    var docHeader = (summaryMode === "N") ? "DocumentNo" : "";
 /*    var currentPage = document.getElementById("page").value; */

    var html = "";
    html += "<div class='card'><div class='card-body'>";
    html += "<div class='table-responsive'>";
    html += "<table class='table table-striped table-bordered table-md' id='reportTable'>";
    html += "<thead style='border: black;border-radius: 4px;'><tr>";
    html += "<th>Date</th>";
    html += "<th>" + docHeader + "</th>";
    html += "<th>BPartner</th>";
    html += "<th>Product</th>";
    html += "<th class='text-end'>Qty</th>";
    html += "<th class='text-end'>Price</th>";
    html += "<th class='text-end'>Amount</th>";
    html += "<th>PDF</th>";
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

        // PDF icon (fixed)
        html += "<td><i class='bi bi-file-earmark-pdf-fill text-danger fs-4 pdf-icon' onclick=\"openPDF('" 
                + docNo + "')\"></i></td>";

        html += "</tr>";
    });

    html += "</tbody></table></div>";

    html += "<div class='d-flex justify-content-between mt-2'>";
   /*  html += "<div>Page " + currentPage + "</div>"; */
    html += "<div>";
    html += "<button class='btn btn-sm btn-outline-secondary me-2' onclick='goToPage(-1)'>Previous</button>";
    html += "<button class='btn btn-sm btn-outline-secondary' onclick='goToPage(1)'>Next</button>";
    html += "</div></div>";

    html += "</div></div>";

    document.getElementById("reportArea").innerHTML = html;
}

// ==============================
//  OPEN SINGLE INVOICE PDF
// ==============================
function openPDF(documentNo){
    if (!documentNo) return alert("Document missing");
    
    window.open(
        "<%=request.getContextPath()%>/SingleInvoicePDF?docNo=" 
        + encodeURIComponent(documentNo),
        "_blank"
    );
}

// ==============================
//  DOWNLOAD TABLE AS PDF
// ==============================
function downloadTablePdf(){
    var table = document.getElementById("reportTable");
    if (!table) return alert("No report data");

    const jsPDFObj = window.jspdf;
    var doc = new jsPDFObj.jsPDF();
    doc.text("Purchase & Sales Report", 14, 16);

    doc.autoTable({ html: '#reportTable', startY: 20, styles: { fontSize: 8 }});
    doc.save("report.pdf");
}
</script>

</body>
</html>