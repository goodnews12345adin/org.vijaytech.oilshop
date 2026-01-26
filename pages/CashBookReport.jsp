<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    List<Map<String,Object>> bankList =
        (List<Map<String,Object>>) request.getAttribute("bankList");

    List<Map<String,Object>> bpList =
        (List<Map<String,Object>>) request.getAttribute("bpList");

    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
    String today = df.format(new Date());
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cash Book Report | Vijay Tech Orbit</title>

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>

<!-- Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">

<!-- Select2 -->
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet"/>

<style>
/* ============================
   ✅ PROFIT UI THEME
============================ */
body {
    font-family: 'Plus Jakarta Sans', sans-serif;
    background: #0a1220;
    padding-top: 90px;
    color: #1e293b;
}

/* Header */
.app-header {
    position: fixed;
    top: 0; left: 0; right: 0;
    height: 75px;
    background: rgba(10,18,32,0.92);
    backdrop-filter: blur(10px);
    display: flex;
    align-items: center;
    justify-content: flex-end;
    padding: 0 30px;
    z-index: 5000;
    border-bottom: 1px solid rgba(255,255,255,0.08);
}

.user-info {
    background: rgba(255,255,255,0.08);
    padding: 8px 22px;
    border-radius: 50px;
    color: white;
    font-weight: 800;
}

/* Main Layout */
.page-wrap {
    max-width: 1500px;
    margin: auto;
    padding: 25px;
}

.main-content-card {
    background: rgba(255,255,255,0.97);
    border-radius: 22px;
    padding: 45px;
    box-shadow: 0 20px 55px rgba(0,0,0,0.35);
    position: relative;
    overflow: hidden;
}

/* Decorative top line */
.main-content-card::before {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 6px;
    background: linear-gradient(90deg,#15a0c6,#8b5cf6);
}

/* Title */
.report-title {
    font-size: 26px;
    font-weight: 900;
    margin-bottom: 25px;
    display: flex;
    align-items: center;
    gap: 10px;
}

/* Labels */
label {
    font-weight: 800;
    font-size: 13px;
    text-transform: uppercase;
    color: #64748b;
}

/* Buttons */
.btn-primary {
    background: linear-gradient(135deg,#15a0c6,#0ea5e9);
    border: none;
    font-weight: 800;
    border-radius: 50px;
}

.btn-danger {
    border-radius: 50px;
    font-weight: 800;
}

/* Loader Overlay */
#global-loader {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(10,18,32,0.85);
    z-index: 6000;
    align-items: center;
    justify-content: center;
}

#global-loader h5 {
    color: white;
    font-weight: 800;
}

/* ✅ Modern DataTable */
.table-responsive {
    border-radius: 16px;
    overflow: hidden;
    border: 1px solid #e2e8f0;
    background: white;
}

#cashTable thead th {
    background: #f8fafc;
    font-weight: 900;
    font-size: 13px;
    padding: 16px;
    text-transform: uppercase;
    border-bottom: 2px solid #e2e8f0;
}

#cashTable tbody td {
    padding: 15px;
    border-bottom: 1px solid #e2e8f0;
    font-weight: 600;
}

#cashTable tbody tr:hover {
    background: #f1f5f9;
}

#cashTable tfoot td {
    padding: 16px;
    background: #f8fafc;
    font-weight: 900;
    border-top: 2px solid #e2e8f0;
}

/* Pagination */
.pagination .page-link {
    font-weight: 700;
}
</style>
</head>

<body>

<!-- ✅ HEADER -->
<header class="app-header">
    <div class="user-info">Cash Book Report</div>
</header>

<!-- ✅ SIDEBAR -->
<%@ include file="sidebar.jsp" %>

<!-- ✅ Loader -->
<div id="global-loader">
    <div class="text-center">
        <div class="spinner-border text-info mb-3" style="width:3rem;height:3rem;"></div>
        <h5>Loading Cash Book...</h5>
    </div>
</div>

<!-- ✅ MAIN CONTENT -->
<div class="page-wrap">
<div class="main-content-card">

<div class="report-title">
    <i class="bi bi-journal-text text-primary"></i>
    Cash Book Report
</div>

<form id="filterForm">

<input type="hidden" name="action" id="action" value="search"/>

<div class="row g-3">

    <!-- Bank -->
    <div class="col-md-4">
        <label>Bank / Cash</label>
        <select name="bank_id" class="form-select select2" required>
            <option value="">-- Select Bank --</option>
            <% for(Map<String,Object> b : bankList){ %>
                <option value="<%=b.get("id")%>"><%=b.get("name")%></option>
            <% } %>
        </select>
    </div>

    <!-- BP -->
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

