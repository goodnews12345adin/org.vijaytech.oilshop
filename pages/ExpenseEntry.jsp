<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Properties"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    HttpSession session1 = request.getSession(false);
    Properties ctx = null;

    if (session1 != null) {
        ctx = (Properties) session1.getAttribute("ctx");
    }

    if (ctx == null) {
        response.sendRedirect("userlogin.jsp?error=session_expired");
        return;
    }

    String orgName = (String) session1.getAttribute("orgName");
    if (orgName == null) orgName = "";

    List<Map<String,Object>> bankAccountList = (List<Map<String,Object>>) request.getAttribute("bankAccountList");
    List<Map<String,Object>> expenseAccountList = (List<Map<String,Object>>) request.getAttribute("expenseAccountList");
    List<Map<String,Object>> partnerList = (List<Map<String,Object>>) request.getAttribute("partnerList");
    List<Map<String,Object>> tenderList = (List<Map<String,Object>>) request.getAttribute("tenderList");
%>

<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Expense Entry - <%=orgName%></title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

  <style>
    :root{
      --header-height:64px;
      --card-radius:12px;
      --accent:#15a0c6;
      --bg:#ffffff;
    }
    body{font-family:Inter,system-ui,Arial;background:#f3f7fb;padding-top:90px}
    .app-header{position:fixed;left:50%;transform:translateX(-50%);top:12px;width:90%;max-width:1200px;height:64px;background:white;border-radius:12px;box-shadow:0 8px 20px rgba(0,0,0,0.08);padding:10px 16px;display:flex;justify-content:space-between;align-items:center}
    .page-wrap{display:flex;justify-content:center;padding:22px}
    .card-panel{width:100%;max-width:1200px;background:white;border-radius:12px;padding:20px;box-shadow:0 12px 30px rgba(0,0,0,0.06)}
  </style>
</head>

<body>
<%@ include file="sidebar.jsp" %>

<header class="app-header">
  <h5 class="m-0">Expense Entry</h5>
  <strong><%= orgName %></strong>
</header>

<div class="page-wrap">
  <div class="card-panel">

    <!-- ALERT BOX (hidden by default) -->
    <div id="field_alert" class="alert alert-danger py-1 px-2" style="display:none;">
        Please select either Customer/Vendor or Account Head.
    </div>

    <form id="expenseForm" method="post" action="<%=request.getContextPath()%>/ExpenseEntryServlet">
      <input type="hidden" name="action" value="save">

      <!-- Bank / Document / Date -->
      <div class="row g-3">
        <div class="col-md-4">
          <label class="form-label">Bank / Cash Account *</label>
          <select name="bank_account_id" class="form-select form-select-sm" required>
            <option value="">-- Select Bank/Cash --</option>
            <% if (bankAccountList != null) { for (Map<String,Object> b: bankAccountList) { %>
              <option value="<%= b.get("id") %>"><%= b.get("name") %></option>
            <% }} %>
          </select>
        </div>

        <div class="col-md-4">
          <label class="form-label">Document No.</label>
          <input type="text" name="document_no" class="form-control form-control-sm" placeholder="Auto or enter">
        </div>

        <div class="col-md-4">
          <label class="form-label">Transaction Date *</label>
          <input type="datetime-local" name="transaction_date" class="form-control form-control-sm" required
                 value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(new java.util.Date()) %>">
        </div>
      </div>

      <hr/>

      <!-- Customer/Vendor + Account Head -->
      <div class="row g-3">
        
        <!-- Customer/Vendor -->
        <div class="col-md-4" id="bp_div">
          <label class="form-label">Customer / Vendor *</label>
          <select name="c_bpartner_id" id="c_bpartner_id" class="form-select form-select-sm partner-select">
            <option value="">-- Select Partner --</option>
            <% if (partnerList != null) { for (Map<String,Object> p: partnerList) { %>
              <option value="<%= p.get("id") %>"><%= p.get("name") %></option>
            <% }} %>
          </select>
        </div>

        <!-- Account Head -->
        <div class="col-md-4" id="acc_div">
          <label class="form-label">Account Head *</label>
          <select name="account_head_id" id="account_head_id" class="form-select form-select-sm account-head-select">
            <option value="">-- Select Account Head --</option>
            <% if (expenseAccountList != null) { for (Map<String,Object> e: expenseAccountList) { %>
              <option value="<%= e.get("id") %>"><%= e.get("name") %></option>
            <% }} %>
          </select>
        </div>

        <div class="col-md-4">
          <label class="form-label">Department</label>
          <input type="text" name="department" class="form-control form-control-sm" placeholder="Department">
        </div>

      </div>

      <hr/>

      <!-- Amount & Tender -->
      <div class="row g-3">
        <div class="col-md-3">
          <label class="form-label">Payment Amount *</label>
          <input type="number" step="0.01" name="payment_amount" class="form-control form-control-sm" required value="0.00">
        </div>

        <div class="col-md-3">
          <label class="form-label">Currency</label>
          <input type="text" name="currency" class="form-control form-control-sm" value="INR">
        </div>

        <div class="col-md-3">
          <label class="form-label">Tender Type</label>
          <select name="tender_type" class="form-select form-select-sm">
            <% if (tenderList != null) { for (Map<String,Object> t: tenderList) { %>
              <option value="<%= t.get("value") %>"><%= t.get("name") %></option>
            <% }} else { %>
              <option value="Cash">Cash</option>
              <option value="Bank">Bank</option>
              <option value="UPI">UPI</option>
            <% } %>
          </select>
        </div>
      </div>

      <hr/>

      <div class="row g-3">
        <div class="col-12">
          <label class="form-label">Description</label>
          <input type="text" name="description" class="form-control form-control-sm" placeholder="Description / Note">
        </div>
      </div>

      <hr/>

      <div class="text-end">
        <button type="submit" class="btn btn-success btn-sm">Save</button>
      </div>

    </form>

  </div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
  $(function(){

    $('.partner-select, .account-head-select').select2({ width:'100%' });

    const $bp = $("#c_bpartner_id");
    const $acc = $("#account_head_id");
    const $bpDiv = $("#bp_div");
    const $accDiv = $("#acc_div");
    const $alert = $("#field_alert");

    function validateChoice() {
        let bpVal = $bp.val();
        let accVal = $acc.val();

        if ((bpVal && accVal) || (!bpVal && !accVal)) {
            $alert.show();
            return false;
        }
        $alert.hide();
        return true;
    }

    function toggleFields() {
        let bpVal = $bp.val();
        let accVal = $acc.val();

        if (bpVal) {
            $accDiv.hide();
            $acc.val(null).trigger('change');
        } else {
            $accDiv.show();
        }

        if (accVal) {
            $bpDiv.hide();
            $bp.val(null).trigger('change');
        } else {
            $bpDiv.show();
        }

        validateChoice();
    }

    $bp.on("change", toggleFields);
    $acc.on("change", toggleFields);

    $("#expenseForm").on("submit", function(e){
        if (!validateChoice()) {
            e.preventDefault();
        }
    });

  });
</script>

</body>
</html>