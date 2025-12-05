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

<style>
    /* Basic layout for the main content area */
    body { min-height: 100vh; }
   .card.main-content {
    margin-left: 10px;
    padding: 20px;
    background-color: #ffffff;
    border: 1px solid #dee2e6;
    border-radius: .25rem;
    max-width: 98%;
    margin-top: 20px;
}
    .select2-container {
        width: 100% !important; /* Ensure select2 takes full width */
    }
    /* Small adjustment for card containing the form */
    .card.form-container {
        border: 1px solid #d1e7dd;
    }
    .card-header {
        background-color: #f8f9fa;
        font-weight: bold;
    }
</style>
</head>
<body class="bg-light">
<%@ include file="header.jsp" %>
<%@ include file="sidebar.jsp" %>

<div class="card main-content">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3><%= request.getAttribute("orgName") != null ? request.getAttribute("orgName") : "Organization" %> - Product</h3>
        <button class="btn btn-primary" id="newBtn">New Product</button>
    </div>

    <div id="alert" style="display:none" class="alert"></div>

    
        <div class="card form-container">
            <div class="card-header">Create / Edit Product</div>
            <div class="card-body">

                <form id="productForm">
                    <input type="hidden" id="productId" value="0">

                    <div class="row">
                        <div class="mb-2 col-md-6">
                            <label class="form-label" for="Value">Value (Code)</label>
                            <input class="form-control" id="Value" required>
                        </div>

                        <div class="mb-2 col-md-6">
                            <label class="form-label" for="Name">Name</label>
                            <input class="form-control" id="Name">
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="mb-2 col-md-4">
                            <label class="form-label" for="M_Product_Category_ID">Category</label>
                            <select id="M_Product_Category_ID" class="form-select" required></select>
                        </div>

                        <div class="mb-2 col-md-4">
                            <label class="form-label" for="C_UOM_ID">UOM</label>
                            <select id="C_UOM_ID" class="form-select" required></select>
                        </div>
                        
                        <div class="mb-2 col-md-4">
                            <label class="form-label" for="EntryType">Type</label>
                            <select id="EntryType" class="form-select" required>
                                <option value="">-- Select Type --</option>
                                <option value="Purchase">Purchase</option>
                                <option value="Sales">Sales</option>
                            </select>
                        </div>
                    </div>

                    <div class="mb-2">
                        <label class="form-label" for="Description">Description</label>
                        <textarea id="Description" class="form-control"></textarea>
                    </div>

                    <div class="row mb-2">
                        <div class="col-md-4">
                            <label class="form-label" for="HSNCode">HSN Code</label>
                            <input id="HSNCode" class="form-control">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="Barcode">Barcode / SKU</label>
                            <input id="Barcode" class="form-control">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="BillPrice">Bill Price</label>
                            <input id="BillPrice" type="number" class="form-control" step="0.01">
                        </div>
                    </div>

                    <div class="d-flex gap-2 mt-3">
                        <button type="submit" class="btn btn-success">Save</button>
                        <button type="button" id="resetBtn" class="btn btn-secondary">Reset</button>
                    </div>
                </form>

            </div>
        </div>
    
</div>
    


<%
    // Ensure the attributes are present before attempting to quote/parse
    String catsStr = request.getAttribute("productList") != null
            ? request.getAttribute("productList").toString()
            : "[]";

    String uomStr = request.getAttribute("uom") != null
            ? request.getAttribute("uom").toString()
            : "[]";
%>

<script>
// JSON data embedded from the request attributes
// NOTE: org.json.JSONObject.quote() is used server-side to escape the JSON string for JavaScript
var catsJson = <%= org.json.JSONObject.quote(catsStr) %>;
var uomsJson = <%= org.json.JSONObject.quote(uomStr) %>;
var cats = JSON.parse(catsJson);
var uoms = JSON.parse(uomsJson);

/**
 * Populates the Category and UOM dropdowns using the JSON data.
 */
