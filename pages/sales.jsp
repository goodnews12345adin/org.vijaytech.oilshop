<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="org.vijaytech.oilshop.Organization" %>
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

    <meta charset="UTF-8">
    <title>Sales Entry</title>

    <meta name="viewport"
          content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover">

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet">

    <!-- Select2 -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css"
          rel="stylesheet"/>

    <style>
        /* ===========================
           Tokens & responsive layout
           Mobile-first
        =========================== */
        :root {
            --sidebar-width: 260px;
            --header-height: 64px;
            --header-compact: 54px;
            --card-radius: 12px;
            --accent-a: #19b6b0;
            --accent-b: #15a0c6;
            --bg-1: #ffffff;
            --text-dark: #0f1724;
            --muted-text: #475569;
            --elev-2: 0 18px 36px rgba(2, 6, 23, 0.12);
            --transition: 220ms;
            --content-offset: 0px;
        }

        * {
            box-sizing: border-box;
        }

        html,
        body {
            height: 100%;
            margin: 0;
            padding: 0;
            font-family: Inter, system-ui, -apple-system,
                         "Segoe UI", Roboto, Arial;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        body {
            background: linear-gradient(
                180deg,
                #e6eef6 0%,
                #f8fafc 100%
            );
            color: var(--text-dark);
            padding-top: calc(
                var(--header-height)
                + env(safe-area-inset-top, 0px)
                + 12px
            );
        }

        /* ===========================
           Floating Header
        =========================== */
        .app-header {
            position: fixed;
            top: 15px;
            left: 59%;
            transform: translateX(-50%);
            height: var(--header-height);
            min-width: 320px;
            width: calc(100% - 32px);
            max-width: 980px;

            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;

            padding: 10px 14px;
            border-radius: 16px;

            background: linear-gradient(
                180deg,
                rgba(255, 255, 255, 0.04),
                rgba(255, 255, 255, 0.02)
            );
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);

            box-shadow: 0 10px 40px rgba(2, 6, 23, 0.45);
            border: 1px solid rgba(255, 255, 255, 0.03);

            z-index: 4000;
            transition: transform var(--transition),
                        width var(--transition),
                        height var(--transition);
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .header-title {
            font-size: 1rem;
            font-weight: 700;
            color: #e6f3f3;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .header-action {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 10px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.02);
            color: #e6f3f3;
            border: 1px solid rgba(255, 255, 255, 0.02);
            font-weight: 600;
        }

        /* ===========================
           Page Wrapper
        =========================== */
        .page-wrap {
            transition: transform var(--transition),
                        margin var(--transition);
            transform: translateX(var(--content-offset));
            padding: 18px;
            min-height: calc(100vh - 120px);
            display: flex;
            justify-content: center;
        }

        html.sidebar-open {
            --content-offset: var(--sidebar-width);
        }

        /* ===========================
           Invoice Box
        =========================== */
        .invoice-box {
            max-width: 1200px;
            width: 100%;
            background: var(--bg-1);
            border-radius: 14px;
            padding: 18px;
            box-shadow: var(--elev-2);
            border: 1px solid rgba(15, 23, 42, 0.04);
        }

        .invoice-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
            flex-wrap: wrap;
        }

        .org-title {
            font-size: 1.05rem;
            font-weight: 700;
        }

        /* ===========================
           Tables
        =========================== */
        .table thead th {
            background: #fbfcfe;
            border-bottom: 1px solid rgba(15, 23, 42, 0.04);
            font-weight: 700;
            font-size: 0.88rem;
        }

        .table tbody td {
            vertical-align: middle;
            font-size: 0.92rem;
        }

        /* ===========================
           Totals
        =========================== */
        .total-box {
            margin-top: 18px;
            text-align: right;
            font-size: 0.98rem;
        }

        .total-box .value {
            font-weight: 800;
            font-size: 1.25rem;
        }

        /* ===========================
           Loader
        =========================== */
        #loader {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.36);
            z-index: 4200;
            align-items: center;
            justify-content: center;
        }

        #loader .box {
            background: #fff;
            padding: 18px 22px;
            border-radius: 10px;
            box-shadow: var(--elev-2);
        }

        /* ===========================
           Media Queries
        =========================== */
        @media (max-width: 480px) {
            .app-header {
                height: var(--header-compact);
                padding: 6px 10px;
            }

            body {
                padding-top: calc(
                    var(--header-compact)
                    + env(safe-area-inset-top, 0px)
                    + 8px
                );
            }

            html.sidebar-open {
                --content-offset: 220px;
            }

            .invoice-box {
                padding: 12px;
            }
        }

        @media (min-width: 768px) {
            .page-wrap {
                justify-content: flex-start;
                padding-left: 40px;
            }
        }

        @media (min-width: 992px) {
            .page-wrap {
                padding-left: 60px;
            }

            .invoice-box {
                width: 140%;
            }
        }

        @media print {
            .app-header,
            .btn {
                display: none !important;
            }

            .invoice-box {
                box-shadow: none;
                border: none;
            }
        }
    </style>

