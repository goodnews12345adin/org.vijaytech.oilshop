<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.vijaytech.textile.Organization"%>
<%@page import="java.util.List"%>
<%@ page import="java.util.Properties" %>
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
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${pageTitle}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f9fafb; font-family: "Inter", "Roboto", sans-serif; min-height: 100vh; }
        .invoice-box { background: #fff; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); padding: 20px; }
        .border-dashed { border: 1px dashed #ccc; padding: 10px; border-radius: 6px; }
        .table th, .table td { vertical-align: middle !important; }
        .total-box { font-size: 1.1rem; font-weight: 500; }
        .table input { min-width: 80px; }
    </style>
</head>

<body class="bg-light py-4">
<%@ include file="header.jsp" %>
<%@ include file="sidebar.jsp" %>

<div class="container mt-4">
    <div class="invoice-box">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-0">${orgName}</h4>
                <div>Date: <strong id="invoice-date"></strong></div>
            </div>
            <div class="text-end">
                <h5 class="mb-0">Sales Invoice</h5>
            </div>
        </div>

        <div class="row mb-3">
            <div class="col-md-6">
                <div class="border-dashed">
                    <strong>Bill To</strong>
                    <input class="form-control mt-2" id="cust-name" placeholder="Customer Name">
                    <input class="form-control mt-2" id="cust-address" placeholder="Address">
                    <input class="form-control mt-2" id="cust-phone" placeholder="Phone / GSTIN">
                </div>

                <div class="mt-3">
                    <strong>Select Product</strong>
                    <select id="manual-product" class="form-select form-select-sm mt-2">
                        <option value="">--Select Product--</option>
                        <%
                            List<Map<String, Object>> productList = (List<Map<String, Object>>) request.getAttribute("productList");
                            if (productList != null && !productList.isEmpty()) {
                                for (Map<String, Object> p : productList) {
                                    String name = (p.get("name") != null) ? p.get("name").toString().trim() : "";
                                    String rate = (p.get("rate") != null) ? p.get("rate").toString().trim() : "0";
                                    String uom = (p.get("uom") != null) ? p.get("uom").toString().trim() : "";
                                    String prodId = (p.get("prodId") != null) ? p.get("prodId").toString().trim() : "0";
                        %>
                        <option 
                            value="<%= name %>|<%= rate %>|<%= uom %>"
                            data-prodid="<%= prodId %>">
                            <%= name %> - ₹<%= rate %> / <%= uom %>
                        </option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
            </div>
        </div>

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

        <div class="text-end mt-3">
            <button id="recalculate" class="btn btn-primary btn-sm">Recalculate</button>
            <button id="send-btn" class="btn btn-success btn-sm">Send</button>
        </div>

        <div class="mt-3 text-end total-box">
            <div>Subtotal: ₹<span id="subtotal">0.00</span></div>
            <div>Total: ₹<strong id="grand-total">0.00</strong></div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
$(document).ready(function() {
    $('#manual-product').select2({
        placeholder: "--Select Product--",
        allowClear: true,
        width: '100%'
    });

    document.getElementById('invoice-date').textContent = new Date().toLocaleDateString();

    const itemsBody = document.getElementById('items-body');

    // 🧮 Recalculate totals
    function recalculate() {
        let subtotal = 0;
        itemsBody.querySelectorAll('tr').forEach((tr, i) => {
            tr.querySelector('td:first-child').textContent = i + 1;
            const qty = parseFloat(tr.querySelector('.qty').value) || 0;
            const rate = parseFloat(tr.querySelector('.rate').value) || 0;
            const amt = qty * rate;
            tr.querySelector('.amount').textContent = amt.toFixed(2);
            subtotal += amt;
        });
        document.getElementById('subtotal').textContent = subtotal.toFixed(2);
        document.getElementById('grand-total').textContent = subtotal.toFixed(2);
    }

    // ➕ Add product row
    function addRow(Id, name, unit, qty, rate) {
        const tr = document.createElement('tr');
        // console.log("Adding Row for Prod ID:", Id);

        const tdIndex = document.createElement('td');
        const tdDesc = document.createElement('td');
        const tdUom = document.createElement('td');
        const tdQty = document.createElement('td');
        const tdRate = document.createElement('td');
        const tdAmount = document.createElement('td');
        const tdAction = document.createElement('td');

        tdAmount.className = 'amount text-end';
        tdAction.className = 'text-center';

        const inputDesc = Object.assign(document.createElement('input'), {
            className: 'form-control form-control-sm desc',
            value: name
        });
        const inputProdId = Object.assign(document.createElement('input'), {
            type: 'hidden',
            className: 'ProdId',
            value: Id
        });
        const inputUom = Object.assign(document.createElement('input'), {
            className: 'form-control form-control-sm uom',
            value: unit
        });
        const inputQty = Object.assign(document.createElement('input'), {
            type: 'number',
            className: 'form-control form-control-sm qty',
            value: qty
        });
        const inputRate = Object.assign(document.createElement('input'), {
            type: 'number',
            className: 'form-control form-control-sm rate',
            value: rate
        });
        const btnRemove = Object.assign(document.createElement('button'), {
            className: 'btn btn-sm btn-danger remove-row',
            textContent: '×'
        });

        tdDesc.appendChild(inputDesc);
        tdDesc.appendChild(inputProdId);
        tdUom.appendChild(inputUom);
        tdQty.appendChild(inputQty);
        tdRate.appendChild(inputRate);
        tdAmount.textContent = (qty * rate).toFixed(2);
        tdAction.appendChild(btnRemove);

        [tdIndex, tdDesc, tdUom, tdQty, tdRate, tdAmount, tdAction].forEach(td => tr.appendChild(td));
        itemsBody.appendChild(tr);

        function updateRowAmount() {
            const q = parseFloat(inputQty.value) || 0;
            const r = parseFloat(inputRate.value) || 0;
            const amt = q * r;
            tdAmount.textContent = amt.toFixed(2);
            recalculate();
        }

        btnRemove.addEventListener('click', () => {
            tr.remove();
            recalculate();
        });

        [inputQty, inputRate].forEach(inp => inp.addEventListener('input', updateRowAmount));
        updateRowAmount();
    }

    // 🧵 On product select
    $('#manual-product').change(function() {
        const val = this.value.trim();
        if (!val) return;

        const [name, rateStr, unit] = val.split('|');
        const rate = parseFloat(rateStr) || 0;
        const selectedOption = this.options[this.selectedIndex];
        const prodId = selectedOption?.dataset?.prodid || "0";

        console.log('Selected:', { prodId, name, rate, unit });

        if (!name) {
            alert('Invalid product data');
            return;
        }

        const rows = Array.from(itemsBody.querySelectorAll('tr'));
        let existingRow = rows.find(row => row.querySelector('.desc')?.value.trim().toLowerCase() === name.toLowerCase());

        if (existingRow) {
            const qtyInput = existingRow.querySelector('.qty');
            qtyInput.value = parseFloat(qtyInput.value || 0) + 1;
            recalculate();
        } else {
            addRow(prodId, name, unit, 1, rate);
        }

        $(this).val('').trigger('change');
    });

    // 🧾 Send data
    $('#send-btn').click(function() {
        const data = {
            customer: {
                name: $("#cust-name").val(),
                address: $("#cust-address").val(),
                phone: $("#cust-phone").val()
            },
            items: $("#items-body tr").map(function() {
                const $row = $(this);
                return {
                    prodId: $row.find(".ProdId").val(),
                    product: $row.find(".desc").val(),
                    unit: $row.find(".uom").val(),
                    qty: parseFloat($row.find(".qty").val()) || 0,
                    rate: parseFloat($row.find(".rate").val()) || 0,
                    amount: parseFloat($row.find(".amount").text()) || 0
                };
            }).get()
        };

        console.log("Sending JSON:", JSON.stringify({ salesData: data }, null, 2));

        $.ajax({
            type: "POST",
            url: "<%= request.getContextPath() %>/SalesServlet",
            data: JSON.stringify({ salesData: data }),
            contentType: "application/json; charset=utf-8",
            success: function(response) {
                alert("Sales saved successfully!");
                console.log(response);
            },
            error: function(xhr, status, error) {
                alert("Error saving sales: " + xhr.responseText);
                console.error(error);
            }
        });
    });

    $('#recalculate').click(recalculate);
});
</script>
</body>
</html>