<div class="row g-3 mt-3">

    <div class="col-md-3">
        <label>From Date</label>
        <input type="date" name="from_date" class="form-control" value="<%=today%>"/>
    </div>

    <div class="col-md-3">
        <label>To Date</label>
        <input type="date" name="to_date" class="form-control" value="<%=today%>"/>
    </div>

    <div class="col-md-2 d-flex align-items-end">
        <button type="button" id="btnSearch" class="btn btn-primary w-100">
            Search
        </button>
    </div>

    <div class="col-md-2 d-flex align-items-end">
        <button type="button" id="btnPdf" class="btn btn-danger w-100">
            Export PDF
        </button>
    </div>

</div>
</form>

<hr/>

<!-- ✅ TABLE -->
<div class="table-responsive">
<table class="table" id="cashTable">

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
<tr>
    <td colspan="5" class="text-end">GRAND TOTAL</td>
    <td class="text-end text-success" id="totalReceipt">0.00</td>
    <td class="text-end text-danger" id="totalPayment">0.00</td>
    <td class="text-end fw-bold" id="totalBalance">0.00</td>
</tr>
</tfoot>

</table>
</div>

<!-- Pagination -->
<div class="d-flex justify-content-between mt-3">
    <div id="pageInfo" class="text-muted"></div>
    <ul class="pagination pagination-sm mb-0" id="pagination"></ul>
</div>

</div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
var cashData = [];
var pageSize = 20;
var currentPage = 1;

$(function(){

    $('.select2').select2({ width:'100%' });

    $("#btnSearch").click(function(){

        $("#global-loader").css("display","flex");

        $.ajax({
            url: "<%=request.getContextPath()%>/CashBookReport",
            type: "POST",
            data: $("#filterForm").serialize(),
            dataType: "json",

            success: function(data){

                $("#global-loader").hide();

                if(!data || data.length === 0){
                    $("#resultBody").html("<tr><td colspan='8' class='text-center'>No records</td></tr>");
                    $("#totalReceipt,#totalPayment,#totalBalance").text("0.00");
                    $("#pagination").html("");
                    return;
                }

                cashData = data;
                currentPage = 1;

                renderPage();
                renderPagination();
                calculateTotals();
            },

            error: function(){
                $("#global-loader").hide();
                alert("Error loading report");
            }
        });
    });

    $("#btnPdf").click(function(){

        $("#action").val("pdf");

        $("#filterForm")
            .attr("action","<%=request.getContextPath()%>/CashBookReport")
            .attr("method","post")
            .attr("target","_blank")[0]
            .submit();

        $("#filterForm").removeAttr("target");
    });

});

function renderPage(){

    var start = (currentPage - 1) * pageSize;
    var end   = start + pageSize;

    var pageData = cashData.slice(start,end);

    var html = "";

    for(var i=0;i<pageData.length;i++){

        var r = pageData[i];

        html += "<tr>";
        html += "<td>"+r.datetrx+"</td>";
        html += "<td>"+r.documentno+"</td>";
        html += "<td>"+(r.bpname||"")+"</td>";
        html += "<td>"+(r.accounthead||"")+"</td>";
        html += "<td>"+(r.description||"")+"</td>";
        html += "<td class='text-end text-success fw-bold'>"+Number(r.receipt||0).toFixed(2)+"</td>";
        html += "<td class='text-end text-danger fw-bold'>"+Number(r.payment||0).toFixed(2)+"</td>";
        html += "<td class='text-end fw-bold'>"+Number(r.balance||0).toFixed(2)+"</td>";
        html += "</tr>";
    }

    $("#resultBody").html(html);

    $("#pageInfo").html("Showing "+(start+1)+" to "+Math.min(end,cashData.length)+" of "+cashData.length+" entries");
}

function renderPagination(){

    var totalPages = Math.ceil(cashData.length/pageSize);
    var html = "";

    for(var i=1;i<=totalPages;i++){

        var active = (i===currentPage) ? "active" : "";

        html += "<li class='page-item "+active+"'>";
        html += "<a href='#' class='page-link' onclick='gotoPage("+i+")'>"+i+"</a>";
        html += "</li>";
    }

    $("#pagination").html(html);
}

function gotoPage(p){
    currentPage = p;
    renderPage();
    renderPagination();
}

function calculateTotals(){

    var receipt=0,payment=0,balance=0;

    for(var i=0;i<cashData.length;i++){
        receipt += Number(cashData[i].receipt||0);
        payment += Number(cashData[i].payment||0);
        balance = Number(cashData[i].balance||0);
    }

    $("#totalReceipt").text(receipt.toFixed(2));
    $("#totalPayment").text(payment.toFixed(2));
    $("#totalBalance").text(balance.toFixed(2));
}
</script>

</body>
</html>