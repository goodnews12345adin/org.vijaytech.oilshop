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
    if (orgName == null) orgName = "Organization";

    // Casting attributes with null safety
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
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">

  <style>
    :root {
      --primary-color: #15a0c6;
      --card-radius: 12px;
    }
    body {
      font-family: 'Inter', sans-serif;
      background-color: #f4f7fa;
      color: #334155;
    }
    .main-content {
      padding: 40px 20px;
    }
    .expense-card {
      background: #ffffff;
      border: none;
      border-radius: var(--card-radius);
      box-shadow: 0 10px 25px rgba(0,0,0,0.05);
    }
    .card-header-custom {
      background: white;
      border-bottom: 1px solid #eef2f6;
      padding: 20px;
      border-radius: var(--card-radius) var(--card-radius) 0 0;
    }
    .form-label {
      font-weight: 600;
      font-size: 0.85rem;
      color: #475569;
    }
    .required-label::after {
      content: " *";
      color: #ef4444;
    }
    .divider {
      margin: 2rem 0;
      border-top: 1px solid #e2e8f0;
    }
    /* Select2 Bootstrap Overrides */
    .select2-container--default .select2-selection--single {
      height: 38px;
      border: 1px solid #dee2e6;
      border-radius: 6px;
    }
  </style>
</head>

<body>
<%@ include file="sidebar.jsp" %>

<div class="main-content container">
  <div class="expense-card">
    
    <div class="card-header-custom d-flex justify-content-between align-items-center">
      <h5 class="mb-0 text-primary fw-bold">
        <i class="bi bi-wallet2 me-2"></i>Expense Entry
      </h5>
      <span class="badge bg-light text-dark border p-2">
        <i class="bi bi-building me-1"></i><%= orgName %>
      </span>
    </div>

    <div class="card-body p-4">
      <div id="logic_alert" class="alert alert-warning d-none">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        Please provide <strong>either</strong> a Partner (Customer/Vendor) <strong>or</strong> an Account Head.
      </div>

      <form id="expenseForm" method="post" action="<%=request.getContextPath()%>/ExpenseEntryServlet" class="needs-validation" novalidate>
        <input type="hidden" name="action" value="save">

        <div class="row g-4">
          <div class="col-md-4">
            <label class="form-label required-label">Bank / Cash Account</label>
            <select name="bank_account_id" class="form-select" required>
              <option value="">-- Select Bank/Cash --</option>
              <% if (bankAccountList != null) { for (Map<String,Object> b: bankAccountList) { %>
                <option value="<%= b.get("id") %>"><%= b.get("name") %></option>
              <% }} %>
            </select>
          </div>

          <div class="col-md-4">
            <label class="form-label">Document Number</label>
            <div class="input-group">
                <span class="input-group-text bg-light"><i class="bi bi-hash"></i></span>
                <input type="text" name="document_no" class="form-control" placeholder="Automatic if empty">
            </div>
          </div>

          <div class="col-md-4">
            <label class="form-label required-label">Transaction Date</label>
            <input type="datetime-local" name="transaction_date" class="form-control" required
                   value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(new java.util.Date()) %>">
          </div>
        </div>

        <div class="divider"></div>

        <div class="row g-4">
          <div class="col-md-6" id="bp_div">
            <label class="form-label required-label">Customer / Vendor</label>
            <select name="c_bpartner_id" id="c_bpartner_id" class="form-select partner-select">
              <option value="">-- Select Partner --</option>
              <% if (partnerList != null) { for (Map<String,Object> p: partnerList) { %>
                <option value="<%= p.get("id") %>"><%= p.get("name") %></option>
              <% }} %>
            </select>
            <small class="text-muted">Use this for payments against specific partners.</small>
          </div>

          <div class="col-md-6" id="acc_div">
            <label class="form-label required-label">Account Head</label>
            <select name="account_head_id" id="account_head_id" class="form-select account-head-select">
              <option value="">-- Select Account Head --</option>
              <% if (expenseAccountList != null) { for (Map<String,Object> e: expenseAccountList) { %>
                <option value="<%= e.get("id") %>"><%= e.get("name") %></option>
              <% }} %>
            </select>
            <small class="text-muted">Use this for direct expenses (e.g., Office Supplies).</small>
          </div>
        </div>

        <div class="divider"></div>

        <div class="row g-4">
          <div class="col-md-3">
            <label class="form-label required-label">Payment Amount</label>
            <div class="input-group">
                <span class="input-group-text bg-light">₹</span>
                <input type="number" step="0.01" name="payment_amount" class="form-control fw-bold" required min="0.01">
            </div>
          </div>

          <div class="col-md-3">
            <label class="form-label">Tender Type</label>
            <select name="tender_type" class="form-select">
              <% if (tenderList != null) { for (Map<String,Object> t: tenderList) { %>
                <option value="<%= t.get("value") %>"><%= t.get("name") %></option>
              <% }} else { %>
                <option value="Cash">Cash</option>
                <option value="Bank">Bank Transfer</option>
                <option value="UPI">UPI</option>
              <% } %>
            </select>
          </div>

          <div class="col-md-6">
            <label class="form-label">Description / Remarks</label>
            <input type="text" name="description" class="form-control" placeholder="What is this expense for?">
          </div>
        </div>

        <div class="mt-5 text-end">
          <button type="reset" class="btn btn-light px-4 me-2">Reset</button>
          <button type="submit" class="btn btn-success px-5 fw-bold">
            <i class="bi bi-check-circle me-2"></i>Save Expense
          </button>
        </div>

      </form>
    </div>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
$(function(){
    // Initialize Searchable Dropdowns
    $('.partner-select, .account-head-select').select2({ width:'100%' });

    const $bp = $("#c_bpartner_id");
    const $acc = $("#account_head_id");
    const $alert = $("#logic_alert");

    function validateMutualExclusion() {
        let bpVal = $bp.val();
        let accVal = $acc.val();

        // Error if both selected or both empty
        if ((bpVal && accVal) || (!bpVal && !accVal)) {
            $alert.removeClass('d-none');
            return false;
        }
        $alert.addClass('d-none');
        return true;
    }

    // Toggle Visibility logic
    function toggleFields() {
        let bpVal = $bp.val();
        let accVal = $acc.val();

        if (bpVal) {
            $("#acc_div").css('opacity', '0.5'); // Visual cue instead of hard hide
            $acc.prop('disabled', true);
        } else {
            $("#acc_div").css('opacity', '1');
            $acc.prop('disabled', false);
        }

        if (accVal) {
            $("#bp_div").css('opacity', '0.5');
            $bp.prop('disabled', true);
        } else {
            $("#bp_div").css('opacity', '1');
            $bp.prop('disabled', false);
        }
        
        validateMutualExclusion();
    }

    $bp.on("change", toggleFields);
    $acc.on("change", toggleFields);

    // Form Submit Handler
    $("#expenseForm").on("submit", function(e){
        // Bootstrap native validation
        if (!this.checkValidity()) {
            e.preventDefault();
            e.stopPropagation();
        }
        
        // Business Logic validation
        if (!validateMutualExclusion()) {
            e.preventDefault();
            window.scrollTo(0, 0); // Scroll to alert
        }
        
        $(this).addClass('was-validated');
    });
});
</script>

</body>
</html>