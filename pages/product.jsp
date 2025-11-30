<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Product" %></title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">

   <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0/dist/js/select2.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

</head>
<body class="bg-light">
<%@ include file="header.jsp" %>
<%@ include file="sidebar.jsp" %>

<div class="card ">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3><%= request.getAttribute("orgName") != null ? request.getAttribute("orgName") : "Organization" %> - Product</h3>
        <button class="btn btn-primary" id="newBtn">New Product</button>
    </div>

    <div id="alert" style="display:none" class="alert"></div>

    
        <!-- Product Form -->
            <div class="card">
                <div class="card-header">Create / Edit Product</div>
                <div class="card-body">

                    <form id="productForm">
                        <input type="hidden" id="productId" value="0">

                        <div class="mb-2">
                            <label class="form-label">Value (Code)</label>
                            <input class="form-control" id="Value" required>
                        </div>

                        <div class="mb-2">
                            <label class="form-label">Name</label>
                            <input class="form-control" id="Name">
                        </div>

                        <div class="mb-2">
                            <label class="form-label">Category</label>
                            <select id="M_Product_Category_ID" class="form-select" required></select>
                        </div>

                        <div class="mb-2">
                            <label class="form-label">UOM</label>
                            <select id="C_UOM_ID" class="form-select" required></select>
                        </div>
					<div class="mb-2">
						<label class="form-label">Type</label> <select id="EntryType"
							class="form-select" required>
							<option value="">-- Select Type --</option>
							<option value="Purchase">Purchase</option>
							<option value="Sales">Sales</option>
						</select>
					</div>

					<div class="mb-2">
                            <label class="form-label">Description</label>
                            <textarea id="Description" class="form-control"></textarea>
                        </div>

                        <div class="row mb-2">
                            <div class="col-md-6">
                                <label class="form-label">HSN Code</label>
                                <input id="HSNCode" class="form-control">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Barcode / SKU</label>
                                <input id="Barcode" class="form-control">
                            </div>
                        </div>

                        <div class="mb-2">
                            <label class="form-label">Bill Price</label>
                            <input id="BillPrice" type="number" class="form-control" step="0.01">
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-success">Save</button>
                            <button type="button" id="resetBtn" class="btn btn-secondary">Reset</button>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    


<%
    String catsStr = request.getAttribute("productList") != null
            ? request.getAttribute("productList").toString()
            : "[]";

    String uomStr = request.getAttribute("uom") != null
            ? request.getAttribute("uom").toString()
            : "[]";
%>

<script>
var catsJson = <%= org.json.JSONObject.quote(catsStr) %>;
var uomsJson = <%= org.json.JSONObject.quote(uomStr) %>;
var cats = JSON.parse(catsJson);
var uoms = JSON.parse(uomsJson);

function populateUI() {
	let catSel = document.getElementById('M_Product_Category_ID');
	let uomSel = document.getElementById('C_UOM_ID');

	// Clear existing
	catSel.innerHTML = "";
	uomSel.innerHTML = "";

	// Default option
	let defaultCat = document.createElement("option");
	defaultCat.value = "";
	defaultCat.text = "-- Select Category --";
	catSel.appendChild(defaultCat);

	cats.forEach(c => {
	    let opt = document.createElement("option");
	    opt.value = c.M_Product_Category_ID;
	    opt.text = c.Name;
	    catSel.appendChild(opt);
	});

	// Default UOM option
	let defaultUom = document.createElement("option");
	defaultUom.value = "";
	defaultUom.text = "-- Select UOM --";
	uomSel.appendChild(defaultUom);

	uoms.forEach(u => {
	    let opt = document.createElement("option");
	    opt.value = u.C_UOM_ID;
	    opt.text = u.Name;
	    uomSel.appendChild(opt);
	});
}

populateUI();

// Enable Select2 searchable dropdowns
$(document).ready(function() {
    $('#M_Product_Category_ID').select2({ placeholder: "Select Category", width: '100%' });
    $('#C_UOM_ID').select2({ placeholder: "Select UOM", width: '100%' });
});

function resetForm() {
    document.getElementById('productId').value = 0;
    document.getElementById('Value').value = '';
    document.getElementById('Name').value = '';
    $('#M_Product_Category_ID').val('').trigger('change');
    $('#C_UOM_ID').val('').trigger('change');
    document.getElementById('Description').value = '';
    document.getElementById('HSNCode').value = '';
    document.getElementById('Barcode').value = '';
    document.getElementById('BillPrice').value = '';
}

document.getElementById('resetBtn').addEventListener('click', resetForm);
document.getElementById('newBtn').addEventListener('click', resetForm);

document.getElementById('productForm').addEventListener('submit', function(e) {
    e.preventDefault();
alert("working");
    let payload = {
        productId: parseInt(document.getElementById('productId').value),
        Value: document.getElementById('Value').value,
        Name: document.getElementById('Name').value,
        M_Product_Category_ID: parseInt(document.getElementById('M_Product_Category_ID').value),
        C_UOM_ID: parseInt(document.getElementById('C_UOM_ID').value),
        Description: document.getElementById('Description').value,
        HSNCode: document.getElementById('HSNCode').value,
        Barcode: document.getElementById('Barcode').value,
        BillPrice: parseFloat(document.getElementById('BillPrice').value || 0),
        EntryType: document.getElementById('EntryType').value
    };

    $.ajax({
        url: "<%= request.getContextPath() %>/PurchaseProduct",
        type: "POST",
        data: JSON.stringify(payload),
        contentType: "application/json; charset=utf-8",
        success: function(res) {
          alert("✅ Purchase saved successfully!");
         /*  $("#items-body").empty();
          $("#supplier").val('').trigger('change');
          updateTotal(); */
        },
        error: function(xhr) {
          alert("❌ Error saving purchase: " + xhr.responseText);
        }
      });
});

function showAlert(msg, type) {
    let a = document.getElementById('alert');
    a.style.display = 'block';
    a.className = 'alert alert-' + type;
    a.innerText = msg;
    setTimeout(() => a.style.display = 'none', 3000);
}
</script>
</body>
</html>