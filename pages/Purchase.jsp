<%@ page import="java.util.*, org.compiere.model.*, org.compiere.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
<title>Purchase Entry</title>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<style>

/* -----------------------------------------------
   SIDEBAR RESPONSIVE FIX
------------------------------------------------*/
body {
    margin-left: 260px;        /* sidebar width for desktop */
    transition: 0.3s ease;
}

/* mobile & tablet → sidebar collapses */
@media (max-width:1024px){
    body { margin-left: 0 !important; }
}

.main-content{
    padding:20px;
}

/* -----------------------------------------------
   TABLE + FORM STYLES
------------------------------------------------*/
body { background-color:#f8f9fa; }
.table th, .table td { vertical-align: middle; }
.select2-container { width: 100% !important; }

/* -----------------------------------------------
   MOBILE RESPONSIVE TABLE (IMPORTANT)
------------------------------------------------*/
@media (max-width: 768px) {

    /* Hide table header */
    #purchase-items thead { display:none !important; }

    /* Convert rows to block */
    #purchase-items tbody tr {
        display: block;
        border:1px solid #ddd;
        margin-bottom:12px;
        padding:12px;
        border-radius:10px;
        background:#fff;
    }

    #purchase-items tbody td {
        display:flex;
        justify-content: space-between;
        padding:8px 0;
        border:none !important;
    }

    /* Add labels before values */
    #purchase-items tbody td::before {
        content: attr(data-label);
        font-weight:600;
        flex:1;
        text-align:left;
    }

    /* Product column too complex → hide */
    #purchase-items tbody td:first-child {
        display:block !important;  
        flex-direction:column;
    }

    #purchase-items tbody td input {
        width:120px;
        text-align:right;
    }
}

</style>
</head>

<body>

<%@ include file="header.jsp" %>
<%@ include file="sidebar.jsp" %>

<div class="main-content">
<h4>Purchase Entry</h4>

<form id="purchase-form" class="card p-3 shadow-sm bg-white">

    <!-- Supplier -->
    <div class="row mb-3">
        <div class="col-md-4">
            <label class="form-label">Supplier</label>
            <select id="supplier" class="form-select form-select-sm">
                <option value="">--Select Supplier--</option>
                <%
                    List<Map<String,Object>> supplierList =
                        (List<Map<String,Object>>) request.getAttribute("supplierList");
                    if(supplierList != null){
                        for(Map<String,Object> s: supplierList){
                %>
                    <option value="<%=s.get("id")%>"><%=s.get("name")%></option>
                <%
                        }
                    }
                %>
            </select>
        </div>
    </div>

    <!-- Items Table -->
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
/* SAME JAVASCRIPT – NO CHANGES */
$(document).ready(function() {

    let products = [];
    let productsLoaded = false;

    $("#supplier").select2({
        placeholder: "--Select Supplier--",
        allowClear: true,
        width:"100%"
    });

    function loadProducts() {
        return $.ajax({
            url: "<%= request.getContextPath() %>/PurchaseServlet?action=getProducts",
            method: "GET",
            dataType: "json"
        })
        .done(function(res){
            products = res;
            productsLoaded = true;
        })
        .fail(function(){
            alert("Could not load products");
        });
    }
    loadProducts();

    $("#add-item").click(function(){
        if(!productsLoaded) return alert("Wait...");
        const $row = $(`
            <tr>
                <td data-label="Product">
                    <select class="form-select form-select-sm prod-id"></select>
                    <input type="hidden" class="prod-name">
                    <input type="hidden" class="uom">
                    <input type="hidden" class="uom-id">
                </td>
                <td data-label="Qty"><input type="number" min="1" class="form-control form-control-sm qty" value="1"></td>
                <td data-label="Rate"><input type="number" step="0.01" class="form-control form-control-sm rate" value="0"></td>
                <td data-label="Amount" class="amount text-end">0.00</td>
                <td data-label="Action"><button type="button" class="btn btn-danger btn-sm remove">X</button></td>
            </tr>
        `);

        const $sel = $row.find(".prod-id");
        $sel.append('<option value="">--Select Product--</option>');
        products.forEach(p => {
            $sel.append(`<option value="${p.id}">${p.name}</option>`);
        });
        $sel.select2({width:"100%"});
        $("#items-body").append($row);
    });

    $(document).on("change", ".prod-id", function(){
        const $row = $(this).closest("tr");
        const id = $(this).val();
        if(!id) return;

        const p = products.find(x => x.id == id);
        $row.find(".prod-name").val(p.name);
        $row.find(".rate").val(p.rate || 0);
        $row.find(".uom").val(p.uom);
        $row.find(".uom-id").val(p.uomId);

        calc($row);
    });

    $(document).on("input", ".qty, .rate", function(){
        calc($(this).closest("tr"));
    });

    function calc($row){
        const q = parseFloat($row.find(".qty").val()) || 0;
        const r = parseFloat($row.find(".rate").val()) || 0;
        $row.find(".amount").text((q * r).toFixed(2));
        total();
    }

    function total(){
        let t = 0;
        $("#items-body tr").each(function(){
            t += parseFloat($(this).find(".amount").text()) || 0;
        });
        $("#grand-total").text(t.toFixed(2));
    }

    $(document).on("click", ".remove", function(){
        $(this).closest("tr").remove();
        total();
    });

});
</script>

</body>
</html>