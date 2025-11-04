<%@page import="java.util.Map"%>
<%@page import="org.syvasoft.tallyfrontcrusher.model.TF_MProduct"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- <%@ taglib uri="http://jakarta.apache.org/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/jsp/jstl/functions" prefix="fn" %> --%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${pageTitle}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: "Inter", "Roboto", sans-serif; min-height: 100vh; }
        .main-content { margin-left: 250px; padding: 80px 25px; transition: all 0.3s ease; }
        .card { border: none; border-radius: 12px; box-shadow: 0 2px 6px rgba(0,0,0,0.08); }
        .border-dashed { border: 1px dashed #ccc; padding: 10px; border-radius: 6px; }
    </style>
</head>

<body class="bg-light py-4">
<%@ include file="header.jsp" %>
<%@ include file="sidebar.jsp" %>

<div class="container mt-5">
    <div class="invoice-box bg-white p-4 rounded shadow-sm">
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
            <input class="form-control mt-2" id="cust-phone" placeholder="Phone | GSTIN">
        </div>

        <div class="mt-3">
            <strong>Select Product</strong>
            <select id="manual-product" class="form-select form-select-sm mt-2">
                <option value="">--Select Product--</option>
                <%
                    List<Map<String, Object>> productList = (List<Map<String, Object>>) request.getAttribute("productList");
                    if (productList != null && !productList.isEmpty()) {
                        for (Map<String, Object> p : productList) {
                            String name = p.get("name").toString();
                            String rate = p.get("rate").toString();
                            String uom = p.get("uom").toString();
                %>
                            <option value="<%= name %>|<%= rate %>|<%= uom %>">
                                <%= name %> - ₹<%= rate %>
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
                        <th>Description</th>
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
            <button id="add-row" class="btn btn-outline-primary btn-sm">+ Add Line</button>
            <button id="recalculate" class="btn btn-primary btn-sm">Recalculate</button>
            <button id="print-btn" class="btn btn-success btn-sm">Print</button>
        </div>

        <div class="mt-3 text-end">
            <div>Subtotal: ₹<span id="subtotal">0.00</span></div>
            <div>Total: ₹<strong id="grand-total">0.00</strong></div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
document.getElementById('invoice-date').textContent = new Date().toLocaleDateString();

const itemsBody = document.getElementById('items-body');

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

function addRow(name = '', rate = 0, unit = 'Meter', qty = 1) {
    const tr = document.createElement('tr');
    tr.innerHTML = `
        <td></td>
        <td><input class='form-control form-control-sm desc' value='${name}'/></td>
        <td><input class='form-control form-control-sm uom' value='${unit}'/></td>
        <td><input type='number' class='form-control form-control-sm qty' value='${qty}'/></td>
        <td><input type='number' class='form-control form-control-sm rate' value='${rate}'/></td>
        <td class='amount text-end'>0.00</td>
        <td class='text-center'><button class='btn btn-sm btn-danger remove-row'>×</button></td>
    `;
    tr.querySelector('.remove-row').addEventListener('click', () => { tr.remove(); recalculate(); });
    tr.querySelectorAll('.qty, .rate').forEach(inp => inp.addEventListener('input', recalculate));
    itemsBody.appendChild(tr);
    recalculate();
}

$('#manual-product').change(function() {
    if (this.value) {
        const [id, name, rate, unit] = this.value.split('|');
        addRow(name, parseFloat(rate), unit);
    }
});

$('#add-row').click(() => addRow());
$('#recalculate').click(recalculate);
$('#print-btn').click(() => window.print());
</script>
</body>
</html>
