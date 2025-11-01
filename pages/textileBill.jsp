<%@page import="org.vijaytech.textile.Organization"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Textile Billing</title>

  <!-- ✅ Bootstrap with correct integrity -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" 
        rel="stylesheet" 
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" 
        crossorigin="anonymous">

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
          integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
          crossorigin="anonymous"></script>

  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://unpkg.com/html5-qrcode@2.3.8"></script>

  <style>
    body { background-color: #f8f9fa; }
    .invoice-box { background: #fff; padding: 24px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,.1); margin-top: 20px; }
    .border-dashed { border: 1px dashed #dee2e6; border-radius: 6px; padding: 12px; }
    @media print { .no-print { display: none !important; } }
  </style>
</head>

<body class="bg-light py-4">
<div class="container">
  <div class="invoice-box">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h4 class="mb-0">Sree Textiles</h4>
        <div>No. 123, Textile Street</div>
        <div>Phone: +91 98765 43210 | GST: 29ABCDE1234F2Z5</div>
      </div>
      <div class="text-end">
        <h5 class="mb-0">Tax Invoice</h5>
        <div>Date: <strong id="invoice-date"></strong></div>
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
          </select>
        </div>
      </div>

      <div class="col-md-6">
        <div class="border-dashed">
          <strong>Barcode Scanner</strong>
          <div id="reader" class="mt-2"></div>
          <div class="mt-2 text-center">
            <button id="start-scan" class="btn btn-sm btn-primary">Start Scan</button>
            <button id="stop-scan" class="btn btn-sm btn-secondary">Stop Scan</button>
          </div>
          <input class="form-control mt-2" id="barcode-result" placeholder="Scanned Barcode" readonly>
        </div>
      </div>
    </div>

    <div class="table-responsive">
      <table class="table table-sm table-bordered align-middle" id="items-table">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Barcode</th>
            <th>Description</th>
            <th>Unit</th>
            <th>Qty</th>
            <th>Rate (₹)</th>
            <th>Amount (₹)</th>
            <th class="no-print">Action</th>
          </tr>
        </thead>
        <tbody id="items-body"></tbody>
      </table>
    </div>

    <div class="text-end no-print">
      <button id="add-row" class="btn btn-outline-primary btn-sm">+ Add Line</button>
      <button id="recalculate" class="btn btn-primary btn-sm">Recalculate</button>
      <button id="print-btn" class="btn btn-success btn-sm">Print</button>
    </div>

    <div class="mt-3 text-end">
      <div>Subtotal: ₹<span id="subtotal">0.00</span></div>
      <div>Total (incl GST): ₹<strong id="grand-total">0.00</strong></div>
    </div>
  </div>
</div>

<script>
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

// ➕ Add a row
function addRow(barcode = '', desc = '', qty = 1, rate = 0, unit = 'Meter') {
  const tr = document.createElement('tr');
  tr.innerHTML = `
    <td></td>
    <td><input class='form-control form-control-sm barcode' value='${barcode}'/></td>
    <td><input class='form-control form-control-sm desc' value='${desc}'/></td>
    <td><select class='form-select form-select-sm'><option>Meter</option><option>Roll</option><option>Kg</option></select></td>
    <td><input type='number' class='form-control form-control-sm qty' value='${qty}'/></td>
    <td><input type='number' class='form-control form-control-sm rate' value='${rate}'/></td>
    <td class='amount text-end'>0.00</td>
    <td class='text-center no-print'><button class='btn btn-sm btn-danger remove-row'>×</button></td>`;
  tr.querySelector('td select').value = unit;
  tr.querySelectorAll('.qty,.rate').forEach(inp => inp.addEventListener('input', recalculate));
  tr.querySelector('.remove-row').addEventListener('click', () => { tr.remove(); recalculate(); });
  itemsBody.appendChild(tr);
  recalculate();
}

$('#add-row').click(() => addRow());
$('#recalculate').click(recalculate);
$('#print-btn').click(() => window.print());

// 🧾 Load products into dropdown
$(document).ready(function() {
  const AD_Org_ID = <%= AD_Org_ID %>;
  const contextPath = '<%= request.getContextPath() %>';
  
  $.ajax({
    url: contextPath + '/LoadBillInfo',
    type: 'GET',
    data: { AD_Org_ID: AD_Org_ID },
    dataType: 'json',
    success: function(data) {
    	console.log("dta : ",data);
    	alert("working");
      if (data.productRates && data.productRates.length > 0) {
        const dropdown = $('#manual-product');
        dropdown.empty().append('<option value="">--Select Product--</option>');

            // Create a string of all options
            let optionsStr = data.productRates.map(function(item) {
                // Optional: debug the item
                console.log("items: ", item);
                
                const val = item.productId + "|" + item.product + "|" + item.rate;
                const text = item.product + " - ₹" + item.rate;
                return '<option value="' + val + '">' + text + '</option>';
            }).join(''); // join all option strings into one

            // Append to dropdown at once
            dropdown.append(optionsStr);
        } else {
            console.log("No productRates found");
        }

        	}

      }
    },
    error: function(xhr, status, error) {
      console.error("AJAX error:", status, error);
    }
  });
});

// 🎯 On manual product select
$('#manual-product').change(function() {
  if (this.value) {
    const [id, rate, name, unit] = this.value.split('|');
    addRow('', name, 1, parseFloat(rate), unit);
  }
});

// 📸 Barcode scanner
let html5QrCode;
$('#start-scan').click(() => {
  if (!html5QrCode) html5QrCode = new Html5Qrcode("reader");
  html5QrCode.start({ facingMode: "environment" }, { fps: 10, qrbox: 250 }, (decodedText) => {
    $('#barcode-result').val(decodedText);
    fetch('<%= request.getContextPath() %>/LoadBillInfo?barcode=' + encodeURIComponent(decodedText))
      .then(res => res.json())
      .then(prod => addRow(decodedText, prod.productName, 1, parseFloat(prod.rate), prod.uom))
      .catch(err => console.error(err));
  });
});

$('#stop-scan').click(() => { if (html5QrCode) html5QrCode.stop(); });
</script>
</body>
</html>