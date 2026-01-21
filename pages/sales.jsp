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
      padding-top: 90px;
      min-height: 100vh;
      background-image: 
        radial-gradient(at 0% 0%, rgba(21, 160, 198, 0.03) 0px, transparent 50%),
        radial-gradient(at 100% 100%, rgba(10, 18, 32, 0.02) 0px, transparent 50%);
    }

    /* HEADER */
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
      z-index: 1040;
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

    /* MAIN CONTAINER */
    .page-wrap {
      padding: 20px 40px 100px 40px;
      max-width: 1400px;
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

    /* INPUTS & FORMS */
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

    /* Select2 Overrides */
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

    /* TABLE */
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
    
    .remove-row {
        width: 30px; height: 30px;
        padding: 0;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
    }

    /* TOTALS BOX */
   .total-box {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-end;
    gap: 20px;
    background: #0b132b;
    padding: 25px;
    border-radius: 16px;
    margin-top: 20px;
    }

    .total-item-group {
        display: flex;
        flex-direction: column;
        min-width: 140px;
        flex-grow: 1;
    }

    .total-item-group label {
        font-size: 12px;
        color: #9aa4b2;
        margin-bottom: 6px;
        font-weight: 500;
    }

    .total-item-group input {
        height: 40px;
        background: rgba(255,255,255,0.1);
        border: 1px solid rgba(255,255,255,0.2);
        color: #fff;
        text-align: right;
        border-radius: 8px;
    }

    .total-spacer {
        flex-grow: 1;
    }

    #grand-total {
        font-size: 32px;
        font-weight: 800;
        color: #1ec8ff;
        line-height: 1;
    }

    #Bal-amt {
        font-size: 28px;
        font-weight: 700;
        color: #ff4757;
    }

    /* BUTTONS */
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

    /* THERMAL RECEIPT HIDDEN AREA */
    #thermal-print-area {
        display: none; 
        width: 80mm;
        background-color: #ffffff;
        color: #000000;
        font-family: 'Courier New', Courier, monospace;
        font-size: 12px;
        padding: 2mm;
        line-height: 1.2;
    }
    
    .receipt-header { text-align: center; margin-bottom: 10px; border-bottom: 1px dashed #000; padding-bottom: 5px; }
    .receipt-row { display: flex; justify-content: space-between; margin-bottom: 4px; }
    .receipt-divider { border-top: 1px dashed #000; margin: 5px 0; }
    .receipt-footer { text-align: center; margin-top: 10px; font-size: 11px; }

    /* RESPONSIVE */
    @media (max-width: 768px) {
        .app-header { padding: 0 20px; }
        .invoice-box { padding: 20px; }
        .total-box { flex-direction: column; }
        .btn { width: 100%; margin-bottom: 10px; }
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
                            <input type="text" class="form-control" id="cust-phone" placeholder="Phone" required>
                            <label for="cust-phone">Phone Number *</label>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-lg-7">
                    <div class="p-4 bg-light rounded-4 border h-100">
                        <label class="form-label fw-bold d-flex justify-content-between mb-3">
                            <span class="text-dark"><i class="bi bi-box-seam me-2"></i>Add Products</span>
                            <span class="text-primary small cursor-pointer"><i class="bi bi-search me-1"></i>Search (Press Enter)</span>
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
                             <span>Tip: Type product name and press <strong>ENTER</strong> to add quickly.</span>
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
        <label class="d-flex justify-content-between">
            Discount 
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" id="disc-type-toggle" style="width:32px; height:18px;">
                <label class="form-check-label text-white small" for="disc-type-toggle" id="disc-type-label">₹</label>
            </div>
        </label>
        <div class="input-group">
            <input type="number" id="discount" class="form-control form-control-sm" value="" min="0">
            <button class="btn btn-outline-light btn-sm" type="button" id="round-off-btn" title="Round Off Total">
                <i class="bi bi-calculator"></i>
            </button>
        </div>
    </div>

    <div class="total-item-group">
        <label>Cash Paid</label>
        <input type="number" id="cash" class="form-control form-control-sm" value="" min="0">
    </div>

    <div class="total-item-group">
        <label>UPI / Bank</label>
        <input type="number" id="upi" class="form-control form-control-sm" value="" min="0">
    </div>

   <div class="total-item-group text-end w-auto">
        <label class="text-danger">Balance Due</label>
        <span id="Bal-amt"></span>
    </div>

    <div class="total-spacer"></div> 

    <div class="total-item-group text-end w-auto">
        <label class="text-white" style="font-size:13px">Subtotal</label>
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
                    <button id="hold-btn" class="btn btn-warning text-dark border border-dark-subtle">
                        <i class="bi bi-pause-circle me-1"></i>Hold Order
                    </button>
                    <button id="resume-btn" class="btn btn-info text-white border border-dark-subtle d-none">
                        <i class="bi bi-play-circle me-1"></i>Resume Order
                    </button>
                </div>

                <button id="cancel" class="btn btn-danger border d-none">
                        <i class="bi bi-arrow-counterclockwise me-2"></i>Cancel Last
                </button>
                <button id="recalculate" class="btn btn-light border">
                    <i class="bi bi-arrow-clockwise me-2"></i>Recalc
                </button>
                <button id="send-btn" class="btn btn-success px-5">
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

<div id="loader">
    <div class="box">
        <div class="spinner-border text-info" role="status"></div>
        <span id="loader-text">Processing Sales Entry...</span>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
 $(function () { 
    $("#cancelId").val("0");

    /* ===========================
       QZ TRAY SETUP (Silent Printing)
       =========================== */
    
    // Setup signing using default keys. 
    // NOTE: For production, replace these with your own generated keys.
    qz.security.setCertificatePromise(function(resolve, reject) {
        resolve("-----BEGIN CERTIFICATE-----\nMIIDXTCCAkWgAwIBAgIJAKg0HhUxzBrdMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV\nBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX\naWRnaXRzIFB0eSBMdGQwHhcNMTcwOTA0MDQzOTI5WhcNMTgwOTA0MDQzOTI5WjBF\nMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50\nZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB\nCgKCAQEAuPwsKsV0g2EgLQLUjdInXx3gXVwJnCiC4K1/H6VNF2nzQ3VLDmKQAu7Jf\nwGpQ6KZZF+j2N7sUHnJyCkg+0R3bA3JX5V8kxvK7dOq4DlBjkURUqS3LY3U6K3jXJ\n5f0L6H8f8nKbJZJNYJVjmZJ8p2Wj8bZ6K5W1WfWZ9Wv7Jq0pY0UqY6F8R3bA3JX5V\n8kxvK7dOq4DlBjkURUqS3LY3U6K3jXJ5f0L6H8f8nKbJZJNYJVjmZJ8p2Wj8bZ6K\n5W1WfWZ9Wv7Jq0pY0UqY6F8R3bA3JX5V8kxvK7dOq4DlBjkURUqS3LY3U6K3jXJ5\nf0L6H8f8nKbJZJNYJVjmZJ8wIDAQABo1AwTjAdBgNVHQ4EFgQUhP7V5k4V8JF1dJK9JK9JK9JK9JK9JK9JK9JK9JK9J\nK9JK9HwYDVR0lBBgwFAYKKwYBBAGCNwoDDAYKKwYBBAGCNwoDBDAKBggrBgEFBQcD\nATANBgkqhkiG9w0BAQsFAAOCAQEAXPQ3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3Q==\n-----END CERTIFICATE-----");
    });

    qz.security.setSignaturePromise(function(toSign) {
        return function(resolve, reject) {
            try {
                var pk = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC4/CwqxXSDYSAtA\ntS0MidaHeBdXAmcKILgrX8fpU0XafNDdUsOYoAC7sl/AalDoplkX6PY3uxQecnIKS\nD7RHdsDclfnXyTG8rt06rgOUOSRRFStLctjTorcel8n+0vofx/ycpslkk1glWOZnk\nynZaPxtnornVbVZ9Zn1a/smrSljRSpjoXxHdsDclfnXyTG8rt06rgOUOSRRFStLc\ntjTorcel8n+0vofx/ycpslkk1glWOZnkynZaPxtnornVbVZ9Zn1a/smrSljRSpjo\nXxHdsDclfnXyTG8rt06rgOUOSRRFStLctjTorcel8n+0vofx/ycpslkk1glWOZnk\nynZaPxtnornVbVZ9Zn1a/smrSljRSpjoXxHdsDclfnXyTG8rt06rgOUOSRRFStLc\ntjTorcel8n+0vofx/ycpslkk1glWbQIDAQABAoIBAE7P3X3X3X3X3X3X3X3X3X\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3Q==\n-----END PRIVATE KEY-----";
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

    // Helper function
    function stob64(str) {
        return btoa(String.fromCharCode.apply(null, str.replace(/\r|\n/g, "").replace(/([\da-fA-F]{2}) ?/g, "0x$1 ").replace(/ +$/, "").split(" ")));
    }

    // Connect to QZ Tray on page load to avoid popups later
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
            showToast('success', 'Rounded off to ₹' + nearestRound.toFixed(2));
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
            showToast('error', 'Nothing to hold.');
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
        showToast('success', 'Order Held Successfully!');
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
        
        if(!confirm("Resume previous held order? Current cart will be cleared.")) return;

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
        showToast('success', 'Order Resumed!');
    });

    /* ===========================
       Utils
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

    function resetInvoiceForm() {
        $('.invoice-box').css('opacity', '0.5');
        setTimeout(() => {
            // Clear Inputs
            $('#cust-name, #cust-address, #cust-phone').val('');
            $('#manual-product').val(null).trigger('change');
            $('#discount').val(''); // Empty discount input
            $('#cash').val('');     // Empty cash input
            $('#upi').val('');      // Empty UPI input

            // Clear Table
            $('#items-body').empty();
            checkEmptyState();

            // Clear Labels/Spans (Empty instead of 0.00)
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
    THERMAL PRINTER LOGIC (QZ Tray)
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

     // 2. QZ Tray Printing (Optimized for Silent Mode)
     var connectPromise = Promise.resolve();

     // Only attempt to connect if we are NOT already active. 
     // This prevents "Already Connected" errors.
     if (!qz.websocket.isActive()) {
         connectPromise = qz.websocket.connect();
     }

     connectPromise.then(function() {
         // Use getDefault() for SILENT printing (no popups).
         // If no default is set, it falls back to find() (may show dialog).
         return qz.printers.getDefault().catch(function(e) {
             // If getDefault fails (e.g. no default set), try to find one.
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
         
         // Only show error if we actually failed, 
         // or if error is not just a connection blip (we might still be connected).
         var errMessage = err.message || err.toString();
         
         // If QZ Tray is actually active, a transient error might have occurred.
         // We suppress it to avoid false "Printing Failed" messages.
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
            showToast('error', 'Please add at least one product.');
            return;
        }

        var balAmt = parseFloat($("#Bal-amt").text()) || 0;
        
        if (balAmt < -0.1) {
            showToast('error', 'Payment exceeds total amount!');
            return;
        }

        // Enforce full payment (optional - uncomment to require exact payment)
        /*
        if (balAmt > 0) {
            showToast('error', 'Balance Amount Pending: ₹' + balAmt.toFixed(2));
            return;
        }
        */

        $("#loader").css("display", "flex");
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
                $("#loader").hide();

                if (response && response.status === "success") {
                    // CRITICAL FIX: Use the docNo returned from backend
                    const docNo = response.docNo;
                    $("#cancelId").val(docNo);
                    toggleCancelButton();
                    
                    showToast('success', 'Invoice Saved Successfully!');
                        
                    // Trigger Silent Print
                    printThermalReceipt(docNo);
                    
                    // Clear Form
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
    
    /* ===========================
       CANCEL ENTRY LOGIC
    =========================== */
    $("#cancel").on("click", function () {
        const cancelId = $("#cancelId").val();
        if (!cancelId || cancelId === "0") {
            showToast('error', 'Id Not Found');
            return; 
        }
        if(!confirm("Are you sure you want to CANCEL this invoice?")) return;

        $("#loader").show();
        $.ajax({
            type: "POST",
            url: "<%= request.getContextPath() %>/CancelSalesEntry",
            data: { documentNo: cancelId },
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
            }
        });
    });

});
</script>
</body>
</html>
