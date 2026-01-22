<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <!-- Essential viewport meta tag for mobile responsiveness -->
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover" />
  <title>Product Category | Vijay Tech Orbit</title>

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
      /* Prevent horizontal scrollbar on mobile */
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
      white-space: nowrap; /* Prevent name breaking */
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
      max-width: 1400px;
      margin: 0 auto;
      width: 100%;
      /* Centering the card */
      display: flex;
      justify-content: center;
      align-items: flex-start; 
    }

    .category-card {
      background: var(--card-bg);
      border-radius: var(--radius-lg);
      padding: 40px;
      box-shadow: var(--shadow-card);
      border: 1px solid rgba(255,255,255,0.5);
      position: relative;
      overflow: hidden;
      width: 100%;
      max-width: 700px;
    }

    /* Top Decorative Line */
    .category-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 6px;
        background: linear-gradient(90deg, var(--accent), #8b5cf6);
    }

    .category-card h4 {
      font-weight: 800;
      font-size: 26px;
      color: #0f172a;
      margin-bottom: 35px;
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .category-card h4 i { color: var(--accent); font-size: 28px; }

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

    /* Buttons */
    .btn-action {
      background: white;
      border: 2px solid var(--accent);
      color: var(--accent);
      padding: 12px 24px;
      border-radius: 50px;
      font-weight: 700;
      transition: var(--transition);
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      width: 100%;
    }
    .btn-action:hover { 
        background: var(--accent); 
        color: white; 
        box-shadow: 0 10px 20px -5px rgba(21, 160, 198, 0.4);
        transform: translateY(-2px);
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
      width: 100%;
    }
    .btn-submit:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px -5px rgba(21, 160, 198, 0.5);
        filter: brightness(1.1);
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
       RESPONSIVE MEDIA QUERIES (ALL DEVICES)
       =========================== */
    
    /* Tablet & Small Laptops (992px and down) */
    @media (max-width: 992px) {
      .page-wrap { padding: 20px 30px; }
      .app-header { padding: 0 20px; }
      .category-card { padding: 30px; }
    }

    /* Landscape Tablets & Large Phones (768px and down) */
    @media (max-width: 768px) {
      .page-wrap { padding: 15px 20px; }
      .category-card { 
          padding: 25px; 
          border-radius: 18px;
      }
      .category-card h4 { 
          font-size: 22px; 
          margin-bottom: 25px; 
      }
      .category-card h4 i { font-size: 24px; }
      .card-subtitle { font-size: 14px; }
      
      /* Slightly reduce input height for smaller screens */
      .form-control, .form-select {
          height: 50px;
      }
    }

    /* Mobile Phones (576px and down) */
    @media (max-width: 576px) {
      /* Header adjustments */
      .app-header { padding: 0 15px; }
      
      /* Hide non-critical header text to save space */
      .user-name { display: none; }
      .status-online { display: none; }
      .user-info { padding: 6px 10px 6px 6px; gap: 8px; }

      /* Card adjustments */
      .page-wrap { 
          padding: 10px 10px 80px 10px; 
          align-items: flex-start;
      }
      .category-card { 
          padding: 25px 20px; 
          border-radius: 15px;
          box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1);
      }
      
      .category-card h4 { 
          font-size: 20px; 
          margin-bottom: 20px; 
      }
      
      /* Inputs */
      .form-control, .form-select {
          height: 48px;
          padding: 0 15px;
          font-size: 15px; /* Prevent iOS zoom */
      }
      
      textarea.form-control {
          min-height: 100px;
      }

      /* Modal adjustments for mobile */
      .modal-dialog-centered {
          margin: 15px; /* Keep away from edges */
      }
      .wb-msg { font-size: 0.95rem; }
    }

    /* Very Small Screens (iPhone SE/Mini 360px) */
    @media (max-width: 360px) {
        .category-card h4 { font-size: 18px; }
        .form-label { font-size: 11px; }
        .btn-action, .btn-submit { font-size: 14px; padding: 10px 20px; }
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
    <div class="category-card">
      <h4><i class="bi bi-grid-3x3-gap-fill"></i> Product Category</h4>
      <p class="card-subtitle">Create and organize new inventory categories.</p>

      <form id="catForm" novalidate>
        <div class="mb-4">
          <label for="Name" class="form-label">Category Name <span class="text-danger">*</span></label>
          <input type="text" id="Name" class="form-control" placeholder="e.g. Textiles, Electronics" required autocomplete="off">
        </div>

        <div class="mb-4">
          <label for="Value" class="form-label">Search Key / Value</label>
          <input type="text" id="Value" class="form-control" placeholder="Short code (optional)" autocomplete="off">
        </div>

        <div class="mb-4">
          <label for="Description" class="form-label">Description</label>
          <textarea id="Description" class="form-control" rows="3" placeholder="Describe this category..."></textarea>
        </div>

        <div class="row g-3 mt-4">
          <div class="col-md-6 col-12">
            <!-- col-12 added to ensure stacking on mobile even without md-6 -->
            <button type="button" id="resetBtn" class="btn-action">
              <i class="bi bi-x-circle"></i> Reset
            </button>
          </div>
          <div class="col-md-6 col-12">
            <button type="submit" class="btn-submit shadow">
              <i class="bi bi-cloud-arrow-up-fill me-2"></i> Save Category
            </button>
          </div>
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

    // Form Submission
    $("#catForm").submit(function(e) {
      e.preventDefault();

      const name = $("#Name").val().trim();
      const value = $("#Value").val().trim();
      const desc = $("#Description").val().trim();

      // Simple Validation
      if(!name) {
          showWonderfulBox('error', 'Missing Information', 'Please provide a Category Name.');
          $("#Name").focus();
          return;
      }

      // Show Loader
      $("#global-loader").css("display","flex").hide().fadeIn(200);

      const data = {
          Name: name,
          Value: value,
          Description: desc
      };

      $.ajax({
          type: "POST",
          url: "<%= request.getContextPath() %>/ProductCategory",
          data: JSON.stringify(data),
          contentType: "application/json",
          success: function (response) {
              $("#global-loader").fadeOut(200);
              showWonderfulBox('success', 'Saved Successfully', 'Product category has been created.', function(){
                  $("#catForm")[0].reset();
              });
          },
          error: function(xhr) {
              $("#global-loader").fadeOut(200);
              const errorMsg = xhr.responseText || "Could not save category. Please try again.";
              showWonderfulBox('error', 'Error', errorMsg);
          }
      });
    });

    $("#resetBtn").click(function() {
        $("#catForm")[0].reset();
    });
  });
  </script>
</body>
</html>