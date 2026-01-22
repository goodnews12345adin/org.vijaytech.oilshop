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

    // Casting attributes with null safety - PRESERVED LOGIC
    List<Map<String,Object>> bankAccountList = (List<Map<String,Object>>) request.getAttribute("bankAccountList");
    List<Map<String,Object>> expenseAccountList = (List<Map<String,Object>>) request.getAttribute("expenseAccountList");
    List<Map<String,Object>> partnerList = (List<Map<String,Object>>) request.getAttribute("partnerList");
    List<Map<String,Object>> tenderList = (List<Map<String,Object>>) request.getAttribute("tenderList");
%>

<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover" />
  <title>Expense Entry | <%=orgName%></title>

  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
  
  <!-- Fonts & Icons -->
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
  
  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  
  <!-- Select2 -->
  <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
  <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

  <style>
    /* === ROOT VARIABLES === */
    :root {
      --sidebar-width: 260px;
      --header-height: 75px;
      --accent: #15a0c6;
      --accent-dark: #0e7d9b;
      --accent-glow: rgba(21, 160, 198, 0.3);
      --bg-dark: #0a1220;
      --card-bg: #ffffff;
      --text-main: #1e293b;
      --text-muted: #64748b;
      --border-light: #e2e8f0;
      --radius-lg: 20px;
      --radius-sm: 12px;
      --shadow-card: 0 20px 40px -5px rgba(0, 0, 0, 0.1);
      --shadow-glow: 0 0 20px var(--accent-glow);
      --transition: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    /* === GLOBAL RESETS === */
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: var(--bg-dark);
      /* Animated Background */
      background-image: 
        radial-gradient(circle at top right, rgba(21, 160, 198, 0.08), transparent 40%),
        radial-gradient(circle at bottom left, rgba(139, 92, 246, 0.05), transparent 40%);
      color: var(--text-main);
      margin: 0;
      padding-top: calc(var(--header-height) + 20px);
      min-height: 100vh;
      overflow-x: hidden;
    }

    /* ===========================
       HEADER UI
       =========================== */
    .app-header {
      position: fixed;
      top: 0;
      right: 0;
      left: 0;
      height: var(--header-height);
      background: rgba(10, 18, 32, 0.9);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      display: flex;
      align-items: center;
      justify-content: flex-end;
      padding: 0 40px;
      z-index: 4000;
      border-bottom: 1px solid rgba(255, 255, 255, 0.05);
      box-shadow: 0 4px 20px rgba(0,0,0,0.2);
      transition: padding 0.3s ease;
    }

    .header-user-zone {
      display: flex;
      flex-direction: column;
      align-items: flex-end;
      gap: 4px;
    }

    .version-tag {
      background: rgba(25, 182, 176, 0.15);
      color: #19b6b0;
      font-size: 10px;
      font-weight: 800;
      padding: 3px 10px;
      border-radius: 20px;
      border: 1px solid rgba(25, 182, 176, 0.3);
      text-transform: uppercase;
      letter-spacing: 1px;
    }

    .user-info {
      display: flex;
      align-items: center;
      gap: 15px;
      background: rgba(255,255,255,0.05);
      padding: 6px 16px 6px 6px;
      border-radius: 50px;
      border: 1px solid rgba(255,255,255,0.1);
    }

    .user-name {
      color: #ffffff;
      font-weight: 700;
      font-size: 14px;
      white-space: nowrap;
    }

    .btn-logout {
      background: #ff4d4d;
      color: white;
      border: none;
      width: 32px; height: 32px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: var(--transition);
      font-size: 14px;
      flex-shrink: 0;
    }
    .btn-logout:hover {
      background: #e60000;
      transform: rotate(90deg);
      box-shadow: 0 0 10px rgba(255, 77, 77, 0.5);
    }

    .status-online {
      font-size: 10px;
      color: rgba(255, 255, 255, 0.4);
      font-weight: 500;
    }

    /* ===========================
       CONTENT LAYOUT
       =========================== */
    .page-wrap {
      padding: 20px 40px 100px 40px;
      transition: var(--transition);
      max-width: 1600px; /* Full window size scenario */
      margin: 0 auto;
      width: 100%;
      display: flex;
      justify-content: center;
      align-items: flex-start; 
    }

    .main-content-card {
      background: var(--card-bg);
      border-radius: var(--radius-lg);
      padding: 40px;
      box-shadow: var(--shadow-card);
      border: 1px solid rgba(255,255,255,0.5);
      position: relative;
      overflow: hidden;
      width: 100%;
    }

    /* Top Decorative Line */
    .main-content-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 6px;
        background: linear-gradient(90deg, var(--accent), #8b5cf6);
    }

    .main-content-card h4 {
      font-weight: 800;
      font-size: 26px;
      color: #0f172a;
      margin-bottom: 35px;
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .main-content-card h4 i { color: var(--accent); font-size: 28px; }

    /* Form Controls */
    .form-label { 
        font-weight: 700; 
        color: var(--text-muted); 
        font-size: 13px; 
        margin-bottom: 8px; 
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .form-control, .form-select {
        height: 54px;
        border-radius: var(--radius-sm);
        border: 1px solid var(--border-light);
        background: #f8fafc;
        color: var(--text-main);
        font-weight: 600;
        transition: var(--transition);
        padding: 0 18px;
    }

    .form-control:focus, .form-select:focus {
        background: #fff;
        border-color: var(--accent);
        box-shadow: 0 0 0 4px rgba(21, 160, 198, 0.1);
        transform: translateY(-1px);
    }

    .input-group-text {
        background: #f1f5f9;
        border: 1px solid var(--border-light);
        color: var(--text-muted);
        font-weight: 600;
    }

    /* Alert Styling */
    .alert-custom {
        background: #fffbeb;
        border-left: 4px solid #f59e0b;
        color: #92400e;
        border-radius: var(--radius-sm);
        padding: 15px;
        font-size: 0.95rem;
        font-weight: 500;
        display: none; /* Default hidden */
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
    }
    .alert-custom i { font-size: 1.2rem; }

    /* Buttons */
    .btn-submit {
      background: linear-gradient(135deg, var(--accent), #0ea5e9);
      color: white;
      border: none;
      padding: 14px 40px;
      font-weight: 700;
      border-radius: 50px;
      box-shadow: 0 10px 25px -5px rgba(21, 160, 198, 0.4);
      transition: var(--transition);
    }
    .btn-submit:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px -5px rgba(21, 160, 198, 0.5);
        filter: brightness(1.1);
        color: white;
    }

    .btn-reset {
      background: white;
      border: 2px solid var(--accent);
      color: var(--accent);
      padding: 14px 40px;
      border-radius: 50px;
      font-weight: 700;
      transition: var(--transition);
    }
    .btn-reset:hover { 
        background: var(--accent); 
        color: white; 
        box-shadow: 0 10px 20px -5px rgba(21, 160, 198, 0.4);
        transform: translateY(-2px);
    }

    /* === GLOBAL LOADER === */
    #global-loader {
        display: none;
        align-items: center;
        justify-content: center;
        position: fixed;
        inset: 0;
        z-index: 5500;
        background: rgba(10, 18, 32, 0.8);
        backdrop-filter: blur(8px);
        -webkit-backdrop-filter: blur(8px);
    }
    .loader-content {
        text-align: center;
        color: white;
    }

    /* Select2 Customization */
    .select2-container--default .select2-selection--single {
        height: 54px !important;
        border: 1px solid var(--border-light) !important;
        border-radius: var(--radius-sm) !important;
        background: #f8fafc !important;
        display: flex;
        align-items: center;
    }
    .select2-container--default .select2-selection--single .select2-selection__rendered {
        padding-left: 18px;
        font-weight: 600;
    }
    .select2-container--default .select2-selection--single .select2-selection__arrow {
        height: 52px !important;
        right: 10px !important;
    }
    .select2-dropdown {
        border: 1px solid var(--border-light) !important;
        border-radius: var(--radius-sm) !important;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1) !important;
    }

    /* ===========================
       RESPONSIVE MEDIA QUERIES (ALL DEVICES)
       =========================== */
    @media (max-width: 992px) {
      .page-wrap { padding: 20px 30px; }
      .app-header { padding: 0 20px; }
      .main-content-card { padding: 30px; }
    }

    @media (max-width: 768px) {
      .page-wrap { padding: 15px 20px; }
      .main-content-card { padding: 25px; }
      .main-content-card h4 { font-size: 22px; }
    }

    @media (max-width: 576px) {
      .app-header { padding: 0 15px; }
      .user-name { display: none; }
      .status-online { display: none; }
      .page-wrap { padding: 10px 10px 80px 10px; }
      .main-content-card { padding: 25px 20px; }
      .form-control, .form-select { height: 50px; }
    }
  </style>
