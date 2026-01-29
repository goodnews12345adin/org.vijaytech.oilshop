<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Properties" %>
<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

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

    String role = (String) session1.getAttribute("userRole");
    if (role == null) {
        role = "user";
        session1.setAttribute("userRole", role);
    }

    String orgName = (String) session1.getAttribute("orgName");
    if (orgName == null) {
        orgName = "";
    }

    List<Map<String, Object>> productList =
            (List<Map<String, Object>>) request.getAttribute("productList");
%>

<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Sales Entry | Vijay Tech Orbit</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />

  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
  
  <!-- Fonts & Icons -->
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
  
  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  
  <!-- Select2 (Dropdowns) -->
  <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
  <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
  
  <!-- QZ Tray (Silent Printing) & Crypto -->
  <script src="https://cdn.jsdelivr.net/npm/qz-tray@2.2.4/qz-tray.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jsrsasign/10.8.6/jsrsasign-all-min.js"></script>

<style>
    /* === ROOT VARIABLES === */
    :root {
      --accent: #15a0c6;
      --accent-dark: #0e7d9b;
      --accent-glow: rgba(21, 160, 198, 0.4);
      --bg-slate: #f8fafc;
      --header-bg: rgba(10, 18, 32, 0.95);
      --glass-border: rgba(255, 255, 255, 0.1);
      --card-radius: 24px;
      --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      --danger: #ef4444;
      --success: #10b981;
    }

    /* === GLOBAL RESETS === */
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: var(--bg-slate);
      color: #1e293b;
      margin: 0;
      padding-top: 90px;
      min-height: 100vh;
      /* Modern Background Gradient */
      background-image: 
        radial-gradient(at 0% 0%, rgba(21, 160, 198, 0.05) 0px, transparent 50%),
        radial-gradient(at 100% 100%, rgba(10, 18, 32, 0.02) 0px, transparent 50%);
    }

    /* === HEADER === */
    .app-header {
      position: fixed;
      top: 0; right: 0; left: 0;
      height: 75px;
      background: var(--header-bg);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 40px;
      z-index: 1040;
      border-bottom:1px solid var(--glass-border);
      box-shadow: 0 10px 40px rgba(0,0,0,0.1);
    }

    .header-title {
      font-weight: 800;
      font-size: 1.35rem;
      color: #fff;
      letter-spacing: -0.5px;
      display: flex;
      align-items: center;
      text-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }

    .header-action {
      background: rgba(255, 255, 255, 0.08);
      padding: 8px 20px;
      border-radius: 50px;
      border: 1px solid rgba(255,255,255,0.1);
      display: flex;
      align-items: center;
      transition: var(--transition);
      box-shadow: 0 4px 15px rgba(0,0,0,0.2);
    }
    .header-action:hover { background: rgba(255,255,255,0.15); transform: translateY(-2px); }

    /* === MAIN LAYOUT === */
    .page-wrap {
      padding: 30px 40px 100px 40px;
      max-width: 1500px;
      margin: 0 auto;
      width: 100%;
    }

    .invoice-box {
      background: #ffffff;
      border-radius: var(--card-radius);
      padding: 45px;
      box-shadow: 0 20px 60px -10px rgba(0,0,0,0.08);
      border: 1px solid #edf2f7;
      position: relative;
      overflow: hidden;
    }

    /* Top Decorative Bar */
    .invoice-box::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 8px;
        background: linear-gradient(90deg, var(--accent), #3b82f6);
        box-shadow: 0 4px 20px var(--accent-glow);
    }

    .invoice-head {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 40px;
      padding-bottom: 25px;
      border-bottom: 2px solid #f1f5f9;
    }

    .org-title {
      font-size: 28px;
      font-weight: 800;
      color: #0f172a;
      letter-spacing: -1px;
    }

    /* === INPUT STYLING === */
    .border-dashed {
      border: 2px dashed #cbd5e1;
      border-radius: 20px;
      padding: 30px;
      background: #fafbfc;
      transition: var(--transition);
      height: 100%;
      position: relative;
      z-index: 1;
    }
    
    .border-dashed:hover {
        border-color: var(--accent);
        background: #fff;
        box-shadow: 0 10px 30px rgba(21, 160, 198, 0.08);
    }

    .form-control, .form-select {
      height: 50px;
      border-radius: 12px;
      border: 1px solid #e2e8f0;
      padding: 10px 18px;
      font-size: 15px;
      font-weight: 500;
      transition: var(--transition);
      box-shadow: 0 2px 4px rgba(0,0,0,0.02);
      background-color: #fff;
    }

    /* Focus States for Accessibility */
    .form-control:focus, .form-select:focus {
      border-color: var(--accent);
      box-shadow: 0 0 0 4px rgba(21, 160, 198, 0.1);
      background-color: #fff;
      transform: translateY(-1px);
    }

    .form-control-sm {
        height: 42px;
        border-radius: 10px;
        font-size: 14px;
    }

    /* Select2 Customization */
    .select2-container--default .select2-selection--single {
      height: 50px !important;
      border-radius: 12px !important;
      border-color: #e2e8f0 !important;
      background: #fff !important;
      display: flex;
      align-items: center;
      box-shadow: 0 2px 4px rgba(0,0,0,0.02);
    }
    .select2-container--default .select2-selection--single .select2-selection__arrow {
        top: 12px !important;
    }
    .select2-dropdown {
        border: 1px solid #e2e8f0 !important;
        border-radius: 12px !important;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1) !important;
    }

    /* === TABLE STYLING === */
    .table-responsive {
      border-radius: 20px;
      border: 1px solid #f1f5f9;
      margin-top: 30px;
      overflow-x: auto;
      box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05);
    }

    .table { margin-bottom: 0; background: #fff; }
    
    .table th {
      background: #f8fafc;
      text-transform: uppercase;
      font-size: 11px;
      font-weight: 800;
      color: #64748b;
      padding: 20px 15px;
      border: none;
      white-space: nowrap;
      letter-spacing: 0.5px;
    }

    .table tbody td {
      padding: 18px 15px;
      border-bottom: 1px solid #f1f5f9;
      vertical-align: middle;
      font-size: 15px;
      color: #334155;
    }
    
    .table tbody tr:hover { background-color: #f8fafc; }
    
    .remove-row {
        width: 34px; height: 34px;
        padding: 0;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        transition: all 0.2s;
        border: 1px solid #fee2e2;
        color: var(--danger);
    }
    .remove-row:hover {
        background: var(--danger);
        color: #fff;
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
    }

    /* === TOTALS SECTION (Fixed Visibility) === */
   .total-box {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-end;
    gap: 25px;
    background: #0b132b;
    padding: 30px;
    border-radius: 20px;
    margin-top: 30px;
    box-shadow: inset 0 2px 10px rgba(255,255,255,0.05);
    background-image: linear-gradient(135deg, #0f172a, #1e293b);
    }

    .total-item-group {
        display: flex;
        flex-direction: column;
        min-width: 160px;
        flex-grow: 1;
    }

    .total-item-group label {
        font-size: 12px;
        color: #94a3b8;
        margin-bottom: 8px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    /* FIX: Darker background for white text */
    .total-item-group input {
        height: 45px;
        background: rgba(15, 23, 42, 0.5) !important; 
        border: 1px solid rgba(255,255,255,0.2);
        color: #fff !important;
        text-align: right;
        border-radius: 10px;
        font-size: 16px;
        font-weight: 600;
        transition: var(--transition);
    }
    .total-item-group input:focus {
        background: rgba(255,255,255,0.15);
        border-color: var(--accent);
        outline: none;
    }

    .total-spacer { flex-grow: 1; }

    #grand-total {
        font-size: 38px;
        font-weight: 800;
        color: #1ec8ff;
        line-height: 1;
        text-shadow: 0 0 20px rgba(30, 200, 255, 0.4);
    }

    #Bal-amt {
        font-size: 30px;
        font-weight: 700;
        color: #ff4757;
    }

    /* === BUTTONS === */
    .btn {
        padding: 12px 28px;
        border-radius: 12px;
        font-weight: 600;
        letter-spacing: 0.3px;
        transition: var(--transition);
        text-transform: none;
    }

    .btn-success {
      background: var(--accent);
      border: none;
      box-shadow: 0 10px 20px -5px rgba(21, 160, 198, 0.5);
    }
    .btn-success:hover {
      background: var(--accent-dark);
      transform: translateY(-3px);
      box-shadow: 0 15px 30px -5px rgba(21, 160, 198, 0.6);
    }

    /* === LOADER OVERLAY === */
    #loader {
      background: rgba(255, 255, 255, 0.85);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      display: none;
      align-items: center;
      justify-content: center;
      position: fixed;
      inset: 0;
      z-index: 9999;
      opacity: 0;
      transition: opacity 0.3s ease;
    }
    #loader.active { opacity: 1; }

    #loader .box {
      background: #ffffff;
      color: #0f172a;
      padding: 40px 60px;
      border-radius: 24px;
      font-weight: 700;
      box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
      display: flex;
      align-items: center;
      gap: 20px;
      border: 1px solid #e2e8f0;
      transform: scale(0.9);
      transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
    }
    #loader.active .box { transform: scale(1); }

    /* === THERMAL RECEIPT (Fixed Alignment) === */
    #thermal-print-area {
        display: none; 
        width: 80mm; /* Standard width */
        background-color: #ffffff;
        color: #000000;
        font-family: 'Courier New', Courier, monospace;
        font-size: 12px;
        padding: 2mm;
        line-height: 1.3; /* Better spacing */
        text-align: left;
    }
    
    .receipt-header { text-align: center; margin-bottom: 10px; border-bottom: 1px dashed #000; padding-bottom: 5px; }
    .receipt-row { 
        display: flex; 
        justify-content: space-between; /* Aligns left and right perfectly */
        margin-bottom: 4px; 
        width: 100%;
    }
    .receipt-divider { border-top: 1px dashed #000; margin: 5px 0; }
    .receipt-footer { text-align: center; margin-top: 10px; font-size: 11px; }

    /* === WONDERFUL BOX (Custom Modal) === */
    #wonderful-alert-box {
        z-index: 100000; /* Above loader */
    }
    
    .modal-content.wonderful-box {
        border: none;
        border-radius: 24px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.15);
        background: #fff;
        overflow: hidden;
        animation: slideUpFade 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }

    @keyframes slideUpFade {
        from { opacity: 0; transform: translate(0, 50px) scale(0.95); }
        to { opacity: 1; transform: translate(0, 0) scale(1); }
    }

    .wonderful-icon-area {
        height: 80px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 10px;
    }
    
    .wonderful-icon-area i {
        font-size: 3.5rem;
        display: block;
    }

    .wb-icon-success { color: var(--success); text-shadow: 0 4px 15px rgba(16, 185, 129, 0.3); }
    .wb-icon-error { color: var(--danger); text-shadow: 0 4px 15px rgba(239, 68, 68, 0.3); }
    .wb-icon-warning { color: #f59e0b; text-shadow: 0 4px 15px rgba(245, 158, 11, 0.3); }
    .wb-icon-confirm { color: var(--accent); text-shadow: 0 4px 15px rgba(21, 160, 198, 0.3); }

    .wonderful-title {
        font-size: 1.5rem;
        font-weight: 800;
        color: #1e293b;
        margin-bottom: 0.5rem;
    }

    .wonderful-msg {
        color: #64748b;
        font-size: 1rem;
        margin-bottom: 2rem;
        line-height: 1.5;
    }

    .wonderful-btn {
        padding: 12px 30px;
        border-radius: 50px;
        font-weight: 700;
        font-size: 0.95rem;
        letter-spacing: 0.5px;
        transition: all 0.2s;
        border: none;
        min-width: 120px;
    }

    .wb-btn-confirm {
        background: var(--accent);
        color: white;
        box-shadow: 0 4px 15px rgba(21, 160, 198, 0.3);
    }
    .wb-btn-confirm:hover { background: var(--accent-dark); transform: translateY(-2px); }

    .wb-btn-cancel {
        background: #f1f5f9;
        color: #64748b;
    }
    .wb-btn-cancel:hover { background: #e2e8f0; color: #334155; }

    /* Backdrop */
    .modal-backdrop.show {
        opacity: 0.6;
        background: #0f172a;
        backdrop-filter: blur(5px);
    }

    /* === ERROR / SUCCESS TOAST (Kept for compatibility but unused in logic) === */
    .toast-container {
        z-index: 99999;
    }
    .custom-toast {
        background: rgba(255,255,255,0.9);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border: none;
        border-radius: 16px;
        box-shadow: 0 15px 40px rgba(0,0,0,0.15);
        overflow: hidden;
        min-width: 350px;
        transform: translateX(120%);
        transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    .custom-toast.show { transform: translateX(0); }
    
    .custom-toast.text-bg-success {
        background: rgba(16, 185, 129, 0.95);
        color: white;
    }
    .custom-toast.text-bg-danger {
        background: rgba(239, 68, 68, 0.95);
        color: white;
    }
    .custom-toast .toast-body {
        font-weight: 600;
        font-size: 0.95rem;
    }

    /* MEDIA QUERIES (Previous) */
    @media (max-width: 575.98px) {
        .app-header { padding: 0 20px; height: 65px; }
        .header-title { font-size: 1.1rem; }
        .header-action span { display: none; } 
        .page-wrap { padding: 20px 10px 90px 10px; }
        .invoice-box { padding: 20px; border-radius: 16px; }
        .invoice-head { flex-direction: column; gap: 15px; }
        .border-dashed { padding: 20px; }
        .table-responsive { margin-top: 15px; border-radius: 12px; }
        .table th, .table td { padding: 10px 8px; font-size: 13px; }
        .total-box { flex-direction: column; padding: 20px; gap: 15px; }
        .total-item-group { width: 100%; }
        .total-spacer { display: none; }
        .btn { width: 100%; margin-bottom: 10px; justify-content: center; }
        .d-flex.justify-content-end { flex-direction: column; }
        #grand-total { font-size: 32px; }
        #Bal-amt { font-size: 26px; }
    }
    /* Other media queries omitted for brevity but assumed present */
</style>
</head>
<body>

<!-- HEADER -->
<header class="app-header">
    <div class="header-left">
        <div class="header-title">
            <i class="bi bi-cart-check-fill me-3 text-info fs-3"></i>
            <span>Sales Entry</span>
        </div>
    </div>

    <div class="header-right">
        <div class="header-action">
            <i class="bi bi-building-fill text-info me-2 fs-5"></i>
            <span class="text-white small fw-bold text-uppercase tracking-wider"><%= orgName %></span>
        </div>
    </div>
</header>

<%@ include file="sidebar.jsp" %>

<div class="page-wrap" id="pageWrap">
    <main class="container-main">
        <div class="invoice-box">
            
            <!-- Invoice Header -->
            <div class="invoice-head">
                <div>
                    <div class="org-title"><%= orgName %></div>
                    <div class="badge rounded-pill bg-info bg-opacity-10 text-info mt-3 px-4 py-2 border border-info border-opacity-25 fw-bold">
                        <i class="bi bi-receipt-cutoff me-1"></i> NEW INVOICE
                    </div>
                </div>
                <div class="text-end">
                    <div class="text-muted small fw-bold text-uppercase tracking-wide mb-1">Date</div>
                    <div class="fw-bold fs-4 text-dark" id="invoice-date"></div>
                </div>
            </div>

            <div class="row g-4 mb-4">
                <!-- Bill To Section -->
                <div class="col-12 col-lg-5">
                    <div class="border-dashed">
                        <div class="d-flex align-items-center mb-4">
                            <div class="bg-primary bg-opacity-10 p-3 rounded-3 me-3 shadow-sm">
                                <i class="bi bi-person-lines-fill text-primary fs-4"></i>
                            </div>
                            <span class="fw-bold fs-5 text-dark">Bill To</span>
                        </div>
                        <div class="form-floating mb-3">
                            <input type="text" class="form-control" id="cust-name" placeholder="Name">
                            <label for="cust-name" class="text-muted">Customer Name</label>
                        </div>
                        <div class="form-floating mb-3">
                            <input type="text" class="form-control" id="cust-address" placeholder="Address">
                            <label for="cust-address" class="text-muted">Address</label>
                        </div>
                        <!-- PHONE IS NO LONGER REQUIRED -->
                        <div class="form-floating">
                            <input type="text" class="form-control" id="cust-phone" placeholder="Phone">
                            <label for="cust-phone" class="text-muted">Phone Number (Optional)</label>
                        </div>
                    </div>
                </div>

                <!-- Add Products Section -->
                <div class="col-12 col-lg-7">
                    <div class="p-4 bg-light rounded-4 border border-light-subtle h-100">
                        <label class="form-label fw-bold d-flex justify-content-between mb-3">
                            <span class="text-dark"><i class="bi bi-box-seam me-2"></i>Add Products</span>
                            <span class="text-primary small cursor-pointer text-decoration-underline"><i class="bi bi-search me-1"></i>Search (Press Enter)</span>
                        </label>
                        
                        <div class="mb-4">
                            <select id="manual-product" class="form-select" style="width:100%">
                                <option value="">-- Search & Select Product --</option>
                                <%
                                    if (productList != null) {
                                        for (Map<String, Object> p : productList) {
                                            String name   = p.get("name")   != null ? p.get("name").toString()   : "";
                                            String rate   = p.get("rate")   != null ? p.get("rate").toString()   : "0";
                                            String uom    = p.get("uom")    != null ? p.get("uom").toString()    : "";
                                            String prodId = p.get("prodId") != null ? p.get("prodId").toString() : "0";
                                            String search = p.get("value")  != null ? p.get("value").toString()  : "";
                                %>
                                <option value="<%= name %>|<%= rate %>|<%= uom %>"
                                        data-prodid="<%= prodId %>"
                                        data-search="<%= search %>">
                                    <%= name %> (₹<%= rate %>/<%= uom %>) [Code: <%= search %>]
                                </option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>
                        
                        <div class="d-flex align-items-center gap-3 text-muted small bg-white p-3 rounded border border-secondary-subtle shadow-sm">
                             <i class="bi bi-lightbulb-fill text-warning fs-5"></i>
                             <span>Tip: Type product name and press <strong class="text-dark">ENTER</strong> to add quickly.</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Item Table -->
            <div class="table-responsive">
                <table class="table table-hover align-middle" id="items-table">
                    <thead>
                        <tr>
                            <th class="text-center" width="5%">#</th>
                            <th width="35%">Description</th>
                            <th class="text-center" width="10%">Unit</th>
                            <th class="text-center" width="15%">Qty</th>
                            <th class="text-end" width="15%">Rate (₹)</th>
                            <th class="text-end" width="15%">Amount (₹)</th>
                            <th class="text-center" width="5%"></th>
                        </tr>
                    </thead>
                    <tbody id="items-body">
                    </tbody>
                </table>
                <div id="empty-state" class="text-center py-5 text-muted">
                    <i class="bi bi-basket3 fs-1 d-block mb-2 opacity-10"></i>
                    No items added yet
                </div>
            </div>

           <div class="total-box">

    <div class="total-item-group">
        <label class="d-flex justify-content-between">
            Discount 
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" id="disc-type-toggle" style="width:36px; height:20px;">
                <label class="form-check-label text-white small" for="disc-type-toggle" id="disc-type-label">₹</label>
            </div>
        </label>
        <div class="input-group">
            <input type="number" id="discount" class="form-control form-control-sm" value="" min="0" placeholder="0.00">
            <button class="btn btn-outline-light btn-sm" type="button" id="round-off-btn" title="Round Off Total">
                <i class="bi bi-calculator"></i>
            </button>
        </div>
    </div>

    <div class="total-item-group">
        <label>Cash Paid</label>
        <input type="number" id="cash" class="form-control form-control-sm" value="" min="0" placeholder="0.00">
    </div>

    <div class="total-item-group">
        <label>UPI / Bank</label>
        <input type="number" id="upi" class="form-control form-control-sm" value="" min="0" placeholder="0.00">
    </div>

   <div class="total-item-group text-end w-auto">
        <label class="text-danger">Balance Due</label>
        <span id="Bal-amt"></span>
    </div>

    <div class="total-spacer"></div> 

    <div class="total-item-group text-end w-auto">
        <label class="text-white" style="font-size:14px">Subtotal</label>
        <span class="fw-bold text-white">₹<span id="subtotal"></span></span>
    </div>

    <div class="total-item-group text-end w-auto">
        <label class="total-big-label text-info">Grand Total</label>
        <span id="grand-total"></span>
    </div>

</div>
                <input type="hidden" id="cancelId" value="0"></input>
            <div class="d-flex justify-content-end gap-3 mt-4 flex-wrap align-items-center">
                <div class="me-auto">
                    <button id="hold-btn" class="btn btn-warning text-dark border border-dark-subtle shadow-sm">
                        <i class="bi bi-pause-circle me-1"></i>Hold Order
                    </button>
                    <button id="resume-btn" class="btn btn-info text-white border border-dark-subtle shadow-sm d-none">
                        <i class="bi bi-play-circle me-1"></i>Resume Order
                    </button>
                </div>

                <button id="cancel" class="btn btn-danger border d-none">
                        <i class="bi bi-arrow-counterclockwise me-2"></i>Cancel Last
                </button>
                <button id="recalculate" class="btn btn-light border shadow-sm">
                    <i class="bi bi-arrow-clockwise me-2"></i>Recalc
                </button>
                <button id="send-btn" class="btn btn-success px-5 shadow">
                    <i class="bi bi-printer-fill me-2"></i>Save & Print
                </button>
            </div>
        </div>
    </main>
</div>

<!-- HIDDEN PRINT AREA FOR THERMAL PRINTER -->
<div id="thermal-print-area">
    <div class="receipt-header">
        <h2 style="margin:0; font-size: 18px; font-weight: bold;"><%= orgName %></h2>
        <p style="margin:5px 0; font-size: 12px;">Receipt / Invoice</p>
        <p style="margin:0; font-size: 11px;">Bill No: <span id="print-inv-no" style="font-weight:bold"></span></p>
        <p style="margin:0; font-size: 11px;" id="print-date"></p>
        <p style="margin:0; font-size: 11px;">Bill To: <span id="print-cust">Walk-in</span></p>
    </div>
    <div class="receipt-divider"></div>
    
    <!-- Items -->
    <div id="print-items"></div>
    
    <div class="receipt-divider"></div>
    
    <div class="receipt-row">
        <span>Subtotal:</span>
        <span id="print-subtotal">0.00</span>
    </div>
    <div class="receipt-row">
        <span>Discount:</span>
        <span id="print-discount">0.00</span>
    </div>
    <div class="receipt-row" style="font-weight:bold; font-size:14px; margin-top:5px;">
        <span>TOTAL:</span>
        <span id="print-total">0.00</span>
    </div>
    
    <div class="receipt-divider"></div>
    <div class="receipt-row">
        <span>Cash:</span>
        <span id="print-cash">0.00</span>
    </div>
    <div class="receipt-row">
        <span>UPI:</span>
        <span id="print-upi">0.00</span>
    </div>
    <div class="receipt-row" style="font-weight:bold;">
        <span>BALANCE:</span>
        <span id="print-balance">0.00</span>
    </div>
    
    <div class="receipt-footer">
        <p>Thank you for your business!</p>
        <p>Software by Vijay Tech Orbit</p>
    </div>
</div>

<!-- LOADER -->
<div id="loader">
    <div class="box">
        <div class="spinner-border text-info" role="status" style="width: 1.5rem; height: 1.5rem;"></div>
        <span id="loader-text">Processing Sales Entry...</span>
    </div>
</div>

<!-- === WONDERFUL ALERT BOX (REPLACES TOAST AND CONFIRM) === -->
<div class="modal fade" id="wonderful-alert-box" tabindex="-1" aria-labelledby="wonderfulAlertLabel" aria-hidden="true" data-bs-backdrop="static">
  <div class="modal-dialog modal-dialog-centered modal-sm">
    <div class="modal-content wonderful-box text-center">
      <div class="modal-body p-4">
        
        <!-- Icon Area -->
        <div class="wonderful-icon-area" id="wb-icon-area">
          <!-- Icon injected by JS -->
        </div>

        <!-- Title -->
        <h5 class="wonderful-title" id="wb-title">Title</h5>
        
        <!-- Message -->
        <p class="wonderful-msg" id="wb-message">Message goes here...</p>

        <!-- Actions (Buttons) -->
        <div class="d-flex justify-content-center gap-2" id="wb-actions">
          <!-- Buttons injected by JS -->
        </div>

      </div>
    </div>
  </div>
</div>

<!-- ORIGINAL TOAST (Kept in DOM but logic replaced per request) -->
<div class="toast-container position-fixed bottom-0 end-0 p-4">
  <div id="liveToast" class="toast custom-toast align-items-center" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body d-flex align-items-center gap-3">
        <i id="toast-icon" class="bi fs-3"></i>
        <span id="toast-message" class="fw-semibold">Message here</span>
      </div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
 $(function () { 
    $("#cancelId").val("0");

    // Initialize Wonderful Box Modal
    const wonderfulModal = new bootstrap.Modal(document.getElementById('wonderful-alert-box'));

    /**
     * SHOW WONDERFUL BOX
     * Unified function for Success, Error, Warning, and Confirm messages.
     * Centers beautifully on all devices.
     */
    function showWonderfulBox(type, title, message, onConfirm, onCancel) {
        const $iconArea = $('#wb-icon-area');
        const $title = $('#wb-title');
        const $msg = $('#wb-message');
        const $actions = $('#wb-actions');

        $actions.empty(); // Clear previous buttons
        $title.text(title);
        $msg.html(message); // Allow HTML for line breaks

        let iconClass = '';
        let iconTag = '';

        // Determine Icon
        if (type === 'success') {
            iconClass = 'wb-icon-success';
            iconTag = '<i class="bi bi-check-circle-fill"></i>';
        } else if (type === 'error') {
            iconClass = 'wb-icon-error';
            iconTag = '<i class="bi bi-x-circle-fill"></i>';
        } else if (type === 'warning') {
            iconClass = 'wb-icon-warning';
            iconTag = '<i class="bi bi-exclamation-triangle-fill"></i>';
        } else if (type === 'confirm') {
            iconClass = 'wb-icon-confirm';
            iconTag = '<i class="bi bi-question-circle-fill"></i>';
        } else {
            // Default Info
            iconClass = 'wb-icon-confirm';
            iconTag = '<i class="bi bi-info-circle-fill"></i>';
        }

        $iconArea.removeClass().addClass('wonderful-icon-area ' + iconClass).html(iconTag);

        // Determine Buttons
        if (type === 'confirm') {
            // Two buttons: Confirm and Cancel
            const btnYes = $('<button class="btn wonderful-btn wb-btn-confirm">Yes, Proceed</button>');
            const btnNo = $('<button class="btn wonderful-btn wb-btn-cancel">Cancel</button>');

            btnYes.on('click', function() {
                wonderfulModal.hide();
                if (typeof onConfirm === 'function') onConfirm();
            });

            btnNo.on('click', function() {
                wonderfulModal.hide();
                if (typeof onCancel === 'function') onCancel();
            });

            $actions.append(btnYes, btnNo);
        } else {
            // One button: OK
            const btnOk = $('<button class="btn wonderful-btn wb-btn-confirm">OK</button>');
            
            btnOk.on('click', function() {
                wonderfulModal.hide();
                if (typeof onConfirm === 'function') onConfirm();
            });

            $actions.append(btnOk);
        }

        // Show Modal
        wonderfulModal.show();
    }

    /* ===========================
       QZ TRAY SETUP
       =========================== */
    qz.security.setCertificatePromise(function(resolve, reject) {
        resolve("-----BEGIN CERTIFICATE-----\nMIIDXTCCAkWgAwIBAgIJAKg0HhUxzBrdMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV\nBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX\naWRnaXRzIFB0eSBMdGQwHhcNMTcwOTA0MDQzOTI5WhcNMTgwOTA0MDQzOTI5WjBF\nMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50\nZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB\nCgKCAQEAuPwsKsV0g2EgLQLUjdInXx3gXVwJnCiC4K1/H6VNF2nzQ3VLDmKQAu7Jf\nwGpQ6KZZF+j2N7sUHnJyCkg+0R3bA3JX5V8kxvK7dOq4DlBjkURUqS3LY3U6K3jXJ\n5f0L6H8f8nKbJZJNYJVjmZJ8p2Wj8bZ6K5W1WfWZ9Wv7Jq0pY0UqY6F8R3bA3JX5V\n8kxvK7dOq4DlBjkURUqS3LY3U6K3jXJ5f0L6H8f8nKbJZJNYJVjmZJ8p2Wj8bZ6K\n5W1WfWZ9Wv7Jq0pY0UqY6F8R3bA3JX5V8kxvK7dOq4DlBjkURUqS3LY3U6K3jXJ5\nf0L6H8f8nKbJZJNYJVjmZJ8wIDAQABo1AwTjAdBgNVHQ4EFgQUhP7V5k4V8JF1dJK9JK9JK9JK9JK9JK9J\nK9JK9HwYDVR0lBBgwFAYKKwYBBAGCNwoDDAYKKwYBBAGCNwoDBDAKBggrBgEFBQcD\nATANBgkqhkiG9w0BAQsFAAOCAQEAXPQ3X3X3X3X3X3X3X3X3X3X3X\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3Q==\n-----END CERTIFICATE-----");
    });

    qz.security.setSignaturePromise(function(toSign) {
        return function(resolve, reject) {
            try {
                var pk = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC4/CwqxXSDYSAtA\ntS0MidaHeBdXAmcKILgrX8fpU0XafNDdUsOYoAC7sl/AalDoplkX6PY3uxQecnIKS\nD7RHdsDclfnXyTG8rt06rgOUOSRRFStLctjTorcel8n+0vofx/ycpslkk1glWOZnk\nynZaPxtnornVbVZ9Zn1a/smrSljRSpjoXxHdsDclfnXyTG8rt06rgOUOSRRFStLc\ntjTorcel8n+0vofx/ycpslkk1glWOZnkynZaPxtnornVbVZ9Zn1a/smrSljRSpjo\nXxHdsDclfnXyTG8rt06rgOUOSRRFStLctjTorcel8n+0vofx/ycpslkk1glWOZnk\nynZaPxtnornVbVZ9Zn1a/smrSljRSpjoXxHdsDclfnXyTG8rt06rgOUOSRRFStLc\ntjTorcel8n+0vofx/ycpslkk1glWbQIDAQABAoIBAE7P3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3Q==\n-----END PRIVATE KEY-----";
                var rsa = new KJUR.crypto.Signature({"alg": "SHA1withRSA"});
                rsa.init(pk);
                rsa.updateString(toSign);
                var hex = rsa.sign();
                resolve(stob64(hex));
            } catch (e) {
                console.error(e);
                reject(e);
            }
        };
    });

    function stob64(str) {
        return btoa(String.fromCharCode.apply(null, str.replace(/\r|\n/g, "").replace(/([\da-fA-F]{2}) ?/g, "0x$1 ").replace(/ +$/, "").split(" ")));
    }

    qz.websocket.connect().catch(function(err) {
        console.warn("QZ Tray Connection Failed (Will try again on print):", err);
    });

    /* ===========================
       Select2 Initialization
    =========================== */
    $("#manual-product").select2({
        placeholder: "-- Search Product --",
        width: "100%",
        allowClear: true,
        dropdownCssClass: "p-2",
        matcher: function (params, data) {
            if (!params.term || typeof params.term !== "string") return data;
            const term = params.term.toLowerCase();
            const text = String(data.text || "").toLowerCase();
            const sKey = String($(data.element).data("search") || "").toLowerCase();
            if (text.includes(term) || sKey.includes(term)) return data;
            return null;
        }
    });

    $('#manual-product').on('select2:select', function (e) { $(this).trigger('change'); });

    /* ===========================
       Date & Setup
    =========================== */
    const now = new Date();
    document.getElementById("invoice-date").textContent = now.toLocaleDateString("en-GB", {
        day: 'numeric', month: 'long', year: 'numeric'
    });
    checkHeldOrder();

    /* ===========================
       Table Logic
    =========================== */
    function checkEmptyState() {
        if ($('#items-body tr').length === 0) {
            $('#empty-state').show();
        } else {
            $('#empty-state').hide();
        }
    }

    function addRow(Id, name, unit, qty, rate) {
        $('#empty-state').hide(); 
        const tr = $('<tr>');
        const tdIndex = $('<td class="text-center fw-bold text-muted"></td>');
        const tdDesc  = $('<td>');
        const tdUom   = $('<td class="text-center">');
        const tdQty   = $('<td>');
        const tdRate  = $('<td>');
        const tdAmt   = $('<td class="text-end fw-bold amount">0.00</td>');
        const tdAct   = $('<td class="text-center">');

        const inDesc = $('<input type="text" class="form-control form-control-sm desc" readonly>').val(name);
        const inId   = $('<input type="hidden" class="ProdId">').val(Id);
        const inUom  = $('<input type="text" class="form-control form-control-sm uom text-center" readonly style="background:#f8f9fa">').val(unit);
        const inQty  = $('<input type="number" class="form-control form-control-sm qty text-center fw-bold" min="0" step="0.01">').val(qty);
        const inRate = $('<input type="number" class="form-control form-control-sm rate text-end" min="0" step="0.01">').val(rate);
        const btnDel = $('<button class="btn btn-sm btn-outline-danger remove-row"><i class="bi bi-x-lg"></i></button>');

        tdDesc.append(inDesc).append(inId);
        tdUom.append(inUom);
        tdQty.append(inQty);
        tdRate.append(inRate);
        tdAct.append(btnDel);

        tr.append(tdIndex, tdDesc, tdUom, tdQty, tdRate, tdAmt, tdAct);
        tr.hide().appendTo("#items-body").fadeIn(300);

        btnDel.on('click', function() {
            tr.fadeOut(300, function() { 
                $(this).remove(); 
                recalc(); 
                checkEmptyState();
            });
        });

        inQty.on('input', updateRow);
        inRate.on('input', updateRow);

        function updateRow() {
            const q = parseFloat(inQty.val()) || 0;
            const r = parseFloat(inRate.val()) || 0;
            tdAmt.text((q * r).toFixed(2));
            recalc();
        }
        updateRow();
    }

    /* ===========================
       Calculations
    =========================== */
    function recalc() {
        let sub = 0;
        $("#items-body tr").each(function (i) {
            $(this).find("td:first").text(i + 1);
            const val = parseFloat($(this).find(".amount").text()) || 0;
            sub += val;
        });
        $("#subtotal").text(sub.toFixed(2));
        calculateTotal();
    }

    function calculateTotal() {
        let sub = parseFloat($("#subtotal").text()) || 0;
        let discInput = parseFloat($("#discount").val()) || 0;
        let isPercent = $("#disc-type-toggle").is(":checked");
        
        let discAmount = 0;
        if(isPercent) {
            discAmount = sub * (discInput / 100);
        } else {
            discAmount = discInput;
        }
        
        let total = Math.max(0, sub - discAmount);
        $("#grand-total").text(total.toFixed(2));
        calculateBalance();
    }

    $("#disc-type-toggle").on("change", function() {
        $("#disc-type-label").text($(this).is(":checked") ? "%" : "₹");
        calculateTotal();
    });
    $("#discount").on("input", calculateTotal);
    $("#cash").on("input", calculateBalance);
    $("#upi").on("input", calculateBalance);
    $("#recalculate").on("click", function(e){ e.preventDefault(); recalc(); });
    
    $("#round-off-btn").on("click", function() {
        let sub = parseFloat($("#subtotal").text()) || 0;
        let nearestRound = Math.round(sub);
        let diff = sub - nearestRound;
        
        if(diff > 0) {
            $("#discount").val(diff.toFixed(2));
            if($("#disc-type-toggle").is(":checked")) {
                 $("#disc-type-toggle").prop("checked", false).trigger("change");
            }
            calculateTotal();
            showWonderfulBox('success', 'Rounded Off', 'Total rounded off to ₹' + nearestRound.toFixed(2));
        }
    });

    $("#manual-product").on("change", function () {
        const val = this.value;
        if (!val) return;
        const parts = val.split("|");
        const prodId = $(this).find(":selected").data("prodid") || "0";
        
        let exists = false;
        $("#items-body tr").each(function() {
             if($(this).find(".ProdId").val() == prodId) {
                 const qInput = $(this).find(".qty");
                 qInput.val((parseFloat(qInput.val()) || 0) + 1).trigger('input');
                 exists = true;
                 $(this).addClass("table-info");
                 setTimeout(() => $(this).removeClass("table-info"), 500);
             }
        });

        if(!exists) {
            addRow(prodId, parts[0], parts[2], 1, parseFloat(parts[1])||0);
        }
        
        $(this).val(null).trigger('change');
        setTimeout(function() {
            $('#manual-product').select2('open'); 
        }, 100);
    });

    function calculateBalance() {
        const cash = parseFloat($("#cash").val()) || 0;
        const upi  = parseFloat($("#upi").val()) || 0;
        const grandTotal = parseFloat($("#grand-total").text()) || 0;
        const paid = cash + upi;
        const balance = grandTotal - paid;

        const balElem = $("#Bal-amt");
        balElem.text(balance.toFixed(2));
        
        if(balance <= 0.1) {
            balElem.removeClass('text-danger').addClass('text-success');
        } else {
            balElem.removeClass('text-success').addClass('text-danger');
        }
    }

    /* ===========================
       Hold / Resume Logic
    =========================== */
    $("#hold-btn").on("click", function() {
        if($("#items-body tr").length === 0) {
            showWonderfulBox('error', 'Cart Empty', 'There are no items to hold.');
            return;
        }
        const holdData = {
            customer: {
                name: $("#cust-name").val(),
                address: $("#cust-address").val(),
                phone: $("#cust-phone").val()
            },
            items: [],
            discount: $("#discount").val(),
            isDiscPercent: $("#disc-type-toggle").is(":checked")
        };
        
        $("#items-body tr").each(function() {
            holdData.items.push({
                prodId: $(this).find(".ProdId").val(),
                name: $(this).find(".desc").val(),
                uom: $(this).find(".uom").val(),
                qty: $(this).find(".qty").val(),
                rate: $(this).find(".rate").val()
            });
        });
        
        localStorage.setItem('vijay_held_order', JSON.stringify(holdData));
        showWonderfulBox('success', 'Order Held', 'The current order has been saved successfully.');
        resetInvoiceForm();
        checkHeldOrder();
    });

    function checkHeldOrder() {
        const held = localStorage.getItem('vijay_held_order');
        if(held) {
            $("#resume-btn").removeClass("d-none");
        } else {
            $("#resume-btn").addClass("d-none");
        }
    }

    $("#resume-btn").on("click", function() {
        const held = JSON.parse(localStorage.getItem('vijay_held_order'));
        if(!held) return;
        
        // Show Wonderful Confirmation Box
        showWonderfulBox('confirm', 'Resume Order?', 'Resume previous held order? The current cart will be cleared.', 
            function() { // On Confirm
                $("#cust-name").val(held.customer.name);
                $("#cust-address").val(held.customer.address);
                $("#cust-phone").val(held.customer.phone);
                $("#discount").val(held.discount);
                $("#disc-type-toggle").prop("checked", held.isDiscPercent).trigger("change");

                $("#items-body").empty();
                held.items.forEach(item => {
                    addRow(item.prodId, item.name, item.uom, item.qty, item.rate);
                });
                
                localStorage.removeItem('vijay_held_order');
                checkHeldOrder();
                showWonderfulBox('success', 'Resumed', 'Order has been resumed successfully.');
            },
            function() { // On Cancel
                // Do nothing
            }
        );
    });

    /* ===========================
       Utils
    =========================== */
    const toastEl = document.getElementById('liveToast');
    const toast = new bootstrap.Toast(toastEl, { delay: 4000 });

    function resetInvoiceForm() {
        $('.invoice-box').css('opacity', '0.5');
        setTimeout(() => {
            $('#cust-name, #cust-address, #cust-phone').val('');
            $('#manual-product').val(null).trigger('change');
            $('#discount').val(''); 
            $('#cash').val('');     
            $('#upi').val('');      

            $('#items-body').empty();
            checkEmptyState();

            $('#subtotal').text('');     
            $('#grand-total').text('');  
            $('#Bal-amt').text('');     

            $('.invoice-box').css('opacity', '1');
        }, 300);
    }

    function toggleCancelButton() {
        const cancelId = $("#cancelId").val();
        if (cancelId && cancelId !== "0") {
            $("#cancel").removeClass("d-none");
        } else {
            $("#cancel").addClass("d-none");
        }
    }

    /* ===========================
    THERMAL PRINTER LOGIC
 =========================== */
 function printThermalReceipt(docNo) {
     // 1. Populate Data
     $('#print-date').text(new Date().toLocaleString());
     $('#print-inv-no').text(docNo || "PENDING");
     
     const custName = $('#cust-name').val();
     $('#print-cust').text(custName ? custName : 'Walk-in Customer');
     
     let itemsHtml = '';
     $('#items-body tr').each(function() {
         const name = $(this).find('.desc').val();
         const qty = $(this).find('.qty').val();
         const rate = $(this).find('.rate').val();
         const amt = $(this).find('.amount').text();
         const shortName = name.length > 18 ? name.substring(0, 18) + '..' : name;
         
         itemsHtml += `
             <div class="receipt-row" style="font-size:11px;">
                 <span>${shortName} x${qty}</span>
                 <span>${amt}</span>
             </div>
         `;
     });
     $('#print-items').html(itemsHtml);
     
     $('#print-subtotal').text($('#subtotal').text() || "0.00");
     $('#print-discount').text($('#discount').val() + ($("#disc-type-toggle").is(":checked")?"%":""));
     $('#print-total').text($('#grand-total').text() || "0.00");
     $('#print-cash').text($('#cash').val() || "0.00");
     $('#print-upi').text($('#upi').val() || "0.00");
     $('#print-balance').text($('#Bal-amt').text() || "0.00");

     // 2. QZ Tray Printing
     var connectPromise = Promise.resolve();
     if (!qz.websocket.isActive()) {
         connectPromise = qz.websocket.connect();
     }

     connectPromise.then(function() {
         return qz.printers.getDefault().catch(function(e) {
             console.warn("No default printer found, searching...");
             return qz.printers.find();
         });
     }).then(function(printer) {
         if (!printer) {
             throw new Error("No printer selected or available.");
         }
         var config = qz.configs.create(printer);
         var printData = [
             {
                 type: 'html',
                 format: 'plain', 
                 content: document.getElementById('thermal-print-area').innerHTML
             }
         ];
         return qz.print(config, printData);
     }).then(function() {
         console.log("Printed successfully");
     }).catch(function(err) {
         console.error("Print Error:", err);
         if (qz.websocket.isActive()) {
              console.warn("Connection recovered or transient error occurred, print may still execute.");
         }
     });
 }
    /* ===========================
       AJAX SAVE
    =========================== */
    $("#send-btn").on("click", function () {
        if ($("#items-body tr").length === 0) {
            showWonderfulBox('warning', 'Missing Items', 'Please add at least one product to proceed.');
            return;
        }

        var balAmt = parseFloat($("#Bal-amt").text()) || 0;
        
        if (balAmt < -0.1) {
            showWonderfulBox('error', 'Payment Error', 'Payment amount exceeds the total invoice amount!');
            return;
        }

        // Activate Loader
        $("#loader").css("display", "flex").addClass("active");

        const data = {
            discountType: $("#disc-type-toggle").is(":checked") ? "PERCENT" : "FIXED",
            discount: parseFloat($("#discount").val()) || 0,
            subtotal: $("#subtotal").text(),
            total: $("#grand-total").text(),
            customer: {
                name: $("#cust-name").val(),
                address: $("#cust-address").val(),
                phone: $("#cust-phone").val()
            },
            items: []
        };

        $("#items-body tr").each(function () {
            const row = $(this);
            data.items.push({
                prodId: row.find(".ProdId").val(),
                product: row.find(".desc").val(),
                unit: row.find(".uom").val(),
                qty: parseFloat(row.find(".qty").val()) || 0,
                rate: parseFloat(row.find(".rate").val()) || 0,
                amount: parseFloat(row.find(".amount").text()) || 0
            });
        });

        $.ajax({
            type: "POST",
            url: "<%= request.getContextPath() %>/SalesSaveServlet",
            data: JSON.stringify({ salesData: data }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                $("#loader").removeClass("active");
                setTimeout(() => { $("#loader").hide(); }, 300);

                if (response && response.status === "success") {
                    const docNo = response.docNo;
                    $("#cancelId").val(docNo);
                    toggleCancelButton();
                    
                    showWonderfulBox('success', 'Invoice Saved', `Invoice No. <strong>${docNo}</strong> saved successfully! Printing receipt...`);
                        
                    printThermalReceipt(docNo);
                    
                    resetInvoiceForm();

                } else {
                    const err = response ? (response.error || response.message) : "Unknown error";
                    showWonderfulBox('error', 'Save Failed', err);
                }
            },
            error: function (xhr, status, error) {
                $("#loader").removeClass("active");
                setTimeout(() => { $("#loader").hide(); }, 300);
                // Show error in Wonderful Box
                showWonderfulBox('error', 'Connection Failed', 'Server Connection Failed: ' + error);
                console.error(xhr);
            }
        });
    });
    
    /* ===========================
       CANCEL ENTRY LOGIC
    =========================== */
    $("#cancel").on("click", function () {
        const cancelId = $("#cancelId").val();
        if (!cancelId || cancelId === "0") {
            showWonderfulBox('error', 'Error', 'Document ID not found.');
            return; 
        }
        
        // Wonderful Confirmation Box
        showWonderfulBox('confirm', 'Cancel Invoice?', 'Are you sure you want to CANCEL this invoice? This action cannot be undone.',
            function() { // On Confirm
                $("#loader").css("display", "flex").addClass("active");
                $.ajax({
                    type: "POST",
                    url: "<%= request.getContextPath() %>/CancelSalesEntry",
                    data: { documentNo: cancelId },
                    success: function (response) {
                        $("#loader").removeClass("active");
                        setTimeout(() => { $("#loader").hide(); }, 300);
                        if (response && response.status === "success") {
                            $("#cancelId").val("0");
                            $("#cancel").addClass("d-none");
                            showWonderfulBox('success', 'Canceled', 'The invoice has been canceled successfully.');
                            resetInvoiceForm();
                        } else {
                            const err = response ? (response.error || response.message) : "Unknown error";
                            showWonderfulBox('error', 'Failed', err);
                        }
                    },
                    error: function (xhr, status, error) {
                        $("#loader").removeClass("active");
                        setTimeout(() => { $("#loader").hide(); }, 300);
                        showWonderfulBox('error', 'Connection Failed', "Server Connection Failed: " + error);
                    }
                });
            },
            function() { // On Cancel
                // Do nothing
            }
        );
    });

});
</script>
</body>
</html>