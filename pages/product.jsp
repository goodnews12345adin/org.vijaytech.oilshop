<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="org.json.JSONObject"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Product Master Pro | Orbit ERP</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap -->
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">

<!-- ✅ Select2 from CDNJS (FIXED MIME ISSUE) -->
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.1.0-rc.0/css/select2.min.css">

<!-- Icons -->
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
:root {
	--erp-primary: #4361ee;
	--erp-bg: #f8f9fd;
}

body {
	background: var(--erp-bg);
	font-family: Inter, sans-serif;
}

.main-content-card {
	background: #fff;
	border-radius: 20px;
	box-shadow: 0 10px 30px rgba(0, 0, 0, .04);
}

.form-progress {
	height: 4px;
	background: #e9ecef;
	margin-bottom: 25px;
}

#progress-inner {
	height: 100%;
	width: 0%;
	background: var(--erp-primary);
	transition: .3s;
}

.btn-erp-primary {
	background: var(--erp-primary);
	color: #fff;
	border: none;
	padding: 12px 30px;
	border-radius: 12px;
	font-weight: 700;
}

.erp-toast {
	position: fixed;
	top: 25px;
	right: 25px;
	display: none;
	z-index: 3000;
}
</style>
</head>

<body>

	<%@ include file="header.jsp"%>
	<%@ include file="sidebar.jsp"%>

	<div id="erp-toast" class="erp-toast alert text-white"></div>

	<div class="container py-5">
		<div class="row justify-content-center">
			<div class="col-xl-10">

				<div class="main-content-card p-4">

					<div class="form-progress">
						<div id="progress-inner"></div>
					</div>

					<form id="productForm">

						<input type="hidden" id="productId" value="0">

						<!-- Essential -->
						<div class="row g-3 mb-4">
							<div class="col-md-4">
								<label class="form-label">Search Key (SKU)</label> <input
									id="Value" class="form-control" required>
							</div>
							<div class="col-md-8">
								<label class="form-label">Product Name</label> <input id="Name"
									class="form-control" required>
							</div>
						</div>

						<!-- Category -->
						<div class="row g-3 mb-4">
							<div class="col-md-4">
								<label class="form-label">Product Category</label> <select
									id="M_Product_Category_ID" class="form-select select2-init"
									required></select>
							</div>
							<div class="col-md-4">
								<label class="form-label">UOM</label> <select id="C_UOM_ID"
									class="form-select select2-init" required></select>
							</div>
							<div class="col-md-4">
								<label class="form-label">Record Type</label> <select
									id="EntryType" class="form-select" required>
									<option value="Both">Buy & Sell</option>
									<option value="Purchase">RPurchase Only</option>
									<option value="Sales">Sales Only</option>
								</select>
							</div>
						</div>

						<!-- Pricing -->
						<div class="row g-3 mb-4">
							<div class="col-md-3">
								<label class="form-label">HSN Code</label> <input id="HSNCode"
									class="form-control">
							</div>
							<div class="col-md-3">
								<label class="form-label">Base Price</label> <input
									id="BillPrice" type="number" class="form-control pricing-calc"
									value="0">
							</div>
							<div class="col-md-2">
								<label class="form-label">Tax %</label> <select id="TaxRate"
									class="form-select pricing-calc">
									<option value="0">0%</option>
									<option value="5" selected>5%</option>
									<option value="12">12%</option>
									<option value="18">18%</option>
								</select>
							</div>
						</div>

						<div class="mb-4">
							<label class="form-label">Description</label>
							<textarea id="Description" class="form-control" rows="3"></textarea>
						</div>

						<div class="d-flex justify-content-between">
							<button type="button" class="btn btn-link text-danger fw-bold"
								onclick="resetForm()">Clear Draft</button>

							<button type="submit" id="saveBtn" class="btn btn-erp-primary">
								<span id="btnText"><i class="bi bi-shield-check me-2"></i>Finalize
									& Save</span> <span id="btnSpinner"
									class="spinner-border spinner-border-sm d-none"></span>
							</button>
						</div>

					</form>
				</div>
			</div>
		</div>
	</div>

	<!-- JS -->
	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

	<!-- ✅ Select2 CDNJS -->
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.1.0-rc.0/js/select2.min.js"></script>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

	<script>
/* ================= SAFE JSON FROM JSP ================= */
const cats = JSON.parse(
  <%=JSONObject
		.quote(request.getAttribute("productList") != null ? request.getAttribute("productList").toString() : "[]")%>
);

const uoms = JSON.parse(
  <%=JSONObject.quote(request.getAttribute("uom") != null ? request.getAttribute("uom").toString() : "[]")%>
);

/* ================= INIT ================= */
$(function(){

// Populate dropdowns
cats.forEach(c =>
  $('#M_Product_Category_ID').append(
    new Option(c.Name, c.M_Product_Category_ID)
  )
);

uoms.forEach(u =>
  $('#C_UOM_ID').append(
    new Option(u.Name, u.C_UOM_ID)
  )
);

// Select2 (safe)
if ($.fn.select2) {
  $('.select2-init').select2({ width:'100%' });
}

// Progress bar
$('input,select,textarea').on('input change', function(){
  let f=0;
  if($('#Value').val())f++;
  if($('#Name').val())f++;
  if($('#M_Product_Category_ID').val())f++;
  if($('#C_UOM_ID').val())f++;
  if($('#BillPrice').val()>0)f++;
  $('#progress-inner').css('width',(f/5*100)+'%');
});

// Submit
$('#productForm').on('submit', function(e){
  e.preventDefault();

  const btn=$('#saveBtn');
  btn.prop('disabled',true);
  $('#btnText').addClass('d-none');
  $('#btnSpinner').removeClass('d-none');

  const payload = {
		    productId: $('#productId').val(),
		    Value: $('#Value').val(),
		    Name: $('#Name').val(),
		    M_Product_Category_ID: $('#M_Product_Category_ID').val(),
		    C_UOM_ID: $('#C_UOM_ID').val(),
		    HSNCode: $('#HSNCode').val(),
		    BillPrice: $('#BillPrice').val(),
		    TaxRate: $('#TaxRate').val(),
		    Description: $('#Description').val(),

		    // ✅ THIS IS REQUIRED
		    EntryType: $('#EntryType').val()
		};

  $.ajax({
    url:'<%=request.getContextPath()%>/Product',
    type:'POST',
    contentType: "application/json; charset=UTF-8",
    dataType: "json",
    data: JSON.stringify(payload),
    success:function(){
      showToast('Product saved successfully','success');
      resetForm();
    },
    error:function(xhr){
      showToast(xhr.responseText,'danger');
    },
    complete:function(){
      btn.prop('disabled',false);
      $('#btnText').removeClass('d-none');
      $('#btnSpinner').addClass('d-none');
    }
  });
});

});

function showToast(msg,type){
  $('#erp-toast')
    .removeClass('bg-success bg-danger')
    .addClass(type==='success'?'bg-success':'bg-danger')
    .text(msg).fadeIn().delay(3000).fadeOut();
}

function resetForm(){
  $('#productForm')[0].reset();
  $('.select2-init').val('').trigger('change');
  $('#progress-inner').css('width','0%');
}
</script>

</body>
</html>