</head>

<body>

  <!-- HEADER -->
  <header class="app-header">
    <div class="header-user-zone">
      <span class="version-tag">v44.1</span>
      <div class="user-info">
        <span class="user-name">Guest User</span>
        <div class="btn-logout" onclick="location.href='logout.jsp'" title="Logout">
          <i class="bi bi-power"></i>
        </div>
      </div>
      <span class="status-online">Status: Online</span>
    </div>
  </header>

  <!-- SIDEBAR -->
  <%@ include file="sidebar.jsp" %>

  <!-- GLOBAL LOADER -->
  <div id="global-loader">
    <div class="loader-content">
        <div class="spinner-border text-info mb-3" role="status" style="width: 3rem; height: 3rem;"></div>
        <h5 class="fw-bold">Processing...</h5>
    </div>
  </div>

  <!-- MAIN CONTENT -->
  <div class="page-wrap">
    <div class="col-xl-12"> <!-- Full width for full window scenario -->
      
      <div class="main-content-card">
        <h4><i class="bi bi-wallet2"></i> Expense Entry</h4>
        <p class="text-muted" style="margin-top:-25px; margin-bottom:30px; font-weight:500;">
          Record outgoing payments or expenses. Organization: <strong><%= orgName %></strong>
        </p>

        <form id="expenseForm" method="post" action="<%=request.getContextPath()%>/ExpenseEntryServlet" class="needs-validation" novalidate>
          <input type="hidden" name="action" value="save">

          <div class="row g-4 mb-4">
            <div class="col-md-4 col-12">
              <label class="form-label required-label">Bank / Cash Account</label>
              <select name="bank_account_id" class="form-select" required>
                <option value="">-- Select Bank/Cash --</option>
                <% if (bankAccountList != null) { for (Map<String,Object> b: bankAccountList) { %>
                  <option value="<%= b.get("id") %>"><%= b.get("name") %></option>
                <% }} %>
              </select>
            </div>

            <div class="col-md-4 col-12">
              <label class="form-label">Document Number</label>
              <div class="input-group">
                  <span class="input-group-text"><i class="bi bi-hash"></i></span>
                  <input type="text" name="document_no" class="form-control" placeholder="Automatic if empty">
              </div>
            </div>

            <div class="col-md-4 col-12">
              <label class="form-label required-label">Transaction Date</label>
              <input type="datetime-local" name="transaction_date" class="form-control" required
                     value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(new java.util.Date()) %>">
            </div>
          </div>

          <!-- Logic Alert (Styled) -->
          <div id="logic_alert" class="alert-custom">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            Please provide <strong>either</strong> a Partner (Customer/Vendor) <strong>or</strong> an Account Head.
          </div>

          <div class="row g-4 mb-4">
            <div class="col-md-6 col-12" id="bp_div">
              <label class="form-label">Customer / Vendor</label>
              <select name="c_bpartner_id" id="c_bpartner_id" class="form-select partner-select">
                <option value="">-- Select Partner --</option>
                <% if (partnerList != null) { for (Map<String,Object> p: partnerList) { %>
                  <option value="<%= p.get("id") %>"><%= p.get("name") %></option>
                <% }} %>
              </select>
              <small class="text-muted d-block mt-1">Use this for payments against specific partners.</small>
            </div>

            <div class="col-md-6 col-12" id="acc_div">
              <label class="form-label">Account Head</label>
              <select name="account_head_id" id="account_head_id" class="form-select account-head-select">
                <option value="">-- Select Account Head --</option>
                <% if (expenseAccountList != null) { for (Map<String,Object> e: expenseAccountList) { %>
                  <option value="<%= e.get("id") %>"><%= e.get("name") %></option>
                <% }} %>
              </select>
              <small class="text-muted d-block mt-1">Use this for direct expenses (e.g., Office Supplies).</small>
            </div>
          </div>

          <div class="row g-4 mb-4">
            <div class="col-md-3 col-6">
              <label class="form-label required-label">Payment Amount</label>
              <div class="input-group">
                  <span class="input-group-text">₹</span>
                  <input type="number" step="0.01" name="payment_amount" class="form-control fw-bold" required min="0.01">
              </div>
            </div>

            <div class="col-md-3 col-6">
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

            <div class="col-md-6 col-12">
              <label class="form-label">Description / Remarks</label>
              <input type="text" name="description" class="form-control" placeholder="What is this expense for?">
            </div>
          </div>

          <div class="mt-5 text-end">
            <button type="reset" class="btn-reset me-3">
              <i class="bi bi-arrow-counterclockwise me-2"></i> Reset
            </button>
            <button type="submit" class="btn-submit shadow">
              <i class="bi bi-shield-check me-2"></i> Save Expense
            </button>
          </div>

        </form>
      </div>

    </div>
  </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
 $(function(){
    // Initialize Searchable Dropdowns with Custom Theme
    $('.partner-select, .account-head-select').select2({ width:'100%' });

    const $bp = $("#c_bpartner_id");
    const $acc = $("#account_head_id");
    const $alert = $("#logic_alert");

    function validateMutualExclusion() {
        let bpVal = $bp.val();
        let accVal = $acc.val();

        // Error if both selected or both empty
        if ((bpVal && accVal) || (!bpVal && !accVal)) {
            $alert.slideDown(300);
            return false;
        }
        $alert.slideUp(300);
        return true;
    }

    // Toggle Visibility logic
    function toggleFields() {
        let bpVal = $bp.val();
        let accVal = $acc.val();

        if (bpVal) {
            $("#acc_div").css('opacity', '0.4'); 
            $acc.prop('disabled', true);
        } else {
            $("#acc_div").css('opacity', '1');
            $acc.prop('disabled', false);
        }

        if (accVal) {
            $("#bp_div").css('opacity', '0.4');
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
            $(this).addClass('was-validated');
            return;
        }
        
        // Business Logic validation
        if (!validateMutualExclusion()) {
            e.preventDefault();
            $('html, body').animate({ scrollTop: 0 }, 500); // Scroll to alert smoothly
            return;
        }

        // Show Global Loader for "Trending" feel
        $("#global-loader").css("display","flex").hide().fadeIn(200);
        // Form submits naturally after this
    });
});
</script>

</body>
</html>