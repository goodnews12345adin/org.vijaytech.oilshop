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

    String orgName = (String) session1.getAttribute("orgName");
    if (orgName == null) orgName = "";

    List<Map<String, Object>> productList =
           (List<Map<String, Object>>) request.getAttribute("productList");
%>

<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Sales Entry</title>

<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

<style>
/* ===========================
   Tokens & responsive header + layout fixes
   Mobile-first
   =========================== */
:root{
  --sidebar-width: 260px;
  --header-height: 64px;
  --header-compact: 54px;
  --card-radius: 12px;
  --accent-a: #19b6b0;
  --accent-b: #15a0c6;
  --bg-1: #ffffff;
  --text-dark: #0f1724;
  --muted-text: #475569;
  --elev-2: 0 18px 36px rgba(2,6,23,0.12);
  --transition: 220ms;
  --content-offset: 0px; /* JS will update when sidebar toggles */
}

/* base resets */
*{box-sizing:border-box}
html,body{height:100%; margin:0; padding:0; font-family:Inter, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial; -webkit-font-smoothing:antialiased; -moz-osx-font-smoothing:grayscale;}
/* body must reserve space for fixed header including safe-area */
body{
  background: linear-gradient(180deg,#e6eef6 0%, #f8fafc 100%);
  color:var(--text-dark);
  padding-top: calc(var(--header-height) + env(safe-area-inset-top, 0px) + 12px);
  -webkit-font-smoothing:antialiased;
}

/* Floating header (style C) */
.app-header {
  position: fixed;
  top: env(safe-area-inset-top, 8px); /* respect notch */
  left: 50%;
  transform: translateX(-50%);
  height: var(--header-height);
  min-width: 320px;
  width: calc(100% - 32px);
  max-width: 980px;
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:12px;
  padding: 10px 14px;
  border-radius: 16px;
  z-index: 4000;
  background: linear-gradient(180deg, rgba(255,255,255,0.04), rgba(255,255,255,0.02));
  box-shadow: 0 10px 40px rgba(2,6,23,0.45);
  border: 1px solid rgba(255,255,255,0.03);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  transition: transform var(--transition) ease, width var(--transition) ease, height var(--transition) ease;
}

.header-left { display:flex; align-items:center; gap:12px; }
.hamburger {
  width:44px; height:44px; display:inline-grid; place-items:center;
  border-radius:10px;
  background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
  border:1px solid rgba(255,255,255,0.03);
  cursor:pointer;
  transition: transform var(--transition) ease;
}
.hamburger .bars { width:20px; height:14px; position:relative; }
.hamburger .bars span{ display:block; position:absolute; left:0; right:0; height:2px; background:#e6eef2; border-radius:2px; transition: transform var(--transition) ease, opacity var(--transition) ease; }
.hamburger .bars span:nth-child(1){ top:0; }
.hamburger .bars span:nth-child(2){ top:6px; }
.hamburger .bars span:nth-child(3){ top:12px; }

/* hamburger -> X when sidebar open */
html.sidebar-open .hamburger .bars span:nth-child(1){ transform: translateY(6px) rotate(45deg); }
html.sidebar-open .hamburger .bars span:nth-child(2){ opacity:0; }
html.sidebar-open .hamburger .bars span:nth-child(3){ transform: translateY(-6px) rotate(-45deg); }

.header-title { font-size:1rem; font-weight:700; color:#e6f3f3; }
.header-right { display:flex; gap:10px; align-items:center; }
.header-action{ display:inline-flex; gap:8px; align-items:center; padding:6px 10px; border-radius:999px; background: rgba(255,255,255,0.02); color:#e6f3f3; border:1px solid rgba(255,255,255,0.02); font-weight:600; }

/* page wrap — this will be pushed when sidebar opens via --content-offset */
.page-wrap{
  transition: transform var(--transition) ease, margin var(--transition) ease;
  transform: translateX(var(--content-offset));
  padding: 18px;
  min-height: calc(100vh - (var(--header-height) + 36px));
  display:flex;
  align-items:flex-start;
  justify-content:center;
}

/* update --content-offset when html.sidebar-open is present (JS also updates) */
html.sidebar-open { --content-offset: var(--sidebar-width); }

/* invoice box and content */
.invoice-box{
  max-width:1200px;
  margin:0 auto;
  background:var(--bg-1);
  border-radius:14px;
  box-shadow:var(--elev-2);
  padding:18px;
  border: 1px solid rgba(15,23,42,0.04);
}

.invoice-head{
  display:flex;
  justify-content:space-between;
  align-items:center;
  gap:12px;
  margin-bottom:12px;
  flex-wrap:wrap;
}
.org-title{ font-size:1.05rem; font-weight:700; color:var(--text-dark); }
.invoice-type{ font-size:0.95rem; color:var(--muted-text); font-weight:600; }

/* inputs, table, select2 */
.border-dashed{ border:1px dashed rgba(99,102,241,0.06); padding:10px; border-radius:8px; background: linear-gradient(180deg, rgba(10,20,40,0.02), rgba(255,255,255,0.02)); }
.table-responsive{ margin-top:12px; }
.table thead th{ background: #fbfcfe; border-bottom:1px solid rgba(15,23,42,0.04); font-weight:700; color:var(--muted-text); font-size:0.88rem; }
.table tbody td { vertical-align:middle; font-size:0.92rem; color:var(--text-dark); }
/* .select2-container .select2-selection--single { height: calc(1.5em + 0.75rem); padding: .25rem .5rem; }
.select2-container--default .select2-selection--single .select2-selection__rendered { line-height:1.5; }
.select2-dropdown-full-width { max-width: 100% !important; } */

/* buttons & totals */
.btn-sm { padding:6px 10px; font-size:0.85rem; }
.total-box{ margin-top:18px; text-align:right; font-size:0.98rem; color:var(--text-dark); }
.total-box .value{ font-weight:800; font-size:1.25rem; display:inline-block; margin-left:6px; }

/* loader & alerts */
#loader{ display:none; position:fixed; inset:0; background: rgba(0,0,0,0.36); z-index:4200; align-items:center; justify-content:center; }
#loader .box{ background:#fff; padding:18px 22px; border-radius:10px; box-shadow:var(--elev-2); color:var(--text-dark); }

/* small screens tweaks */
@media (max-width: 480px){
  .app-header{ height: var(--header-compact); padding:6px 10px; border-radius:12px; top:env(safe-area-inset-top,6px); }
  body{ padding-top: calc(var(--header-compact) + env(safe-area-inset-top, 0px) + 8px); }
  html.sidebar-open { --content-offset: 220px; } /* smaller push on tiny screens */
  .invoice-box{ margin:0 8px; padding:12px; border-radius:12px; }
  .table thead th, .table tbody td{ font-size:0.82rem; padding:6px; }
  .select2-container { width:100% !important; }
}

/* medium and desktop spacing */
@media (min-width: 768px) {
  .page-wrap { justify-content:flex-start; padding-left:40px; }
  .invoice-box{ max-width:900px; }
}
@media (min-width: 992px) {
  .page-wrap { padding-left:60px; }
  html.sidebar-open { --content-offset: var(--sidebar-width); }
  .invoice-box{ max-width:1100px; padding:22px; border-radius:14px; }
}

/* print rules */
@media print {
  .app-header, .hamburger, #loader, .btn { display:none !important; }
  .invoice-box{ box-shadow:none; border:none; }
  .table thead th { background: #f3f4f6 !important; -webkit-print-color-adjust: exact; }
}

/* reduced motion */
@media (prefers-reduced-motion: reduce) {
  *{ transition:none !important; animation-duration:0.001ms !important; }
}
.select2-fixed-dropdown {
    max-height: 260px !important;
    min-height: 150px !important;
    overflow-y: auto !important;
    position: relative !important;
    z-index: 999999 !important; /* above header and page-wrap */
}

.select2-container--open .select2-dropdown {
    display: block !important;
    visibility: visible !important;
    opacity: 1 !important;
}

</style>

</head>
<body>

<!-- Floating header (style C) -->
<header class="app-header" role="banner" aria-label="Application header">
  <div class="header-left">
    <button id="sidebarToggle" class="hamburger" aria-controls="sidebar" aria-expanded="false" title="Toggle sidebar" type="button">
      <span class="bars" aria-hidden="true"><span></span><span></span><span></span></span>
    </button>
    <div class="header-title">Sales Entry</div>
  </div>

  <div class="header-right">
    <div class="header-action" title="Organization">
      <i class="bi bi-building" style="font-size:1rem; color:#e6f3f3;"></i>
      <span style="color:#e6f3f3; margin-left:6px;"><%= orgName %></span>
    </div>
  </div>
</header>

<%@ include file="sidebar.jsp" %>

<!-- Page content (will be pushed by header/sidebar toggle) -->
<div class="page-wrap" id="pageWrap" role="main" aria-labelledby="pageTitle">
  <main class="container-main" role="main" aria-labelledby="pageTitle">
    <div class="invoice-box" role="region" aria-label="Sales Invoice">

        <!-- Header -->
        <div class="invoice-head" id="pageTitle">
            <div>
                <div class="org-title"><%= orgName %></div>
                <div class="text-muted-sm">Sales Invoice</div>
            </div>
            <div class="text-end">
                <div class="invoice-type">Date: <strong id="invoice-date"></strong></div>
            </div>
        </div>

        <!-- Bill To + Product selector -->
        <div class="row g-3">
            <div class="col-12 col-md-6">
                <div class="border-dashed">
                    <div class="fw-semibold mb-2">Bill To</div>
                    <input class="form-control mb-2" id="cust-name" placeholder="Customer Name" aria-label="Customer name">
                    <input class="form-control mb-2" id="cust-address" placeholder="Address" aria-label="Customer address">
                    <input class="form-control mb-2" id="cust-phone" placeholder="Phone / GSTIN" aria-label="Customer phone or GSTIN">
                </div>
            </div>

           <div class="col-12 col-md-6">
                <label class="form-label fw-semibold">Select Product</label>
                <select id="manual-product" class="form-select" style="width:100%">
                    <%

                    if (productList != null) {
                        for (Map<String,Object> p : productList) {
                        	String name   = p.get("name")   != null ? p.get("name").toString()   : "";
                        	String rate   = p.get("rate")   != null ? p.get("rate").toString()   : "0";
                        	String uom    = p.get("uom")    != null ? p.get("uom").toString()    : "";
                        	String prodId = p.get("prodId") != null ? p.get("prodId").toString() : "0";
                        	String search = p.get("value")  != null ? p.get("value").toString()  : "";

                    %>
                    <option 
                        value="<%= name %>|<%= rate %>|<%= uom %>"
                        data-prodid="<%= prodId %>"
                        data-search="<%= search %>">
                        <%= search %> - <%= name %> - ₹<%= rate %> / <%= uom %>
                    </option>
                    <% } } %>
                </select>
            </div>
        </div>

        <!-- Items table -->
        <div class="table-responsive mt-3">
            <table class="table table-sm table-bordered align-middle" id="items-table" role="table" aria-label="Invoice items">
                <thead class="table-light">
                    <tr>
                        <th style="width:36px">S.no</th>
                        <th>Product</th>
                        <th style="width:96px">Unit</th>
                        <th style="width:96px">Qty</th>
                        <th style="width:110px">Rate (₹)</th>
                        <th style="width:120px">Amount (₹)</th>
                        <th style="width:68px">Action</th>
                    </tr>
                </thead>
                <tbody id="items-body" aria-live="polite"></tbody>
            </table>
        </div>
<div class="mt-4 text-end total-box">
 <div class="mt-2">
            Discount:
            <input type="number" id="discount"
                   class="form-control form-control-sm d-inline-block"
                   style="width:120px; display:inline-block;"
                   value="0">
        </div>
 <div class="mt-2">
            Cash:
            <input type="number" id="cash"
                   class="form-control form-control-sm d-inline-block"
                   style="width:120px; display:inline-block;"
                   value="0">
        </div>
        <div class="mt-2">
            UPI:
            <input type="number" id="upi"
                   class="form-control form-control-sm d-inline-block"
                   style="width:120px; display:inline-block;"
                   value="0">
        </div>
		<div>Subtotal: ₹<span id="subtotal">0.00</span></div>
        <div class="mt-2">
            Total: ₹<strong id="grand-total">0.00</strong>
        </div>
    </div>
    <div class="text-end mt-3">
        <button id="recalculate" class="btn btn-primary btn-sm">Recalculate</button>
        <button id="send-btn" class="btn btn-success btn-sm">Send</button>
    </div>
        <!-- Totals -->
       

    </div>

    <!-- Page footer -->
    <div class="page-footer">
        © <%= java.time.Year.now().getValue() %> <%= orgName %>
    </div>
  </main>
</div> <!-- page-wrap -->

<!-- Global loader -->
<div id="loader" role="status" aria-hidden="true">
    <div class="box">Please wait... Processing</div>
</div>

<!-- Alerts container -->
<div class="position-fixed top-3 end-3" style="z-index:5050; pointer-events:none;">
  <div id="alertBox" style="pointer-events:auto;"></div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
$(function(){
	$("#manual-product").select2({
	    placeholder: "--Select Product--",
	    width: "100%",
	    allowClear: true,
	    dropdownParent: $('body'),   // IMPORTANT FIX
	    dropdownCssClass: "select2-dropdown-full-width",
	    matcher: function(params, data) {
	        if (!params.term) return data;

	        const term = params.term.toLowerCase();
	        const text = (data.text || "").toLowerCase();
	        const sKey = ($(data.element).data("search") || "").toLowerCase();

	        return text.includes(term) || sKey.includes(term) ? data : null;
	    }
	});
    // --- Sidebar toggle (push behavior) ---
    const toggleBtn = document.getElementById('sidebarToggle');
    const htmlEl = document.documentElement;
    const STORAGE_KEY = 'sidebarOpenVijay_purchase';
    // initialize from storage
    const isOpen = localStorage.getItem(STORAGE_KEY) === '1';
    if (isOpen) {
      htmlEl.classList.add('sidebar-open');
      toggleBtn.setAttribute('aria-expanded','true');
    }

    function setSidebarOpen(open) {
      if (open) {
        htmlEl.classList.add('sidebar-open');
        toggleBtn.setAttribute('aria-expanded','true');
        localStorage.setItem(STORAGE_KEY, '1');
      } else {
        htmlEl.classList.remove('sidebar-open');
        toggleBtn.setAttribute('aria-expanded','false');
        localStorage.setItem(STORAGE_KEY, '0');
      }
      toggleBtn.focus({ preventScroll: true });
      // update CSS variable used by page-wrap
      document.documentElement.style.setProperty('--content-offset', open ? getComputedStyle(document.documentElement).getPropertyValue('--sidebar-width') : '0px');
    }

    toggleBtn.addEventListener('click', function(e){
      e.preventDefault();
      setSidebarOpen(!htmlEl.classList.contains('sidebar-open'));
    });

    // close on ESC
    document.addEventListener('keydown', function(e){
      if (e.key === 'Escape' && htmlEl.classList.contains('sidebar-open')) {
        setSidebarOpen(false);
      }
    });

    // click outside to close on small screens
    document.addEventListener('click', function(ev){
      const t = ev.target;
      const insideHeader = t.closest('.app-header');
      const insideSidebar = t.closest('.app-sidebar');
      if (!insideHeader && !insideSidebar && htmlEl.classList.contains('sidebar-open')) {
        if (window.innerWidth < 800) setSidebarOpen(false);
      }
    });

    // make sure header width & variables update on resize (prevents huge blank area)
    (function(){
      const header = document.querySelector('.app-header');
      function updateLayoutVars() {
        // ensure content-offset variable set to current value
        const offset = htmlEl.classList.contains('sidebar-open') ? getComputedStyle(document.documentElement).getPropertyValue('--sidebar-width') : '0px';
        document.documentElement.style.setProperty('--content-offset', offset.trim());
        // adjust header max width for very small screens
        if (window.innerWidth <= 480) {
          header.style.maxWidth = (window.innerWidth - 32) + 'px';
        } else {
          header.style.maxWidth = '980px';
        }
      }
      window.addEventListener('resize', updateLayoutVars);
      // initial call
      updateLayoutVars();
      // call after toggle clicks as well
      if (toggleBtn) toggleBtn.addEventListener('click', () => setTimeout(updateLayoutVars, 10));
    })();

    // =========== invoice logic (Select2, add rows, totals, AJAX) ===========
    document.getElementById("invoice-date").textContent = new Date().toLocaleDateString("en-GB");

 /*    // Select2 init
    $("#manual-product").select2({
        placeholder: "--Select Product--",
        width: "100%",
        allowClear: true,
        dropdownCssClass: "select2-dropdown-full-width",
        matcher: function(params, data) {
            if (!params.term) return data;
            const term = String(params.term).toLowerCase();
            const text = String(data.text || "").toLowerCase();
            const sKey = String($(data.element).data("search") || "").toLowerCase();
            if (text.includes(term) || sKey.includes(term)) return data;
            return null;
        }
    }); */

    // Add row function
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
        inputQty.min = '0';
        inputQty.step = '0.01';
        inputQty.className = 'form-control form-control-sm qty';
        inputQty.value = qty;

        const inputRate = document.createElement('input');
        inputRate.type = 'number';
        inputRate.min = '0';
        inputRate.step = '0.01';
        inputRate.className = 'form-control form-control-sm rate';
        inputRate.value = rate;

        const btnRemove = document.createElement('button');
        btnRemove.className = 'btn btn-sm btn-outline-danger remove-row';
        btnRemove.textContent = '×';
        btnRemove.title = 'Remove row';

        tdDesc.appendChild(inputDesc);
        tdDesc.appendChild(inputProdId);
        tdUom.appendChild(inputUom);
        tdQty.appendChild(inputQty);
        tdRate.appendChild(inputRate);
        tdAction.appendChild(btnRemove);

        tr.appendChild(tdIndex);
        tr.appendChild(tdDesc);
        tr.appendChild(tdUom);
        tr.appendChild(tdQty);
        tr.appendChild(tdRate);
        tr.appendChild(tdAmount);
        tr.appendChild(tdAction);

        document.getElementById("items-body").appendChild(tr);

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

    // recalc totals
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

    function showAlert(type, message) {
        let alertHTML =
            '<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' +
                message +
                '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
            '</div>';
        $("#alertBox").html(alertHTML);
    }

    // Send / save via AJAX
    $("#send-btn").click(function(){
        $("#loader").css("display","flex").attr("aria-hidden","false");

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
            type: "POST",
            url: "<%= request.getContextPath() %>/SalesSaveServlet",
            data: JSON.stringify({ salesData: data }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(response) {
                $("#loader").hide().attr("aria-hidden","true");

                if (!response) {
                    showAlert('danger', 'Empty response from server');
                    return;
                }

                if (response.status && response.status === "success") {
                    if (response.pdfUrl) {
                        window.open(response.pdfUrl, "_blank");
                        showAlert('success', 'Invoice generated successfully.');
                    } else if (response.fileName) {
                        var fallback = "<%= request.getContextPath() %>/invoices/" + encodeURIComponent(response.fileName);
                        window.open(fallback, "_blank");
                        showAlert('success', 'Invoice generated (fallback).');
                    } else {
                        showAlert('success', 'Saved successfully but no PDF URL returned.');
                    }
                } else {
                    let msg = response.error || response.message || 'Unknown error';
                    showAlert('danger', 'Error: ' + msg);
                }
            },
            error: function(xhr, status, error) {
                $("#loader").hide().attr("aria-hidden","true");
                let errMsg = 'Server error: ' + (xhr.responseJSON && xhr.responseJSON.error ? xhr.responseJSON.error : (xhr.responseText || error));
                showAlert('danger', errMsg);
                console.error("AJAX Error:", error, xhr);
            }
        });

    });

    // Accessibility: allow enter on select2 search to pick the item quickly
  /*   $(document).on('keydown', '.select2-search__field', function(e){
        if(e.key === 'Enter'){
            e.preventDefault();
            $('.select2-results__option[aria-selected=false]').first().trigger('mouseup');
        }
    }); */

}); // end ready
</script>

</body>
</html>
