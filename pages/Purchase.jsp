<%@ page import="java.util.*, org.compiere.model.*, org.compiere.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Purchase Entry | Vijay Tech Orbit</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />

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
      max-width: 1400px;
      margin: 0 auto;
      width: 100%;
    }

    .purchase-card {
      background: var(--card-bg);
      border-radius: var(--radius-lg);
      padding: 40px;
      box-shadow: var(--shadow-card);
      border: 1px solid rgba(255,255,255,0.5);
      position: relative;
      overflow: hidden;
    }

    /* Top Decorative Line */
    .purchase-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 6px;
        background: linear-gradient(90deg, var(--accent), #8b5cf6);
    }

    .purchase-card h4 {
      font-weight: 800;
      font-size: 26px;
      color: #0f172a;
      margin-bottom: 35px;
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .purchase-card h4 i { color: var(--accent); font-size: 28px; }

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

    /* Table Area */
    .table-container {
      border: 1px solid var(--border-light);
      border-radius: var(--radius-sm);
      overflow: hidden;
      margin: 30px 0;
      background: #fff;
      box-shadow: inset 0 2px 4px rgba(0,0,0,0.02);
    }
    
    .table-responsive {
        border-radius: var(--radius-sm);
    }

    .table thead th {
      background: #f1f5f9;
      color: var(--text-muted);
      font-size: 11px;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 1px;
      padding: 18px 15px;
      border: none;
    }
    .table tbody td {
        padding: 15px;
        vertical-align: middle;
        border-bottom: 1px solid #f1f5f9;
        transition: background 0.2s;
    }
    .table tbody tr:hover { background-color: #f8fafc; }
    .table .form-control, .table .form-select {
        height: 44px;
        padding: 0 12px;
        font-size: 14px;
    }

    /* Empty State */
    .empty-state {
        text-align: center;
        padding: 40px 20px;
        color: var(--text-muted);
        background: #fdfdfd;
        border-bottom: 1px dashed var(--border-light);
    }
    .empty-state i { font-size: 40px; color: #cbd5e1; margin-bottom: 15px; display: block; }

    /* Buttons */
    .btn-add {
      background: white;
      border: 2px solid var(--accent);
      color: var(--accent);
      padding: 12px 24px;
      border-radius: var(--radius-sm);
      font-weight: 700;
      transition: var(--transition);
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .btn-add:hover { 
        background: var(--accent); 
        color: white; 
        box-shadow: 0 10px 20px -5px rgba(21, 160, 198, 0.4);
        transform: translateY(-2px);
    }

    .net-amount-box {
      font-size: 18px;
      font-weight: 600;
      color: var(--text-muted);
      padding: 15px 25px;
      background: #f8fafc;
      border-radius: var(--radius-sm);
      border: 1px solid var(--border-light);
      display: flex;
      align-items: center;
      gap: 10px;
    }
    #grand-total { 
        color: var(--accent); 
        font-weight: 800; 
        font-size: 28px;
        text-shadow: 0 0 15px var(--accent-glow);
    }

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
    }

    /* Remove Button */
    .btn-remove {
        border: none;
        background: transparent;
        color: #ef4444;
        opacity: 0.6;
        transition: var(--transition);
        padding: 8px;
        border-radius: 50%;
    }
    .btn-remove:hover {
        opacity: 1;
        background: #fee2e2;
        transform: scale(1.1);
    }

    /* === WONDERFUL BOX (Custom Modal) === */
    #wonderful-alert-box {
        z-index: 6000;
    }
    .modal-content.wonderful-box {
        border: none;
        border-radius: 24px;
        box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
        overflow: hidden;
        animation: popIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
    }
    @keyframes popIn {
        from { transform: scale(0.9); opacity: 0; }
        to { transform: scale(1); opacity: 1; }
    }
    .wb-icon-area {
        height: 60px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 10px;
    }
    .wb-icon-area i { font-size: 3rem; }
    .wb-icon-success i { color: #10b981; text-shadow: 0 4px 15px rgba(16, 185, 129, 0.3); }
    .wb-icon-error i { color: #ef4444; text-shadow: 0 4px 15px rgba(239, 68, 68, 0.3); }
    .wb-icon-confirm i { color: var(--accent); text-shadow: 0 4px 15px rgba(21, 160, 198, 0.3); }
    
    .wb-title { font-weight: 800; font-size: 1.25rem; margin-bottom: 0.5rem; }
    .wb-msg { color: var(--text-muted); margin-bottom: 1.5rem; }
    
    .wb-btn-confirm {
        background: var(--accent); color: white; border: none;
        padding: 10px 25px; border-radius: 30px; font-weight: 700;
    }
    .wb-btn-cancel {
        background: #f1f5f9; color: var(--text-muted); border: none;
        padding: 10px 25px; border-radius: 30px; font-weight: 600;
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

    /* ===========================
       MEDIA QUERIES
       =========================== */
    
    /* Tablet & Mobile Sidebar adjustments */
    @media (max-width: 992px) {
      .page-wrap { margin-left: 0; padding: 20px; }
      .app-header { padding: 0 20px; }
      .purchase-card { padding: 25px; }
    }

    /* Mobile Landscape */
    @media (max-width: 768px) {
        .purchase-card h4 { font-size: 20px; }
        .net-amount-box {
            width: 100%;
            justify-content: center;
            flex-direction: column;
            gap: 5px;
            margin-top: 20px;
        }
        .d-flex.justify-content-between.mt-4 {
            flex-direction: column-reverse;
            align-items: center;
            gap: 20px;
        }
        .btn-add, .btn-submit { width: 100%; justify-content: center; }
        .table-responsive {
            border: 1px solid var(--border-light);
            border-radius: var(--radius-sm);
        }
        /* Adjust Select2 in table on mobile */
        .select2-container--default .select2-selection--single {
            height: 44px !important;
        }
    }

    /* Small Mobile */
    @media (max-width: 576px) {
        .user-info span.user-name { display: none; } /* Hide name on very small screens */
        .header-user-zone { align-items: center; }
        .purchase-card { border-radius: 15px; padding: 15px; }
        .btn-add, .btn-submit { padding: 10px 20px; }
        #grand-total { font-size: 24px; }
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

  <!-- MAIN CONTENT -->
  <div class="page-wrap">
    <div class="purchase-card">
      <h4><i class="bi bi-cart-plus"></i> New Purchase Entry</h4>

      <form id="purchase-form" novalidate>
        <div class="mb-4">
          <label class="form-label">Vendor / Supplier</label>
          <select id="supplier" class="form-select">
            <option value="">-- Select Supplier --</option>
            <%
              List<Map<String,Object>> supplierList = (List<Map<String,Object>>) request.getAttribute("supplierList");
              if (supplierList != null) {
                for (Map<String,Object> s : supplierList) {
            %>
              <option value="<%= s.get("id") %>"><%= s.get("name") %></option>
            <% } } %>
          </select>
        </div>

        <div class="table-container">
          <div class="table-responsive">
            <table class="table align-middle mb-0" id="purchase-items">
              <thead>
                <tr>
                  <th width="50" class="text-center">#</th>
                  <th>Product Description</th>
                  <th width="110">Qty</th>
                  <th width="120">Unit Rate</th>
                  <th width="120" class="text-end">Subtotal</th>
                  <th width="50" class="text-center"></th>
                </tr>
              </thead>
              <tbody id="items-body">
              </tbody>
            </table>
            <div id="empty-state" class="empty-state">
                <i class="bi bi-basket2"></i>
                <p>No products added yet</p>
            </div>
          </div>
        </div>

        <div class="d-flex flex-wrap align-items-center justify-content-between mt-4 gap-3">
          <button type="button" id="add-item" class="btn btn-add">
            <i class="bi bi-plus-lg"></i> Add Product
          </button>
          
          <div class="net-amount-box">
            Net Amount: 
            <span style="font-size: 16px; color: #94a3b8;">₹</span> 
            <span id="grand-total">0.00</span>
          </div>
        </div>

        <div class="d-flex justify-content-end mt-5">
          <button type="submit" class="btn btn-submit shadow">
            <i class="bi bi-shield-check me-2"></i> Submit Purchase
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- GLOBAL LOADER -->
  <div id="global-loader">
    <div class="loader-content">
        <div class="spinner-border text-info mb-3" role="status" style="width: 3rem; height: 3rem;"></div>
        <h5 class="fw-bold">Processing...</h5>
    </div>
  </div>

  <!-- WONDERFUL ALERT BOX (Custom Modal) -->
  <div class="modal fade" id="wonderful-alert-box" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered modal-sm">
      <div class="modal-content wonderful-box text-center">
        <div class="modal-body p-4">
          <div class="wb-icon-area" id="wb-icon-area">
            <!-- Icon injected by JS -->
          </div>
          <h5 class="wb-title" id="wb-title">Title</h5>
          <p class="wb-msg" id="wb-message">Message here...</p>
          <div class="d-flex justify-content-center gap-2" id="wb-actions">
            <!-- Buttons injected by JS -->
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- SCRIPTS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
  $(function(){
    let products = [];
    let productsLoaded = false;

    // Initialize Custom Modal
    const wonderfulModal = new bootstrap.Modal(document.getElementById('wonderful-alert-box'));

    function showWonderfulBox(type, title, message, onConfirm) {
        const $iconArea = $('#wb-icon-area');
        const $title = $('#wb-title');
        const $msg = $('#wb-message');
        const $actions = $('#wb-actions');
        
        $actions.empty();
        $title.text(title);
        $msg.html(message);

        let iconClass = '';
        if(type === 'success') {
            iconClass = 'wb-icon-success';
            $iconArea.html('<i class="bi bi-check-circle-fill"></i>');
        } else if (type === 'error') {
            iconClass = 'wb-icon-error';
            $iconArea.html('<i class="bi bi-x-circle-fill"></i>');
        } else if (type === 'confirm') {
            iconClass = 'wb-icon-confirm';
            $iconArea.html('<i class="bi bi-question-circle-fill"></i>');
        }

        $iconArea.removeClass().addClass('wb-icon-area ' + iconClass);

        const btnOk = $('<button class="wb-btn-confirm">OK</button>');
        btnOk.on('click', function() {
            wonderfulModal.hide();
            if (typeof onConfirm === 'function') onConfirm();
        });
        $actions.append(btnOk);

        wonderfulModal.show();
    }

    // Supplier Select2
    $("#supplier").select2({ 
        placeholder: "-- Select Supplier --", 
        width: "100%",
        dropdownCssClass: "p-2"
    });

    // Load Products via AJAX
    function loadProducts() {
      return $.ajax({
        url: "<%= request.getContextPath() %>/PurchaseServlet?action=getProducts",
        method: "GET",
        dataType: "json"
      }).done(function(result) {
        products = result || [];
        productsLoaded = true;
      }).fail(function() {
          showWonderfulBox('error', 'Data Error', 'Failed to load products list. Please refresh.');
      });
    }
    loadProducts();

    // Add Item Row
    $("#add-item").click(function() {
      if (!productsLoaded) {
          showWonderfulBox('error', 'Not Ready', 'Products are still loading. Please wait.');
          return;
      }
      
      // Hide empty state
      $('#empty-state').hide();

      const $row = $(`
        <tr>
          <td class="idx text-center text-muted fw-bold">0</td>
          <td>
            <select class="form-select prod-id"></select>
            <input type="hidden" class="prod-name" />
            <input type="hidden" class="uom" />
            <input type="hidden" class="uom-id" />
          </td>
          <td><input type="number" min="0" step="0.01" class="form-control qty text-center" value="1"></td>
          <td><input type="number" step="0.01" min="0" class="form-control rate text-end" value="0"></td>
          <td class="amount text-end fw-bold text-primary">0.00</td>
          <td class="text-center">
            <button type="button" class="btn-remove"><i class="bi bi-trash3-fill fs-5"></i></button>
          </td>
        </tr>
      `);

      const $select = $row.find(".prod-id");
      $select.append('<option value="">-- Select Product --</option>');
      products.forEach(p => {
        $select.append($('<option/>',{ 
            value: p.id, 
            text: p.name, 
            'data-rate': p.rate, 
            'data-uom': p.uom, 
            'data-uomid': p.uomId 
        }));
      });

      $select.select2({ 
          placeholder: "-- Select --", 
          width: "100%",
          dropdownCssClass: "p-2",
          dropdownParent: $row // Fix dropdown clipping in scrollable table
      });
      
      $("#items-body").append($row);
      updateIndexes();
      
      // Animation for new row
      $row.hide().fadeIn(300);
    });

    // Event: Product Change
    $(document).on("change", ".prod-id", function() {
      const $row = $(this).closest("tr");
      const prodId = $(this).val();
      if (!prodId) return;
      
      const product = products.find(p => String(p.id) === String(prodId));
      if (product) {
        $row.find(".prod-name").val(product.name || "");
        $row.find(".rate").val(product.rate || 0);
        $row.find(".uom").val(product.uom || "");
        $row.find(".uom-id").val(product.uomId || "");
        
        // Highlight row briefly
        $row.addClass("table-active");
        setTimeout(() => $row.removeClass("table-active"), 500);
        
        recalcRow($row);
      }
    });

    // Event: Quantity/Rate Change
    $(document).on("input change", ".qty, .rate", function() { 
        recalcRow($(this).closest("tr")); 
    });

    function recalcRow($row) {
      const qty = parseFloat($row.find(".qty").val()) || 0;
      const rate = parseFloat($row.find(".rate").val()) || 0;
      const amt = qty * rate;
      $row.find(".amount").text(amt.toFixed(2));
      updateTotal();
    }

    function updateIndexes() {
      $("#items-body tr").each(function(i) { $(this).find(".idx").text(i+1); });
    }

    // Event: Remove Row
    $(document).on("click", ".btn-remove", function() {
      const $row = $(this).closest("tr");
      $row.fadeOut(200, function() { 
          $(this).remove(); 
          updateIndexes(); 
          updateTotal();
          if($("#items-body tr").length === 0) {
              $('#empty-state').fadeIn(300);
          }
      });
    });

    function updateTotal() {
      let total = 0;
      $("#items-body tr").each(function() { 
          total += parseFloat($(this).find(".amount").text()) || 0; 
      });
      $("#grand-total").text(total.toFixed(2));
    }

    // Submit Form
    $("#purchase-form").submit(function(e) {
      e.preventDefault();
      const supplierId = $("#supplier").val();
      if (!supplierId) {
          showWonderfulBox('warning', 'Missing Info', 'Please select a Vendor/Supplier.');
          $("#supplier").next().addClass('select2-error');
          return;
      }

      const items = $("#items-body tr").map(function() {
        const $r = $(this);
        const pid = $r.find(".prod-id").val();
        if (!pid) return null;
        return {
          prodId: pid,
          product: $r.find(".prod-name").val(),
          uom: $r.find(".uom").val(),
          uomId: $r.find(".uom-id").val(),
          qty: parseFloat($r.find(".qty").val()) || 0,
          rate: parseFloat($r.find(".rate").val()) || 0,
          amount: parseFloat($r.find(".amount").text()) || 0
        };
      }).get().filter(i => i !== null);

      if (items.length === 0) {
          showWonderfulBox('warning', 'Empty List', 'Please add at least one product to the purchase order.');
          return;
      }

      // Show Loader
      $("#global-loader").css("display","flex").hide().fadeIn(200);
      
      $.ajax({
        url: "<%= request.getContextPath() %>/PurchaseServlet",
        type: "POST",
        data: JSON.stringify({ purchaseData: { supplierId: supplierId, items: items } }),
        contentType: "application/json; charset=utf-8",
        success: function(res) {
            $("#global-loader").fadeOut(200);
            if (res.status === 'success' || res === 'OK') {
                showWonderfulBox('success', 'Saved Successfully', 'Purchase record has been saved to the database.', function(){
                    location.reload();
                });
            } else {
                 showWonderfulBox('error', 'Error', res.message || 'Unknown server error occurred.');
            }
        },
        error: function(xhr, status, error) {
            $("#global-loader").fadeOut(200);
            showWonderfulBox('error', 'Connection Failed', 'Could not connect to server: ' + error);
        }
      });
    });
  });
  </script>
</body>
</html>