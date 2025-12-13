<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    List<Map<String,Object>> orgList  = (List<Map<String,Object>>) request.getAttribute("orgList");
    List<Map<String,Object>> bankList = (List<Map<String,Object>>) request.getAttribute("bankList");
    List<Map<String,Object>> bpList   = (List<Map<String,Object>>) request.getAttribute("bpList");

    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
    String today = df.format(new Date());
%>

<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cash Book Report</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

<style>
    body {
        background:#f3f7fb;
        font-family:Inter,Arial;
    }
    .card-box {
        margin-top:30px;
        padding:20px;
        background:white;
        border-radius:10px;
        box-shadow:0 6px 20px rgba(0,0,0,0.08);
    }
    table th {
        background:#f8f9fa;
    }
    #loader {
        display:none;
        font-size:1.2rem;
        font-weight:bold;
        color:#0a58ca;
    }
</style>

</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="container">

    <div class="card-box">
        <h4 class="mb-3">Cash Book Report</h4>

        <!-- FILTER FORM (AJAX) -->
        <form id="filterForm">

            <div class="row g-3">

                <!-- Org -->
                <div class="col-md-4">
                    <label class="form-label">Organization</label>
                    <select name="ad_org_id" class="form-select select2" required>
                        <option value="">-- Select Org --</option>
                        <% if(orgList != null){ for(Map<String,Object> o : orgList){ %>
                            <option value="<%= o.get("id") %>"><%= o.get("name") %></option>
                        <% }} %>
                    </select>
                </div>

                <!-- Bank -->
                <div class="col-md-4">
                    <label class="form-label">Bank / Cash Account</label>
                    <select name="bank_id" class="form-select select2" required>
                        <option value="">-- Select Bank/Cash --</option>
                        <% if(bankList != null){ for(Map<String,Object> b : bankList){ %>
                            <option value="<%= b.get("id") %>"><%= b.get("name") %></option>
                        <% }} %>
                    </select>
                </div>

                <!-- BP -->
                <div class="col-md-4">
                    <label class="form-label">Business Partner (Optional)</label>
                    <select name="bp_id" class="form-select select2">
                        <option value="">-- All Partners --</option>
                        <% if(bpList != null){ for(Map<String,Object> p : bpList){ %>
                            <option value="<%= p.get("id") %>"><%= p.get("name") %></option>
                        <% }} %>
                    </select>
                </div>

            </div>

            <div class="row g-3 mt-2">

                <!-- From Date -->
                <div class="col-md-4">
                    <label class="form-label">From Date</label>
                    <input type="date" name="from_date" class="form-control" value="<%= today %>">
                </div>

                <!-- To Date -->
                <div class="col-md-4">
                    <label class="form-label">To Date</label>
                    <input type="date" name="to_date" class="form-control" value="<%= today %>">
                </div>

                <!-- Search -->
                <div class="col-md-4 d-flex align-items-end">
                    <button type="button" id="btnSearch" class="btn btn-primary w-100">Search</button>
                </div>

            </div>

        </form>

        <!-- Loader -->
        <div id="loader" class="mt-3">Loading... Please wait</div>

        <hr class="my-4"/>

        <!-- RESULTS -->
        <div class="table-responsive">
        <table class="table table-bordered table-sm" id="resultsTable">
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Document No</th>
                    <th>BP Name</th>
                    <th>Account Head</th>
                    <th>Description</th>
                    <th>Receipt</th>
                    <th>Payment</th>
                    <th>Balance</th>
                </tr>
            </thead>
            <tbody id="resultBody">
                <tr><td colspan="8" class="text-center text-muted">No data</td></tr>
            </tbody>
        </table>
        </div>

    </div>

</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
$(function(){

    $('.select2').select2({ width:'100%' });

    $("#btnSearch").on("click", function(){

      /*   $("#loader").show(); */
        $("#resultBody").html("");

        $.ajax({
            url: "<%=request.getContextPath()%>/CashBookReport",
            type: "POST",
            data: $("#filterForm").serialize(),
            dataType: "json",
            success: function(response){

                $("#loader").hide();

                if(response.length === 0){
                    $("#resultBody").html("<tr><td colspan='8' class='text-center text-muted'>No records found</td></tr>");
                    return;
                }

                var html = "";
                $.each(response, function(i, row) {

                    var datetrx     = row.datetrx     != null ? row.datetrx     : "";
                    var documentno  = row.documentno  != null ? row.documentno  : "";
                    var bpname      = row.bpname      != null ? row.bpname      : "";
                    var accounthead = row.accounthead != null ? row.accounthead : "";
                    var description = row.description != null ? row.description : "";
                    var receipt     = row.receipt     != null ? row.receipt     : 0;
                    var payment     = row.payment     != null ? row.payment     : 0;
                    var balance     = row.balance     != null ? row.balance     : 0;

                    html += "<tr>"
                          + "<td>" + datetrx + "</td>"
                          + "<td>" + documentno + "</td>"
                          + "<td>" + bpname + "</td>"
                          + "<td>" + accounthead + "</td>"
                          + "<td>" + description + "</td>"
                          + "<td>" + receipt + "</td>"
                          + "<td>" + payment + "</td>"
                          + "<td>" + balance + "</td>"
                          + "</tr>";
                });

                $("#resultBody").html(html);

                // Fill hidden PDF fields
                $("#pdf_org").val($("[name='ad_org_id']").val());
                $("#pdf_bank").val($("[name='bank_id']").val());
                $("#pdf_bp").val($("[name='bp_id']").val());
                $("#pdf_from").val($("[name='from_date']").val());
                $("#pdf_to").val($("[name='to_date']").val());
            },
            error: function(err){
                $("#loader").hide();
                alert("Error loading data. Check server logs.");
            }
        });

    });

});
</script>

</body>
</html>