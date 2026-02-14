<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Properties" %>
<%@ page language="java"
contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8" %>

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

String orgName = (String) session1.getAttribute("orgName");
if (orgName == null) {
orgName = "";
}

List<Map<String, Object>> productList =
(List<Map<String, Object>>) request.getAttribute("productList");
%>

<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>Sales Entry | Vijay Tech Orbit</title>
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />

<!-- Bootstrap CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>

<!-- Fonts & Icons -->
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Select2 (Dropdowns) -->
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<!-- QZ Tray (Silent Printing) & Crypto -->
<script src="https://cdn.jsdelivr.net/npm/qz-tray@2.2.4/qz-tray.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jsrsasign/10.8.6/jsrsasign-all-min.js"></script>

<style>
/* === ROOT VARIABLES === */
:root {
--accent: #15a0c6;
--accent-dark: #0e7d9b;
--accent-glow: rgba(21, 160, 198, 0.4);
--bg-slate: #f8fafc;
--header-bg: rgba(10, 18, 32, 0.95);
--glass-border: rgba(255, 255, 255, 0.1);
--card-radius: 24px;
--transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
--danger: #ef4444;
--success: #10b981;
}

/* === GLOBAL RESETS === */
body {
font-family: 'Plus Jakarta Sans', sans-serif;
background-color: var(--bg-slate);
color: #1e293b;
margin: 0;
padding-top: 90px;
min-height: 100vh;
background-image:
radial-gradient(at 0% 0%, rgba(21, 160, 198, 0.05) 0px, transparent 50%),
radial-gradient(at 100% 100%, rgba(10, 18, 32, 0.02) 0px, transparent 50%);
}

/* === HEADER === */
.app-header {
position: fixed;
top: 0; right: 0; left: 0;
height: 75px;
background: var(--header-bg);
backdrop-filter: blur(16px);
-webkit-backdrop-filter: blur(16px);
display: flex;
align-items: center;
justify-content: space-between;
padding: 0 40px;
z-index: 1040;
border-bottom:1px solid var(--glass-border);
box-shadow: 0 10px 40px rgba(0,0,0,0.1);
}

.header-title {
font-weight: 800;
font-size: 1.35rem;
color: #fff;
letter-spacing: -0.5px;
display: flex;
align-items: center;
text-shadow: 0 4px 12px rgba(0,0,0,0.3);
}

.header-action {
background: rgba(255, 255, 255, 0.08);
padding: 8px 20px;
border-radius: 50px;
border: 1px solid rgba(255,255,255,0.1);
display: flex;
align-items: center;
transition: var(--transition);
box-shadow: 0 4px 15px rgba(0,0,0,0.2);
}
.header-action:hover { background: rgba(255,255,255,0.15); transform: translateY(-2px); }

/* === MAIN LAYOUT === */
.page-wrap {
padding: 30px 40px 100px 40px;
max-width: 1500px;
margin: 0 auto;
width: 100%;
}

.invoice-box {
background: #ffffff;
border-radius: var(--card-radius);
padding: 45px;
box-shadow: 0 20px 60px -10px rgba(0,0,0,0.08);
border: 1px solid #edf2f7;
position: relative;
overflow: hidden;
}

.invoice-box::before {
content: '';
position: absolute;
top: 0; left: 0; right: 0;
height: 8px;
background: linear-gradient(90deg, var(--accent), #3b82f6);
box-shadow: 0 4px 20px var(--accent-glow);
}

.invoice-head {
display: flex;
justify-content: space-between;
align-items: flex-start;
margin-bottom: 40px;
padding-bottom: 25px;
border-bottom: 2px solid #f1f5f9;
}

.org-title {
font-size: 28px;
font-weight: 800;
color: #0f172a;
letter-spacing: -1px;
}

/* === INPUT STYLING === */
.border-dashed {
border: 2px dashed #cbd5e1;
border-radius: 20px;
padding: 30px;
background: #fafbfc;
transition: var(--transition);
height: 100%;
position: relative;
z-index: 1;
}

.border-dashed:hover {
border-color: var(--accent);
background: #fff;
box-shadow: 0 10px 30px rgba(21, 160, 198, 0.08);
}

.form-control, .form-select {
height: 50px;
border-radius: 12px;
border: 1px solid #e2e8f0;
padding: 10px 18px;
font-size: 15px;
font-weight: 500;
transition: var(--transition);
box-shadow: 0 2px 4px rgba(0,0,0,0.02);
background-color: #fff;
}

.form-control:focus, .form-select:focus {
border-color: var(--accent);
box-shadow: 0 0 0 4px rgba(21, 160, 198, 0.1);
background-color: #fff;
transform: translateY(-1px);
}

.form-control-sm {
height: 42px;
border-radius: 10px;
font-size: 14px;
}

.select2-container--default .select2-selection--single {
height: 50px !important;
border-radius: 12px !important;
border-color: #e2e8f0 !important;
background: #fff !important;
display: flex;
align-items: center;
box-shadow: 0 2px 4px rgba(0,0,0,0.02);
}
.select2-container--default .select2-selection--single .select2-selection__arrow {
top: 12px !important;
}
.select2-dropdown {
border: 1px solid #e2e8f0 !important;
border-radius: 12px !important;
box-shadow: 0 10px 30px rgba(0,0,0,0.1) !important;
}

/* === TABLE STYLING === */
.table-responsive {
border-radius: 20px;
border: 1px solid #f1f5f9;
margin-top: 30px;
overflow-x: auto;
box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05);
}

