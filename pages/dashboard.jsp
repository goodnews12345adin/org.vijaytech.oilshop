<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%@ page import="java.sql.*, javax.naming.*, javax.sql.DataSource" %>

<%
    // ===================== KPI VARIABLES =====================
    Long todaySalesCount       = null;
    Long todayPurchaseCount    = null;
    Long pendingBillingCount   = null;
    Long shippedCount          = null;
    Long weeklySalesCount      = null;
    Long weeklyPurchaseCount   = null;
    Long monthlySalesCount     = null;
    Long monthlyPurchaseCount  = null;

    Double todaySalesAmount      = null;
    Double todayPurchaseAmount   = null;
    Double weeklySalesAmount     = null;
    Double weeklyPurchaseAmount  = null;
    Double monthlySalesAmount    = null;
    Double monthlyPurchaseAmount = null;

    Double todayExpenseAmount    = null;
    Double weeklyExpenseAmount   = null;
    Double monthlyExpenseAmount  = null;

    // ===================== STRING SQL QUERIES =====================

    // ---- COUNT KPIs ----
    String SQL_TODAY_SALES_COUNT =
        "SELECT COUNT(*) FROM SALES_ORDER WHERE DATE(order_date) = CURRENT_DATE";

    String SQL_TODAY_PURCHASE_COUNT =
        "SELECT COUNT(*) FROM PURCHASE_ORDER WHERE DATE(purchase_date) = CURRENT_DATE";

    String SQL_PENDING_BILLING_COUNT =
        "SELECT COUNT(*) FROM SALES_ORDER " +
        "WHERE status = 'Pending Billing' AND DATE(order_date) = CURRENT_DATE";

    String SQL_SHIPPED_COUNT =
        "SELECT COUNT(*) FROM SALES_ORDER " +
        "WHERE status = 'Shipped' AND DATE(order_date) = CURRENT_DATE";

    String SQL_WEEKLY_SALES_COUNT =
        "SELECT COUNT(*) FROM SALES_ORDER " +
        "WHERE YEARWEEK(order_date, 1) = YEARWEEK(CURRENT_DATE, 1)";

    String SQL_WEEKLY_PURCHASE_COUNT =
        "SELECT COUNT(*) FROM PURCHASE_ORDER " +
        "WHERE YEARWEEK(purchase_date, 1) = YEARWEEK(CURRENT_DATE, 1)";

    String SQL_MONTHLY_SALES_COUNT =
        "SELECT COUNT(*) FROM SALES_ORDER " +
        "WHERE MONTH(order_date) = MONTH(CURRENT_DATE) " +
        "AND YEAR(order_date) = YEAR(CURRENT_DATE)";

    String SQL_MONTHLY_PURCHASE_COUNT =
        "SELECT COUNT(*) FROM PURCHASE_ORDER " +
        "WHERE MONTH(purchase_date) = MONTH(CURRENT_DATE) " +
        "AND YEAR(purchase_date) = YEAR(CURRENT_DATE)";

    // ---- AMOUNT KPIs (Sales / Purchase) ----
    String SQL_TODAY_SALES_AMOUNT =
        "SELECT SUM(total_amount) FROM SALES_ORDER " +
        "WHERE DATE(order_date) = CURRENT_DATE";

    String SQL_TODAY_PURCHASE_AMOUNT =
        "SELECT SUM(total_amount) FROM PURCHASE_ORDER " +
        "WHERE DATE(purchase_date) = CURRENT_DATE";

    String SQL_WEEKLY_SALES_AMOUNT =
        "SELECT SUM(total_amount) FROM SALES_ORDER " +
        "WHERE YEARWEEK(order_date, 1) = YEARWEEK(CURRENT_DATE, 1)";

    String SQL_WEEKLY_PURCHASE_AMOUNT =
        "SELECT SUM(total_amount) FROM PURCHASE_ORDER " +
        "WHERE YEARWEEK(purchase_date, 1) = YEARWEEK(CURRENT_DATE, 1)";

    String SQL_MONTHLY_SALES_AMOUNT =
        "SELECT SUM(total_amount) FROM SALES_ORDER " +
        "WHERE MONTH(order_date) = MONTH(CURRENT_DATE) " +
        "AND YEAR(order_date) = YEAR(CURRENT_DATE)";

    String SQL_MONTHLY_PURCHASE_AMOUNT =
        "SELECT SUM(total_amount) FROM PURCHASE_ORDER " +
        "WHERE MONTH(purchase_date) = MONTH(CURRENT_DATE) " +
        "AND YEAR(purchase_date) = YEAR(CURRENT_DATE)";

    // ---- EXPENSE KPIs ----
    String SQL_TODAY_EXPENSE_AMOUNT =
        "SELECT SUM(amount) FROM EXPENSES " +
        "WHERE DATE(expense_date) = CURRENT_DATE";

    String SQL_WEEKLY_EXPENSE_AMOUNT =
        "SELECT SUM(amount) FROM EXPENSES " +
        "WHERE YEARWEEK(expense_date, 1) = YEARWEEK(CURRENT_DATE, 1)";

    String SQL_MONTHLY_EXPENSE_AMOUNT =
        "SELECT SUM(amount) FROM EXPENSES " +
        "WHERE MONTH(expense_date) = MONTH(CURRENT_DATE) " +
        "AND YEAR(expense_date) = YEAR(CURRENT_DATE)";

    // ===================== DB EXECUTION (ONLY JSP + STRING QUERIES) =====================
    try {
        InitialContext ic = new InitialContext();
        DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/textile_db");

        try (Connection conn = ds.getConnection()) {

            // ============== COUNT KPIs ==============

            // todaySalesCount - Today's Sales Count
            try (PreparedStatement ps = conn.prepareStatement(SQL_TODAY_SALES_COUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) todaySalesCount = rs.getLong(1);
            }

            // todayPurchaseCount - Today's Purchase Count
            try (PreparedStatement ps = conn.prepareStatement(SQL_TODAY_PURCHASE_COUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) todayPurchaseCount = rs.getLong(1);
            }

            // pendingBillingCount - Pending Billing (Count)
            try (PreparedStatement ps = conn.prepareStatement(SQL_PENDING_BILLING_COUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) pendingBillingCount = rs.getLong(1);
            }

            // shippedCount - Shipped (Count)
            try (PreparedStatement ps = conn.prepareStatement(SQL_SHIPPED_COUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) shippedCount = rs.getLong(1);
            }

            // weeklySalesCount - Weekly Sales Count
            try (PreparedStatement ps = conn.prepareStatement(SQL_WEEKLY_SALES_COUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) weeklySalesCount = rs.getLong(1);
            }

            // weeklyPurchaseCount - Weekly Purchase Count
            try (PreparedStatement ps = conn.prepareStatement(SQL_WEEKLY_PURCHASE_COUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) weeklyPurchaseCount = rs.getLong(1);
            }

            // monthlySalesCount - Monthly Sales Count
            try (PreparedStatement ps = conn.prepareStatement(SQL_MONTHLY_SALES_COUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) monthlySalesCount = rs.getLong(1);
            }

            // monthlyPurchaseCount - Monthly Purchase Count
            try (PreparedStatement ps = conn.prepareStatement(SQL_MONTHLY_PURCHASE_COUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) monthlyPurchaseCount = rs.getLong(1);
            }

            // ============== AMOUNT KPIs (Sales / Purchase) ==============

            // todaySalesAmount - Today's Sales Amount
            try (PreparedStatement ps = conn.prepareStatement(SQL_TODAY_SALES_AMOUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    todaySalesAmount = rs.getDouble(1);
                    if (rs.wasNull()) todaySalesAmount = null;
                }
            }

            // todayPurchaseAmount - Today's Purchase Amount
            try (PreparedStatement ps = conn.prepareStatement(SQL_TODAY_PURCHASE_AMOUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    todayPurchaseAmount = rs.getDouble(1);
                    if (rs.wasNull()) todayPurchaseAmount = null;
                }
            }

            // weeklySalesAmount - Weekly Sales Amount
            try (PreparedStatement ps = conn.prepareStatement(SQL_WEEKLY_SALES_AMOUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    weeklySalesAmount = rs.getDouble(1);
                    if (rs.wasNull()) weeklySalesAmount = null;
                }
            }

            // weeklyPurchaseAmount - Weekly Purchase Amount
            try (PreparedStatement ps = conn.prepareStatement(SQL_WEEKLY_PURCHASE_AMOUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    weeklyPurchaseAmount = rs.getDouble(1);
                    if (rs.wasNull()) weeklyPurchaseAmount = null;
                }
            }

            // monthlySalesAmount - Monthly Sales Amount
            try (PreparedStatement ps = conn.prepareStatement(SQL_MONTHLY_SALES_AMOUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    monthlySalesAmount = rs.getDouble(1);
                    if (rs.wasNull()) monthlySalesAmount = null;
                }
            }

            // monthlyPurchaseAmount - Monthly Purchase Amount
            try (PreparedStatement ps = conn.prepareStatement(SQL_MONTHLY_PURCHASE_AMOUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    monthlyPurchaseAmount = rs.getDouble(1);
                    if (rs.wasNull()) monthlyPurchaseAmount = null;
                }
            }

            // ============== EXPENSE KPIs ==============

            // todayExpenseAmount - Today's Expense
            try (PreparedStatement ps = conn.prepareStatement(SQL_TODAY_EXPENSE_AMOUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    todayExpenseAmount = rs.getDouble(1);
                    if (rs.wasNull()) todayExpenseAmount = null;
                }
            }

            // weeklyExpenseAmount - Current Week's Expense
            try (PreparedStatement ps = conn.prepareStatement(SQL_WEEKLY_EXPENSE_AMOUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    weeklyExpenseAmount = rs.getDouble(1);
                    if (rs.wasNull()) weeklyExpenseAmount = null;
                }
            }

            // monthlyExpenseAmount - Current Month's Expense
            try (PreparedStatement ps = conn.prepareStatement(SQL_MONTHLY_EXPENSE_AMOUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    monthlyExpenseAmount = rs.getDouble(1);
                    if (rs.wasNull()) monthlyExpenseAmount = null;
                }
            }

        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    // ===================== EXPOSE AS REQUEST ATTRIBUTES =====================
    request.setAttribute("todaySalesCount", todaySalesCount);
    request.setAttribute("todayPurchaseCount", todayPurchaseCount);
    request.setAttribute("pendingBillingCount", pendingBillingCount);
    request.setAttribute("shippedCount", shippedCount);
    request.setAttribute("weeklySalesCount", weeklySalesCount);
    request.setAttribute("weeklyPurchaseCount", weeklyPurchaseCount);
    request.setAttribute("monthlySalesCount", monthlySalesCount);
    request.setAttribute("monthlyPurchaseCount", monthlyPurchaseCount);

    request.setAttribute("todaySalesAmount", todaySalesAmount);
    request.setAttribute("todayPurchaseAmount", todayPurchaseAmount);
    request.setAttribute("weeklySalesAmount", weeklySalesAmount);
    request.setAttribute("weeklyPurchaseAmount", weeklyPurchaseAmount);
    request.setAttribute("monthlySalesAmount", monthlySalesAmount);
    request.setAttribute("monthlyPurchaseAmount", monthlyPurchaseAmount);

    request.setAttribute("todayExpenseAmount", todayExpenseAmount);
    request.setAttribute("weeklyExpenseAmount", weeklyExpenseAmount);
    request.setAttribute("monthlyExpenseAmount", monthlyExpenseAmount);
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <title>Dashboard | Vijay Tech</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        /* ========= GLOBAL VARIABLES & THEME ========= */
        :root{
            --sidebar-width: 260px;
            --navbar-height: 64px;

            --outer-frame:#c7c6dc;
            --bg-1:#f3f4f6;
            --bg-2:#eef2f6;
            --panel-dark:#08143a;
            --panel-dark-2:#09184b;
            --accent-a:#19b6b0;
            --accent-b:#15a0c6;
            --accent-c:#3bd0c3;
            --muted-light:rgba(255,255,255,0.86);
            --muted:#9aa6c3;
            --card-radius:14px;
            --outer-radius:18px;
            --success:#16a34a;
            --danger:#ef4444;
            --focus-shadow:0 10px 30px rgba(0,0,0,0.35);
            --panel-border:rgba(255,255,255,0.03);

            --kpi-number:#19b6b0;
            --kpi-purchase:#ffc107; /* New color for purchase KPIs */
            --kpi-expense:#ef4444; /* New color for expense KPIs */
        }

        * { box-sizing: border-box; }
        html, body { height: 100%; }

        /* ========= BODY BACKGROUND ========= */
        body {
            margin: 0;
            padding: 0;
            padding-top: var(--navbar-height); /* space for fixed header */
            font-family: 'Poppins', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            color: #fff;

            background:
                radial-gradient(ellipse at center,
                    rgba(8, 20, 58, 0.6),
                    rgba(3, 10, 28, 0.9)
                ),
                url('/textileapp/pages/img/bg-textile.jpg')
                center / cover no-repeat fixed;

            overflow-x: auto;
            scrollbar-gutter: stable;
        }

        /* ========= TOP NAVBAR (HEADER) ========= */
        .app-navbar {
            background: linear-gradient(180deg, var(--panel-dark), var(--panel-dark-2));
            border-bottom: 1px solid rgba(255,255,255,0.06);
            box-shadow: 0 8px 30px rgba(2,6,23,0.45);
            z-index: 3000;
        }

        .navbar-brand {
            display: inline-flex;
            align-items: center;
            gap: .5rem;
            color: var(--muted-light) !important;
        }

        .navbar-brand i {
            color: var(--accent-a);
            font-size: 1.15rem;
            text-shadow: 0 4px 18px rgba(25,182,176,0.25);
        }

        .navbar-toggler {
            border-color: rgba(255,255,255,0.15);
        }
        .navbar-toggler-icon {
            filter: invert(1) brightness(1.1);
        }

        .btn-header-logout {
            border-radius: 999px;
            border: none;
            padding-inline: 15px;
            background: linear-gradient(90deg, var(--accent-a), var(--accent-b));
            color: #0b1724;
            font-weight: 600;
            box-shadow: 0 10px 30px rgba(0,0,0,0.25);
        }
        .btn-header-logout:hover {
            filter: brightness(1.05);
            transform: translateY(-1px);
        }

        /* ========= SIDEBAR AREA ========= */
        .app-sidebar {
            position: fixed;
            left: 0;
            top: var(--navbar-height);
            bottom: 0;
            width: var(--sidebar-width);
            background: linear-gradient(180deg,#041b33 0%, #07223a 100%);
            color: #bfe7ea;
            padding: 24px 18px;
            overflow-y: auto;
            z-index: 2000;
            box-shadow: 2px 0 40px rgba(0,0,0,0.45);
        }

        .app-sidebar * { box-sizing: border-box; }

        /* ========= MAIN CONTENT ALIGNMENT ========= */
        main.main {
            margin-left: 0;
            padding: 24px 26px 110px; /* bottom padding so content not hidden by footer */
            min-height: calc(100vh - var(--navbar-height));
            width:100%;
        }

        /* Center big dashboard inside main */
        .dashboard-outer-wrapper {
            max-width: 1320px;
            margin: 0 auto;
            margin-top: -75px;
            
        }

        @media (max-width: 992px) {
            .app-sidebar {
                position: relative;
                width: 100%;
                top: 0;
                height: auto;
                box-shadow: none;
            }
            main.main {
                margin-left: 0;
                padding: 16px 14px 110px;
            }
        }

        /* ========= DASHBOARD PANEL ========= */
        .dashboard-outer {
            width: 100%;
            border-radius: var(--outer-radius);
            padding: 18px;
            background: linear-gradient(180deg,
                rgba(255,255,255,0.03),
                rgba(255,255,255,0.015));
            border: 1px solid rgba(255,255,255,0.12);
            box-shadow:
                inset 0 0 80px rgba(0,0,0,0.35),
                0 22px 40px rgba(0,0,0,0.55);
            backdrop-filter: blur(10px);
        }

        /* Top pill inside dashboard */
        .dashboard-top-pill {
            background: linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0.02));
            border-radius: 16px;
            padding: 12px 18px;
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom: 18px;
            border: 1px solid rgba(255,255,255,0.14);
            box-shadow: 0 10px 30px rgba(2,6,23,0.6);
        }
        .dashboard-top-pill h5 {
            margin:0;
            color:#e6eef2;
            font-weight:600;
            letter-spacing: 0.02em;
        }

        .dashboard-inner {
            background: linear-gradient(180deg, rgba(255,255,255,0.03), rgba(255,255,255,0.015));
            border-radius: 14px;
            padding: 24px;
            border: 1px solid rgba(255,255,255,0.08);
        }

        /* ========= KPI CARDS ========= */
        .kpi-row {
            display:flex;
            gap: 20px;
            margin-bottom: 22px;
        }

        .kpi {
            background: #ffffff;
            border-radius: 12px;
            padding: 16px 20px;
            flex:1;
            min-height:90px;
            display:flex;
            flex-direction:column;
            justify-content:space-between;
            box-shadow: 0 14px 38px rgba(15,23,42,0.18);
            color: #10323a;
            position: relative;
            overflow: hidden;
        }
        /* Custom styles for different KPI types */
        .kpi.sales::after{
            content:"";
            position:absolute;
            inset:0;
            background: radial-gradient(circle at top right,
                            rgba(25,182,176,0.14),
                            transparent 55%);
            pointer-events:none;
        }
        .kpi.purchase {
            /* Inherits default background/shadow */
        }
        .kpi.purchase::after{
            content:"";
            position:absolute;
            inset:0;
            background: radial-gradient(circle at top right,
                            rgba(255,193,7,0.14),
                            transparent 55%);
            pointer-events:none;
        }
        .kpi.expense {
            /* Inherits default background/shadow */
        }
        .kpi.expense::after{
            content:"";
            position:absolute;
            inset:0;
            background: radial-gradient(circle at top right,
                            rgba(239,68,68,0.14),
                            transparent 55%);
            pointer-events:none;
        }
        .kpi.sales .kpi-number { color: var(--kpi-number); }
        .kpi.purchase .kpi-number { color: var(--kpi-purchase); }
        .kpi.expense .kpi-number { color: var(--kpi-expense); }

        .kpi .kpi-title {
            font-weight:700;
            color: #1f2933;
            font-size: 0.96rem;
            letter-spacing: 0.02em;
        }
        .kpi .kpi-number {
            font-size: 2.4rem;
            font-weight:800;
            margin-top:6px;
            line-height: 1.05;
        }
        .kpi .kpi-sub {
            font-size: 0.75rem;
            color:#6b7a89;
        }

        @media (max-width: 768px) {
            .kpi-row { flex-direction:column; gap: 12px; }
        }

        /* New layout for the table and expenses card */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
        }
        @media (max-width: 992px) {
            .dashboard-grid {
                grid-template-columns: 1fr; /* Stack on smaller screens */
            }
        }

        /* ========= RECENT ORDERS CARD ========= */
        .orders-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 18px 18px 14px;
            margin-top: 12px;
            box-shadow: 0 18px 38px rgba(15,23,42,0.16);
            color: #0d2224;
            position: relative;
        }
        .orders-card .header-wrap {
            position: relative;
            margin-bottom: 6px;
        }
        .orders-card h6 {
            color:#253b3f;
            margin:0;
            font-weight:700;
        }
        .orders-card .subtitle {
            font-size: 0.78rem;
            color:#7a8e93;
        }
        .orders-card .card-tools {
            display:flex;
            gap:8px;
        }

        /* table */
        .table-responsive {
            padding-top: 8px;
        }
        .soft-table thead th {
            color: #104c4a;
            font-weight: 700;
            border-bottom: 1px solid rgba(0,0,0,0.06);
            background: linear-gradient(180deg,#f8fafc,#edf2f7);
            font-size: 0.8rem;
        }
        .soft-table tbody td {
            color: #0e2e30;
            border-top: 1px solid rgba(0,0,0,0.03);
            font-size: 0.82rem;
        }
        .table-hover > tbody > tr:hover {
            background-color: rgba(21,160,198,0.03);
        }

        .badge {
            padding: 6px 10px;
            border-radius: 999px;
            font-weight: 600;
            font-size: 0.72rem;
        }
        .badge.bg-success { background-color: #159a58 !important; }
        .badge.bg-warning { background-color: #ffd43b !important; color:#082025; }
        .badge.bg-info { background-color: #12b6d7 !important; color:#06202b; }

        /* ========= BUTTON STYLES ========= */
        .btn-teal {
            background: linear-gradient(135deg,#19b6b0,#15a0c6);
            color: #fff;
            border:none;
            padding:7px 14px;
            border-radius: 999px;
            font-weight:600;
            font-size:0.8rem;
            box-shadow: 0 12px 26px rgba(21,160,198,0.35);
        }
        .btn-teal:hover { filter: brightness(1.03); }

        .btn-outline-soft {
            border:1px solid rgba(148,163,184,0.38);
            background: transparent;
            color:#64748b;
            border-radius: 999px;
            padding:5px 11px;
            font-size: 0.78rem;
        }
        .btn-outline-soft:hover {
            background: rgba(148,163,184,0.08);
            color:#0f172a;
        }

        /* ========= BOTTOM FOOTER (GLOBAL) ========= */
        .bottom-footer {
            position: fixed;
            left: var(--sidebar-width);
            right: 0;
            bottom: 0;
            height: 64px;
            background:#ffffff;
            display:flex;
            align-items:center;
            justify-content:center;
            box-shadow: 0 -8px 30px rgba(15,23,42,0.2);
            z-index: 2500;
        }
        .footer-inner{
            font-size:0.9rem;
            color:#334155;
            line-height: 1.4;
        }
        .footer-link{
            color: var(--accent-b);
            text-decoration:none;
            font-weight:600;
        }
        .footer-link:hover{ text-decoration:underline; }

        @media (max-width: 992px) {
            .bottom-footer {
                left: 0;
            }
        }

        /* ========= SCROLLBAR ========= */
        ::-webkit-scrollbar { width: 9px; }
        ::-webkit-scrollbar-thumb {
            background: rgba(148,163,184,0.6);
            border-radius: 6px;
        }
    </style>

</head>

<body>

    <%-- Fixed top header (same on every page) --%>
    <%@ include file="header.jsp" %>

    <%-- Sidebar: make sure outer element has class="app-sidebar" in sidebar.jsp --%>
    <%@ include file="sidebar.jsp" %>

    <main class="main">
        <div class="dashboard-outer-wrapper">
            <div class="dashboard-outer">

                <div class="dashboard-top-pill">
                    <div style="display:flex; align-items:center; gap:12px;">
                        <h5>Dashboard </h5>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <span class="btn-outline-soft" style="border-radius:999px; display:inline-flex; align-items:center; gap:6px;">
                            <i class="bi bi-calendar-event"></i>
                            <span>Today</span>
                        </span>
                        <span class="btn-outline-soft" style="display:inline-flex; align-items:center; gap:8px; border-radius:999px;">
                            <i class="bi bi-person-circle"></i>
                            <span style="font-weight:600; color:#e2f3f3;">${sessionScope.user.username != null ? sessionScope.user.username : "admin"}</span>
                        </span>
                    </div>
                </div>

                <div class="dashboard-inner">

                    <%-- Today's Counts (Orders/Sales and Purchases) --%>
                    <div class="kpi-row">
                        <div class="kpi sales">
                            <div class="kpi-title">Today's Sales Count</div>
                            <div class="kpi-number">${todaySalesCount != null ? todaySalesCount : "0"}</div>
                            <div class="kpi-sub">Total orders generated today</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-title">Today's Purchase Count</div>
                            <div class="kpi-number">${todayPurchaseCount != null ? todayPurchaseCount : "0"}</div>
                            <div class="kpi-sub">Materials/items purchased today</div>
                        </div>
                        <div class="kpi sales">
                            <div class="kpi-title">Pending Billing (Count)</div>
                            <div class="kpi-number">${pendingBillingCount != null ? pendingBillingCount : "7"}</div>
                            <div class="kpi-sub">Awaiting customer approval</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-title">Shipped (Count)</div>
                            <div class="kpi-number">${shippedCount != null ? shippedCount : "15"}</div>
                            <div class="kpi-sub">Outbound shipments today</div>
                        </div>
                    </div>
                    
                    <%-- Weekly/Monthly Counts --%>
                    <div class="kpi-row">
                        <div class="kpi sales">
                            <div class="kpi-title">Weekly Sales Count</div>
                            <div class="kpi-number">${weeklySalesCount != null ? weeklySalesCount : "185"}</div>
                            <div class="kpi-sub">Completed sales in current week</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-title">Weekly Purchase Count</div>
                            <div class="kpi-number">${weeklyPurchaseCount != null ? weeklyPurchaseCount : "68"}</div>
                            <div class="kpi-sub">Invoices processed this week</div>
                        </div>
                        <div class="kpi sales">
                            <div class="kpi-title">Monthly Sales Count</div>
                            <div class="kpi-number">${monthlySalesCount != null ? monthlySalesCount : "750"}</div>
                            <div class="kpi-sub">Orders completed this month</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-title">Monthly Purchase Count</div>
                            <div class="kpi-number">${monthlyPurchaseCount != null ? monthlyPurchaseCount : "290"}</div>
                            <div class="kpi-sub">Invoices processed this month</div>
                        </div>
                    </div>
                    
                    <%-- Sales/Purchase Amount KPIs --%>
                    <div class="kpi-row">
                        <div class="kpi sales">
                            <div class="kpi-title">Today's Sales Amount</div>
                            <div class="kpi-number"><span style="font-size:1.8rem;">₹</span> ${todaySalesAmount != null ? String.format("%,.0f", todaySalesAmount) : "1,25,000"}</div>
                            <div class="kpi-sub">Total value of sales today</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-title">Today's Purchase Amount</div>
                            <div class="kpi-number"><span style="font-size:1.8rem;">₹</span> ${todayPurchaseAmount != null ? String.format("%,.0f", todayPurchaseAmount) : "85,000"}</div>
                            <div class="kpi-sub">Total value of procurement today</div>
                        </div>
                        <div class="kpi sales">
                            <div class="kpi-title">Weekly Sales Amount</div>
                            <div class="kpi-number"><span style="font-size:1.8rem;">₹</span> ${weeklySalesAmount != null ? String.format("%,.0f", weeklySalesAmount) : "15,50,000"}</div>
                            <div class="kpi-sub">Total revenue this week</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-title">Weekly Purchase Amount</div>
                            <div class="kpi-number"><span style="font-size:1.8rem;">₹</span> ${weeklyPurchaseAmount != null ? String.format("%,.0f", weeklyPurchaseAmount) : "9,80,000"}</div>
                            <div class="kpi-sub">Total spend this week</div>
                        </div>
                    </div>
                    
                    <%-- Monthly Sales/Purchase Amount --%>
                    <div class="kpi-row">
                        <div class="kpi sales" style="flex:2;">
                            <div class="kpi-title">Monthly Sales Amount</div>
                            <div class="kpi-number"><span style="font-size:1.8rem;">₹</span> ${monthlySalesAmount != null ? String.format("%,.0f", monthlySalesAmount) : "58,00,000"}</div>
                            <div class="kpi-sub">Total revenue generated in the current month</div>
                        </div>
                        <div class="kpi purchase" style="flex:2;">
                            <div class="kpi-title">Monthly Purchase Amount</div>
                            <div class="kpi-number"><span style="font-size:1.8rem;">₹</span> ${monthlyPurchaseAmount != null ? String.format("%,.0f", monthlyPurchaseAmount) : "35,20,000"}</div>
                            <div class="kpi-sub">Total value of all material purchases this month</div>
                        </div>
                    </div>

                    <div class="dashboard-grid">
                        
                        <div class="orders-card" style="margin-top:0;">
                            <div class="header-wrap">
                                <div style="display:flex; align-items:center; justify-content:space-between;">
                                    <div>
                                        <h6>Recent Orders</h6>
                                        <div class="subtitle">Latest movement from your textile customers</div>
                                    </div>
                                    <div class="card-tools">
                                        <button class="btn-outline-soft d-none d-md-inline-flex">
                                            <i class="bi bi-funnel"></i>&nbsp; Filter
                                        </button>
                                        <button class="btn-teal">
                                            <i class="bi bi-plus-lg"></i>&nbsp; New Order
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <div class="table-responsive">
                                <table class="table table-hover align-middle soft-table mb-0">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Customer</th>
                                            <th>Item</th>
                                            <th class="text-center">Qty</th>
                                            <th>Status</th>
                                            <th class="text-end">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>1001</td>
                                            <td>Shri Mills</td>
                                            <td>Cotton Yarn</td>
                                            <td class="text-center">120</td>
                                            <td><span class="badge bg-success">Shipped</span></td>
                                            <td class="text-end">
                                                <button class="btn-outline-soft">View</button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>1002</td>
                                            <td>A1 Textiles</td>
                                            <td>Dyed Fabric</td>
                                            <td class="text-center">60</td>
                                            <td><span class="badge bg-warning">Pending</span></td>
                                            <td class="text-end">
                                                <button class="btn-outline-soft">View</button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>1003</td>
                                            <td>RK Traders</td>
                                            <td>Grey Fabric</td>
                                            <td class="text-center">90</td>
                                            <td><span class="badge bg-info">Processing</span></td>
                                            <td class="text-end">
                                                <button class="btn-outline-soft">View</button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>1004</td>
                                            <td>New Buyer</td>
                                            <td>Printed Fabric</td>
                                            <td class="text-center">150</td>
                                            <td><span class="badge bg-info">Processing</span></td>
                                            <td class="text-end">
                                                <button class="btn-outline-soft">View</button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>1005</td>
                                            <td>Textile Hub</td>
                                            <td>Cotton Yarn</td>
                                            <td class="text-center">200</td>
                                            <td><span class="badge bg-success">Shipped</span></td>
                                            <td class="text-end">
                                                <button class="btn-outline-soft">View</button>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div><div class="orders-card" style="margin-top:0;">
                            <div class="header-wrap">
                                <div style="display:flex; align-items:center; justify-content:space-between;">
                                    <div>
                                        <h6>Daily Expenses</h6>
                                        <div class="subtitle">Quick overview of recent expenditure</div>
                                    </div>
                                    <div class="card-tools">
                                        <button class="btn-outline-soft">
                                            <i class="bi bi-currency-dollar"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            
                            <div style="margin-top: 10px;">
                                <div class="kpi expense" style="padding:12px 16px; margin-bottom: 12px;">
                                    <div class="kpi-title" style="font-size:0.85rem;">Today's Expense</div>
                                    <div class="kpi-number" style="font-size:1.8rem;"><span style="font-size:1.4rem;">₹</span> ${todayExpenseAmount != null ? String.format("%,.0f", todayExpenseAmount) : "15,400"}</div>
                                    <div class="kpi-sub">Total miscellaneous payments</div>
                                </div>
                                <div class="kpi expense" style="padding:12px 16px; margin-bottom: 12px;">
                                    <div class="kpi-title" style="font-size:0.85rem;">Current Week's Expense</div>
                                    <div class="kpi-number" style="font-size:1.8rem;"><span style="font-size:1.4rem;">₹</span> ${weeklyExpenseAmount != null ? String.format("%,.0f", weeklyExpenseAmount) : "85,600"}</div>
                                    <div class="kpi-sub">Total expense for the week</div>
                                </div>
                                <div class="kpi expense" style="padding:12px 16px;">
                                    <div class="kpi-title" style="font-size:0.85rem;">Current Month's Expense</div>
                                    <div class="kpi-number" style="font-size:1.8rem;"><span style="font-size:1.4rem;">₹</span> ${monthlyExpenseAmount != null ? String.format("%,.0f", monthlyExpenseAmount) : "3,20,000"}</div>
                                    <div class="kpi-sub">Total operational expenses this month</div>
                                </div>
                            </div>
                        </div>

                    </div></div></div></div></main>

    <%-- fixed bottom footer, same for all pages --%>
    <%@ include file="footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>

</html>
