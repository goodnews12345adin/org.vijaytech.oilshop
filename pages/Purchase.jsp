<%@ page import="java.util.*, org.compiere.model.*, org.compiere.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Purchase Entry</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />

  <!-- bootstrap, jquery, select2 -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
  <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

  <style>
    /* ------------------------------
       Tokens & Layout
       ------------------------------ */
    :root{
      --sidebar-width: 260px;            /* width of your sidebar.jsp */
      --header-height: 64px;
      --glass-bg: rgba(255,255,255,0.06);
      --accent: #15a0c6;
      --card-radius: 12px;
      --shadow-lg: 0 22px 40px rgba(2,6,23,0.4);
      --transition: 280ms;
    }

    html,body { height:100%; margin:0; font-family:Inter,system-ui,-apple-system,"Segoe UI", Roboto, Arial; -webkit-font-smoothing:antialiased; -moz-osx-font-smoothing:grayscale; }
    body {
      background: linear-gradient(180deg,#0a1220 0%, #141927 60%);
      color: #0f1724;
      padding-top: calc(var(--header-height) + 16px);
    }

    /* ===========================
       HEADER (floating, mobile-app style)
       =========================== */
    .app-header {
      position: fixed;
      top: 8px;
      left: 50%;
      transform: translateX(-50%);
      height: var(--header-height);
      min-width: 320px;
      width: calc(100% - 32px);
      max-width: 960px;
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:12px;
      background: linear-gradient(180deg, rgba(255,255,255,0.03), rgba(255,255,255,0.02));
      border-radius: 16px;
      padding: 10px 14px;
      box-shadow: 0 8px 30px rgba(2,6,23,0.6);
      border: 1px solid rgba(255,255,255,0.03);
      z-index: 4000;
      backdrop-filter: blur(8px);
    }

    .header-left {
      display:flex;
      align-items:center;
      gap:12px;
    }

    /* hamburger */
    .hamburger {
      width:44px;
      height:44px;
      display:inline-grid;
      place-items:center;
      border-radius:10px;
      background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
      border:1px solid rgba(255,255,255,0.03);
      cursor:pointer;
      transition: transform var(--transition) ease;
    }
    .hamburger .bars {
      width:20px;
      height:14px;
      position:relative;
    }
    .hamburger .bars span {
      display:block;
      position:absolute;
      left:0;
      right:0;
      height:2px;
      background:#e6eef2;
      border-radius:2px;
      transition: transform var(--transition) ease, opacity var(--transition) ease;
    }
    .hamburger .bars span:nth-child(1) { top:0; }
    .hamburger .bars span:nth-child(2) { top:6px; }
    .hamburger .bars span:nth-child(3) { top:12px; }

    /* hamburger -> X when active */
    html.sidebar-open .hamburger .bars span:nth-child(1) { transform: translateY(6px) rotate(45deg); }
    html.sidebar-open .hamburger .bars span:nth-child(2) { opacity:0; }
    html.sidebar-open .hamburger .bars span:nth-child(3) { transform: translateY(-6px) rotate(-45deg); }

    .header-title {
      font-size:1rem;
      font-weight:600;
      color: #e8f7f7;
      letter-spacing: 0.01em;
    }

    .header-right { display:flex; gap:10px; align-items:center; }

    .header-action {
      display:inline-flex;
      gap:8px;
      align-items:center;
      background: rgba(255,255,255,0.03);
      padding:6px 10px;
      border-radius:999px;
      color:#e6f3f3;
      border:1px solid rgba(255,255,255,0.02);
      font-weight:600;
      font-size:0.9rem;
    }

    /* ===========================
       SIDEBAR PUSH EFFECT
       (we add class .sidebar-open to html to show sidebar and shift content)
       =========================== */

    /* default: sidebar off (we don't control sidebar markup here) */
    :root { --content-offset: 0px; }

    /* when open, shift main content to the right by sidebar width */
    html.sidebar-open body { --content-offset: var(--sidebar-width); }

    /* we apply the transform to the page container */
    .page-wrap {
      transition: transform var(--transition) ease, margin var(--transition) ease;
      transform: translateX(var(--content-offset));
      padding: 16px;
      min-height: calc(100vh - 100px);
      display:flex;
      align-items:flex-start;
      justify-content:center;
    }

    /* ensure sidebar appears above content - sidebar.jsp should handle its own positioning */
    .app-sidebar { transition: transform var(--transition) ease; }

    /* ===========================
       PURCHASE CARD styling
       =========================== */
    .purchase-card {
      width:100%;
      max-width:520px;   /* slightly wider on desktop */
      border-radius:14px;
      background: linear-gradient(180deg, rgba(255,255,255,0.98), rgba(250,250,250,0.98));
      padding:18px;
      box-shadow: var(--shadow-lg);
      border: 1px solid rgba(0,0,0,0.06);
    }

    .purchase-card h4 { margin:0 0 12px; color:#0b1224; font-weight:600; }

    .table thead th { background:#fbfdff; color:#475569; font-weight:700; font-size:0.86rem; }
    .table tbody td { font-size:0.92rem; padding:8px 8px; vertical-align: middle; }

    .select2-container { width:100% !important; }
    .table .select2-container { min-width:140px; }

    .totals-row { margin-top:12px; display:flex; gap:12px; align-items:center; }
    .total { margin-left:auto; font-weight:700; font-size:1rem; }

    /* small screens adjustments */
    @media (max-width: 480px) {
      .app-header { left: 8px; transform: none; width: calc(100% - 16px); max-width: 480px; border-radius:12px; top:6px; }
      .purchase-card { max-width:420px; padding:14px; }
      body { padding-top: calc(var(--header-height) + 12px); }
      html.sidebar-open body { --content-offset: 220px; } /* smaller push on tiny screens */
      .table thead th, .table tbody td { font-size:0.8rem; padding:6px; }
      .table .select2-container { min-width:120px; }
      .app-sidebar { display:block; } /* allow sidebar but pushed */
    }

    /* medium screens */
    @media (min-width: 768px) {
      .purchase-card { max-width:720px; }
      .page-wrap { justify-content:flex-start; padding-left:40px; } /* nicer on tablet/desktop */
    }

    /* desktop - ensure full push */
    @media (min-width: 992px) {
      .page-wrap { padding-left:60px; }
      html.sidebar-open body { --content-offset: var(--sidebar-width); }
      .purchase-card { max-width:760px; }
    }

    /* Print rules */
    @media print {
      .app-header, .hamburger { display:none !important; }
      .app-sidebar { display:none !important; }
      .purchase-card { box-shadow:none; border:none; max-width:100%;}
      body { background:#fff; padding-top: 0; }
    }

    /* reduced motion */
    @media (prefers-reduced-motion: reduce) {
      * { transition: none !important; animation-duration: 0.001ms !important; }
    }
  </style>
</head>

<body>

  <!-- ========== Header (floating) ========== -->
  <header class="app-header" role="banner" aria-label="Application header">
    <div class="header-left">
      <button id="sidebarToggle" class="hamburger" aria-controls="sidebar" aria-expanded="false" title="Toggle sidebar" type="button">
        <span class="bars" aria-hidden="true">
          <span></span><span></span><span></span>
        </span>
      </button>
      <div class="header-title">Purchase Entry</div>
    </div>

    <div class="header-right">
      <div class="header-action" title="Organization">
        <i class="bi bi-building" style="font-size:1rem; color: #e6f3f3;"></i>
        <span style="color:#e6f3f3; margin-left:6px;">Vijay Tech</span>
      </div>
    </div>
  </header>

  <!-- include sidebar (assumed .app-sidebar exists in sidebar.jsp) -->
  <%@ include file="sidebar.jsp" %>

  <!-- ========== Page wrap (will be pushed when sidebar opens) ========== -->
  <div class="page-wrap" id="pageWrap" role="main">

    <!-- Purchase card -->
    <div class="purchase-card" role="region" aria-label="Purchase Entry Form">
      <h4>Purchase Entry</h4>

      <form id="purchase-form" novalidate>
        <div class="mb-3">
          <label class="form-label">Supplier</label>
          <select id="supplier" class="form-select form-select-sm" aria-label="Supplier select">
            <option value="">--Select Supplier--</option>
            <%
              List<Map<String,Object>> supplierList = (List<Map<String,Object>>) request.getAttribute("supplierList");
              if (supplierList != null) {
                for (Map<String,Object> s : supplierList) {
            %>
              <option value="<%= s.get("id") %>"><%= s.get("name") %></option>
            <%
                }
              }
            %>
          </select>
        </div>

        <div class="table-responsive">
          <table class="table table-bordered table-sm align-middle" id="purchase-items" role="table">
            <thead class="table-light">
              <tr>
                <th style="width:36px">#</th>
                <th>Product (with UOM)</th>
                <th style="width:90px">Qty</th>
                <th style="width:110px">Rate</th>
                <th style="width:110px">Amount</th>
                <th style="width:68px">Action</th>
              </tr>
            </thead>
            <tbody id="items-body" aria-live="polite"></tbody>
          </table>
        </div>

        <div class="totals-row">
          <button type="button" id="add-item" class="btn btn-sm btn-outline-primary">+ Add Item</button>
          <div class="total">Total: ₹ <span id="grand-total">0.00</span></div>
        </div>

        <div class="mt-3 text-end">
          <button type="submit" class="btn btn-success btn-sm px-4">Save Purchase</button>
        </div>
      </form>
    </div>

  </div> <!-- page-wrap -->

  <!-- loader overlay -->
  <div id="global-loader" aria-hidden="true" style="display:none; align-items:center; justify-content:center; position:fixed; inset:0; z-index:4500; background:rgba(0,0,0,0.36);">
    <div style="background:#fff;padding:14px 18px;border-radius:10px; box-shadow:0 8px 24px rgba(0,0,0,0.2);">Processing...</div>
  </div>

  <!-- Alerts container -->
  <div class="position-fixed top-3 end-3" style="z-index:5050; pointer-events:none;">
    <div id="alertBox" style="pointer-events:auto;"></div>
  </div>

  <!-- Scripts: existing JS (preserved) + toggle behavior -->
  <script>
  $(function(){
    // --- Sidebar toggle logic (push content) ---
    const toggleBtn = document.getElementById('sidebarToggle');
    const htmlEl = document.documentElement;
    const STORAGE_KEY = 'sidebarOpenVijay';
    // initialize from storage
    const isOpen = localStorage.getItem(STORAGE_KEY) === '1';
    if (isOpen) {
      htmlEl.classList.add('sidebar-open');
      toggleBtn.setAttribute('aria-expanded','true');
    }

    function setSidebarOpen(open) {
      if (open) {
        htmlEl.classList.add('sidebar-open');
        toggleBtn.setAttribute('aria-expanded','true');
        localStorage.setItem(STORAGE_KEY, '1');
      } else {
        htmlEl.classList.remove('sidebar-open');
        toggleBtn.setAttribute('aria-expanded','false');
        localStorage.setItem(STORAGE_KEY, '0');
      }
      // ensure focus remains on toggle for accessibility
      toggleBtn.focus({ preventScroll: true });
    }

    toggleBtn.addEventListener('click', function(e){
      e.preventDefault();
      setSidebarOpen(!htmlEl.classList.contains('sidebar-open'));
    });

    // close sidebar on ESC
    document.addEventListener('keydown', function(e){
      if (e.key === 'Escape' && htmlEl.classList.contains('sidebar-open')) {
        setSidebarOpen(false);
      }
    });

    // Click outside to close on small screens (optional)
    document.addEventListener('click', function(ev){
      const target = ev.target;
      const clickedInsideHeader = target.closest('.app-header');
      const clickedInsideSidebar = target.closest('.app-sidebar');
      if (!clickedInsideHeader && !clickedInsideSidebar && htmlEl.classList.contains('sidebar-open')) {
        // on larger screens we keep it open; on small screens we close when clicking outside
        if (window.innerWidth < 800) {
          setSidebarOpen(false);
        }
      }
    });


    // ============================
    // Existing Purchase entry JS (preserved from your previous code)
    // ============================
    let products = [];
    let productsLoaded = false;

    $("#supplier").select2({
      placeholder: "--Select Supplier--",
      allowClear: true,
      width: "100%"
    });

    function loadProducts() {
      return $.ajax({
        url: "<%= request.getContextPath() %>/PurchaseServlet?action=getProducts",
        method: "GET",
        dataType: "json"
      })
      .done(function(result) {
        products = result || [];
        productsLoaded = true;
        console.log("Products loaded:", products);
      })
      .fail(function(xhr) {
        productsLoaded = true; // avoid blocking adding rows
        console.error("Failed to load products:", xhr.responseText);
      });
    }
    loadProducts();

    // Add row
    $("#add-item").click(function() {
      if (!productsLoaded) return alert("Please wait, loading products...");
      if (products.length === 0) return alert("No products found!");

      const $row = $(`
        <tr>
          <td class="text-center idx">0</td>
          <td>
            <select class="form-select form-select-sm prod-id" style="width:100%"></select>
            <input type="hidden" class="prod-name" />
            <input type="hidden" class="uom" />
            <input type="hidden" class="uom-id" />
          </td>
          <td><input type="number" min="0" step="0.01" class="form-control form-control-sm qty" value="1"></td>
          <td><input type="number" step="0.01" min="0" class="form-control form-control-sm rate" value="0"></td>
          <td class="amount text-end">0.00</td>
          <td class="text-center"><button type="button" class="btn btn-outline-danger btn-sm btn-remove">X</button></td>
        </tr>
      `);

      const $select = $row.find(".prod-id");
      $select.append('<option value="">--Select Product--</option>');
      products.forEach(p => {
        $select.append($('<option/>',{
          value: p.id,
          text: p.name,
          'data-rate': p.rate,
          'data-uom': p.uom,
          'data-uomid': p.uomId
        }));
      });

      $select.select2({ placeholder: "--Select Product--", allowClear: true, width: "100%" });

      $("#items-body").append($row);
      updateIndexes();
    });

    $(document).on("change", ".prod-id", function() {
      const $row = $(this).closest("tr");
      const prodId = $(this).val();
      if (!prodId) {
        $row.find(".rate").val(0);
        $row.find(".prod-name").val("");
        $row.find(".uom").val("");
        $row.find(".uom-id").val("");
        $row.find(".amount").text("0.00");
        updateTotal();
        return;
      }
      const product = products.find(p => String(p.id) === String(prodId));
      if (product) {
        $row.find(".prod-name").val(product.name || "");
        $row.find(".rate").val(product.rate || 0);
        $row.find(".uom").val(product.uom || "");
        $row.find(".uom-id").val(product.uomId || "");
        recalcRow($row);
      } else {
        const $opt = $(this).find("option:selected");
        $row.find(".rate").val($opt.data("rate") || 0);
        $row.find(".uom").val($opt.data("uom") || "");
        $row.find(".uom-id").val($opt.data("uomid") || "");
        recalcRow($row);
      }
    });

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

    $(document).on("click", ".btn-remove", function() {
      const $select = $(this).closest("tr").find(".prod-id");
      try { if ($select.data('select2')) $select.select2('destroy'); } catch(e){}
      $(this).closest("tr").remove();
      updateIndexes();
      updateTotal();
    });

    function updateTotal() {
      let total = 0;
      $("#items-body tr").each(function() { total += parseFloat($(this).find(".amount").text()) || 0; });
      $("#grand-total").text(total.toFixed(2));
    }

    $("#purchase-form").submit(function(e) {
      e.preventDefault();

      const supplierId = $("#supplier").val();
      if (!supplierId) { alert("Please select a supplier."); return; }

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

      if (items.length === 0) { alert("Please add at least one item."); return; }
      const invalid = items.find(it => it.qty <= 0 || it.rate <= 0);
      if (invalid) { alert("Quantity and Rate must be greater than zero for all items."); return; }

      $("#global-loader").css("display","flex").attr("aria-hidden","false");

      $.ajax({
        url: "<%= request.getContextPath() %>/PurchaseServlet",
        type: "POST",
        data: JSON.stringify({ purchaseData: { supplierId: supplierId, items: items } }),
        contentType: "application/json; charset=utf-8",
        success: function(res) {
          $("#global-loader").hide().attr("aria-hidden","true");
          // success feedback
          $('#alertBox').html('<div class="alert alert-success alert-dismissible fade show" role="alert">Purchase saved successfully! <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>');
          $("#items-body").empty();
          $("#supplier").val('').trigger('change');
          updateTotal();
        },
        error: function(xhr) {
          $("#global-loader").hide().attr("aria-hidden","true");
          const err = xhr.responseText || "Server error";
          $('#alertBox').html('<div class="alert alert-danger alert-dismissible fade show" role="alert">Error saving purchase: ' + err + ' <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>');
        }
      });
    });

    // accessibility: allow Enter to select first Select2 result in the search input
    $(document).on('keydown', '.select2-search__field', function(e){
      if (e.key === 'Enter') {
        e.preventDefault();
        $('.select2-results__option[aria-selected=false]').first().trigger('mouseup');
      }
    });

  }); // end ready
  </script>

  <!-- bootstrap bundle (placed at the end) -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
