<%@ page import="java.util.*, org.compiere.model.*, org.compiere.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Purchase Entry | Vijay Tech Orbit</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />

  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
  
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
  <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

  <style>
    :root {
      --sidebar-width: 260px;
      --header-height: 75px;
      --accent: #15a0c6;
      --bg-dark: #0a1220;
      --card-bg: #ffffff;
      --transition: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: var(--bg-dark);
      background-image: radial-gradient(circle at top right, rgba(21, 160, 198, 0.05), transparent);
      color: #1e293b;
      margin: 0;
      padding-top: calc(var(--header-height) + 20px);
      min-height: 100vh;
    }

    /* ===========================
       HEADER UI (Based on Image)
       =========================== */
    .app-header {
      position: fixed;
      top: 0;
      right: 0;
      left: 0;
      height: var(--header-height);
      background: rgba(10, 18, 32, 0.95);
      backdrop-filter: blur(10px);
      display: flex;
      align-items: center;
      justify-content: flex-end; /* Align user info to right */
      padding: 0 40px;
      z-index: 4000;
      border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    }

    .header-user-zone {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;
    }

    .version-tag {
      background: rgba(25, 182, 176, 0.2);
      color: #19b6b0;
      font-size: 10px;
      font-weight: 800;
      padding: 2px 8px;
      border-radius: 20px;
      border: 1px solid rgba(25, 182, 176, 0.3);
    }

    .user-info {
      display: flex;
      align-items: center;
      gap: 15px;
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
      padding: 6px 16px;
      border-radius: 8px;
      font-weight: 700;
      font-size: 13px;
      display: flex;
      align-items: center;
      gap: 6px;
      transition: var(--transition);
    }
    .btn-logout:hover {
      background: #e60000;
      transform: translateY(-1px);
    }

    .status-online {
      font-size: 10px;
      color: rgba(255, 255, 255, 0.5);
    }

    /* ===========================
       CONTENT LAYOUT
       =========================== */
    .page-wrap {
      padding: 20px 40px;
      transition: var(--transition);
    }

    .purchase-card {
      background: var(--card-bg);
      border-radius: 30px;
      padding: 40px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.2);
      max-width: 1000px;
      margin: 0 auto;
    }

    .purchase-card h4 {
      font-weight: 800;
      font-size: 24px;
      color: #0a1220;
      margin-bottom: 30px;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .purchase-card h4::before {
      content: '';
      display: block;
      width: 4px;
      height: 24px;
      background: var(--accent);
      border-radius: 10px;
    }

    /* Form Controls */
    .form-label { font-weight: 700; color: #64748b; font-size: 13px; margin-bottom: 8px; }
    .select2-container--default .select2-selection--single {
      height: 50px;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      background: #f8fafc;
    }

    /* Table */
    .table-container {
      border: 1px solid #e2e8f0;
      border-radius: 16px;
      overflow: hidden;
      margin: 25px 0;
    }
    .table thead th {
      background: #f8fafc;
      color: #64748b;
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      padding: 15px;
      border: none;
    }

    /* Buttons */
    .btn-add {
      border: 2px solid var(--accent);
      color: var(--accent);
      background: transparent;
      padding: 10px 20px;
      border-radius: 12px;
      font-weight: 700;
      transition: var(--transition);
    }
    .btn-add:hover { background: rgba(21, 160, 198, 0.05); }

    .net-amount-box {
      font-size: 18px;
      font-weight: 600;
      color: #64748b;
    }
    #grand-total { color: var(--accent); font-weight: 800; font-size: 24px; }

    .btn-submit {
      background: transparent;
      color: #475569;
      border: none;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: var(--transition);
    }
    .btn-submit:hover { color: var(--accent); }

    @media (max-width: 992px) {
      .page-wrap { margin-left: 0; padding: 20px; }
    }
  </style>
</head>

<body>

  <header class="app-header">
    <div class="header-user-zone">
      <span class="version-tag">v44.1</span>
      <div class="user-info">
        <span class="user-name">Guest</span>
        <button class="btn-logout" onclick="location.href='logout.jsp'">
          <i class="bi bi-power"></i> Logout
        </button>
      </div>
      <span class="status-online">Status: Online</span>
    </div>
  </header>

  <%@ include file="sidebar.jsp" %>

  <div class="page-wrap">
    <div class="purchase-card">
      <h4>New Purchase Entry</h4>

      <form id="purchase-form" novalidate>
        <div class="mb-4">
          <label class="form-label">Vendor / Supplier</label>
          <select id="supplier" class="form-select">
            <option value="">--Select Supplier--</option>
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
          <table class="table align-middle mb-0" id="purchase-items">
            <thead>
              <tr>
                <th width="60">#</th>
                <th>Product Description</th>
                <th width="120">Quantity</th>
                <th width="140">Unit Rate</th>
                <th width="140" class="text-end">Subtotal</th>
                <th width="60"></th>
              </tr>
            </thead>
            <tbody id="items-body">
              </tbody>
          </table>
        </div>

        <div class="d-flex align-items-center justify-content-between mt-4">
          <button type="button" id="add-item" class="btn btn-add">
            <i class="bi bi-plus-lg me-1"></i> Add Product
          </button>
          
          <div class="net-amount-box">
            Net Amount: <span id="currency-symbol">₹</span> <span id="grand-total">0.00</span>
          </div>
        </div>

        <div class="d-flex justify-content-end mt-5">
          <button type="submit" class="btn btn-submit">
            <i class="bi bi-shield-check"></i> Submit Purchase
          </button>
        </div>
      </form>
    </div>
  </div>

  <div id="global-loader" style="display:none; align-items:center; justify-content:center; position:fixed; inset:0; z-index:5000; background:rgba(10, 18, 32, 0.8); backdrop-filter: blur(5px);">
    <div class="spinner-border text-info" role="status"></div>
  </div>

  <script>
  $(function(){
    let products = [];
    let productsLoaded = false;

    $("#supplier").select2({ placeholder: "--Select Supplier--", width: "100%" });

    function loadProducts() {
      return $.ajax({
        url: "<%= request.getContextPath() %>/PurchaseServlet?action=getProducts",
        method: "GET",
        dataType: "json"
      }).done(function(result) {
        products = result || [];
        productsLoaded = true;
      });
    }
    loadProducts();

    $("#add-item").click(function() {
      if (!productsLoaded) return;
      const $row = $(`
        <tr>
          <td class="idx text-muted fw-bold">0</td>
          <td>
            <select class="form-select prod-id"></select>
            <input type="hidden" class="prod-name" /><input type="hidden" class="uom" /><input type="hidden" class="uom-id" />
          </td>
          <td><input type="number" min="0" step="0.01" class="form-control qty" value="1"></td>
          <td><input type="number" step="0.01" min="0" class="form-control rate" value="0"></td>
          <td class="amount text-end fw-bold">0.00</td>
          <td class="text-center">
            <button type="button" class="btn btn-link text-danger p-0 btn-remove"><i class="bi bi-trash3-fill"></i></button>
          </td>
        </tr>
      `);

      const $select = $row.find(".prod-id");
      $select.append('<option value="">--Select Product--</option>');
      products.forEach(p => {
        $select.append($('<option/>',{ value: p.id, text: p.name, 'data-rate': p.rate, 'data-uom': p.uom, 'data-uomid': p.uomId }));
      });

      $select.select2({ placeholder: "--Select Product--", width: "100%" });
      $("#items-body").append($row);
      updateIndexes();
    });

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
        recalcRow($row);
      }
    });

    $(document).on("input change", ".qty, .rate", function() { recalcRow($(this).closest("tr")); });

    function recalcRow($row) {
      const qty = parseFloat($row.find(".qty").val()) || 0;
      const rate = parseFloat($row.find(".rate").val()) || 0;
      $row.find(".amount").text((qty * rate).toFixed(2));
      updateTotal();
    }

    function updateIndexes() {
      $("#items-body tr").each(function(i) { $(this).find(".idx").text(i+1); });
    }

    $(document).on("click", ".btn-remove", function() {
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

      if (items.length === 0) { alert("Please add items."); return; }

      $("#global-loader").css("display","flex");
      $.ajax({
        url: "<%= request.getContextPath() %>/PurchaseServlet",
        type: "POST",
        data: JSON.stringify({ purchaseData: { supplierId: supplierId, items: items } }),
        contentType: "application/json; charset=utf-8",
        success: function(res) {
          $("#global-loader").hide();
          alert("Success! Purchase Record Saved.");
          location.reload();
        },
        error: function() {
          $("#global-loader").hide();
          alert("Error saving record.");
        }
      });
    });
  });
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>