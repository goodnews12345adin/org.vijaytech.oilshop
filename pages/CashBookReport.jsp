<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    List<Map<String,Object>> bankList = (List<Map<String,Object>>) request.getAttribute("bankList");
    List<Map<String,Object>> bpList   = (List<Map<String,Object>>) request.getAttribute("bpList");

    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
    String today = df.format(new Date());
%>

<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title>Cash Book Report</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet"/>

<style>
body { background:#f3f7fb; font-family:Inter,Arial; }
.card-box {
    margin-top:30px; padding:20px; background:#fff;
    border-radius:10px; box-shadow:0 6px 20px rgba(0,0,0,0.08);
}
table th { background:#f8f9fa; }
#loader { display:none; font-weight:bold; color:#0a58ca; }
.pagination { margin-bottom:0; }
tfoot td { background:#f1f3f5; }
</style>
</head>

<body>
<%@ include file="sidebar.jsp" %>

<div class="container">
<div class="card-box">

<h4 class="mb-3">Cash Book Report</h4>

<form id="filterForm" method="post">

    <input type="hidden" name="action" id="action" value="search"/>

    <div class="row g-3">
        <div class="col-md-4">
            <label>Bank / Cash</label>
            <select name="bank_id" class="form-select select2" required>
                <option value="">-- Select Bank --</option>
                <% for(Map<String,Object> b : bankList){ %>
                    <option value="<%=b.get("id")%>"><%=b.get("name")%></option>
                <% } %>
            </select>
        </div>

        <div class="col-md-4">
            <label>Business Partner</label>
            <select name="bp_id" class="form-select select2">
                <option value="">-- All --</option>
                <% for(Map<String,Object> p : bpList){ %>
                    <option value="<%=p.get("id")%>"><%=p.get("name")%></option>
                <% } %>
            </select>
        </div>
    </div>

    <div class="row g-3 mt-2">
        <div class="col-md-4">
            <label>From Date</label>
            <input type="date" name="from_date" class="form-control" value="<%=today%>"/>
        </div>
        <div class="col-md-4">
            <label>To Date</label>
            <input type="date" name="to_date" class="form-control" value="<%=today%>"/>
        </div>

        <div class="col-md-2 d-flex align-items-end">
            <button type="button" id="btnSearch" class="btn btn-primary w-100">Search</button>
        </div>

        <div class="col-md-2 d-flex align-items-end">
            <button type="button" id="btnPdf" class="btn btn-danger w-100">PDF</button>
        </div>
    </div>
</form>

<div id="loader" class="mt-3">Loading...</div>

<hr/>

<div class="table-responsive">
<table class="table table-bordered table-sm">
<thead>
<tr>
    <th>Date</th>
    <th>Document No</th>
    <th>BP Name</th>
    <th>Account Head</th>
    <th>Description</th>
    <th class="text-end">Receipt</th>
    <th class="text-end">Payment</th>
    <th class="text-end">Balance</th>
</tr>
</thead>

<tbody id="resultBody">
<tr><td colspan="8" class="text-center text-muted">No data</td></tr>
</tbody>

<tfoot>
<tr class="fw-bold">
    <td colspan="5" class="text-end">TOTAL</td>
    <td class="text-end" id="totalReceipt">0.00</td>
    <td class="text-end" id="totalPayment">0.00</td>
    <td class="text-end" id="totalBalance">0.00</td>
</tr>
</tfoot>
</table>
</div>

<!-- Pagination -->
<div class="d-flex justify-content-between align-items-center mt-2">
    <div id="pageInfo" class="text-muted"></div>
    <nav>
        <ul class="pagination pagination-sm mb-0" id="pagination"></ul>
    </nav>
</div>

</div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
let cashData = [];
let pageSize = 20;
let currentPage = 1;

$(function(){

    $('.select2').select2({ width:'100%' });

    $("#btnSearch").click(function(){

        $("#action").val("search");
        $("#loader").show();

        $.ajax({
            url: "<%=request.getContextPath()%>/CashBookReport",
            type: "POST",
            data: $("#filterForm").serialize(),
            dataType: "json",
            success: function(data){

                $("#loader").hide();

                if (!data || data.length === 0) {
                    $("#resultBody").html("<tr><td colspan='8' class='text-center'>No records</td></tr>");
                    $("#pagination").html("");
                    $("#pageInfo").html("");
                    $("#totalReceipt,#totalPayment,#totalBalance").text("0.00");
                    return;
                }

                cashData = data;
                currentPage = 1;
                renderPage();
                renderPagination();
                calculateTotals();
            },
            error:function(){
                $("#loader").hide();
                alert("Error loading data");
            }
        });
    });

    $("#btnPdf").click(function () {
        $("#action").val("pdf");

        $("#filterForm")
            .attr("action", "<%=request.getContextPath()%>/CashBookReport")
            .attr("method", "post")
            .attr("target", "_blank")[0]
            .submit();

        // IMPORTANT: reset target back (so Search stays normal)
        $("#filterForm").removeAttr("target");
    });

});

function renderPage() {

    let start = (currentPage - 1) * pageSize;
    let end   = start + pageSize;
    let pageData = cashData.slice(start, end);

    let html = "";
    for (let i = 0; i < pageData.length; i++) {
        let r = pageData[i];
        html += "<tr>"
            + "<td>"+r.datetrx+"</td>"
            + "<td>"+r.documentno+"</td>"
            + "<td>"+(r.bpname||"")+"</td>"
            + "<td>"+(r.accounthead||"")+"</td>"
            + "<td>"+(r.description||"")+"</td>"
            + "<td class='text-end'>"+r.receipt+"</td>"
            + "<td class='text-end'>"+r.payment+"</td>"
            + "<td class='text-end fw-bold'>"+r.balance+"</td>"
            + "</tr>";
    }

    $("#resultBody").html(html);
    $("#pageInfo").html(
        "Showing " + (start+1) + " to " + Math.min(end, cashData.length)
        + " of " + cashData.length + " entries"
    );
}

function renderPagination() {

    let totalPages = Math.ceil(cashData.length / pageSize);
    let html = "";

    html += '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="gotoPage('+(currentPage-1)+')">Prev</a></li>';

    for (let i = 1; i <= totalPages; i++) {
        html += '<li class="page-item ' + (i === currentPage ? 'active' : '') + '">' +
                '<a class="page-link" href="#" onclick="gotoPage('+i+')">'+i+'</a></li>';
    }

    html += '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="gotoPage('+(currentPage+1)+')">Next</a></li>';

    document.getElementById("pagination").innerHTML = html;
}

function gotoPage(page) {
    let totalPages = Math.ceil(cashData.length / pageSize);
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    renderPage();
    renderPagination();
}

function calculateTotals() {

    let totalReceipt = 0;
    let totalPayment = 0;
    let closingBalance = 0;

    for (let i = 0; i < cashData.length; i++) {
        totalReceipt += parseFloat(cashData[i].receipt || 0);
        totalPayment += parseFloat(cashData[i].payment || 0);
        closingBalance = parseFloat(cashData[i].balance || 0);
    }

    $("#totalReceipt").text(totalReceipt.toFixed(2));
    $("#totalPayment").text(totalPayment.toFixed(2));
    $("#totalBalance").text(closingBalance.toFixed(2));
}
</script>

</body>
</html>