function populateUI() {
	let catSel = document.getElementById('M_Product_Category_ID');
	let uomSel = document.getElementById('C_UOM_ID');

	// Clear existing options
	catSel.innerHTML = "";
	uomSel.innerHTML = "";

	// Default Category option
	let defaultCat = document.createElement("option");
	defaultCat.value = "";
	defaultCat.text = "-- Select Category --";
	catSel.appendChild(defaultCat);

    // Populate Category options
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

    // Populate UOM options
	uoms.forEach(u => {
	    let opt = document.createElement("option");
	    opt.value = u.C_UOM_ID;
	    opt.text = u.Name;
	    uomSel.appendChild(opt);
	});
}

// Execute population on page load
populateUI();

// Enable Select2 searchable dropdowns once the DOM is ready
$(document).ready(function() {
    $('#M_Product_Category_ID').select2({ 
        placeholder: "Select Category", 
        allowClear: true,
        width: '100%' 
    });
    $('#C_UOM_ID').select2({ 
        placeholder: "Select UOM", 
        allowClear: true,
        width: '100%' 
    });
});

/**
 * Resets all fields in the product form.
 */
function resetForm() {
    document.getElementById('productId').value = 0;
    document.getElementById('Value').value = '';
    document.getElementById('Name').value = '';
    
    // Select2 requires 'val' and 'trigger' to clear the selection
    $('#M_Product_Category_ID').val('').trigger('change'); 
    $('#C_UOM_ID').val('').trigger('change');
    
    document.getElementById('Description').value = '';
    document.getElementById('HSNCode').value = '';
    document.getElementById('Barcode').value = '';
    document.getElementById('BillPrice').value = '';
    document.getElementById('EntryType').value = '';
    
    document.getElementById('productForm').querySelector('button[type="submit"]').textContent = 'Save';
}

// Event Listeners for Reset and New buttons
document.getElementById('resetBtn').addEventListener('click', resetForm);
document.getElementById('newBtn').addEventListener('click', resetForm);

// Form Submission Handler
document.getElementById('productForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    // alert("working"); // Temporarily commented out, as requested in the initial code

    // Collect data into payload
    let payload = {
        productId: parseInt(document.getElementById('productId').value) || 0,
        Value: document.getElementById('Value').value,
        Name: document.getElementById('Name').value,
        M_Product_Category_ID: parseInt(document.getElementById('M_Product_Category_ID').value) || 0,
        C_UOM_ID: parseInt(document.getElementById('C_UOM_ID').value) || 0,
        Description: document.getElementById('Description').value,
        HSNCode: document.getElementById('HSNCode').value,
        Barcode: document.getElementById('Barcode').value,
        // Ensure BillPrice is parsed correctly, defaulting to 0 if empty
        BillPrice: parseFloat(document.getElementById('BillPrice').value || 0),
        EntryType: document.getElementById('EntryType').value
    };
    
    console.log("Submitting Payload:", payload);

    $.ajax({
        url: "<%= request.getContextPath() %>/Product",
        type: "POST",
        data: JSON.stringify(payload),
        contentType: "application/json; charset=utf-8",
        success: function(res) {
          showAlert("Product saved successfully!", "success");
          // Assuming the save is successful, reset the form for next entry
          resetForm();
          // NOTE: You might need to add logic here to refresh the product listing table
        },
        error: function(xhr) {
          showAlert("Error saving product: " + xhr.responseText, "danger");
          console.error("AJAX Error:", xhr);
        }
      });
});

/**
 * Displays a temporary alert message.
 * @param {string} msg - The message to display.
 * @param {string} type - The Bootstrap alert type (e.g., 'success', 'danger').
 */
function showAlert(msg, type) {
    let a = document.getElementById('alert');
    a.style.display = 'block';
    // Clear previous classes and set new ones
    a.className = 'alert'; 
    a.classList.add('alert-' + type);
    a.innerText = msg;
    setTimeout(() => a.style.display = 'none', 5000); // Increased timeout for readability
}
</script>
</body>
</html>