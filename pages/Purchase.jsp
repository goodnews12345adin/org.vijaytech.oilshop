<%@ page import="java.util.*, org.compiere.model.*, org.compiere.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
<title>Purchase Entry</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<style>
  body {
    background-color: #f8f9fa;
  }
  .main-content {
    margin-left: 220px; /* space for sidebar */
    padding: 20px;
  }
  h4 {
    font-weight: 600;
    margin-bottom: 20px;
  }
  table th, table td {
    vertical-align: middle;
  }
</style>
</head>

<body>
  <%@ include file="header.jsp" %>
  <%@ include file="sidebar.jsp" %>

  <div class="main-content">
    <h4>Purchase Entry</h4>

    <form id="purchase-form" class="card p-3 shadow-sm bg-white">
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
            <% }} %>
          </select>
        </div>
      </div>

      <div class="table-responsive">
        <table class="table table-bordered table-sm align-middle" id="purchase-items">
          <thead class="table-light">
            <tr>
              <th style="width:25%">Product</th>
              <th style="width:15%">UOM</th>
              <th style="width:15%">Qty</th>
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
      <button type="submit" class="btn btn-success btn-sm px-4">Save Purchase</button>
    </form>
  </div>

  <script>
  $(document).ready(function() {

    // ✅ Add new item row
    $("#add-item").click(function() {
      let productOptions = `<option value="">--Select--</option>`;
      <%
  List<Map<String,Object>> productList = (List<Map<String,Object>>) request.getAttribute("productList");
  if (productList != null) {
    for (Map<String,Object> p : productList) {
%>
  productOptions += `<option value="<%= p.get("id") %>"><%= p.get("name") %></option>`;
<%
    }
  }
%>


      $("#items-body").append(`
        <tr>
          <td><select class="form-select form-select-sm prod-id">${productOptions}</select></td>
          <td><input type="text" class="form-control form-control-sm uom" value="Nos"></td>
          <td><input type="number" min="1" class="form-control form-control-sm qty" value="1"></td>
          <td><input type="number" step="0.01" class="form-control form-control-sm rate" value="0"></td>
          <td class="amount text-end">0.00</td>
          <td><button type="button" class="btn btn-outline-danger btn-sm remove">X</button></td>
        </tr>
      `);
    });

    // ✅ Auto calculate line total
    $(document).on("input", ".qty, .rate", function() {
      const $row = $(this).closest("tr");
      const qty = parseFloat($row.find(".qty").val()) || 0;
      const rate = parseFloat($row.find(".rate").val()) || 0;
      $row.find(".amount").text((qty * rate).toFixed(2));
    });

    // ✅ Remove item row
    $(document).on("click", ".remove", function() {
      $(this).closest("tr").remove();
    });

    // ✅ Submit purchase data
    $("#purchase-form").submit(function(e) {
      e.preventDefault();

      const data = {
        supplierId: $("#supplier").val(),
        items: $("#items-body tr").map(function() {
          const $row = $(this);
          return {
            prodId: $row.find(".prod-id").val(),
            unit: $row.find(".uom").val(),
            qty: parseFloat($row.find(".qty").val()) || 0,
            rate: parseFloat($row.find(".rate").val()) || 0,
            amount: parseFloat($row.find(".amount").text()) || 0
          };
        }).get()
      };

      if (!data.supplierId) {
        alert("Please select a supplier before saving.");
        return;
      }

      $.ajax({
        type: "POST",
        url: "<%= request.getContextPath() %>/PurchaseServlet",
        data: JSON.stringify({ purchaseData: data }),
        contentType: "application/json; charset=utf-8",
        success: function(res) {
          alert("✅ Purchase saved successfully!");
          console.log(res);
          $("#items-body").empty(); // clear table after save
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