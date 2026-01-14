<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="org.vijaytech.oilshop.Organization" %>
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

  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
  
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
  <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
  <!-- QZ Tray -->
<script src="https://cdn.jsdelivr.net/npm/qz-tray@2.2.4/qz-tray.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jsrsasign/10.8.6/jsrsasign-all-min.js"></script>


<style>
    :root {
      --accent: #15a0c6;
      --accent-dark: #0e7d9b;
      --bg-slate: #f8fafc;
      --header-bg: rgba(10, 18, 32, 0.95);
      --glass-border: rgba(255, 255, 255, 0.1);
      --card-radius: 24px;
      --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: var(--bg-slate);
      color: #1e293b;
      margin: 0;
      padding-top: 90px; /* Space for fixed header */
      min-height: 100vh;
      background-image: 
        radial-gradient(at 0% 0%, rgba(21, 160, 198, 0.03) 0px, transparent 50%),
        radial-gradient(at 100% 100%, rgba(10, 18, 32, 0.02) 0px, transparent 50%);
    }

    /* ===========================
       FLOATING HEADER
    =========================== */
    .app-header {
      position: fixed;
      top: 0; right: 0; left: 0;
      height: 75px;
      background: var(--header-bg);
      backdrop-filter: blur(12px);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 40px;
      z-index: 1040; /* High z-index */
      border-bottom: 1px solid var(--glass-border);
      box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    }

    .header-title {
      font-weight: 800;
      font-size: 1.25rem;
      color: #fff;
      letter-spacing: -0.5px;
      display: flex;
      align-items: center;
    }

    .header-action {
      background: rgba(255, 255, 255, 0.05);
      padding: 8px 16px;
      border-radius: 12px;
      border: 1px solid var(--glass-border);
      display: flex;
      align-items: center;
      transition: var(--transition);
    }

    /* ===========================
       CONTAINER & CARDS
    =========================== */
    .page-wrap {
      padding: 20px 40px 100px 40px;
      max-width: 1400px; /* Slightly wider for modern screens */
      margin: 0 auto;
    }

    .invoice-box {
      background: #ffffff;
      border-radius: var(--card-radius);
      padding: 40px;
      box-shadow: 0 10px 40px -10px rgba(0,0,0,0.05);
      border: 1px solid #edf2f7;
      position: relative;
      overflow: hidden;
    }

    /* Decorative top accent */
    .invoice-box::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 6px;
        background: linear-gradient(90deg, var(--accent), #4f46e5);
    }

    .invoice-head {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 30px;
      padding-bottom: 20px;
      border-bottom: 1px solid #f1f5f9;
    }

    .org-title {
      font-size: 24px;
      font-weight: 800;
      color: #0f172a;
      letter-spacing: -1px;
    }

    /* ===========================
       INPUTS & CONTROLS
    =========================== */
    .border-dashed {
      border: 2px dashed #cbd5e1;
      border-radius: 18px;
      padding: 25px;
      background: #f8fafc;
      transition: var(--transition);
      height: 100%;
    }
    
    .border-dashed:hover {
        border-color: var(--accent);
        background: #fff;
    }

    .form-control, .form-select {
      height: 48px;
      border-radius: 12px;
      border: 1px solid #e2e8f0;
      padding: 10px 15px;
      font-size: 14px;
      font-weight: 500;
      transition: var(--transition);
      box-shadow: 0 2px 5px rgba(0,0,0,0.02);
    }

    .form-control:focus, .form-select:focus {
      border-color: var(--accent);
      box-shadow: 0 0 0 4px rgba(21, 160, 198, 0.15);
      background-color: #fff;
    }

    .form-control-sm {
        height: 38px;
        border-radius: 8px;
    }

    /* Select2 Customization */
    .select2-container--default .select2-selection--single {
      height: 48px !important;
      border-radius: 12px !important;
      border-color: #e2e8f0 !important;
      background: #fff !important;
      display: flex;
      align-items: center;
    }
    .select2-container--default .select2-selection--single .select2-selection__arrow {
        top: 10px !important;
    }

    /* ===========================
       TABLE STYLES
    =========================== */
    .table-responsive {
      border-radius: 16px;
      border: 1px solid #f1f5f9;
      margin-top: 25px;
      overflow-x: auto;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
    }

    .table { margin-bottom: 0; }
    
    .table thead th {
      background: #f1f5f9;
      text-transform: uppercase;
      font-size: 11px;
      font-weight: 700;
      color: #64748b;
      padding: 18px 15px;
      border: none;
      white-space: nowrap;
    }

    .table tbody td {
      padding: 15px;
      border-bottom: 1px solid #f1f5f9;
      vertical-align: middle;
      font-size: 14px;
    }
    
    /* Remove row button */
    .remove-row {
        width: 30px; height: 30px;
        padding: 0;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
    }

    /* ===========================
       TOTALS BOX (Modern High Contrast)
    =========================== */
    .total-box {
      background: #0f172a;
      border-radius: 20px;
      padding: 30px;
      color: #fff;
      display: flex;
      flex-wrap: wrap;
      gap: 30px;
      justify-content: flex-end;
      align-items: center;
      margin-top: 30px;
      box-shadow: 0 20px 40px -10px rgba(15, 23, 42, 0.3);
    }

    .total-item-group {
      display: flex;
      flex-direction: column;
      min-width: 120px;
    }

    .total-item-group label {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      color: #94a3b8;
      margin-bottom: 8px;
    }

    .total-item-group .form-control-sm {
      background: rgba(255,255,255,0.1);
      border: 1px solid rgba(255,255,255,0.15);
      color: #fff;
      text-align: right;
    }
    
    .total-item-group .form-control-sm:focus {
        background: rgba(255,255,255,0.2);
        box-shadow: none;
        border-color: var(--accent);
    }

    #grand-total {
      font-size: 32px;
      color: var(--accent);
      font-weight: 800;
      line-height: 1;
    }

    /* ===========================
       BUTTONS
    =========================== */
    .btn {
        padding: 12px 24px;
        border-radius: 12px;
        font-weight: 600;
        letter-spacing: 0.3px;
    }

    .btn-success {
      background: var(--accent);
      border: none;
      box-shadow: 0 10px 20px -5px rgba(21, 160, 198, 0.4);
      transition: var(--transition);
    }

    .btn-success:hover {
      background: var(--accent-dark);
      transform: translateY(-2px);
      box-shadow: 0 15px 25px -5px rgba(21, 160, 198, 0.5);
    }

    /* Loader Overlay */
    #loader {
      background: rgba(255, 255, 255, 0.8);
      backdrop-filter: blur(5px);
      display: none;
      align-items: center;
      justify-content: center;
      position: fixed;
      inset: 0;
      z-index: 9999;
    }

    #loader .box {
      background: #0f172a;
      color: #fff;
      padding: 30px 50px;
      border-radius: 20px;
      font-weight: 600;
      box-shadow: 0 20px 50px rgba(0,0,0,0.2);
      display: flex;
      align-items: center;
      gap: 15px;
    }

    /* ===========================
       MEDIA QUERIES (Responsive)
    =========================== */
    @media (max-width: 992px) {
        .page-wrap { padding: 20px; }
        .invoice-box { padding: 25px; }
        .total-box { justify-content: space-between; }
    }

    @media (max-width: 768px) {
        .app-header { padding: 0 20px; height: 65px; }
        .header-title span { display: none; } /* Hide text keep icon on small */
        body { padding-top: 75px; }
        
        .invoice-head {
            flex-direction: column;
            align-items: flex-start;
            gap: 15px;
        }
        .invoice-head .text-end {
            text-align: left !important;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .col-lg-5, .col-lg-7 { width: 100%; } /* Stack columns */
        
        /* Force table to be scrollable */
        .table-responsive { overflow-x: auto; }
        
        .total-box {
            flex-direction: column;
            align-items: stretch;
            padding: 20px;
        }
        .total-item-group { width: 100%; text-align: left !important; }
        .total-item-group .form-control-sm { text-align: left; }
        
        .d-flex.justify-content-end.gap-3 {
            flex-direction: column;
        }
        .btn { width: 100%; }
    }
  </style>
</head>
<body>

<header class="app-header">
    <div class="header-left">
        <div class="header-title">
            <i class="bi bi-cart-check-fill me-2 text-info fs-4"></i>
            <span>Sales Entry</span>
        </div>
    </div>

    <div class="header-right">
        <div class="header-action">
            <i class="bi bi-building-fill text-info me-2"></i>
            <span class="text-white small fw-bold text-uppercase"><%= orgName %></span>
        </div>
    </div>
</header>

<%@ include file="sidebar.jsp" %>

<div class="page-wrap" id="pageWrap">
    <main class="container-main">
        <div class="invoice-box">
            
            <div class="invoice-head">
                <div>
                    <div class="org-title"><%= orgName %></div>
                    <div class="badge rounded-pill bg-info bg-opacity-10 text-info mt-2 px-3 py-2">
                        <i class="bi bi-receipt me-1"></i> NEW INVOICE
                    </div>
                </div>
                <div class="text-end">
                    <div class="text-muted small fw-bold text-uppercase tracking-wide">Date</div>
                    <div class="fw-bold fs-5" id="invoice-date"></div>
                </div>
            </div>

            <div class="row g-4 mb-4">
                <div class="col-12 col-lg-5">
                    <div class="border-dashed">
                        <div class="d-flex align-items-center mb-4">
                            <div class="bg-primary bg-opacity-10 p-2 rounded-circle me-3">
                                <i class="bi bi-person-lines-fill text-primary"></i>
                            </div>
                            <span class="fw-bold fs-5 text-dark">Bill To</span>
                        </div>
                        <div class="form-floating mb-3">
                            <input type="text" class="form-control" id="cust-name" placeholder="Name">
                            <label for="cust-name">Customer Name</label>
                        </div>
                        <div class="form-floating mb-3">
                            <input type="text" class="form-control" id="cust-address" placeholder="Address">
                            <label for="cust-address">Address</label>
                        </div>
                        <div class="form-floating">
                            <input type="text" class="form-control" id="cust-phone" placeholder="Phone">
                            <label for="cust-phone">Phone Number</label>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-lg-7">
                    <div class="p-4 bg-light rounded-4 border h-100">
                        <label class="form-label fw-bold d-flex justify-content-between mb-3">
                            <span class="text-dark"><i class="bi bi-box-seam me-2"></i>Add Products</span>
                            <span class="text-primary small cursor-pointer"><i class="bi bi-search me-1"></i>Search Inventory</span>
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
                        
                        <div class="d-flex align-items-center gap-2 text-muted small bg-white p-3 rounded border">
                             <i class="bi bi-info-circle-fill text-primary"></i>
                             <span>Selecting a product automatically adds it to the list below. You can adjust quantity there.</span>
                        </div>
                    </div>
                </div>
            </div>

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
                    <i class="bi bi-basket3 fs-1 d-block mb-2 opacity-25"></i>
                    No items added yet
                </div>
            </div>

            <div class="total-box">
                <div class="total-item-group">
                    <label>Discount (₹)</label>
                    <input type="number" id="discount" class="form-control form-control-sm" value="0">
                </div>
                <div class="total-item-group">
                    <label>Cash Paid</label>
                    <input type="number" id="cash" class="form-control form-control-sm" value="0">
                </div>
                <div class="total-item-group">
                    <label>UPI / Bank</label>
                    <input type="number" id="upi" class="form-control form-control-sm" value="0">
                </div>
                
                <div class="vr d-none d-lg-block bg-secondary opacity-25" style="height: 50px;"></div>

                <div class="total-item-group text-end">
                    <label>Subtotal</label>
                    <span class="fw-bold fs-5 opacity-75">₹<span id="subtotal">0.00</span></span>
                </div>
                <div class="total-item-group text-end">
                    <label class="text-info">Grand Total</label>
                    <span id="grand-total">0.00</span>
                </div>
            </div>
				<input type="hidden" id="cancelId" value="0"></input>
            <div class="d-flex justify-content-end gap-3 mt-4">
            <button id="cancel" class="btn btn-danger border">
                    <i class="bi bi-arrow me-2"></i>Cancel Entry
                </button>
                <button id="recalculate" class="btn btn-light border">
                    <i class="bi bi-arrow-clockwise me-2"></i>Recalculate
                </button>
                <button id="send-btn" class="btn btn-success px-5">
                    <i class="bi bi-send-fill me-2"></i>Finalize & Save
                </button>
            </div>
        </div>
    </main>
</div>

<div id="loader">
    <div class="box">
        <div class="spinner-border text-info" role="status"></div>
        <span>Processing Sales Entry...</span>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1055;">
  <div id="liveToast" class="toast align-items-center border-0" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body d-flex align-items-center gap-2">
        <i id="toast-icon" class="bi bi-check-circle-fill fs-5"></i>
        <span id="toast-message" class="fw-semibold">Message here</span>
      </div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
  </div>
</div>
<iframe id="printFrame"
        style="display:none;width:0;height:0;border:0"></iframe>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
$(function () { 
	$("#cancelId").val("0");

    /* ===========================
       Select2 Initialization
    =========================== */
    $("#manual-product").select2({
        placeholder: "-- Search Product --",
        width: "100%",
        allowClear: true,
        dropdownCssClass: "p-2",

        matcher: function (params, data) {

            // If no search term, return all data
            if (!params.term || typeof params.term !== "string") {
                return data;
            }

            // Ensure text is always a string
            const term = params.term.toLowerCase();
            const text = String(data.text || "").toLowerCase();

            // Ensure custom search key is string
            const sKey = String($(data.element).data("search") || "").toLowerCase();

            // Match against visible text OR custom search key
            if (text.includes(term) || sKey.includes(term)) {
                return data;
            }

            return null;
        }
    });


    /* ===========================
       Sidebar & Layout Logic
    =========================== */
    const toggleBtn = document.getElementById('sidebarToggle');
    const htmlEl = document.documentElement;
    const STORAGE_KEY = 'sidebarOpenVijay_purchase';
    const isOpen = localStorage.getItem(STORAGE_KEY) === '1';

    if (isOpen && toggleBtn) {
        htmlEl.classList.add('sidebar-open');
        if(toggleBtn) toggleBtn.setAttribute('aria-expanded', 'true');
    }

    function setSidebarOpen(open) {
        if (!toggleBtn) return;
        if (open) {
            htmlEl.classList.add('sidebar-open');
            toggleBtn.setAttribute('aria-expanded', 'true');
            localStorage.setItem(STORAGE_KEY, '1');
        } else {
            htmlEl.classList.remove('sidebar-open');
            toggleBtn.setAttribute('aria-expanded', 'false');
            localStorage.setItem(STORAGE_KEY, '0');
        }
        document.documentElement.style.setProperty(
            '--content-offset',
            open ? getComputedStyle(document.documentElement).getPropertyValue('--sidebar-width') : '0px'
        );
    }

    if (toggleBtn) {
        toggleBtn.addEventListener('click', (e) => {
            e.preventDefault();
            setSidebarOpen(!htmlEl.classList.contains('sidebar-open'));
        });
    }

    /* ===========================
       Date & Setup
    =========================== */
    document.getElementById("invoice-date").textContent = new Date().toLocaleDateString("en-GB", {
        day: 'numeric', month: 'long', year: 'numeric'
    });

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
        $('#empty-state').hide(); // Hide empty placeholder

        const tr = $('<tr>');

        // Cells
        const tdIndex = $('<td class="text-center fw-bold text-muted"></td>');
        const tdDesc  = $('<td>');
        const tdUom   = $('<td class="text-center">');
        const tdQty   = $('<td>');
        const tdRate  = $('<td>');
        const tdAmt   = $('<td class="text-end fw-bold amount">0.00</td>');
        const tdAct   = $('<td class="text-center">');

        // Inputs
        const inDesc = $('<input type="text" class="form-control form-control-sm desc" readonly>').val(name);
        const inId   = $('<input type="hidden" class="ProdId">').val(Id);
        
        const inUom  = $('<input type="text" class="form-control form-control-sm uom text-center" readonly style="background:#f8f9fa">').val(unit);
        
        const inQty  = $('<input type="number" class="form-control form-control-sm qty text-center fw-bold" min="0" step="0.01">').val(qty);
        
        const inRate = $('<input type="number" class="form-control form-control-sm rate text-end" min="0" step="0.01">').val(rate);

        const btnDel = $('<button class="btn btn-sm btn-outline-danger remove-row"><i class="bi bi-x-lg"></i></button>');

        // Assemble
        tdDesc.append(inDesc).append(inId);
        tdUom.append(inUom);
        tdQty.append(inQty);
        tdRate.append(inRate);
        tdAct.append(btnDel);

        tr.append(tdIndex, tdDesc, tdUom, tdQty, tdRate, tdAmt, tdAct);
        
        // Add Animation
        tr.hide().appendTo("#items-body").fadeIn(300);

        // Events
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

    function recalc() {
        let sub = 0;
        $("#items-body tr").each(function (i) {
            $(this).find("td:first").text(i + 1); // Renumber
            const val = parseFloat($(this).find(".amount").text()) || 0;
            sub += val;
        });

        $("#subtotal").text(sub.toFixed(2));
        
        const disc = parseFloat($("#discount").val()) || 0;
        const total = Math.max(0, sub - disc);
        
        $("#grand-total").text(total.toFixed(2));
    }

    $("#discount").on("input", recalc);
    $("#recalculate").on("click", function(e){
        e.preventDefault();
        recalc();
        // Visual feedback
        const icon = $(this).find('i');
        icon.addClass('spin-anim'); 
        setTimeout(() => icon.removeClass('spin-anim'), 500);
    });

    // Product Select Listener
    $("#manual-product").on("change", function () {
        const val = this.value;
        if (!val) return;

        const parts = val.split("|");
        const prodId = $(this).find(":selected").data("prodid") || "0";
        
        // Check duplicate
        let exists = false;
        $("#items-body tr").each(function() {
             if($(this).find(".ProdId").val() == prodId) {
                 const qInput = $(this).find(".qty");
                 qInput.val((parseFloat(qInput.val()) || 0) + 1).trigger('input');
                 exists = true;
                 
                 // Highlight row
                 $(this).addClass("table-info");
                 setTimeout(() => $(this).removeClass("table-info"), 500);
             }
        });

        if(!exists) {
            addRow(prodId, parts[0], parts[2], 1, parseFloat(parts[1])||0);
        }

        $(this).val("").trigger("change");
    });

    /* ===========================
       Toast / Response Helper
    =========================== */
    const toastEl = document.getElementById('liveToast');
    const toast = new bootstrap.Toast(toastEl, { delay: 4000 });

    function showToast(type, msg) {
        const bgClass = type === 'success' ? 'text-bg-success' : 'text-bg-danger';
        const iconClass = type === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill';
        
        $('#liveToast').removeClass('text-bg-success text-bg-danger').addClass(bgClass);
        $('#toast-icon').removeClass().addClass('bi ' + iconClass + ' fs-5');
        $('#toast-message').text(msg);
        toast.show();
    }

    /* ===========================
       RESET FORM (Clear Data)
    =========================== */
    function resetInvoiceForm() {
        // Fade out box content briefly
        $('.invoice-box').css('opacity', '0.5');
        
        setTimeout(() => {
            // Clear Customer
            $('#cust-name, #cust-address, #cust-phone').val('');
            
            // Clear Table
            $('#items-body').empty();
            checkEmptyState();
            
            // Clear Totals
            $('#discount, #cash, #upi').val('0');
            $('#subtotal, #grand-total').text('0.00');
            
            // Reset Select2
            $('#manual-product').val(null).trigger('change');
            
            // Restore Opacity
            $('.invoice-box').css('opacity', '1');
            
        }, 300);
    }

    /* ===========================
       AJAX SAVE
    =========================== */
    function toggleCancelButton() {
        const cancelId = $("#cancelId").val();
        if (cancelId && cancelId !== "0") {
            $("#cancel").removeClass("d-none");
        } else {
            $("#cancel").addClass("d-none");
        }
    }

    $("#send-btn").on("click", function () {
        // Simple Validation
        if ($("#items-body tr").length === 0) {
            showToast('error', 'Please add at least one product.');
            return;
        }

        $("#loader").css("display", "flex");

        const data = {
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
                $("#loader").hide();

                if (response && response.status === "success") {
                	$("#cancelId").val(response.docNo);
                	/* alert("doc Id "+$("#cancelId").val()); */
                	console.log("cancel id "+$("#cancelId").val());
                	toggleCancelButton();
                    // 1. Show Success Message
                    showToast('success', 'Invoice Saved Successfully!');
							console.log("pdf Path : "+response.pdfUrl);
			                    // 2. Open PDF/Bill if available
			                   if (response.pdfUrl) {
			   <%--   $.ajax({
			        type: "POST",
			        url: "<%= request.getContextPath() %>/ThermalPrintServer",
			        data: {
			            pdf: response.pdfUrl
			        }
			    }); --%> 
			}

 					<%--  else if (response.fileName) {
                        const fb = "<%=request.getContextPath()%>/invoices/" + encodeURIComponent(response.fileName);
                        window.open(fb, "_blank");
                    } --%>

                    // 3. Clear Data (Don't show old data)
                    resetInvoiceForm();

                } else {
                    const err = response ? (response.error || response.message) : "Unknown error";
                    showToast('error', err);
                }
            },
            error: function (xhr, status, error) {
                $("#loader").hide();
                showToast('error', 'Server Connection Failed: ' + error);
                console.error(xhr);
            }
        });
    });
    
    $("#cancel").on("click", function () {

        const cancelId = $("#cancelId").val();
        if (!cancelId || cancelId === "0") {
            return; // safety guard
        }
	console.log("poooo "+cancelId);
        $("#loader").show();

        $.ajax({
            type: "POST",
            url: "<%= request.getContextPath() %>/CancelSalesEntry",
            data: {
            	documentNo: cancelId
            },

            success: function (response) {
                $("#loader").hide();

                if (response && response.status === "success") {

                    $("#cancelId").val("0");
                    $("#cancel").addClass("d-none");

                    showToast("success", "Canceled Successfully!");
                    resetInvoiceForm();

                } else {
                    const err = response ? (response.error || response.message) : "Unknown error";
                    showToast("error", err);
                }
            },

            error: function (xhr, status, error) {
                $("#loader").hide();
                showToast("error", "Server Connection Failed: " + error);
                console.error(xhr);
            }
        });

    });

    /* ===========================
    TVS RP 3200 LITE – SILENT PRINT
 =========================== */
 async function silentThermalPrint(pdfUrl) {
     try {
         if (!qz.websocket.isActive()) {
             await qz.websocket.connect();
         }

         const printer = await qz.printers.getDefault();

         const config = qz.configs.create(printer, {
             rasterize: true,
             scaleContent: false,
             density: 203,
             size: { width: 80 }   // FORCE 80mm
         });

         const data = [{
             type: 'pdf',
             data: pdfUrl
         }];

         await qz.print(config, data);
         console.log("TVS RP-3200 printed silently");

     } catch (e) {
         console.error(e);
         showToast("error", "Thermal printer not ready");
     }
 }



});
</script>
</body>
</html>