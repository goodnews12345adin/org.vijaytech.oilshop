<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Partner Management | Vijay Tech Orbit</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />

  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
  
  <!-- Fonts & Icons -->
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
  
  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

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
       HEADER UI (Copied from Purchase.jsp)
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

    .bp-card {
      background: var(--card-bg);
      border-radius: var(--radius-lg);
      padding: 40px;
      box-shadow: var(--shadow-card);
      border: 1px solid rgba(255,255,255,0.5);
      position: relative;
      overflow: hidden;
    }

    /* Top Decorative Line */
    .bp-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 6px;
        background: linear-gradient(90deg, var(--accent), #8b5cf6);
    }

    .bp-card h4 {
      font-weight: 800;
      font-size: 26px;
      color: #0f172a;
      margin-bottom: 35px;
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .bp-card h4 i { color: var(--accent); font-size: 28px; }

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

    /* CHECKBOXES */
    .partner-type-box {
        background: #f8fafc; border: 1px solid var(--border-light);
        border-radius: var(--radius-sm); padding: 15px 25px; display: inline-block;
    }
    .form-check-input:checked { background-color: var(--accent); border-color: var(--accent); }

    /* BUTTONS */
    .btn-submit {
      background: linear-gradient(135deg, var(--accent), #0ea5e9);
      color: white; border: none; padding: 14px 40px; font-weight: 700;
      border-radius: 50px; box-shadow: 0 10px 25px -5px rgba(21, 160, 198, 0.4);
      transition: var(--transition); float: right;
    }
    .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 15px 30px -5px rgba(21, 160, 198, 0.5); filter: brightness(1.1); }

    /* SEARCH & FILTER BAR */
    .filter-bar {
        background: #f8fafc; padding: 15px; border-radius: var(--radius-sm);
        border: 1px solid var(--border-light); margin-bottom: 20px;
        display: flex; gap: 10px; align-items: center; flex-wrap: wrap;
    }
    .filter-btn {
        border: 1px solid var(--border-light); background: white; color: var(--text-muted);
        padding: 8px 20px; border-radius: 20px; font-weight: 600; font-size: 14px;
        transition: all 0.2s;
    }
    .filter-btn:hover { background: #f1f5f9; }
    .filter-btn.active {
        background: var(--accent); color: white; border-color: var(--accent);
        box-shadow: 0 4px 12px rgba(21, 160, 198, 0.3);
    }

    /* TABLE */
    .table-container {
      border: 1px solid var(--border-light); border-radius: var(--radius-sm);
      overflow: hidden; background: #fff; box-shadow: inset 0 2px 4px rgba(0,0,0,0.02);
    }
    .table thead th {
      background: #f1f5f9; color: var(--text-muted); font-size: 11px;
      font-weight: 800; text-transform: uppercase; letter-spacing: 1px; padding: 18px 15px; border: none;
    }
    .table tbody td { padding: 15px; vertical-align: middle; border-bottom: 1px solid #f1f5f9; }
    .table tbody tr:hover { background-color: #f8fafc; }

    /* BADGES - UPDATED FOR PERFECT VISIBILITY (Solid Colors) */
    .badge { padding: 7px 14px; border-radius: 8px; font-size: 12px; font-weight: 700; text-transform: uppercase; border: none; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    
    /* Customer Badge: Solid Emerald Green, White Text */
    .badge-cust { 
        background-color: #10b981; 
        color: #ffffff; 
    }
    
    /* Vendor Badge: Solid Amber/Orange, White Text */
    .badge-vend { 
        background-color: #f59e0b; 
        color: #ffffff; 
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
      .bp-card { padding: 25px; }
    }

    /* Mobile Landscape */
    @media (max-width: 768px) {
        .bp-card h4 { font-size: 20px; }
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
    }

    /* Small Mobile */
    @media (max-width: 576px) {
        .user-info span.user-name { display: none; } /* Hide name on very small screens */
        .header-user-zone { align-items: center; }
        .bp-card { border-radius: 15px; padding: 15px; }
        .btn-add, .btn-submit { padding: 10px 20px; }
    }
  </style>
</head>

<body>

  <!-- HEADER (Replaced with Purchase.jsp Style) -->
  <header class="app-header">
    <div class="header-user-zone">
      <span class="version-tag">v44.1</span>
      <div class="user-info">
        <span class="user-name"><%= (session.getAttribute("username") != null) ? session.getAttribute("username") : "Guest User" %></span>
        <div class="btn-logout" onclick="location.href='${pageContext.request.contextPath}/pages/loginpage.jsp'" title="Logout">
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
    <div class="bp-card">
      <h4><i class="bi bi-people-fill"></i> Partner Management</h4>

      <form id="bp-form">
        <div class="row g-3">
            <div class="col-md-6">
                <label class="form-label">Partner Name</label>
                <input type="text" class="form-control" id="bpName" required placeholder="e.g. John Doe">
            </div>
            <div class="col-md-6">
                <label class="form-label">Search Key</label>
                <input type="text" class="form-control" id="bpValue" placeholder="e.g. CUST-001 (Optional)">
            </div>
            
            <!-- ✅ ADDED: Location, Tax ID, Phone Fields -->
            <div class="col-md-4">
                <label class="form-label">Location</label>
                <input type="text" class="form-control" id="bpLocation" placeholder="City, State">
            </div>
            <div class="col-md-4">
                <label class="form-label">Tax ID (GSTIN)</label>
                <input type="text" class="form-control" id="bpTaxId" placeholder="29ABCDE...">
            </div>
            <div class="col-md-4">
                <label class="form-label">Phone Number</label>
                <input type="text" class="form-control" id="bpPhone" placeholder="+91 98765 43210">
            </div>

            <div class="col-12">
                <label class="form-label">Partner Type <span class="text-danger">*</span></label>
                <div class="partner-type-box">
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="checkbox" id="isCustomer">
                        <label class="form-check-label fw-bold" for="isCustomer">Customer</label>
                    </div>
                    <div class="form-check form-check-inline ms-4">
                        <input class="form-check-input" type="checkbox" id="isVendor">
                        <label class="form-check-label fw-bold" for="isVendor">Vendor</label>
                    </div>
                </div>
            </div>
        </div>
        <div class="clearfix mt-4">
            <button type="submit" class="btn btn-submit shadow">
                <i class="bi bi-person-plus-fill me-2"></i> Create Partner
            </button>
        </div>
      </form>

      <!-- SEARCH & FILTER TOOLBAR -->
      <div class="filter-bar mt-5">
          <div style="flex-grow: 1; max-width: 300px;">
              <input type="text" id="searchInput" class="form-control" placeholder="Search Name or Key...">
          </div>
          <div class="d-flex gap-2">
              <button class="filter-btn active" data-type="all">All</button>
              <button class="filter-btn" data-type="cust">Customer</button>
              <button class="filter-btn" data-type="vend">Vendor</button>
          </div>
      </div>

      <div class="table-container">
          <div class="table-responsive">
              <table class="table align-middle mb-0">
                  <thead>
                      <tr>
                          <th width="80">ID</th>
                          <th>Name</th>
                          <th>Search Key</th>
                          <th>Location</th> <!-- ✅ Added Column -->
                          <th>Tax ID</th>    <!-- ✅ Added Column -->
                          <th>Phone</th>    <!-- ✅ Added Column -->
                          <th>Type</th>
                      </tr>
                  </thead>
                  <tbody id="bp-tbody">
                      <!-- Data loaded via AJAX -->
                  </tbody>
              </table>
          </div>
      </div>
    </div>
  </div>

  <!-- GLOBAL LOADER -->
  <div id="global-loader">
    <div class="loader-content">
        <div class="spinner-border text-info mb-3" role="status" style="width: 3rem; height: 3rem;"></div>
        <h5 class="fw-bold">Processing...</h5>
    </div>
  </div>

  <!-- WONDERFUL ALERT BOX MODAL -->
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

  <!-- SCRIPTS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
  $(function(){
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

    // FILTER LOGIC
    let currentFilter = 'all';

    $('.filter-btn').click(function() {
        $('.filter-btn').removeClass('active');
        $(this).addClass('active');
        currentFilter = $(this).data('type');
        filterTable();
    });

    $('#searchInput').keyup(function() {
        filterTable();
    });

    function filterTable() {
        const searchText = $('#searchInput').val().toLowerCase();
        const $rows = $('#bp-tbody tr');

        $rows.each(function() {
            const $row = $(this);
            const text = $row.text().toLowerCase();
            const isCust = $row.hasClass('is-customer');
            const isVend = $row.hasClass('is-vendor');

            let matchesType = true;
            if (currentFilter === 'cust') matchesType = isCust;
            if (currentFilter === 'vend') matchesType = isVend;

            const matchesText = text.includes(searchText);

            if (matchesType && matchesText) {
                $row.show();
            } else {
                $row.hide();
            }
        });
    }

    // LOAD PARTNERS
    function loadPartners() {
        $.get("<%= request.getContextPath() %>/BPManageServlet?action=list", function(data) {
            const $tbody = $('#bp-tbody').empty();
            if(data && data.length > 0) {
                data.forEach(bp => {
                    let badges = '';
                    let rowClass = '';
                    
                    if(bp.isCustomer === true || bp.isCustomer === 'Y') {
                        badges += '<span class="badge badge-cust me-1">Customer</span>';
                        rowClass += ' is-customer';
                    }
                    if(bp.isVendor === true || bp.isVendor === 'Y') {
                        badges += '<span class="badge badge-vend">Vendor</span>';
                        rowClass += ' is-vendor';
                    }

                    // ✅ Added new columns to table row rendering
                    const row = "<tr class='" + rowClass + "'>" +
                        "<td>" + bp.id + "</td>" +
                        "<td class='fw-bold'>" + bp.name + "</td>" +
                        "<td>" + (bp.value || '') + "</td>" +
                        "<td>" + (bp.location || '-') + "</td>" +
                        "<td>" + (bp.taxId || '-') + "</td>" +
                        "<td>" + (bp.phone || '-') + "</td>" +
                        "<td>" + badges + "</td>" +
                        "</tr>";
                    $tbody.append(row);
                });
                // Re-apply filters after load
                filterTable(); 
            } else {
                // Adjusted colspan to match new column count (7 columns)
                $tbody.append("<tr><td colspan='7' class='text-center text-muted'>No partners found.</td></tr>");
            }
        });
    }

    loadPartners();

    // SUBMIT FORM
    $("#bp-form").submit(function(e) {
      e.preventDefault();
      
      const name = $("#bpName").val().trim();
      const isCustomer = $("#isCustomer").is(":checked");
      const isVendor = $("#isVendor").is(":checked");

      // VALIDATION: Type cannot be empty
      if (!name) {
          showWonderfulBox('confirm', 'Missing Info', 'Partner Name is required.');
          return;
      }
      if (!isCustomer && !isVendor) {
          showWonderfulBox('error', 'Type Required', 'Please select at least one Partner Type (Customer or Vendor).');
          return;
      }

      $("#global-loader").css("display","flex");

      // ✅ Added new fields to payload
      const payload = {
        name: name,
        value: $("#bpValue").val(),
        location: $("#bpLocation").val(),
        taxId: $("#bpTaxId").val(),
        phone: $("#bpPhone").val(),
        isCustomer: isCustomer,
        isVendor: isVendor
      };

      $.ajax({
        url: "<%= request.getContextPath() %>/BPManageServlet",
        type: "POST",
        data: JSON.stringify(payload),
        contentType: "application/json",
        success: function(res) {
            $("#global-loader").hide();
            if(res.status === 'success') {
                showWonderfulBox('success', 'Saved Successfully', res.message, function(){
                    $("#bp-form")[0].reset();
                    loadPartners();
                });
            } else {
                showWonderfulBox('error', 'Error', res.error || res.message);
            }
        },
        error: function(xhr) {
            $("#global-loader").hide();
            let errMsg = "Unknown Error";
            if(xhr.responseJSON && xhr.responseJSON.error) {
                errMsg = xhr.responseJSON.error;
            }
            showWonderfulBox('error', 'Connection Failed', errMsg);
        }
      });
    });
  });
  </script>
</body>
</html>