</head>
<body>

<!-- ===========================
     Floating Header
=========================== -->
<header class="app-header"
        role="banner"
        aria-label="Application header">

    <div class="header-left">
        <div class="header-title">
            Sales Entry
        </div>
    </div>

    <div class="header-right">
        <div class="header-action"
             title="Organization">
            <i class="bi bi-building"
               style="font-size:1rem; color:#e6f3f3;"></i>
            <span style="color:#e6f3f3; margin-left:6px;">
                <%= orgName %>
            </span>
        </div>
    </div>
</header>

<!-- Sidebar -->
<%@ include file="sidebar.jsp" %>

<!-- ===========================
     Page Content
=========================== -->
<div class="page-wrap"
     id="pageWrap"
     role="main"
     aria-labelledby="pageTitle">

    <main class="container-main"
          role="main"
          aria-labelledby="pageTitle">

        <div class="invoice-box"
             role="region"
             aria-label="Sales Invoice">

            <!-- Invoice Header -->
            <div class="invoice-head"
                 id="pageTitle">

                <div>
                    <div class="org-title">
                        <%= orgName %>
                    </div>
                    <div class="text-muted-sm">
                        Sales Invoice
                    </div>
                </div>

                <div class="text-end">
                    <div class="invoice-type">
                        Date:
                        <strong id="invoice-date"></strong>
                    </div>
                </div>
            </div>

            <!-- ===========================
                 Bill To + Product Selector
            =========================== -->
            <div class="row g-3">

                <!-- Bill To -->
                <div class="col-12 col-md-6">
                    <div class="border-dashed">

                        <div class="fw-semibold mb-2">
                            Bill To
                        </div>

                        <input type="text"
                               class="form-control mb-2"
                               id="cust-name"
                               placeholder="Customer Name"
                               aria-label="Customer name">

                        <input type="text"
                               class="form-control mb-2"
                               id="cust-address"
                               placeholder="Address"
                               aria-label="Customer address">

                        <input type="text"
                               class="form-control mb-2"
                               id="cust-phone"
                               placeholder="Phone / GSTIN"
                               aria-label="Customer phone or GSTIN">
                    </div>
                </div>

                <!-- Product Select -->
                <div class="col-12 col-md-6">

                    <label class="form-label fw-semibold">
                        Select Product
                    </label>

                    <select id="manual-product"
                            class="form-select"
                            style="width:100%">

                        <%
                            if (productList != null) {
                                for (Map<String, Object> p : productList) {

                                    String name   = p.get("name")   != null ? p.get("name").toString()   : "";
                                    String rate   = p.get("rate")   != null ? p.get("rate").toString()   : "0";
                                    String uom    = p.get("uom")    != null ? p.get("uom").toString()    : "";
                                    String prodId = p.get("prodId") != null ? p.get("prodId").toString() : "0";
                                    String search = p.get("value")  != null ? p.get("value").toString()  : "";
                        %>

                        <option value="<%= name %>|<%= rate %>|<%= uom %>"
                                data-prodid="<%= prodId %>"
                                data-search="<%= search %>">

                            <%= search %>
                            -
                            <%= name %>
                            -
                            ₹<%= rate %> / <%= uom %>

                        </option>

                        <%
                                }
                            }
                        %>
                    </select>
                </div>
            </div>

            <!-- ===========================
                 Items Table
            =========================== -->
            <div class="table-responsive mt-3">

                <table class="table table-sm table-bordered align-middle"
                       id="items-table"
                       role="table"
                       aria-label="Invoice items">

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

                    <tbody id="items-body"
                           aria-live="polite">
                    </tbody>

                </table>
            </div>

            <!-- ===========================
                 Totals Section
            =========================== -->
            <div class="mt-4 text-end total-box">

                <div class="mt-2">
                    Discount:
                    <input type="number"
                           id="discount"
                           class="form-control form-control-sm d-inline-block"
                           style="width:120px;"
                           value="0">
                </div>

                <div class="mt-2">
                    Cash:
                    <input type="number"
                           id="cash"
                           class="form-control form-control-sm d-inline-block"
                           style="width:120px;"
                           value="0">
                </div>

                <div class="mt-2">
                    UPI:
                    <input type="number"
                           id="upi"
                           class="form-control form-control-sm d-inline-block"
                           style="width:120px;"
                           value="0">
                </div>
				<div class="mt-2">
                    Balance Cash:
                    ₹<span id="ReCash">0.00</span>
                </div>
                <div class="mt-2">
                    Subtotal:
                    ₹<span id="subtotal">0.00</span>
                </div>

                <div class="mt-2">
                    Total:
                    ₹<strong id="grand-total">0.00</strong>
                </div>
            </div>

            <!-- ===========================
                 Action Buttons
            =========================== -->
            <div class="text-end mt-3">
                <button id="recalculate"
                        class="btn btn-primary btn-sm">
                    Recalculate
                </button>

                <button id="send-btn"
                        class="btn btn-success btn-sm">
                    Send
                </button>
            </div>

        </div>

        <!-- Footer -->
        <div class="page-footer">
            © <%= java.time.Year.now().getValue() %> <%= orgName %>
        </div>

    </main>
