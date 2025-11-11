<%@ page import="java.util.*, org.compiere.model.*, org.compiere.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
<title>Purchase Entry</title>

<!-- ✅ CSS & JS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<style>
  body { background-color: #f8f9fa; }
  .main-content { margin-left: 220px; padding: 20px; }
  h4 { font-weight: 600; margin-bottom: 20px; }
  table th, table td { vertical-align: middle; }
  .select2-container { width: 100% !important; }
</style>
</head>

<body>
  <%-- <%@ include file="header.jsp" %> --%>
  <%@ include file="sidebar.jsp" %>

  <div class="main-content">
    <h4>Purchase Entry</h4>

    <form id="purchase-form" class="card p-3 shadow-sm bg-white">
      <!-- ✅ Supplier -->
      <div class="row mb-3">
        <div class="col-md-4">
          <label class="form-label">Supplier</label>
          <select id="supplier" class="form-select form-select-sm">
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
      </div>

      <!-- ✅ Purchase Items Table -->
      <div class="table-responsive">
        <table class="table table-bordered table-sm align-middle" id="purchase-items">
          <thead class="table-light">
            <tr>
              <th style="width:35%">Product (with UOM)</th>
              <th style="width:10%">Qty</th>
              <th style="width:15%">Rate</th>
              <th style="width:15%">Amount</th>
              <th style="width:10%">Action</th>
            </tr>
          </thead>
          <tbody id="items-body"></tbody>
        </table>
      </div>

      <button type="button" class="btn btn-sm btn-outline-primary" id="add-item">+ Add Item</button>
      <hr>

      <div class="text-end mb-3">
        <strong>Total: ₹ <span id="grand-total">0.00</span></strong>
      </div>

      <button type="submit" class="btn btn-success btn-sm px-4">Save Purchase</button>
    </form>
  </div>

<script>
$(document).ready(function() {
  let products = [];
  let productsLoaded = false;

  // ✅ Initialize supplier dropdown
  $("#supplier").select2({
    placeholder: "--Select Supplier--",
    allowClear: true
  });

  // ✅ Load product list (with UOM & Rate)
  function loadProducts() {
    return $.ajax({
      url: "<%= request.getContextPath() %>/PurchaseServlet?action=getProducts",
      method: "GET",
      dataType: "json"
    })
    .done(function(result) {
      products = result;
      productsLoaded = true;
      console.log("✅ Products loaded:", products);
    })
    .fail(function(xhr) {
      console.error("❌ Failed to load products:", xhr.responseText);
      alert("❌ Could not load product list from server.");
    });
  }
  loadProducts();

  // ✅ Add new row
  $("#add-item").click(function() {
    if (!productsLoaded) return alert("⚠️ Please wait... product list is still loading.");
    if (products.length === 0) return alert("❌ No products found!");

    const $row = $(`
      <tr>
        <td>
          <select class="form-select form-select-sm prod-id"></select>
          <input type="hidden" class="uom-id" name="uomid" value="">
          <input type="hidden" class="uom" name="uom" value="">
        </td>
        <td><input type="number" min="1" class="form-control form-control-sm qty" value="1" name="qty"></td>
        <td><input type="number" step="0.01" class="form-control form-control-sm rate" value="0" name="rate"></td>
        <td class="amount text-end">0.00</td>
        <td><button type="button" class="btn btn-outline-danger btn-sm remove">X</button></td>
      </tr>
    `);

    // Populate product select
    const $select = $row.find(".prod-id");
    $select.append('<option value="">--Select Product--</option>');
    products.forEach(p => {
      $select.append("<option value="+p.id+">"+p.name +"</option>");
    });

    // Activate Select2
    $select.select2({ placeholder: "--Select Product--", allowClear: true, width: "100%" });

    $("#items-body").append($row);
  });

  // ✅ When product is selected — auto fill UOM, Rate
  $(document).on("change", ".prod-id", function() {
    const $row = $(this).closest("tr");
    const prodId = $(this).val();

    if (!prodId) {
      $row.find(".rate").val(0);
      $row.find(".uom-id").val("");
      $row.find(".uom").val("");
      $row.find(".amount").text("0.00");
      updateTotal();
      return;
    }

    const product = products.find(p => p.id == prodId);
    if (product) {
      $row.find(".rate").val(product.rate || 0);
      $row.find(".uom").val(product.uom || "");
      $row.find(".uom-id").val(product.uomId || "");
      updateRowAmount($row);
    }
  });

  // ✅ Auto amount calculation
  $(document).on("input change", ".qty, .rate", function() {
    const $row = $(this).closest("tr");
    updateRowAmount($row);
  });

  function updateRowAmount($row) {
    const qty = parseFloat($row.find(".qty").val()) || 0;
    const rate = parseFloat($row.find(".rate").val()) || 0;
    const amt = qty * rate;
    $row.find(".amount").text(amt.toFixed(2));
    updateTotal();
  }

  // ✅ Grand total
  function updateTotal() {
    let total = 0;
    $("#items-body tr").each(function() {
      total += parseFloat($(this).find(".amount").text()) || 0;
    });
    $("#grand-total").text(total.toFixed(2));
  }

  // ✅ Remove row
  $(document).on("click", ".remove", function() {
    $(this).closest("tr").find(".prod-id").select2('destroy');
    $(this).closest("tr").remove();
    updateTotal();
  });

  // ✅ Submit form
  $("#purchase-form").submit(function(e) {
    e.preventDefault();

    const data = {
      supplierId: $("#supplier").val(),
      items: $("#items-body tr").map(function() {
        const $r = $(this);
        const prodId = $r.find(".prod-id").val();
        if (!prodId) return null;

        return {
          prodId: prodId,
          uom: $r.find(".uom").val(),
          uomId: $r.find(".uom-id").val(),
          qty: parseFloat($r.find(".qty").val()) || 0,
          rate: parseFloat($r.find(".rate").val()) || 0,
          amount: parseFloat($r.find(".amount").text()) || 0
        };
      }).get().filter(i => i !== null)
    };

    if (!data.supplierId) return alert("⚠️ Please select a supplier.");
    if (data.items.length === 0) return alert("⚠️ Please add at least one item.");

    console.log("Submitting Purchase Data:", data);

    $.ajax({
      url: "<%= request.getContextPath() %>/PurchaseServlet",
      type: "POST",
      data: JSON.stringify({ purchaseData: data }),
      contentType: "application/json; charset=utf-8",
      success: function(res) {
        alert("✅ Purchase saved successfully!");
        $("#items-body").empty();
        $("#supplier").val('').trigger('change');
        updateTotal();
      },
      error: function(xhr) {
        alert("❌ Error saving purchase: " + xhr.responseText);
      }
    });
  });
});
</script>
</body>
</html>
