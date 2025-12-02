<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Product Category</title>

  <!-- jQuery REQUIRED -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

  <style>
    body { font-family: Arial, sans-serif; padding:20px; background:#f4f4f4 }
    .card { background:#fff; padding:18px; border-radius:6px; max-width:100%; margin:auto; box-shadow:0 1px 3px rgba(0,0,0,0.2) }
    h2 { margin-top:0 }
    .row { margin-top:12px }
    label { font-size:13px; font-weight:bold }
    input, textarea { width:100%; padding:8px; border:1px solid #ccc; border-radius:5px }
    table { width:100%; border-collapse:collapse; margin-top:16px }
    th, td { padding:8px; border:1px solid #ddd; text-align:left }
    th { background:#f0f0f0 }
    .btn { padding:7px 14px; border-radius:5px; border:none; cursor:pointer }
    .btn.primary { background:#007bff; color:#fff }
    .btn.secondary { background:#e0e0e0 }
  </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="card">
  <h2>Create Product Category</h2>

  <form id="catForm" onsubmit="return false;">
    <div class="row">
      <label>Category Name*</label>
      <input type="text" id="Name" required>
    </div>

    <div class="row">
      <label>Search Key (Value)</label>
      <input type="text" id="Value">
    </div>

    <div class="row">
      <label>Description</label>
      <textarea id="Description" rows="3"></textarea>
    </div>

    <div class="row">
      <button type="button" id="send-btn" class="btn primary">Save Category</button>
      <button type="button" id="resetBtn" class="btn secondary">Reset</button>
    </div>
  </form>
</div>

<script>

// =============================
// SAVE CATEGORY
// =============================
$('#send-btn').click(function() {

    const data = {
        Name: $("#Name").val(),
        Value: $("#Value").val(),
        Description: $("#Description").val()
    };

    if (!data.Name) {
        alert("Name required!");
        return;
    }

    console.log("Sending Category JSON:", JSON.stringify(data, null, 2));

    $.ajax({
        type: "POST",
        url: "<%= request.getContextPath() %>/ProductCategory",
        data: JSON.stringify(data),
        contentType: "application/json",
        success: function (response) {
            alert("Category Saved Successfully!");
            loadCategories();
        },
        error: function(xhr) {
            alert("Error: " + xhr.responseText);
            console.error(xhr);
        }
    });
});

// =============================
// RESET FORM
// =============================
$("#resetBtn").click(() => {
    $("#catForm")[0].reset();
});

// =============================
// LOAD CATEGORY LIST
// =============================
function loadCategories() {
    $.ajax({
        url: "/api/v1/models/M_Product_Category?$select=Name,Value,Description",
        method: "GET",
        headers: {
            "Authorization": "Bearer <YOUR TOKEN HERE>"
        },
        success: function(res) {
            console.log("Loaded:", res);
            // TODO: render table if you want
        },
        error: function(xhr) {
            console.error(xhr.responseText);
        }
    });
}

// Load on page open
/* loadCategories();
 */
</script>

</body>
</html>