.table { margin-bottom: 0; background: #fff; }

.table th {
background: #f8fafc;
text-transform: uppercase;
font-size: 11px;
font-weight: 800;
color: #64748b;
padding: 20px 15px;
border: none;
white-space: nowrap;
letter-spacing: 0.5px;
}

.table tbody td {
padding: 18px 15px;
border-bottom: 1px solid #f1f5f9;
vertical-align: middle;
font-size: 15px;
color: #334155;
}

.table tbody tr:hover { background-color: #f8fafc; }

.remove-row {
width: 34px; height: 34px;
padding: 0;
display: inline-flex;
align-items: center;
justify-content: center;
border-radius: 50%;
transition: all 0.2s;
border: 1px solid #fee2e2;
color: var(--danger);
}
.remove-row:hover {
background: var(--danger);
color: #fff;
box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

/* === GST INFO COLUMN === */
.gst-info {
font-size: 11px;
color: #64748b;
margin-top: 4px;
}
.gst-info span {
display: block;
line-height: 1.3;
}

/* === TOTALS SECTION === */
.total-box {
display: flex;
flex-wrap: wrap;
align-items: flex-end;
gap: 25px;
background: #0b132b;
padding: 30px;
border-radius: 20px;
margin-top: 30px;
box-shadow: inset 0 2px 10px rgba(255,255,255,0.05);
background-image: linear-gradient(135deg, #0f172a, #1e293b);
}

.total-item-group {
display: flex;
flex-direction: column;
min-width: 160px;
flex-grow: 1;
}

.total-item-group label {
font-size: 12px;
color: #94a3b8;
margin-bottom: 8px;
font-weight: 600;
text-transform: uppercase;
letter-spacing: 0.5px;
}

.total-item-group input {
height: 45px;
background: rgba(15, 23, 42, 0.5) !important;
border: 1px solid rgba(255,255,255,0.2);
color: #fff !important;
text-align: right;
border-radius: 10px;
font-size: 16px;
font-weight: 600;
transition: var(--transition);
}
.total-item-group input:focus {
background: rgba(255,255,255,0.15);
border-color: var(--accent);
outline: none;
}

.total-spacer { flex-grow: 1; }

#grand-total {
font-size: 38px;
font-weight: 800;
color: #1ec8ff;
line-height: 1;
text-shadow: 0 0 20px rgba(30, 200, 255, 0.4);
}

#Bal-amt {
font-size: 30px;
font-weight: 700;
color: #ff4757;
}

/* === GST SUMMARY BOX === */
.gst-summary-box {
background: linear-gradient(135deg, #1e3a5f, #0f2847);
border-radius: 16px;
padding: 20px 25px;
margin-top: 20px;
border: 1px solid rgba(255,255,255,0.1);
}

.gst-summary-box h6 {
color: #94a3b8;
font-size: 12px;
text-transform: uppercase;
letter-spacing: 1px;
margin-bottom: 15px;
font-weight: 700;
}

.gst-row {
display: flex;
justify-content: space-between;
padding: 8px 0;
border-bottom: 1px solid rgba(255,255,255,0.05);
}

.gst-row:last-child {
border-bottom: none;
}

.gst-label {
color: #cbd5e1;
font-size: 13px;
}

.gst-value {
color: #fff;
font-weight: 600;
font-size: 13px;
}

/* === BUTTONS === */
.btn {
padding: 12px 28px;
border-radius: 12px;
font-weight: 600;
letter-spacing: 0.3px;
transition: var(--transition);
text-transform: none;
}

.btn-success {
background: var(--accent);
border: none;
box-shadow: 0 10px 20px -5px rgba(21, 160, 198, 0.5);
}
.btn-success:hover {
background: var(--accent-dark);
transform: translateY(-3px);
box-shadow: 0 15px 30px -5px rgba(21, 160, 198, 0.6);
}

/* === LOADER OVERLAY === */
#loader {
background: rgba(255, 255, 255, 0.85);
backdrop-filter: blur(12px);
-webkit-backdrop-filter: blur(12px);
display: none;
align-items: center;
justify-content: center;
position: fixed;
inset: 0;
z-index: 9999;
opacity: 0;
transition: opacity 0.3s ease;
}
#loader.active { opacity: 1; }

#loader .box {
background: #ffffff;
color: #0f172a;
padding: 40px 60px;
border-radius: 24px;
font-weight: 700;
box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
display: flex;
align-items: center;
gap: 20px;
border: 1px solid #e2e8f0;
transform: scale(0.9);
transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
#loader.active .box { transform: scale(1); }

/* === THERMAL RECEIPT - PERFECT ALIGNMENT FOR 80MM === */
#thermal-print-area {
display: none;
width: 72mm;
max-width: 72mm;
background-color: #ffffff;
color: #000000;
font-family: 'Courier New', Courier, monospace;
font-size: 10px;
padding: 0;
line-height: 1.2;
text-align: left;
box-sizing: border-box;
}

.thermal-content {
padding: 2mm;
box-sizing: border-box;
}

.receipt-header {
text-align: center;
margin-bottom: 8px;
padding-bottom: 6px;
border-bottom: 1px dashed #000;
}

.receipt-header h2 {
margin: 0 0 2px 0;
font-size: 14px;
font-weight: bold;
letter-spacing: 0.5px;
}

.receipt-header .sub-header {
margin: 2px 0;
font-size: 10px;
}

.receipt-header .inv-details {
margin: 4px 0 0 0;
font-size: 9px;
}

.receipt-header .inv-details div {
margin: 1px 0;
}

/* Receipt Table - Perfect Column Alignment */
.receipt-table {
width: 100%;
border-collapse: collapse;
margin: 6px 0;
font-size: 9px;
}

.receipt-table thead {
border-top: 1px dashed #000;
border-bottom: 1px dashed #000;
}

.receipt-table th {
padding: 4px 2px;
text-align: left;
font-weight: bold;
font-size: 9px;
}

.receipt-table th.col-sno { width: 8%; text-align: center; }
.receipt-table th.col-item { width: 42%; }
.receipt-table th.col-qty { width: 12%; text-align: right; }
.receipt-table th.col-rate { width: 18%; text-align: right; }
.receipt-table th.col-amt { width: 20%; text-align: right; }

.receipt-table td {
padding: 3px 2px;
vertical-align: top;
}

.receipt-table td.col-sno { text-align: center; }
.receipt-table td.col-item { word-wrap: break-word; }
.receipt-table td.col-qty { text-align: right; }
.receipt-table td.col-rate { text-align: right; }
.receipt-table td.col-amt { text-align: right; font-weight: bold; }

/* Item Name - Truncate if too long */
.item-name {
max-width: 28mm;
overflow: hidden;
text-overflow: ellipsis;
white-space: nowrap;
display: inline-block;
}

/* GST Breakdown in Items */
.item-gst {
font-size: 7px;
color: #555;
display: block;
margin-top: 1px;
}

/* Totals Section */
.receipt-totals {
margin-top: 6px;
border-top: 1px dashed #000;
padding-top: 6px;
}

.receipt-row {
display: flex;
justify-content: space-between;
padding: 2px 0;
font-size: 10px;
}

.receipt-row.total-row {
font-weight: bold;
font-size: 12px;
border-top: 1px dashed #000;
border-bottom: 1px dashed #000;
padding: 4px 0;
margin-top: 2px;
margin-bottom: 2px;
}

.receipt-row.gst-row {
font-size: 9px;
color: #333;
}

/* Payment Section */
.receipt-payments {
margin-top: 6px;
border-top: 1px dashed #000;
padding-top: 6px;
}

.receipt-footer {
text-align: center;
margin-top: 8px;
padding-top: 6px;
border-top: 1px dashed #000;
font-size: 9px;
}

.receipt-footer p {
margin: 2px 0;
}

.receipt-divider {
border-top: 1px dashed #000;
margin: 4px 0;
}

/* === WONDERFUL BOX (Custom Modal) === */
#wonderful-alert-box { z-index: 100000; }

.modal-content.wonderful-box {
border: none;
border-radius: 24px;
box-shadow: 0 20px 60px rgba(0,0,0,0.15);
background: #fff;
overflow: hidden;
animation: slideUpFade 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

@keyframes slideUpFade {
from { opacity: 0; transform: translate(0, 50px) scale(0.95); }
to { opacity: 1; transform: translate(0, 0) scale(1); }
}

.wonderful-icon-area {
height: 80px;
display: flex;
align-items: center;
justify-content: center;
margin-bottom: 10px;
}

.wonderful-icon-area i { font-size: 3.5rem; display: block; }

.wb-icon-success { color: var(--success); text-shadow: 0 4px 15px rgba(16, 185, 129, 0.3); }
.wb-icon-error { color: var(--danger); text-shadow: 0 4px 15px rgba(239, 68, 68, 0.3); }
.wb-icon-warning { color: #f59e0b; text-shadow: 0 4px 15px rgba(245, 158, 11, 0.3); }
.wb-icon-confirm { color: var(--accent); text-shadow: 0 4px 15px rgba(21, 160, 198, 0.3); }

.wonderful-title {
font-size: 1.5rem;
font-weight: 800;
color: #1e293b;
margin-bottom: 0.5rem;
}

.wonderful-msg {
color: #64748b;
font-size: 1rem;
margin-bottom: 2rem;
line-height: 1.5;
}

.wonderful-btn {
padding: 12px 30px;
border-radius: 50px;
font-weight: 700;
font-size: 0.95rem;
letter-spacing: 0.5px;
transition: all 0.2s;
border: none;
min-width: 120px;
}

.wb-btn-confirm {
background: var(--accent);
color: white;
box-shadow: 0 4px 15px rgba(21, 160, 198, 0.3);
}
.wb-btn-confirm:hover { background: var(--accent-dark); transform: translateY(-2px); }

.wb-btn-cancel {
background: #f1f5f9;
color: #64748b;
}
.wb-btn-cancel:hover { background: #e2e8f0; color: #334155; }

.modal-backdrop.show {
opacity: 0.6;
background: #0f172a;
backdrop-filter: blur(5px);
}

/* === TOAST === */
.toast-container { z-index: 99999; }
.custom-toast {
background: rgba(255,255,255,0.9);
backdrop-filter: blur(12px);
-webkit-backdrop-filter: blur(12px);
border: none;
border-radius: 16px;
box-shadow: 0 15px 40px rgba(0,0,0,0.15);
overflow: hidden;
min-width: 350px;
transform: translateX(120%);
transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}
.custom-toast.show { transform: translateX(0); }

.custom-toast .toast-body {
font-weight: 600;
font-size: 0.95rem;
}

@media (max-width: 575.98px) {
.app-header { padding: 0 20px; height: 65px; }
.header-title { font-size: 1.1rem; }
.header-action span { display: none; }
.page-wrap { padding: 20px 10px 90px 10px; }
.invoice-box { padding: 20px; border-radius: 16px; }
.invoice-head { flex-direction: column; gap: 15px; }
.border-dashed { padding: 20px; }
.table-responsive { margin-top: 15px; border-radius: 12px; }
.table th, .table td { padding: 10px 8px; font-size: 13px; }
.total-box { flex-direction: column; padding: 20px; gap: 15px; }
.total-item-group { width: 100%; }
.total-spacer { display: none; }
.btn { width: 100%; margin-bottom: 10px; justify-content: center; }
.d-flex.justify-content-end { flex-direction: column; }
#grand-total { font-size: 32px; }
#Bal-amt { font-size: 26px; }
}
</style>
</head>
<body>

<!-- HEADER -->
<header class="app-header">
<div class="header-left">
<div class="header-title">
<i class="bi bi-cart-check-fill me-3 text-info fs-3"></i>
<span>Sales Entry</span>
</div>
</div>

<div class="header-right">
<div class="header-action">
<i class="bi bi-building-fill text-info me-2 fs-5"></i>
<span class="text-white small fw-bold text-uppercase tracking-wider"><%= orgName %></span>
</div>
</div>
</header>

<%@ include file="sidebar.jsp" %>

<div class="page-wrap" id="pageWrap">
<main class="container-main">
<div class="invoice-box">

<!-- Invoice Header -->
<div class="invoice-head">
<div>
<div class="org-title"><%= orgName %></div>
<div class="badge rounded-pill bg-info bg-opacity-10 text-info mt-3 px-4 py-2 border border-info border-opacity-25 fw-bold">
<i class="bi bi-receipt-cutoff me-1"></i> NEW INVOICE
</div>
</div>
<div class="text-end">
<div class="text-muted small fw-bold text-uppercase tracking-wide mb-1">Date</div>
<div class="fw-bold fs-4 text-dark" id="invoice-date"></div>
</div>
</div>

<div class="row g-4 mb-4">
<!-- Bill To Section -->
<div class="col-12 col-lg-5">
<div class="border-dashed">
<div class="d-flex align-items-center mb-4">
<div class="bg-primary bg-opacity-10 p-3 rounded-3 me-3 shadow-sm">
<i class="bi bi-person-lines-fill text-primary fs-4"></i>
</div>
<span class="fw-bold fs-5 text-dark">Bill To</span>
</div>
<div class="form-floating mb-3">
<input type="text" class="form-control" id="cust-name" placeholder="Name">
<label for="cust-name" class="text-muted">Customer Name</label>
</div>
<div class="form-floating mb-3">
<input type="text" class="form-control" id="cust-address" placeholder="Address">
<label for="cust-address" class="text-muted">Address</label>
</div>
<div class="form-floating">
<input type="text" class="form-control" id="cust-phone" placeholder="Phone">
<label for="cust-phone" class="text-muted">Phone Number (Optional)</label>
</div>
</div>
</div>

<!-- Add Products Section -->
<div class="col-12 col-lg-7">
<div class="p-4 bg-light rounded-4 border border-light-subtle h-100">
<label class="form-label fw-bold d-flex justify-content-between mb-3">
<span class="text-dark"><i class="bi bi-box-seam me-2"></i>Add Products</span>
<span class="text-primary small cursor-pointer text-decoration-underline"><i class="bi bi-search me-1"></i>Search (Press Enter)</span>
</label>

<div class="mb-4">
<select id="manual-product" class="form-select" style="width:100%">
<option value="">-- Search & Select Product --</option>
<%
if (productList != null) {
for (Map<String, Object> p : productList) {
String name = p.get("name") != null ? p.get("name").toString() : "";
String rate = p.get("rate") != null ? p.get("rate").toString() : "0";
String uom = p.get("uom") != null ? p.get("uom").toString() : "";
String prodId = p.get("prodId") != null ? p.get("prodId").toString() : "0";
String search = p.get("value") != null ? p.get("value").toString() : "";
String gstRate = p.get("gstRate") != null ? p.get("gstRate").toString() : "5";
%>
<option value="<%= name %>|<%= rate %>|<%= uom %>"
data-prodid="<%= prodId %>"
data-search="<%= search %>"
data-gstrate="<%= gstRate %>">
<%= name %> (Rs.<%= rate %>/<%= uom %>) [Code: <%= search %>] - <%= gstRate %>% GST
</option>
<%
}
}
%>
</select>
</div>

<div class="d-flex align-items-center gap-3 text-muted small bg-white p-3 rounded border border-secondary-subtle shadow-sm">
<i class="bi bi-lightbulb-fill text-warning fs-5"></i>
<span>Tip: Type product name and press <strong class="text-dark">ENTER</strong> to add quickly. Prices are inclusive of GST.</span>
</div>
</div>
</div>
</div>

<!-- Item Table -->
<div class="table-responsive">
<table class="table table-hover align-middle" id="items-table">
<thead>
<tr>
<th class="text-center" width="5%">#</th>
<th width="35%">Description</th>
<th class="text-center" width="8%">Unit</th>
<th class="text-center" width="10%">Qty</th>
<th class="text-end" width="12%">Rate (Rs.)</th>
<th class="text-end" width="12%">Amount (Rs.)</th>
<th class="text-end" width="13%">GST Info</th>
<th class="text-center" width="5%"></th>
</tr>
</thead>
<tbody id="items-body">
</tbody>
</table>
<div id="empty-state" class="text-center py-5 text-muted">
<i class="bi bi-basket3 fs-1 d-block mb-2 opacity-10"></i>
No items added yet
</div>
</div>

<!-- GST Summary Box -->
<div class="gst-summary-box" id="gst-summary-box">
<h6><i class="bi bi-calculator me-2"></i>GST Summary (Inclusive Pricing)</h6>
<div class="gst-row">
<span class="gst-label">Taxable Amount</span>
<span class="gst-value">Rs.<span id="gst-taxable">0.00</span></span>
</div>
<div class="gst-row">
<span class="gst-label">CGST (<span id="cgst-rate-label">2.50</span>%)</span>
<span class="gst-value">Rs.<span id="gst-cgst">0.00</span></span>
</div>
<div class="gst-row">
<span class="gst-label">SGST (<span id="sgst-rate-label">2.50</span>%)</span>
<span class="gst-value">Rs.<span id="gst-sgst">0.00</span></span>
</div>
<div class="gst-row" style="border-top: 1px solid rgba(255,255,255,0.2); padding-top: 10px; margin-top: 5px;">
<span class="gst-label" style="font-weight: bold;">Total GST (<span id="total-gst-rate-label">5.00</span>%)</span>
<span class="gst-value" style="font-weight: bold; color: #1ec8ff;">Rs.<span id="gst-total">0.00</span></span>
</div>
</div>

<div class="total-box">

<div class="total-item-group">
<label class="d-flex justify-content-between">
Discount
<div class="form-check form-switch">
<input class="form-check-input" type="checkbox" id="disc-type-toggle" style="width:36px; height:20px;">
<label class="form-check-label text-white small" for="disc-type-toggle" id="disc-type-label">Rs.</label>
</div>
</label>
<div class="input-group">
<input type="number" id="discount" class="form-control form-control-sm" value="" min="0" step="0.01" placeholder="0.00">
<button class="btn btn-outline-light btn-sm" type="button" id="round-off-btn" title="Round Off Total">
<i class="bi bi-calculator"></i>
</button>
</div>
</div>

<div class="total-item-group">
<label>Cash Paid</label>
<input type="number" id="cash" class="form-control form-control-sm" value="" min="0" step="0.01" placeholder="0.00">
</div>

<div class="total-item-group">
<label>UPI / Bank</label>
<input type="number" id="upi" class="form-control form-control-sm" value="" min="0" step="0.01" placeholder="0.00">
</div>

<div class="total-item-group text-end w-auto">
<label class="text-danger">Balance Due</label>
<span id="Bal-amt"></span>
</div>

<div class="total-spacer"></div>

<div class="total-item-group text-end w-auto">
<label class="text-white" style="font-size:14px">Subtotal</label>
<span class="fw-bold text-white">Rs.<span id="subtotal"></span></span>
</div>

<div class="total-item-group text-end w-auto">
<label class="total-big-label text-info">Grand Total</label>
<span id="grand-total"></span>
</div>

</div>
<input type="hidden" id="cancelId" value="0"></input>
<div class="d-flex justify-content-end gap-3 mt-4 flex-wrap align-items-center">
<div class="me-auto">
<button id="hold-btn" class="btn btn-warning text-dark border border-dark-subtle shadow-sm">
<i class="bi bi-pause-circle me-1"></i>Hold Order
</button>
<button id="resume-btn" class="btn btn-info text-white border border-dark-subtle shadow-sm d-none">
<i class="bi bi-play-circle me-1"></i>Resume Order
</button>
</div>

<button id="cancel" class="btn btn-danger border d-none">
<i class="bi bi-arrow-counterclockwise me-2"></i>Cancel Last
</button>
<button id="recalculate" class="btn btn-light border shadow-sm">
<i class="bi bi-arrow-clockwise me-2"></i>Recalc
</button>
<button id="save-btn" class="btn btn-success px-5 shadow">
<i class="bi bi-save me-2"></i>Save
</button>

<button id="save-print-btn" class="btn btn-primary px-5 shadow">
<i class="bi bi-printer-fill me-2"></i>Save & Print
</button>

</div>
</div>
</main>
</div>

<!-- HIDDEN PRINT AREA FOR THERMAL PRINTER - PERFECT ALIGNMENT -->
<div id="thermal-print-area">
<div class="thermal-content">
<div class="receipt-header">
<h2><%= orgName %></h2>
<p class="sub-header">TAX INVOICE</p>
<div class="inv-details">
<div>Bill No: <span id="print-inv-no" style="font-weight:bold"></span></div>
<div id="print-date"></div>
<div>Customer: <span id="print-cust">Walk-in</span></div>
</div>
</div>

<!-- Items Table - Perfect Column Alignment -->
<table class="receipt-table">
<thead>
<tr>
<th class="col-sno">#</th>
<th class="col-item">Item</th>
<th class="col-qty">Qty</th>
<th class="col-rate">Rate</th>
<th class="col-amt">Amount</th>
</tr>
</thead>
<tbody id="print-items">
</tbody>
</table>

<!-- GST Summary -->
<div class="receipt-totals" id="print-gst-section">
<div class="receipt-row gst-row">
<span>Taxable Amt:</span>
<span id="print-taxable">0.00</span>
</div>
<div class="receipt-row gst-row">
<span>CGST (<span id="print-cgst-rate">2.50</span>%):</span>
<span id="print-cgst">0.00</span>
</div>
<div class="receipt-row gst-row">
<span>SGST (<span id="print-sgst-rate">2.50</span>%):</span>
<span id="print-sgst">0.00</span>
</div>
</div>

<!-- Totals -->
<div class="receipt-totals">
<div class="receipt-row">
<span>Subtotal:</span>
<span id="print-subtotal">0.00</span>
</div>
<div class="receipt-row">
<span>Discount:</span>
<span id="print-discount">0.00</span>
</div>
<div class="receipt-row total-row">
<span>TOTAL:</span>
<span id="print-total">0.00</span>
</div>
</div>

<!-- Payments -->
<div class="receipt-payments">
<div class="receipt-row">
<span>Cash:</span>
<span id="print-cash">0.00</span>
</div>
<div class="receipt-row">
<span>UPI:</span>
<span id="print-upi">0.00</span>
</div>
<div class="receipt-row" style="font-weight:bold; border-top: 1px dashed #000; padding-top: 4px; margin-top: 4px;">
<span>BALANCE:</span>
<span id="print-balance">0.00</span>
</div>
</div>

<!-- Footer -->
<div class="receipt-footer">
<p>Thank you for your business!</p>
<p>*** GST Inclusive Pricing ***</p>
<p>Software by Vijay Tech Orbit</p>
</div>
</div>
</div>

<!-- LOADER -->
<div id="loader">
<div class="box">
<div class="spinner-border text-info" role="status" style="width: 1.5rem; height: 1.5rem;"></div>
<span id="loader-text">Processing Sales Entry...</span>
</div>
</div>

<!-- === WONDERFUL ALERT BOX (REPLACES TOAST AND CONFIRM) === -->
<div class="modal fade" id="wonderful-alert-box" tabindex="-1" aria-labelledby="wonderfulAlertLabel" aria-hidden="true" data-bs-backdrop="static">
<div class="modal-dialog modal-dialog-centered modal-sm">
<div class="modal-content wonderful-box text-center">
<div class="modal-body p-4">

<!-- Icon Area -->
<div class="wonderful-icon-area" id="wb-icon-area">
<!-- Icon injected by JS -->
</div>

<!-- Title -->
<h5 class="wonderful-title" id="wb-title">Title</h5>

<!-- Message -->
<p class="wonderful-msg" id="wb-message">Message goes here...</p>

<!-- Actions (Buttons) -->
<div class="d-flex justify-content-center gap-2" id="wb-actions">
<!-- Buttons injected by JS -->
</div>

</div>
</div>
</div>
</div>

<!-- ORIGINAL TOAST (Kept in DOM but logic replaced per request) -->
<div class="toast-container position-fixed bottom-0 end-0 p-4">
<div id="liveToast" class="toast custom-toast align-items-center" role="alert" aria-live="assertive" aria-atomic="true">
<div class="d-flex">
<div class="toast-body d-flex align-items-center gap-3">
<i id="toast-icon" class="bi fs-3"></i>
<span id="toast-message" class="fw-semibold">Message here</span>
</div>
<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
</div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
 $(function () {
 $("#cancelId").val("0");

// Initialize Wonderful Box Modal
const wonderfulModal = new bootstrap.Modal(document.getElementById('wonderful-alert-box'));

/**
* SHOW WONDERFUL BOX
*/
function showWonderfulBox(type, title, message, onConfirm, onCancel) {
const $iconArea = $('#wb-icon-area');
const $title = $('#wb-title');
const $msg = $('#wb-message');
const $actions = $('#wb-actions');

 $actions.empty();
 $title.text(title);
 $msg.html(message);

let iconClass = '';
let iconTag = '';

if (type === 'success') {
iconClass = 'wb-icon-success';
iconTag = '<i class="bi bi-check-circle-fill"></i>';
} else if (type === 'error') {
iconClass = 'wb-icon-error';
iconTag = '<i class="bi bi-x-circle-fill"></i>';
} else if (type === 'warning') {
iconClass = 'wb-icon-warning';
iconTag = '<i class="bi bi-exclamation-triangle-fill"></i>';
} else if (type === 'confirm') {
iconClass = 'wb-icon-confirm';
iconTag = '<i class="bi bi-question-circle-fill"></i>';
} else {
iconClass = 'wb-icon-confirm';
iconTag = '<i class="bi bi-info-circle-fill"></i>';
}

 $iconArea.removeClass().addClass('wonderful-icon-area ' + iconClass).html(iconTag);

if (type === 'confirm') {
const btnYes = $('<button class="btn wonderful-btn wb-btn-confirm">Yes, Proceed</button>');
const btnNo = $('<button class="btn wonderful-btn wb-btn-cancel">Cancel</button>');

btnYes.on('click', function() {
wonderfulModal.hide();
if (typeof onConfirm === 'function') onConfirm();
});

btnNo.on('click', function() {
wonderfulModal.hide();
if (typeof onCancel === 'function') onCancel();
});

 $actions.append(btnYes, btnNo);
} else {
const btnOk = $('<button class="btn wonderful-btn wb-btn-confirm">OK</button>');

btnOk.on('click', function() {
wonderfulModal.hide();
if (typeof onConfirm === 'function') onConfirm();
});

 $actions.append(btnOk);
}

wonderfulModal.show();
}

/* ===========================
QZ TRAY SETUP
=========================== */
qz.security.setCertificatePromise(function(resolve, reject) {
resolve("-----BEGIN CERTIFICATE-----\nMIIDXTCCAkWgAwIBAgIJAKg0HhUxzBrdMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV\nBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX\naWRnaXRzIFB0eSBMdGQwHhcNMTcwOTA0MDQzOTI5WhcNMTgwOTA0MDQzOTI5WjBF\nMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50\nZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB\nCgKCAQEAuPwsKsV0g2EgLQLUjdInXx3gXVwJnCiC4K1/H6VNF2nzQ3VLDmKQAu7Jf\nwGpQ6KZZF+j2N7sUHnJyCkg+0R3bA3JX5V8kxvK7dOq4DlBjkURUqS3LY3U6K3jXJ\n5f0L6H8f8nKbJZJNYJVjmZJ8p2Wj8bZ6K5W1WfWZ9Wv7Jq0pY0UqY6F8R3bA3JX5V\n8kxvK7dOq4DlBjkURUqS3LY3U6K3jXJ5f0L6H8f8nKbJZJNYJVjmZJ8p2Wj8bZ6K\n5W1WfWZ9Wv7Jq0pY0UqY6F8R3bA3JX5V8kxvK7dOq4DlBjkURUqS3LY3U6K3jXJ5\nf0L6H8f8nKbJZJNYJVjmZJ8wIDAQABo1AwTjAdBgNVHQ4EFgQUhP7V5k4V8JF1dJK9JK9JK9JK9JK9JK9J\nK9JK9HwYDVR0lBBgwFAYKKwYBBAGCNwoDDAYKKwYBBAGCNwoDBDAKBggrBgEFBQcD\nATANBgkqhkiG9w0BAQsFAAOCAQEAXPQ3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\nX3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3Q==\n-----END CERTIFICATE-----");
});

qz.security.setSignaturePromise(function(toSign) {
return function(resolve, reject) {
try {
var pk = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC4/CwqxXSDYSAtA\ntS0MidaHeBdXAmcKILgrX8fpU0XafNDdUsOYoAC7sl/AalDoplkX6PY3uxQecnIKS\nD7RHdsDclfnXyTG8rt06rgOUOSRRFStLctjTorcel8n+0vofx/ycpslkk1glWOZnk\nynZaPxtnornVbVZ9Zn1a/smrSljRSpjoXxHdsDclfnXyTG8rt06rgOUOSRRFStLc\ntjTorcel8n+0vofx/ycpslkk1glWOZnkynZaPxtnornVbVZ9Zn1a/smrSljRSpjo\nXxHdsDclfnXyTG8rt06rgOUOSRRFStLctjTorcel8n+0vofx/ycpslkk1glWOZnk\nynZaPxtnornVbVZ9Zn1a/smrSljRSpjoXxHdsDclfnXyTG8rt06rgOUOSRRFStLc\ntjTorcel8n+0vofx/ycpslkk1glWbQIDAQABAoIBAE7P3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3\n3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3X3Q==\n-----END PRIVATE KEY-----";
var rsa = new KJUR.crypto.Signature({"alg": "SHA1withRSA"});
rsa.init(pk);
rsa.updateString(toSign);
var hex = rsa.sign();
resolve(stob64(hex));
} catch (e) {
console.error(e);
reject(e);
}
};
});

function stob64(str) {
return btoa(String.fromCharCode.apply(null, str.replace(/\r|\n/g, "").replace(/([\da-fA-F]{2}) ?/g, "0x$1 ").replace(/ +$/, "").split(" ")));
}

qz.websocket.connect().catch(function(err) {
console.warn("QZ Tray Connection Failed (Will try again on print):", err);
});

/* ===========================
Select2 Initialization
=========================== */
 $("#manual-product").select2({
placeholder: "-- Search Product --",
width: "100%",
allowClear: true,
dropdownCssClass: "p-2",
matcher: function (params, data) {
if (!params.term || typeof params.term !== "string") return data;
const term = params.term.toLowerCase();
const text = String(data.text || "").toLowerCase();
const sKey = String($(data.element).data("search") || "").toLowerCase();
if (text.includes(term) || sKey.includes(term)) return data;
return null;
}
});

 $('#manual-product').on('select2:select', function (e) { $(this).trigger('change'); });

/* ===========================
Date & Setup
=========================== */
const now = new Date();
document.getElementById("invoice-date").textContent = now.toLocaleDateString("en-GB", {
day: 'numeric', month: 'long', year: 'numeric'
});
checkHeldOrder();

/* ===========================
GST CALCULATION UTILITIES - DYNAMIC GST RATE
=========================== */

/**
 * Calculate inclusive GST breakdown with proper rounding
 * For Edible Oil: CGST 2.5% + SGST 2.5% = Total GST 5%
 * 
 * @param {number} amount - Total amount (inclusive of GST)
 * @param {number} gstRate - GST percentage (e.g., 5 for 5%, 12 for 12%, 18 for 18%)
 * @returns {object} - Breakdown with taxable, cgst, sgst, totalGst
 * 
 * FORMULA:
 * Taxable Amount = Total Amount × (100 / (100 + GST Rate))
 * GST Amount = Total Amount - Taxable Amount
 * CGST = GST Amount / 2 (for intra-state)
 * SGST = GST Amount / 2 (for intra-state)
 * 
 * EXAMPLE for 5% GST (Edible Oil):
 * If Total Amount = Rs. 105.00
 * Taxable = 105 × (100/105) = Rs. 100.00
 * GST = 105 - 100 = Rs. 5.00
 * CGST (2.5%) = 5/2 = Rs. 2.50
 * SGST (2.5%) = 5/2 = Rs. 2.50
 */
function calculateInclusiveGST(amount, gstRate) {
    // Handle invalid inputs
    if (!amount || amount <= 0 || isNaN(amount)) {
        return { 
            taxable: 0, 
            gst: 0, 
            cgst: 0, 
            sgst: 0,
            cgstRate: 0,
            sgstRate: 0
        };
    }
    
    // Parse and validate GST rate (default to 5% if invalid)
    gstRate = parseFloat(gstRate);
    if (isNaN(gstRate) || gstRate <= 0) {
        gstRate = 5; // Default for Edible Oil
    }
    
    // Calculate CGST and SGST rates (each is half of total GST for intra-state)
    const cgstRate = gstRate / 2;
    const sgstRate = gstRate / 2;
    
    // Formula for inclusive GST:
    // Taxable Amount = Total Amount × (100 / (100 + GST Rate))
    const divisor = 100 + gstRate;
    const taxable = (amount * 100) / divisor;
    const gst = amount - taxable;
    
    // Split GST into CGST and SGST (for intra-state transactions)
    const cgst = gst / 2;
    const sgst = gst / 2;
    
    // Round to 2 decimal places using proper rounding
    // Using Math.round for proper rounding (not truncation)
    return {
        taxable: Math.round(taxable * 100) / 100,
        gst: Math.round(gst * 100) / 100,
        cgst: Math.round(cgst * 100) / 100,
        sgst: Math.round(sgst * 100) / 100,
        cgstRate: cgstRate,
        sgstRate: sgstRate,
        totalGstRate: gstRate
    };
}

/**
 * Proper rounding function - rounds to 2 decimal places
 * Example: 1.005 rounds to 1.01, 1.004 rounds to 1.00
 */
function roundToTwo(num) {
    return Math.round((num + Number.EPSILON) * 100) / 100;
}

/**
 * Update GST Summary display with dynamic rates
 */
function updateGSTSummary() {
    let totalTaxable = 0;
    let totalCGST = 0;
    let totalSGST = 0;
    let totalGSTAmount = 0;
    
    // Find the GST rate from items (assuming same rate for all items in summary)
    let currentGstRate = 5; // Default
    let currentCgstRate = 2.5;
    let currentSgstRate = 2.5;
    
    $("#items-body tr").each(function() {
        const gstBreakdown = $(this).data('gstBreakdown');
        if (gstBreakdown) {
            totalTaxable += gstBreakdown.taxable;
            totalCGST += gstBreakdown.cgst;
            totalSGST += gstBreakdown.sgst;
            currentGstRate = gstBreakdown.totalGstRate || 5;
            currentCgstRate = gstBreakdown.cgstRate || (currentGstRate / 2);
            currentSgstRate = gstBreakdown.sgstRate || (currentGstRate / 2);
        }
    });
    
    totalGSTAmount = totalCGST + totalSGST;
    
    // Update display values with proper rounding
    $("#gst-taxable").text(roundToTwo(totalTaxable).toFixed(2));
    $("#gst-cgst").text(roundToTwo(totalCGST).toFixed(2));
    $("#gst-sgst").text(roundToTwo(totalSGST).toFixed(2));
    $("#gst-total").text(roundToTwo(totalGSTAmount).toFixed(2));
    
    // Update rate labels dynamically
    $("#cgst-rate-label").text(currentCgstRate.toFixed(2));
    $("#sgst-rate-label").text(currentSgstRate.toFixed(2));
    $("#total-gst-rate-label").text(currentGstRate.toFixed(2));
}

/* ===========================
Table Logic
=========================== */
function checkEmptyState() {
if ($('#items-body tr').length === 0) {
 $('#empty-state').show();
} else {
 $('#empty-state').hide();
}
}

function addRow(Id, name, unit, qty, rate, gstRate) {
 $('#empty-state').hide();
const tr = $('<tr>');
const tdIndex = $('<td class="text-center fw-bold text-muted"></td>');
const tdDesc = $('<td>');
const tdUom = $('<td class="text-center">');
const tdQty = $('<td>');
const tdRate = $('<td>');
const tdAmt = $('<td class="text-end fw-bold amount">0.00</td>');
const tdGST = $('<td class="text-end gst-cell"></td>');
const tdAct = $('<td class="text-center">');

const inDesc = $('<input type="text" class="form-control form-control-sm desc" readonly>').val(name);
const inId = $('<input type="hidden" class="ProdId">').val(Id);
const inGstRate = $('<input type="hidden" class="GstRate">').val(gstRate || 5);
const inUom = $('<input type="text" class="form-control form-control-sm uom text-center" readonly style="background:#f8f9fa">').val(unit);
const inQty = $('<input type="number" class="form-control form-control-sm qty text-center fw-bold" min="0" step="0.01">').val(qty);
const inRate = $('<input type="number" class="form-control form-control-sm rate text-end" min="0" step="0.01">').val(rate);
const btnDel = $('<button class="btn btn-sm btn-outline-danger remove-row"><i class="bi bi-x-lg"></i></button>');

tdDesc.append(inDesc).append(inId).append(inGstRate);
tdUom.append(inUom);
tdQty.append(inQty);
tdRate.append(inRate);
tdAct.append(btnDel);

tr.append(tdIndex, tdDesc, tdUom, tdQty, tdRate, tdAmt, tdGST, tdAct);
tr.hide().appendTo("#items-body").fadeIn(300);

btnDel.on('click', function() {
tr.fadeOut(300, function() {
 $(this).remove();
recalc();
updateGSTSummary();
checkEmptyState();
});
});

inQty.on('input', updateRow);
inRate.on('input', updateRow);

function updateRow() {
const q = parseFloat(inQty.val()) || 0;
const r = parseFloat(inRate.val()) || 0;
const gRate = parseFloat(inGstRate.val()) || 5;
const amount = q * r;

// Round amount to 2 decimal places
tdAmt.text(roundToTwo(amount).toFixed(2));

// Calculate and store GST breakdown with dynamic rate
const gstBreakdown = calculateInclusiveGST(amount, gRate);
tr.data('gstBreakdown', gstBreakdown);

// Update GST cell with proper CGST/SGST percentage display
const cgstPercent = gstBreakdown.cgstRate.toFixed(2);
const sgstPercent = gstBreakdown.sgstRate.toFixed(2);

tdGST.html(
    '<div class="gst-info">' +
    '<span>Taxable: Rs.' + gstBreakdown.taxable.toFixed(2) + '</span>' +
    '<span>CGST (' + cgstPercent + '%): Rs.' + gstBreakdown.cgst.toFixed(2) + '</span>' +
    '<span>SGST (' + sgstPercent + '%): Rs.' + gstBreakdown.sgst.toFixed(2) + '</span>' +
    '<span class="text-info">Total GST: ' + gstBreakdown.totalGstRate + '%</span>' +
    '</div>'
);

recalc();
updateGSTSummary();
}
updateRow();
}

/* ===========================
Calculations with Proper Rounding
=========================== */
function recalc() {
let sub = 0;
 $("#items-body tr").each(function (i) {
 $(this).find("td:first").text(i + 1);
const val = parseFloat($(this).find(".amount").text()) || 0;
sub += val;
});
 $("#subtotal").text(roundToTwo(sub).toFixed(2));
calculateTotal();
}

function calculateTotal() {
let sub = parseFloat($("#subtotal").text()) || 0;
let discInput = parseFloat($("#discount").val()) || 0;
let isPercent = $("#disc-type-toggle").is(":checked");

let discAmount = 0;
if(isPercent) {
discAmount = sub * (discInput / 100);
} else {
discAmount = discInput;
}

// Round discount amount
discAmount = roundToTwo(discAmount);

let total = Math.max(0, sub - discAmount);
 $("#grand-total").text(roundToTwo(total).toFixed(2));
calculateBalance();
}

 $("#disc-type-toggle").on("change", function() {
 $("#disc-type-label").text($(this).is(":checked") ? "%" : "Rs.");
calculateTotal();
});
 $("#discount").on("input", calculateTotal);
 $("#cash").on("input", calculateBalance);
 $("#upi").on("input", calculateBalance);
 $("#recalculate").on("click", function(e){ e.preventDefault(); recalc(); updateGSTSummary(); });

/* ===========================
ROUND OFF BUTTON - Proper Rounding Logic
=========================== */
 $("#round-off-btn").on("click", function() {
    let sub = parseFloat($("#subtotal").text()) || 0;
    let currentDiscount = parseFloat($("#discount").val()) || 0;
    let isPercent = $("#disc-type-toggle").is(":checked");
    
    // Calculate current discount amount
    let currentDiscAmount = isPercent ? (sub * currentDiscount / 100) : currentDiscount;
    
    // Calculate current grand total
    let currentGrandTotal = sub - currentDiscAmount;
    
    // Round to nearest rupee
    let nearestRound = Math.round(currentGrandTotal);
    
    // Calculate the difference (how much to add to discount)
    let diff = roundToTwo(currentGrandTotal - nearestRound);
    
    // Only apply if there's a difference (not already rounded)
    if(Math.abs(diff) > 0.001) {
        // Calculate new discount
        let newDiscountAmount;
        if(isPercent) {
            // If discount is in percentage, convert diff to percentage
            newDiscountAmount = currentDiscount + roundToTwo((diff / sub) * 100);
        } else {
            // If discount is in rupees, add directly
            newDiscountAmount = currentDiscount + diff;
        }
        
        // Ensure discount doesn't go negative
        if(newDiscountAmount >= 0) {
            $("#discount").val(roundToTwo(newDiscountAmount).toFixed(2));
            calculateTotal();
            
            // Show success message
            if(diff > 0) {
                showWonderfulBox('success', 'Rounded Off', 
                    'Total rounded off to Rs.' + nearestRound.toFixed(2) + 
                    '<br>Discount increased by Rs.' + diff.toFixed(2));
            } else {
                showWonderfulBox('success', 'Rounded Off', 
                    'Total rounded off to Rs.' + nearestRound.toFixed(2) + 
                    '<br>Discount adjusted by Rs.' + Math.abs(diff).toFixed(2));
            }
        }
    } else {
        showWonderfulBox('warning', 'Already Rounded', 
            'Total is already rounded to Rs.' + nearestRound.toFixed(2));
    }
});

 $("#manual-product").on("change", function () {
const val = $(this).val();
if (!val) return;
const parts = val.split("|");
const prodId = $(this).find(":selected").data("prodid") || "0";
const gstRate = $(this).find(":selected").data("gstrate") || 5;

let exists = false;
 $("#items-body tr").each(function() {
if($(this).find(".ProdId").val() == prodId) {
const qInput = $(this).find(".qty");
qInput.val((parseFloat(qInput.val()) || 0) + 1).trigger('input');
exists = true;
 $(this).addClass("table-info");
setTimeout(() => $(this).removeClass("table-info"), 500);
}
});

if(!exists) {
addRow(prodId, parts[0], parts[2], 1, parseFloat(parts[1])||0, gstRate);
}

 $(this).val(null).trigger('change');
setTimeout(function() {
 $('#manual-product').select2('open');
}, 100);
});

function calculateBalance() {
const cash = parseFloat($("#cash").val()) || 0;
const upi = parseFloat($("#upi").val()) || 0;
const grandTotal = parseFloat($("#grand-total").text()) || 0;
const paid = cash + upi;
const balance = grandTotal - paid;

const balElem = $("#Bal-amt");
balElem.text(roundToTwo(balance).toFixed(2));

if(balance <= 0.1) {
balElem.removeClass('text-danger').addClass('text-success');
} else {
balElem.removeClass('text-success').addClass('text-danger');
}
}

/* ===========================
Hold / Resume Logic
=========================== */
 $("#hold-btn").on("click", function() {
if($("#items-body tr").length === 0) {
showWonderfulBox('error', 'Cart Empty', 'There are no items to hold.');
return;
}
const holdData = {
customer: {
name: $("#cust-name").val(),
address: $("#cust-address").val(),
phone: $("#cust-phone").val()
},
items: [],
discount: $("#discount").val(),
isDiscPercent: $("#disc-type-toggle").is(":checked")
};

 $("#items-body tr").each(function() {
holdData.items.push({
prodId: $(this).find(".ProdId").val(),
name: $(this).find(".desc").val(),
uom: $(this).find(".uom").val(),
qty: $(this).find(".qty").val(),
rate: $(this).find(".rate").val(),
gstRate: $(this).find(".GstRate").val()
});
});

localStorage.setItem('vijay_held_order', JSON.stringify(holdData));
showWonderfulBox('success', 'Order Held', 'The current order has been saved successfully.');
resetInvoiceForm();
checkHeldOrder();
});

function checkHeldOrder() {
const held = localStorage.getItem('vijay_held_order');
if(held) {
 $("#resume-btn").removeClass("d-none");
} else {
 $("#resume-btn").addClass("d-none");
}
}

 $("#resume-btn").on("click", function() {
const held = JSON.parse(localStorage.getItem('vijay_held_order'));
if(!held) return;

showWonderfulBox('confirm', 'Resume Order?', 'Resume previous held order? The current cart will be cleared.',
function() { // On Confirm
 $("#cust-name").val(held.customer.name);
 $("#cust-address").val(held.customer.address);
 $("#cust-phone").val(held.customer.phone);
 $("#discount").val(held.discount);
 $("#disc-type-toggle").prop("checked", held.isDiscPercent).trigger("change");

 $("#items-body").empty();
held.items.forEach(item => {
addRow(item.prodId, item.name, item.uom, item.qty, item.rate, item.gstRate || 5);
});

localStorage.removeItem('vijay_held_order');
checkHeldOrder();
showWonderfulBox('success', 'Resumed', 'Order has been resumed successfully.');
},
function() { // On Cancel
// Do nothing
}
);
});

/* ===========================
Utils
=========================== */
const toastEl = document.getElementById('liveToast');
const toast = new bootstrap.Toast(toastEl, { delay: 4000 });

function resetInvoiceForm() {
 $('.invoice-box').css('opacity', '0.5');
setTimeout(() => {
 $('#cust-name, #cust-address, #cust-phone').val('');
 $('#manual-product').val(null).trigger('change');
 $('#discount').val('');
 $('#cash').val('');
 $('#upi').val('');

 $('#items-body').empty();
checkEmptyState();

 $('#subtotal').text('');
 $('#grand-total').text('');
 $('#Bal-amt').text('');

 $('#gst-taxable').text('0.00');
 $('#gst-cgst').text('0.00');
 $('#gst-sgst').text('0.00');
 $('#gst-total').text('0.00');

 $('.invoice-box').css('opacity', '1');
}, 300);
}

function toggleCancelButton() {
const cancelId = $("#cancelId").val();
if (cancelId && cancelId !== "0") {
 $("#cancel").removeClass("d-none");
} else {
 $("#cancel").addClass("d-none");
}
}

/* ===========================
THERMAL PRINTER LOGIC - PERFECT ALIGNMENT
=========================== */
function printThermalReceipt(docNo) {
 $('#print-date').text(new Date().toLocaleString());
 $('#print-inv-no').text(docNo || "PENDING");

const custName = $('#cust-name').val();
 $('#print-cust').text(custName ? custName : 'Walk-in Customer');

// Build items table with perfect alignment
let itemsHtml = '';
let printTaxable = 0;
let printCGST = 0;
let printSGST = 0;
let currentGstRate = 5;
let currentCgstRate = 2.5;
let currentSgstRate = 2.5;

 $('#items-body tr').each(function() {
    const name = $(this).find('.desc').val() || '';
    const qty = $(this).find('.qty').val() || '0';
    const rate = $(this).find('.rate').val() || '0';
    const amt = $(this).find('.amount').text() || '0.00';
    const gstBreakdown = $(this).data('gstBreakdown') || { taxable: 0, cgst: 0, sgst: 0, cgstRate: 2.5, sgstRate: 2.5, totalGstRate: 5 };
    
    // Accumulate GST totals
    printTaxable += gstBreakdown.taxable;
    printCGST += gstBreakdown.cgst;
    printSGST += gstBreakdown.sgst;
    currentGstRate = gstBreakdown.totalGstRate || 5;
    currentCgstRate = gstBreakdown.cgstRate || (currentGstRate / 2);
    currentSgstRate = gstBreakdown.sgstRate || (currentGstRate / 2);
    
    // Truncate name to fit column (max ~20 chars for 72mm paper)
    const shortName = name.length > 18 ? name.substring(0, 16) + '..' : name;
    
    itemsHtml += '<tr>';
    itemsHtml += '<td class="col-sno">' + ($(this).index() + 1) + '</td>';
    itemsHtml += '<td class="col-item"><span class="item-name">' + shortName + '</span></td>';
    itemsHtml += '<td class="col-qty">' + parseFloat(qty).toFixed(2) + '</td>';
    itemsHtml += '<td class="col-rate">' + parseFloat(rate).toFixed(2) + '</td>';
    itemsHtml += '<td class="col-amt">' + parseFloat(amt).toFixed(2) + '</td>';
    itemsHtml += '</tr>';
});

 $('#print-items').html(itemsHtml);

// Update GST summary in receipt with dynamic rates
 $('#print-taxable').text(roundToTwo(printTaxable).toFixed(2));
 $('#print-cgst').text(roundToTwo(printCGST).toFixed(2));
 $('#print-sgst').text(roundToTwo(printSGST).toFixed(2));
 $('#print-cgst-rate').text(currentCgstRate.toFixed(2));
 $('#print-sgst-rate').text(currentSgstRate.toFixed(2));

// Update totals
 $('#print-subtotal').text($('#subtotal').text() || "0.00");

const discVal = $('#discount').val() || "0";
const discType = $("#disc-type-toggle").is(":checked") ? "%" : "Rs.";
 $('#print-discount').text(discVal + (discType === "%" ? "%" : ""));

 $('#print-total').text($('#grand-total').text() || "0.00");
 $('#print-cash').text($('#cash').val() || "0.00");
 $('#print-upi').text($('#upi').val() || "0.00");
 $('#print-balance').text($('#Bal-amt').text() || "0.00");

var connectPromise = Promise.resolve();
if (!qz.websocket.isActive()) {
connectPromise = qz.websocket.connect();
}

connectPromise.then(function() {
return qz.printers.getDefault().catch(function(e) {
console.warn("No default printer found, searching...");
return qz.printers.find();
});
}).then(function(printer) {
if (!printer) {
throw new Error("No printer selected or available.");
}
var config = qz.configs.create(printer, {
    units: 'mm',
    altPrinting: true
});
var printData = [
{
type: 'html',
format: 'plain',
content: document.getElementById('thermal-print-area').innerHTML
}
];
return qz.print(config, printData);
}).then(function() {
console.log("Printed successfully");
}).catch(function(err) {
console.error("Print Error:", err);
if (qz.websocket.isActive()) {
console.warn("Connection recovered or transient error occurred, print may still execute.");
}
});
}
/* ===========================
✅ SAVE + SAVE PRINT LOGIC
=========================== */

 $("#save-btn").on("click", function (e) {
e.preventDefault();
saveInvoice(false);
});

 $("#save-print-btn").on("click", function (e) {
e.preventDefault();
saveInvoice(true);
});


/* ===========================
✅ MAIN SAVE FUNCTION
=========================== */

function saveInvoice(printAfterSave) {

if ($("#items-body tr").length === 0) {
showWonderfulBox('warning', 'Missing Items',
'Please add at least one product to proceed.');
return;
}

var balAmt = parseFloat($("#Bal-amt").text()) || 0;

if (balAmt < -0.1) {
showWonderfulBox('error', 'Payment Error',
'Payment amount exceeds the total invoice amount!');
return;
}

 $("#loader").css("display", "flex").addClass("active");

// Collect GST summary data
let totalTaxable = 0;
let totalCGST = 0;
let totalSGST = 0;
let currentGstRate = 5;
let currentCgstRate = 2.5;
let currentSgstRate = 2.5;

const data = {
discountType: $("#disc-type-toggle").is(":checked") ? "PERCENT" : "FIXED",
discount: parseFloat($("#discount").val()) || 0,
subtotal: parseFloat($("#subtotal").text()) || 0,
total: parseFloat($("#grand-total").text()) || 0,
cash: parseFloat($("#cash").val()) || 0,
upi: parseFloat($("#upi").val()) || 0,
printRequired: printAfterSave,
customer: {
name: $("#cust-name").val(),
address: $("#cust-address").val(),
phone: $("#cust-phone").val()
},
items: []
};

 $("#items-body tr").each(function () {
const row = $(this);
const gstBreakdown = row.data('gstBreakdown') || { taxable: 0, cgst: 0, sgst: 0, cgstRate: 2.5, sgstRate: 2.5, totalGstRate: 5 };

totalTaxable += gstBreakdown.taxable;
totalCGST += gstBreakdown.cgst;
totalSGST += gstBreakdown.sgst;
currentGstRate = gstBreakdown.totalGstRate || 5;
currentCgstRate = gstBreakdown.cgstRate || (currentGstRate / 2);
currentSgstRate = gstBreakdown.sgstRate || (currentGstRate / 2);

data.items.push({
prodId: row.find(".ProdId").val(),
product: row.find(".desc").val(),
unit: row.find(".uom").val(),
qty: parseFloat(row.find(".qty").val()) || 0,
rate: parseFloat(row.find(".rate").val()) || 0,
amount: parseFloat(row.find(".amount").text()) || 0,
gstRate: parseFloat(row.find(".GstRate").val()) || 5,
taxable: gstBreakdown.taxable,
cgst: gstBreakdown.cgst,
sgst: gstBreakdown.sgst
});
});

// Add GST summary to data with proper rounding
data.gstSummary = {
totalTaxable: roundToTwo(totalTaxable),
totalCGST: roundToTwo(totalCGST),
totalSGST: roundToTwo(totalSGST),
totalGST: roundToTwo(totalCGST + totalSGST),
gstRate: currentGstRate,
cgstRate: currentCgstRate,
sgstRate: currentSgstRate
};

console.log("Sending Data:", data);

 $.ajax({
type: "POST",
url: "<%= request.getContextPath() %>/SalesSaveServlet",
data: JSON.stringify({ salesData: data }),
contentType: "application/json; charset=utf-8",
dataType: "json",

success: function (response) {

 $("#loader").removeClass("active");
setTimeout(() => { $("#loader").hide(); }, 300);

if (response && response.status === "success") {

const docNo = response.docNo;

showWonderfulBox(
'success',
'Invoice Saved',
`Invoice No. <b>${docNo}</b> saved successfully!`
);

// ✅ Print ONLY if Save+Print
if (printAfterSave) {
printThermalReceipt(docNo);
}

// ✅ Show Cancel Button
 $("#cancelId").val(docNo);
toggleCancelButton();

resetInvoiceForm();

} else {
const err = response ? response.message : "Unknown Error";
showWonderfulBox('error', 'Save Failed', err);
}
},

error: function (xhr, status, error) {
 $("#loader").removeClass("active");
setTimeout(() => { $("#loader").hide(); }, 300);
showWonderfulBox(
'error',
'Server Error',
"Connection Failed: " + error
);
console.error(xhr.responseText);
}
});
}

/* ===========================
CANCEL ENTRY LOGIC
=========================== */
 $("#cancel").on("click", function () {
const cancelId = $("#cancelId").val();
if (!cancelId || cancelId === "0") {
showWonderfulBox('error', 'Error', 'Document ID not found.');
return;
}

showWonderfulBox('confirm', 'Cancel Invoice?', 'Are you sure you want to CANCEL this invoice? This action cannot be undone.',
function() { // On Confirm
 $("#loader").css("display", "flex").addClass("active");
 $.ajax({
type: "POST",
url: "<%= request.getContextPath() %>/CancelSalesEntry",
data: { documentNo: cancelId },
success: function (response) {
 $("#loader").removeClass("active");
setTimeout(() => { $("#loader").hide(); }, 300);
if (response && response.status === "success") {
 $("#cancelId").val("0");
 $("#cancel").addClass("d-none");
showWonderfulBox('success', 'Canceled', 'The invoice has been canceled successfully.');
} else {
const err = response ? (response.error || response.message) : "Unknown error";
showWonderfulBox('error', 'Failed', err);
}
},
error: function (xhr, status, error) {
 $("#loader").removeClass("active");
setTimeout(() => { $("#loader").hide(); }, 300);
showWonderfulBox('error', 'Connection Failed', "Server Connection Failed: " + error);
}
});
},
function() { // On Cancel
// Do nothing
}
);
});

});
</script>
</body>
</html>