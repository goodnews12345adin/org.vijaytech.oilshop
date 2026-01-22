<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.JSONObject"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover" />
  <title>Product Master Pro | Vijay Tech Orbit</title>

  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
  
  <!-- Fonts & Icons -->
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
  
  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  
  <!-- Select2 (Included as per referenced code) -->
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
      /* Allows taking up full width on large screens if needed, or constrained */
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

    .card-subtitle {
        color: var(--text-muted);
        font-size: 15px;
        margin-top: -30px;
        margin-bottom: 30px;
        font-weight: 500;
    }

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

    textarea.form-control {
        height: auto;
        min-height: 120px;
        padding-top: 15px;
    }

    .form-control:focus, .form-select:focus {
        background: #fff;
        border-color: var(--accent);
        box-shadow: 0 0 0 4px rgba(21, 160, 198, 0.1);
        transform: translateY(-1px);
    }

    /* Progress Bar Styling (Updated) */
    .form-progress {
        height: 6px;
        background: #e2e8f0;
        border-radius: 10px;
        margin-bottom: 35px;
        overflow: hidden;
        width: 100%;
    }

    #progress-inner {
        height: 100%;
        width: 0%;
        background: linear-gradient(90deg, var(--accent), #8b5cf6);
        transition: width 0.5s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 0 10px rgba(21, 160, 198, 0.3);
    }

    /* Buttons */
    .btn-erp-primary {
      background: linear-gradient(135deg, var(--accent), #0ea5e9);
      color: white;
      border: none;
      padding: 14px 40px;
      font-weight: 700;
      border-radius: 50px;
      box-shadow: 0 10px 25px -5px rgba(21, 160, 198, 0.4);
      transition: var(--transition);
    }
    .btn-erp-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px -5px rgba(21, 160, 198, 0.5);
        filter: brightness(1.1);
        color: white;
    }

    .btn-reset {
      background: white;
      border: 2px solid var(--accent);
      color: var(--accent);
      padding: 12px 24px;
      border-radius: 50px;
      font-weight: 700;
      transition: var(--transition);
      display: inline-flex;
      align-items: center;
    }
    .btn-reset:hover { 
        background: var(--accent); 
        color: white; 
        box-shadow: 0 10px 20px -5px rgba(21, 160, 198, 0.4);
        transform: translateY(-2px);
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
  <%@ include file="sidebar.jsp"%>

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
          <div class="wb-icon-area" id="wb-icon-area"></div>
          <h5 class="wb-title" id="wb-title">Title</h5>
          <p class="wb-msg" id="wb-message">Message here...</p>
          <div class="d-flex justify-content-center gap-2" id="wb-actions"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- MAIN CONTENT -->
  <div class="page-wrap">
    <div class="col-xl-12"> <!-- Expanded to full width for full window scenario -->
      
      <div class="main-content-card">
        <h4><i class="bi bi-box-seam"></i> Product Master Pro</h4>
        <p class="card-subtitle">Create and manage inventory items.</p>

        <div class="form-progress">
          <div id="progress-inner"></div>
        </div>

        <form id="productForm">
          <input type="hidden" id="productId" value="0">

          <!-- Essential -->
          <div class="row g-3 mb-4">
            <div class="col-md-4 col-12">
              <label class="form-label">Search Key (SKU)</label> 
              <input id="Value" class="form-control" placeholder="e.g. SKU-001" required autocomplete="off">
            </div>
            <div class="col-md-8 col-12">
              <label class="form-label">Product Name</label> 
              <input id="Name" class="form-control" placeholder="e.g. Wireless Mouse" required autocomplete="off">
            </div>
          </div>

          <!-- Category -->
          <div class="row g-3 mb-4">
            <div class="col-md-4 col-12">
              <label class="form-label">Product Category</label> 
              <select id="M_Product_Category_ID" class="form-select select2-init" required></select>
            </div>
            <div class="col-md-4 col-12">
              <label class="form-label">UOM</label> 
              <select id="C_UOM_ID" class="form-select select2-init" required></select>
            </div>
            <div class="col-md-4 col-12">
              <label class="form-label">Record Type</label> 
              <select id="EntryType" class="form-select" required>
                <option value="Both">Buy & Sell</option>
                <option value="Purchase">Purchase Only</option>
                <option value="Sales">Sales Only</option>
              </select>
            </div>
          </div>

          <!-- Pricing -->
          <div class="row g-3 mb-4">
            <div class="col-md-3 col-6">
              <label class="form-label">HSN Code</label> 
              <input id="HSNCode" class="form-control" placeholder="8471">
            </div>
            <div class="col-md-3 col-6">
              <label class="form-label">Base Price</label> 
              <input id="BillPrice" type="number" class="form-control pricing-calc" value="0">
            </div>
            <div class="col-md-2 col-12">
              <label class="form-label">Tax %</label> 
              <select id="TaxRate" class="form-select pricing-calc">
                <option value="0">0%</option>
                <option value="5" selected>5%</option>
                <option value="12">12%</option>
                <option value="18">18%</option>
              </select>
            </div>
          </div>

          <div class="mb-4">
            <label class="form-label">Description</label>
            <textarea id="Description" class="form-control" rows="3" placeholder="Enter product details..."></textarea>
          </div>

          <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
            <button type="button" class="btn-reset" onclick="resetForm()">
              <i class="bi bi-arrow-counterclockwise me-2"></i> Clear Draft
            </button>

            <button type="submit" id="saveBtn" class="btn-erp-primary shadow">
              <span id="btnText"><i class="bi bi-shield-check me-2"></i> Finalize & Save</span> 
              <span id="btnSpinner" class="spinner-border spinner-border-sm d-none"></span>
            </button>
          </div>
        </form>
      </div>

    </div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
  /* ================= SAFE JSON FROM JSP ================= */
  const cats = JSON.parse(
    <%=JSONObject.quote(request.getAttribute("productList") != null ? request.getAttribute("productList").toString() : "[]")%>
  );

  const uoms = JSON.parse(
    <%=JSONObject.quote(request.getAttribute("uom") != null ? request.getAttribute("uom").toString() : "[]")%>
  );

  /* ================= INIT ================= */
  $(function(){
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

    // Populate dropdowns
    cats.forEach(c =>
      $('#M_Product_Category_ID').append(
        new Option(c.Name, c.M_Product_Category_ID)
      )
    );

    uoms.forEach(u =>
      $('#C_UOM_ID').append(
        new Option(u.Name, u.C_UOM_ID)
      )
    );

    // Select2 (safe)
    if ($.fn.select2) {
      $('.select2-init').select2({ 
        width:'100%',
        dropdownCssClass: "p-2"
      });
    }

    // Progress bar
    $('input,select,textarea').on('input change', function(){
      let f=0;
      if($('#Value').val())f++;
      if($('#Name').val())f++;
      if($('#M_Product_Category_ID').val())f++;
      if($('#C_UOM_ID').val())f++;
      if($('#BillPrice').val()>0)f++;
      $('#progress-inner').css('width',(f/5*100)+'%');
    });

    // Submit
    $('#productForm').on('submit', function(e){
      e.preventDefault();

      const btn=$('#saveBtn');
      btn.prop('disabled',true);
      $('#btnText').addClass('d-none');
      $('#btnSpinner').removeClass('d-none');

      // Show Loader
      $("#global-loader").css("display","flex").hide().fadeIn(200);

      const payload = {
        productId: $('#productId').val(),
        Value: $('#Value').val(),
        Name: $('#Name').val(),
        M_Product_Category_ID: $('#M_Product_Category_ID').val(),
        C_UOM_ID: $('#C_UOM_ID').val(),
        HSNCode: $('#HSNCode').val(),
        BillPrice: $('#BillPrice').val(),
        TaxRate: $('#TaxRate').val(),
        Description: $('#Description').val(),
        EntryType: $('#EntryType').val()
      };

      $.ajax({
        url:'<%=request.getContextPath()%>/Product',
        type:'POST',
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        data: JSON.stringify(payload),
        success:function(){
          $("#global-loader").fadeOut(200);
          showWonderfulBox('success', 'Saved Successfully', 'Product record has been saved.', function(){
            resetForm();
          });
        },
        error:function(xhr){
          $("#global-loader").fadeOut(200);
          showWonderfulBox('error', 'Error Occurred', xhr.responseText || 'Could not save product.');
        },
        complete:function(){
          btn.prop('disabled',false);
          $('#btnText').removeClass('d-none');
          $('#btnSpinner').addClass('d-none');
        }
      });
    });

    // Mapping the old toast function to the new Wonderful Box
    window.showToast = function(msg,type){
        const title = type === 'success' ? 'Success' : 'Error';
        const wbType = type === 'success' ? 'success' : 'error';
        showWonderfulBox(wbType, title, msg);
    };
  });

  function resetForm(){
    $('#productForm')[0].reset();
    $('.select2-init').val('').trigger('change');
    $('#progress-inner').css('width','0%');
  }
  </script>
</body>
</html>