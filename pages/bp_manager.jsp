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
    /* === TRENDING UI VARIABLES === */
    :root {
      --sidebar-width: 260px;
      --header-height: 75px;
      --accent: #15a0c6;
      --accent-glow: rgba(21, 160, 198, 0.3);
      --bg-dark: #0a1220;
      --card-bg: #ffffff;
      --text-main: #1e293b;
      --text-muted: #64748b;
      --border-light: #e2e8f0;
      --radius-lg: 20px;
      --radius-sm: 12px;
      --shadow-card: 0 20px 40px -5px rgba(0, 0, 0, 0.1);
      --transition: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: var(--bg-dark);
      background-image: 
        radial-gradient(circle at top right, rgba(21, 160, 198, 0.08), transparent 40%),
        radial-gradient(circle at bottom left, rgba(139, 92, 246, 0.05), transparent 40%);
      color: var(--text-main);
      margin: 0;
      padding-top: calc(var(--header-height) + 20px);
      min-height: 100vh;
    }

    /* HEADER & SIDEBAR (Included via file, but styled here if needed) */
    .app-header {
      position: fixed; top: 0; right: 0; left: 0; height: var(--header-height);
      background: rgba(10, 18, 32, 0.9); backdrop-filter: blur(12px);
      display: flex; align-items: center; justify-content: flex-end;
      padding: 0 40px; z-index: 4000; border-bottom: 1px solid rgba(255,255,255,0.05);
    }
    .user-info { color: white; font-weight: 700; }

    /* MAIN CARD */
    .bp-card {
      background: var(--card-bg);
      border-radius: var(--radius-lg);
      padding: 40px;
      box-shadow: var(--shadow-card);
      border: 1px solid rgba(255,255,255,0.5);
      position: relative; overflow: hidden;
    }
    .bp-card::before {
        content: ''; position: absolute; top: 0; left: 0; right: 0; height: 6px;
        background: linear-gradient(90deg, var(--accent), #8b5cf6);
    }

    /* FORM CONTROLS */
    .form-label { font-weight: 700; color: var(--text-muted); font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
    .form-control {
        height: 54px; border-radius: var(--radius-sm); border: 1px solid var(--border-light);
        background: #f8fafc; font-weight: 600; transition: var(--transition);
    }
    .form-control:focus {
        background: #fff; border-color: var(--accent);
        box-shadow: 0 0 0 4px rgba(21, 160, 198, 0.1);
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
    .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 15px 30px -5px rgba(21, 160, 198, 0.5); }

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

    /* WONDERFUL ALERT BOX */
    #wonderful-alert-box { z-index: 6000; }
    .modal-content.wonderful-box {
        border: none; border-radius: 24px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
        overflow: hidden; animation: popIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
    }
    @keyframes popIn { from { transform: scale(0.9); opacity: 0; } to { transform: scale(1); opacity: 1; } }
    .wb-icon-area { height: 60px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px; }
    .wb-icon-area i { font-size: 3rem; }
    .wb-icon-success i { color: #10b981; text-shadow: 0 4px 15px rgba(16, 185, 129, 0.3); }
    .wb-icon-error i { color: #ef4444; text-shadow: 0 4px 15px rgba(239, 68, 68, 0.3); }
    .wb-icon-confirm i { color: var(--accent); text-shadow: 0 4px 15px rgba(21, 160, 198, 0.3); }
    .wb-title { font-weight: 800; font-size: 1.25rem; margin-bottom: 0.5rem; }
    .wb-msg { color: var(--text-muted); margin-bottom: 1.5rem; }
    .wb-btn-confirm { background: var(--accent); color: white; border: none; padding: 10px 25px; border-radius: 30px; font-weight: 700; }

    /* GLOBAL LOADER */
    #global-loader {
        display: none; align-items: center; justify-content: center; position: fixed;
        inset: 0; z-index: 5500; background: rgba(10, 18, 32, 0.8); backdrop-filter: blur(8px);
    }
    .loader-content { text-align: center; color: white; }
  </style>
</head>
<body>

  <!-- SIDEBAR -->
  <%@ include file="sidebar.jsp" %>

  <!-- HEADER (Copied for standalone context, usually in sidebar) -->
  <header class="app-header">
    <div class="d-flex align-items-center">
        <span class="version-tag" style="background:rgba(25, 182, 176, 0.15); color:#19b6b0; padding:3px 10px; border-radius:20px; font-size:10px; font-weight:800;">v44.1</span>
    </div>
    <div class="user-info ms-3"><%= (session.getAttribute("username") != null) ? session.getAttribute("username") : "Admin" %></div>
  </header>

  <div class="container" style="max-width: 1400px; margin: 0 auto;">
    <div class="bp-card">
      <h4 class="mb-4 fw-bold" style="color: #0f172a;"><i class="bi bi-people-fill text-info"></i> Partner Management</h4>

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
            <button type="submit" class="btn btn-submit">
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
        <div class="spinner-border text-info mb-3" style="width: 3rem; height: 3rem;"></div>
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

                    // NO BALANCE COLUMN
                    const row = "<tr class='" + rowClass + "'>" +
                        "<td>" + bp.id + "</td>" +
                        "<td class='fw-bold'>" + bp.name + "</td>" +
                        "<td>" + (bp.value || '') + "</td>" +
                        "<td>" + badges + "</td>" +
                        "</tr>";
                    $tbody.append(row);
                });
                // Re-apply filters after load
                filterTable(); 
            } else {
                $tbody.append("<tr><td colspan='4' class='text-center text-muted'>No partners found.</td></tr>");
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

      const payload = {
        name: name,
        value: $("#bpValue").val(),
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