</div>

<!-- ===========================
     Loader
=========================== -->
<div id="loader"
     role="status"
     aria-hidden="true">

    <div class="box">
        Please wait... Processing
    </div>
</div>

<!-- ===========================
     Alerts
=========================== -->
<div class="position-fixed top-3 end-3"
     style="z-index:5050; pointer-events:none;">

    <div id="alertBox"
         style="pointer-events:auto;">
    </div>
</div>
<!-- ===========================
     Scripts
=========================== -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
$(function () {

    /* ===========================
       Select2 Product Dropdown
    =========================== */
    $("#manual-product").select2({
        placeholder: "--Select Product--",
        width: "100%",
        allowClear: true,
        dropdownParent: $('body'),
        dropdownCssClass: "select2-dropdown-full-width",
        matcher: function (params, data) {
            if (!params.term) return data;

            const term = params.term.toLowerCase();
            const text = (data.text || "").toLowerCase();
            const sKey = ($(data.element).data("search") || "").toLowerCase();

            return (text.includes(term) || sKey.includes(term))
                ? data
                : null;
        }
    });

    /* ===========================
       Sidebar Toggle Logic
    =========================== */
    const toggleBtn = document.getElementById('sidebarToggle');
    const htmlEl = document.documentElement;
    const STORAGE_KEY = 'sidebarOpenVijay_purchase';

    const isOpen = localStorage.getItem(STORAGE_KEY) === '1';

    if (isOpen && toggleBtn) {
        htmlEl.classList.add('sidebar-open');
        toggleBtn.setAttribute('aria-expanded', 'true');
    }

    function setSidebarOpen(open) {

        if (!toggleBtn) return;

        if (open) {
            htmlEl.classList.add('sidebar-open');
            toggleBtn.setAttribute('aria-expanded', 'true');
            localStorage.setItem(STORAGE_KEY, '1');
        } else {
            htmlEl.classList.remove('sidebar-open');
            toggleBtn.setAttribute('aria-expanded', 'false');
            localStorage.setItem(STORAGE_KEY, '0');
        }

        document.documentElement.style.setProperty(
            '--content-offset',
            open
                ? getComputedStyle(document.documentElement)
                      .getPropertyValue('--sidebar-width')
                : '0px'
        );
    }

    if (toggleBtn) {
        toggleBtn.addEventListener('click', function (e) {
            e.preventDefault();
            setSidebarOpen(!htmlEl.classList.contains('sidebar-open'));
        });
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && htmlEl.classList.contains('sidebar-open')) {
            setSidebarOpen(false);
        }
    });

    document.addEventListener('click', function (e) {
        if (
            window.innerWidth < 800 &&
            htmlEl.classList.contains('sidebar-open') &&
            !e.target.closest('.app-header') &&
            !e.target.closest('.app-sidebar')
        ) {
            setSidebarOpen(false);
        }
    });

    /* ===========================
       Invoice Date
    =========================== */
    document.getElementById("invoice-date").textContent =
        new Date().toLocaleDateString("en-GB");

    /* ===========================
       Add Item Row
    =========================== */
    function addRow(Id, name, unit, qty, rate) {

        const tr = document.createElement('tr');

        const tdIndex  = document.createElement('td');
        const tdDesc   = document.createElement('td');
        const tdUom    = document.createElement('td');
        const tdQty    = document.createElement('td');
        const tdRate   = document.createElement('td');
        const tdAmount = document.createElement('td');
        const tdAction = document.createElement('td');

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

        btnRemove.addEventListener('click', function () {
            tr.remove();
            recalc();
        });

        inputQty.addEventListener('input', updateRowAmount);
        inputRate.addEventListener('input', updateRowAmount);

        updateRowAmount();
    }

    /* ===========================
       Recalculate Totals
    =========================== */
    function recalc() {

        let subtotal = 0;

        $("#items-body tr").each(function (i) {

            $(this).find("td:first").text(i + 1);

            const qty  = parseFloat($(this).find(".qty").val())  || 0;
            const rate = parseFloat($(this).find(".rate").val()) || 0;
            const amt  = qty * rate;

            $(this).find(".amount").text(amt.toFixed(2));
            subtotal += amt;
        });

        $("#subtotal").text(subtotal.toFixed(2));

        const discount = parseFloat($("#discount").val()) || 0;
        let total = subtotal - discount;

        if (total < 0) total = 0;

        $("#grand-total").text(total.toFixed(2));
        updateBalanceCash();
    }
    
    /*  ==========================
    Balance Cash Function
    =========================== */
    function updateBalanceCash() {

        const total = parseFloat($("#grand-total").text()) || 0;
        const cash  = parseFloat($("#cash").val()) || 0;
        const upi   = parseFloat($("#upi").val()) || 0;

        let balance = total - (cash + upi);
        if (balance < 0) balance = 0;

        $("#ReCash").text(balance.toFixed(2));
    }

    $("#discount").on("input", recalc);
    $("#cash, #upi").on("input", updateBalanceCash);

    $("#discount").on("input", recalc);
    $("#recalculate").on("click", recalc);

    /* ===========================
       Product Select Change
    =========================== */
    $("#manual-product").on("change", function () {

        const val = this.value;
        if (!val) return;

        const parts = val.split("|");
        const name  = parts[0];
        const rate  = parseFloat(parts[1]) || 0;
        const unit  = parts[2];

        const prodId = $(this).find(":selected").data("prodid") || "0";

        const exist = [...document.querySelectorAll("#items-body tr")]
            .find(row =>
                row.querySelector(".desc")
                   .value
                   .trim()
                   .toLowerCase() === name.toLowerCase()
            );

        if (exist) {
            const q = exist.querySelector(".qty");
            q.value = (parseFloat(q.value) || 0) + 1;
            recalc();
        } else {
            addRow(prodId, name, unit, 1, rate);
        }

        $(this).val("").trigger("change");
    });

    /* ===========================
       Alert Helper
    =========================== */
    function showAlert(type, message) {

        const alertHTML =
            '<div class="alert alert-' + type +
            ' alert-dismissible fade show" role="alert">' +
            message +
            '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
            '</div>';

        $("#alertBox").html(alertHTML);
    }

    /* ===========================
       Send / Save via AJAX
    =========================== */
    $("#send-btn").on("click", function () {

        $("#loader")
            .css("display", "flex")
            .attr("aria-hidden", "false");

        const data = {
            discount: parseFloat($("#discount").val()) || 0,
            subtotal: $("#subtotal").text(),
            total: $("#grand-total").text(),
            customer: {
                name: $("#cust-name").val(),
                address: $("#cust-address").val(),
                phone: $("#cust-phone").val()
            },
            items: $("#items-body tr").map(function () {

                const $r = $(this);

                return {
                    prodId: $r.find(".ProdId").val(),
                    product: $r.find(".desc").val(),
                    unit: $r.find(".uom").val(),
                    qty: parseFloat($r.find(".qty").val()) || 0,
                    rate: parseFloat($r.find(".rate").val()) || 0,
                    amount: parseFloat($r.find(".amount").text()) || 0
                };
            }).get()
        };

        $.ajax({
            type: "POST",
            url: "<%= request.getContextPath() %>/SalesSaveServlet",
            data: JSON.stringify({ salesData: data }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",

            success: function (response) {

                $("#loader").hide().attr("aria-hidden", "true");

                if (!response) {
                    showAlert('danger', 'Empty response from server');
                    return;
                }

                if (response.status === "success") {

                    if (response.pdfUrl) {
                        window.open(response.pdfUrl, "_blank");
                        showAlert('success', 'Invoice generated successfully.');
                    } else if (response.fileName) {
                        const fallback =
                            "<%= request.getContextPath() %>/invoices/" +
                            encodeURIComponent(response.fileName);
                        window.open(fallback, "_blank");
                        showAlert('success', 'Invoice generated (fallback).');
                    } else {
                        showAlert('success', 'Saved successfully.');
                    }

                } else {
                    showAlert('danger', response.error || response.message);
                }
            },

            error: function (xhr, status, error) {

                $("#loader").hide().attr("aria-hidden", "true");

                const errMsg =
                    xhr.responseJSON && xhr.responseJSON.error
                        ? xhr.responseJSON.error
                        : (xhr.responseText || error);

                showAlert('danger', 'Server error: ' + errMsg);
                console.error("AJAX Error:", error, xhr);
            }
        });
    });

});
</script>
</body>
</html>
