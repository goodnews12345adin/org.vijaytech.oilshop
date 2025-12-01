<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="org.vijaytech.textile.Organization"%>
<%@page import="java.util.Properties"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
HttpSession session1 = request.getSession(false);
Properties ctx = null;

if (session1 != null) {
    ctx = (Properties) session1.getAttribute("ctx");
}

if (ctx == null) {
    response.sendRedirect("userlogin.jsp?error=session_expired");
    return;
}

String role = (String) session1.getAttribute("userRole");
if (role == null) {
    role = "user";
    session1.setAttribute("userRole", role);
}

List<Organization> orgList = (List<Organization>) session.getAttribute("orgList");
Integer AD_Org_ID = (Integer) session.getAttribute("AD_Org_ID");

// ORG NAME FROM SESSION
String orgName = (String) session.getAttribute("orgName");
if (orgName == null) orgName = "";

// PRODUCT LIST
List<Map<String, Object>> productList =
       (List<Map<String, Object>>) request.getAttribute("productList");
%>

<!doctype html>
<html lang="en">

<head>
<meta charset="UTF-8">
<title><%= orgName %> - Sales Invoice</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

<style>
body { background-color: #f9fafb; font-family: "Inter", "Roboto", sans-serif; }
.invoice-box { background: #fff; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); padding: 20px; }
.border-dashed { border: 1px dashed #ccc; padding: 10px; border-radius: 6px; }
.table th, .table td { vertical-align: middle !important; }
.total-box, .total-box span, .total-box strong { color: #000 !important; }

#loader {
    display:none; position: fixed; top:0; left:0; width:100%; height:100%;
    background: rgba(0,0,0,0.4); z-index:9999;
}
#loader div {
    position: absolute; top:50%; left:50%;
    transform:translate(-50%, -50%);
    padding:20px 30px; background:#fff;
    font-size:18px; border-radius:10px;
}
</style>

</head>

<body class="bg-light py-4">

<%@ include file="sidebar.jsp" %>

<div class="container mt-4">
<div class="invoice-box">

    <!-- HEADER -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="mb-0"><%= orgName %></h4>
            <div>Date: <strong id="invoice-date"></strong></div>
        </div>
        <div class="text-end">
            <h5 class="mb-0">Sales Invoice</h5>
        </div>
    </div>

    <!-- BILL TO -->
    <div class="row mb-3">
        <div class="col-md-6">

            <div class="border-dashed">
                <strong>Bill To</strong>
                <input class="form-control mt-2" id="cust-name" placeholder="Customer Name">
                <input class="form-control mt-2" id="cust-address" placeholder="Address">
                <input class="form-control mt-2" id="cust-phone" placeholder="Phone / GSTIN">
            </div>

            <!-- PRODUCT SELECT -->
            <div class="mt-3">
                <strong>Select Product</strong>
                <select id="manual-product" class="form-select form-select-sm mt-2">
                    <option value="">--Select Product--</option>

                    <%
                    if (productList != null) {
                        for (Map<String,Object> p : productList) {
                            String name  = (p.get("name")  != null) ? p.get("name").toString() : "";
                            String rate  = (p.get("rate")  != null) ? p.get("rate").toString() : "0";
                            String uom   = (p.get("uom")   != null) ? p.get("uom").toString()  : "";
                            String prodId= (p.get("prodId")!= null) ? p.get("prodId").toString(): "0";
                            String search= (p.get("search")!= null) ? p.get("search").toString(): "";
                    %>

                    <option 
                        value="<%= name %>|<%= rate %>|<%= uom %>"
                        data-prodid="<%= prodId %>"
                        data-search="<%= search %>"
                    >
                        <%= search %> - <%= name %> - ₹<%= rate %> / <%= uom %>
                    </option>

                    <% } } %>
                </select>
            </div>

        </div>
    </div>

    <!-- PRODUCT TABLE -->
    <div class="table-responsive">
        <table class="table table-sm table-bordered align-middle" id="items-table">
            <thead class="table-light">
                <tr>
                    <th>#</th>
                    <th>Product</th>
                    <th>Unit</th>
                    <th>Qty</th>
                    <th>Rate (₹)</th>
                    <th>Amount (₹)</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="items-body"></tbody>
        </table>
    </div>

    <!-- BUTTONS -->
    <div class="text-end mt-3">
        <button id="recalculate" class="btn btn-primary btn-sm">Recalculate</button>
        <button id="send-btn" class="btn btn-success btn-sm">Send</button>
    </div>

    <!-- TOTAL SECTION + DISCOUNT -->
    <div class="mt-4 text-end total-box">

        <div>Subtotal: ₹<span id="subtotal">0.00</span></div>

        <div class="mt-2">
            Discount:
            <input type="number" id="discount"
                   class="form-control form-control-sm d-inline-block"
                   style="width:120px; display:inline-block;"
                   value="0">
        </div>

        <div class="mt-2">
            Total: ₹<strong id="grand-total">0.00</strong>
        </div>
    </div>

</div>

<!-- LOADER -->
<div id="loader">
    <div>Please wait... Processing</div>
</div>

</div> <!-- END container -->

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
$(function(){

    document.getElementById("invoice-date").textContent =
        new Date().toLocaleDateString("en-GB");

    $("#manual-product").select2({
        placeholder: "--Select Product--",
        width: "100%",
        allowClear: true,
        matcher: function(params, data) {
            if (!params.term) return data;
            let term  = params.term.toLowerCase();
            let text  = (data.text || "").toLowerCase();
            let sKey  = ($(data.element).data("search") || "").toLowerCase();
            if (text.includes(term) || sKey.includes(term)) return data;
            return null;
        }
    });

    // ======================================================
    // PURE DOM ADD ROW FUNCTION (YOUR VERSION)
    // ======================================================
    function addRow(Id, name, unit, qty, rate) {
        const tr = document.createElement('tr');

        const tdIndex = document.createElement('td');
        const tdDesc  = document.createElement('td');
        const tdUom   = document.createElement('td');
        const tdQty   = document.createElement('td');
        const tdRate  = document.createElement('td');
        const tdAmount= document.createElement('td');
        const tdAction= document.createElement('td');

        tdAmount.className = 'amount text-end';
        tdAction.className = 'text-center';

        const inputDesc = document.createElement('input');
        inputDesc.className = 'form-control form-control-sm desc';
        inputDesc.value = name;

        const inputProdId = document.createElement('input');
        inputProdId.type = 'hidden';
        inputProdId.className = 'ProdId';
        inputProdId.value = Id;

        const inputUom = document.createElement('input');
        inputUom.className = 'form-control form-control-sm uom';
        inputUom.value = unit;

        const inputQty = document.createElement('input');
        inputQty.type = 'number';
        inputQty.className = 'form-control form-control-sm qty';
        inputQty.value = qty;

        const inputRate = document.createElement('input');
        inputRate.type = 'number';
        inputRate.className = 'form-control form-control-sm rate';
        inputRate.value = rate;

        const btnRemove = document.createElement('button');
        btnRemove.className = 'btn btn-sm btn-danger remove-row';
        btnRemove.textContent = '×';

        tdDesc.appendChild(inputDesc);
        tdDesc.appendChild(inputProdId);
        tdUom.appendChild(inputUom);
        tdQty.appendChild(inputQty);
        tdRate.appendChild(inputRate);
        tdAmount.textContent = (qty * rate).toFixed(2);
        tdAction.appendChild(btnRemove);

        tr.appendChild(tdIndex);
        tr.appendChild(tdDesc);
        tr.appendChild(tdUom);
        tr.appendChild(tdQty);
        tr.appendChild(tdRate);
        tr.appendChild(tdAmount);
        tr.appendChild(tdAction);

        document.getElementById("items-body").appendChild(tr);

        tdIndex.textContent = document.querySelectorAll("#items-body tr").length;

        function updateRowAmount() {
            const q = parseFloat(inputQty.value) || 0;
            const r = parseFloat(inputRate.value) || 0;
            tdAmount.textContent = (q * r).toFixed(2);
            recalc();
        }

        btnRemove.addEventListener('click', () => {
            tr.remove();
            recalc();
        });

        inputQty.addEventListener('input', updateRowAmount);
        inputRate.addEventListener('input', updateRowAmount);

        updateRowAmount();
    }

    // ======================================================
    // RECALCULATE TOTALS (WORKS WITH DISCOUNT)
    // ======================================================
    function recalc(){
        let subtotal = 0;

        $("#items-body tr").each(function(i){
            $(this).find("td:first").text(i+1);

            let qty = parseFloat($(this).find(".qty").val()) || 0;
            let rate= parseFloat($(this).find(".rate").val()) || 0;

            let amt = qty * rate;
            $(this).find(".amount").text(amt.toFixed(2));

            subtotal += amt;
        });

        $("#subtotal").text(subtotal.toFixed(2));

        let discount = parseFloat($("#discount").val()) || 0;

        let total = subtotal - discount;
        if (total < 0) total = 0;

        $("#grand-total").text(total.toFixed(2));
    }

    $("#discount").on("input", recalc);
    $("#recalculate").click(recalc);

    // ======================================================
    // PRODUCT SELECT EVENT
    // ======================================================
    $("#manual-product").change(function(){
        let val = this.value;
        if(!val) return;

        let [name, rateStr, unit] = val.split("|");
        let rate = parseFloat(rateStr) || 0;
        let prodId = $(this).find(":selected").data("prodid") || "0";

        let exist = [...document.querySelectorAll("#items-body tr")].find(row =>
            row.querySelector(".desc").value.trim().toLowerCase() === name.toLowerCase()
        );

        if(exist){
            let q = exist.querySelector(".qty");
            q.value = (parseFloat(q.value) || 0) + 1;
            recalc();
        } else {
            addRow(prodId, name, unit, 1, rate);
        }

        $(this).val("").trigger("change");
    });

    // ======================================================
    // SEND TO SERVLET
    // ======================================================
    $("#send-btn").click(function(){

        const data = {
            discount: parseFloat($("#discount").val()) || 0,
            subtotal: $("#subtotal").text(),
            total: $("#grand-total").text(),
            customer:{
                name: $("#cust-name").val(),
                address: $("#cust-address").val(),
                phone: $("#cust-phone").val()
            },
            items: $("#items-body tr").map(function(){
                const $r=$(this);
                return{
                    prodId:$r.find(".ProdId").val(),
                    product:$r.find(".desc").val(),
                    unit:$r.find(".uom").val(),
                    qty:parseFloat($r.find(".qty").val())||0,
                    rate:parseFloat($r.find(".rate").val())||0,
                    amount:parseFloat($r.find(".amount").text())||0
                };
            }).get()
        };

        $.ajax({
            type:"POST",
            url:"<%= request.getContextPath() %>/SalesSaveServlet",
            data:JSON.stringify({salesData:data}),
            contentType:"application/json; charset=utf-8",

            beforeSend:function(){ $("#loader").show(); },

            success:function(response){
                if(response.pdfUrl){
                    window.open(response.pdfUrl, "_blank");
                } else {
                    alert("PDF not generated!");
                }
            },

            error:function(xhr){
                alert("Error: "+xhr.responseText);
            },

            complete:function(){ $("#loader").hide(); }
        });

    });

});
</script>

</body>
</html>