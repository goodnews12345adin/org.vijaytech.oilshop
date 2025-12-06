<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%@ page import="org.compiere.util.DB,org.compiere.util.Env,java.math.BigDecimal" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<fmt:setLocale value="en_IN" />

<%
    // ========= Get Client & Org from iDempiere Context =========
    int AD_Client_ID = Env.getAD_Client_ID(Env.getCtx());
    int AD_Org_ID    = Env.getAD_Org_ID(Env.getCtx());

    // Fallback (avoid 0 -> no data)
    if (AD_Client_ID == 0) AD_Client_ID = 1000000;   // change to your client
    if (AD_Org_ID == 0)    AD_Org_ID    = 1000000;   // change to your org

    // ========= KPI Variables =========
    long   todaySalesCount       = 0L;
    long   todayPurchaseCount    = 0L;
    long   weeklySalesCount      = 0L;
    long   weeklyPurchaseCount   = 0L;
    long   monthlySalesCount     = 0L;
    long   monthlyPurchaseCount  = 0L;

    double todaySalesAmount      = 0.0;
    double todayPurchaseAmount   = 0.0;
    double weeklySalesAmount     = 0.0;
    double weeklyPurchaseAmount  = 0.0;
    double monthlySalesAmount    = 0.0;
    double monthlyPurchaseAmount = 0.0;

    double todayExpenseAmount    = 0.0;
    double weeklyExpenseAmount   = 0.0;
    double monthlyExpenseAmount  = 0.0;

    try {
        // ========= Base filters (C_Order) =========
        // Sales = IsSOTrx = 'Y'
        String baseSales =
            " FROM C_Order " +
            "WHERE IsActive='Y' " +
            "AND IsSOTrx='Y' " +
            "AND DocStatus='CO' " +
            "AND AD_Client_ID=" + AD_Client_ID +
            " AND AD_Org_ID=" + AD_Org_ID + " ";

        // Purchase = IsSOTrx = 'N'
        String basePurchase =
            " FROM C_Order " +
            "WHERE IsActive='Y' " +
            "AND IsSOTrx='N' " +
            "AND DocStatus='CO' " +
            "AND AD_Client_ID=" + AD_Client_ID +
            " AND AD_Org_ID=" + AD_Org_ID + " ";

        // ========= COUNT QUERIES =========
        String SQL_TODAY_SALES_COUNT =
            "SELECT COUNT(*) " + baseSales +
            "AND DateOrdered::date = CURRENT_DATE";

        String SQL_TODAY_PURCHASE_COUNT =
            "SELECT COUNT(*) " + basePurchase +
            "AND DateOrdered::date = CURRENT_DATE";

        String SQL_WEEKLY_SALES_COUNT =
            "SELECT COUNT(*) " + baseSales +
            "AND date_trunc('week', DateOrdered) = date_trunc('week', CURRENT_DATE)";

        String SQL_WEEKLY_PURCHASE_COUNT =
            "SELECT COUNT(*) " + basePurchase +
            "AND date_trunc('week', DateOrdered) = date_trunc('week', CURRENT_DATE)";

        String SQL_MONTHLY_SALES_COUNT =
            "SELECT COUNT(*) " + baseSales +
            "AND date_trunc('month', DateOrdered) = date_trunc('month', CURRENT_DATE)";

        String SQL_MONTHLY_PURCHASE_COUNT =
            "SELECT COUNT(*) " + basePurchase +
            "AND date_trunc('month', DateOrdered) = date_trunc('month', CURRENT_DATE)";

        // ========= AMOUNT QUERIES (Sales/Purchase) =========
        String SQL_TODAY_SALES_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + baseSales +
            "AND DateOrdered::date = CURRENT_DATE";

        String SQL_TODAY_PURCHASE_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + basePurchase +
            "AND DateOrdered::date = CURRENT_DATE";

        String SQL_WEEKLY_SALES_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + baseSales +
            "AND date_trunc('week', DateOrdered) = date_trunc('week', CURRENT_DATE)";

        String SQL_WEEKLY_PURCHASE_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + basePurchase +
            "AND date_trunc('week', DateOrdered) = date_trunc('week', CURRENT_DATE)";

        String SQL_MONTHLY_SALES_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + baseSales +
            "AND date_trunc('month', DateOrdered) = date_trunc('month', CURRENT_DATE)";

        String SQL_MONTHLY_PURCHASE_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + basePurchase +
            "AND date_trunc('month', DateOrdered) = date_trunc('month', CURRENT_DATE)";

        // ========= EXPENSE QUERIES (EXPENSES table) =========
        String SQL_TODAY_EXPENSE_AMOUNT =
            "SELECT COALESCE(SUM(amount),0) FROM EXPENSES " +
            "WHERE expense_date::date = CURRENT_DATE";

        String SQL_WEEKLY_EXPENSE_AMOUNT =
            "SELECT COALESCE(SUM(amount),0) FROM EXPENSES " +
            "WHERE date_trunc('week', expense_date) = date_trunc('week', CURRENT_DATE)";

        String SQL_MONTHLY_EXPENSE_AMOUNT =
            "SELECT COALESCE(SUM(amount),0) FROM EXPENSES " +
            "WHERE date_trunc('month', expense_date) = date_trunc('month', CURRENT_DATE)";

        // ===== Optional: log SQLs in console =====
        System.out.println("=== Dashboard SQL (JSP) ===");
        System.out.println("SQL_TODAY_SALES_COUNT      = " + SQL_TODAY_SALES_COUNT);
        System.out.println("SQL_TODAY_PURCHASE_COUNT   = " + SQL_TODAY_PURCHASE_COUNT);
        System.out.println("SQL_WEEKLY_SALES_COUNT     = " + SQL_WEEKLY_SALES_COUNT);
        System.out.println("SQL_WEEKLY_PURCHASE_COUNT  = " + SQL_WEEKLY_PURCHASE_COUNT);
        System.out.println("SQL_MONTHLY_SALES_COUNT    = " + SQL_MONTHLY_SALES_COUNT);
        System.out.println("SQL_MONTHLY_PURCHASE_COUNT = " + SQL_MONTHLY_PURCHASE_COUNT);
        System.out.println("SQL_TODAY_SALES_AMOUNT     = " + SQL_TODAY_SALES_AMOUNT);
        System.out.println("SQL_TODAY_PURCHASE_AMOUNT  = " + SQL_TODAY_PURCHASE_AMOUNT);
        System.out.println("SQL_WEEKLY_SALES_AMOUNT    = " + SQL_WEEKLY_SALES_AMOUNT);
        System.out.println("SQL_WEEKLY_PURCHASE_AMOUNT = " + SQL_WEEKLY_PURCHASE_AMOUNT);
        System.out.println("SQL_MONTHLY_SALES_AMOUNT   = " + SQL_MONTHLY_SALES_AMOUNT);
        System.out.println("SQL_MONTHLY_PURCHASE_AMOUNT= " + SQL_MONTHLY_PURCHASE_AMOUNT);
        System.out.println("SQL_TODAY_EXPENSE_AMOUNT   = " + SQL_TODAY_EXPENSE_AMOUNT);
        System.out.println("SQL_WEEKLY_EXPENSE_AMOUNT  = " + SQL_WEEKLY_EXPENSE_AMOUNT);
        System.out.println("SQL_MONTHLY_EXPENSE_AMOUNT = " + SQL_MONTHLY_EXPENSE_AMOUNT);

        // ========= EXECUTE COUNTS =========
        int iVal;

        iVal = DB.getSQLValue(null, SQL_TODAY_SALES_COUNT);
        todaySalesCount = (iVal > 0) ? iVal : 0;

        iVal = DB.getSQLValue(null, SQL_TODAY_PURCHASE_COUNT);
        todayPurchaseCount = (iVal > 0) ? iVal : 0;

        iVal = DB.getSQLValue(null, SQL_WEEKLY_SALES_COUNT);
        weeklySalesCount = (iVal > 0) ? iVal : 0;

        iVal = DB.getSQLValue(null, SQL_WEEKLY_PURCHASE_COUNT);
        weeklyPurchaseCount = (iVal > 0) ? iVal : 0;

        iVal = DB.getSQLValue(null, SQL_MONTHLY_SALES_COUNT);
        monthlySalesCount = (iVal > 0) ? iVal : 0;

        iVal = DB.getSQLValue(null, SQL_MONTHLY_PURCHASE_COUNT);
        monthlyPurchaseCount = (iVal > 0) ? iVal : 0;

        // ========= EXECUTE AMOUNTS =========
        BigDecimal bd;

        bd = DB.getSQLValueBD(null, SQL_TODAY_SALES_AMOUNT);
        if (bd != null) todaySalesAmount = bd.doubleValue();

        bd = DB.getSQLValueBD(null, SQL_TODAY_PURCHASE_AMOUNT);
        if (bd != null) todayPurchaseAmount = bd.doubleValue();

        bd = DB.getSQLValueBD(null, SQL_WEEKLY_SALES_AMOUNT);
        if (bd != null) weeklySalesAmount = bd.doubleValue();

        bd = DB.getSQLValueBD(null, SQL_WEEKLY_PURCHASE_AMOUNT);
        if (bd != null) weeklyPurchaseAmount = bd.doubleValue();

        bd = DB.getSQLValueBD(null, SQL_MONTHLY_SALES_AMOUNT);
        if (bd != null) monthlySalesAmount = bd.doubleValue();

        bd = DB.getSQLValueBD(null, SQL_MONTHLY_PURCHASE_AMOUNT);
        if (bd != null) monthlyPurchaseAmount = bd.doubleValue();

        // ========= EXECUTE EXPENSES =========
        bd = DB.getSQLValueBD(null, SQL_TODAY_EXPENSE_AMOUNT);
        if (bd != null) todayExpenseAmount = bd.doubleValue();

        bd = DB.getSQLValueBD(null, SQL_WEEKLY_EXPENSE_AMOUNT);
        if (bd != null) weeklyExpenseAmount = bd.doubleValue();

        bd = DB.getSQLValueBD(null, SQL_MONTHLY_EXPENSE_AMOUNT);
        if (bd != null) monthlyExpenseAmount = bd.doubleValue();

        // ===== Log KPI values =====
        System.out.println("=== Dashboard KPI Values (JSP) ===");
        System.out.println("Client: " + AD_Client_ID + "  Org: " + AD_Org_ID);
        System.out.println("todaySalesCount        = " + todaySalesCount);
        System.out.println("todayPurchaseCount     = " + todayPurchaseCount);
        System.out.println("weeklySalesCount       = " + weeklySalesCount);
        System.out.println("weeklyPurchaseCount    = " + weeklyPurchaseCount);
        System.out.println("monthlySalesCount      = " + monthlySalesCount);
        System.out.println("monthlyPurchaseCount   = " + monthlyPurchaseCount);
        System.out.println("todaySalesAmount       = " + todaySalesAmount);
        System.out.println("todayPurchaseAmount    = " + todayPurchaseAmount);
        System.out.println("weeklySalesAmount      = " + weeklySalesAmount);
        System.out.println("weeklyPurchaseAmount   = " + weeklyPurchaseAmount);
        System.out.println("monthlySalesAmount     = " + monthlySalesAmount);
        System.out.println("monthlyPurchaseAmount  = " + monthlyPurchaseAmount);
        System.out.println("todayExpenseAmount     = " + todayExpenseAmount);
        System.out.println("weeklyExpenseAmount    = " + weeklyExpenseAmount);
        System.out.println("monthlyExpenseAmount   = " + monthlyExpenseAmount);
        System.out.println("====================================");

    } catch (Exception e) {
        e.printStackTrace();
    }

    // ========= Expose variables to EL / JSTL =========
    request.setAttribute("todaySalesCount", todaySalesCount);
    request.setAttribute("todayPurchaseCount", todayPurchaseCount);
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
            --kpi-purchase:#ffc107;
            --kpi-expense:#ef4444;
        }

        * { box-sizing: border-box; }
        html, body { height: 100%; }

        body {
            margin: 0;
            padding: 0;
            padding-top: var(--navbar-height);
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

        .navbar-toggler { border-color: rgba(255,255,255,0.15); }
        .navbar-toggler-icon { filter: invert(1) brightness(1.1); }

        .btn-header-logout {
            border-radius: 999px;
            border: none;
            padding-inline: 15px;
            background: linear-gradient(90deg, var(--accent-a), var(--accent-b));
            color: #0b1724;
            font-weight: 600;
            box-shadow: 0 10px 30px rgba(0,0,0,0.25);
        }

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

        main.main {
            margin-left: 0;
            padding: 24px 26px 110px;
            min-height: calc(100vh - var(--navbar-height));
            width:100%;
        }

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

        .kpi-row {
            display:flex;
            gap: 20px;
            margin-bottom: 22px;
        }

        .kpi {
            background: #ffffff;
            border-radius: 12px;
            padding: 18px 20px;
            flex:1;
            min-height:100px;
            display:flex;
            flex-direction:column;
            justify-content:space-between;
            box-shadow: 0 18px 38px rgba(15,23,42,0.18);
            color: #10323a;
            position: relative;
            overflow: hidden;
            border: 1px solid rgba(148, 163, 184, 0.25);
        }

        .kpi.sales::before,
        .kpi.purchase::before {
            content:"";
            position:absolute;
            inset:0;
            opacity:0.85;
            pointer-events:none;
            mix-blend-mode: screen;
        }

        .kpi.sales::before {
            background: radial-gradient(circle at top left, rgba(25,182,176,0.28), transparent 60%);
        }

        .kpi.purchase::before {
            background: radial-gradient(circle at top left, rgba(255,193,7,0.25), transparent 60%);
        }

        .kpi.expense::before {
            background: radial-gradient(circle at top left, rgba(239,68,68,0.25), transparent 60%);
        }

        .kpi-header {
            font-weight:700;
            color:#1f2933;
            font-size:0.95rem;
            letter-spacing:0.03em;
            z-index:1;
        }

        .kpi-number {
            margin-top:6px;
            display:flex;
            align-items:baseline;
            gap:6px;
            z-index:1;
        }
        .kpi-number .currency {
            font-size:1.4rem;
            font-weight:700;
            opacity:0.9;
        }
        .kpi-number .value {
            font-size:2.4rem;
            font-weight:800;
            line-height:1.05;
        }

        .kpi.sales .value { color: var(--kpi-number); }
        .kpi.purchase .value { color: var(--kpi-purchase); }
        .kpi.expense .value { color: var(--kpi-expense); }

        .kpi-sub {
            font-size:0.78rem;
            color:#6b7a89;
            margin-top:4px;
            z-index:1;
        }

        .kpi:hover {
            transform: translateY(-2px);
            box-shadow: 0 24px 46px rgba(15,23,42,0.25);
            transition: all .18s ease-out;
        }

        @media (max-width: 768px) {
            .kpi-row { flex-direction:column; gap: 12px; }
        }

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
            .bottom-footer { left: 0; }
        }

        ::-webkit-scrollbar { width: 9px; }
        ::-webkit-scrollbar-thumb {
            background: rgba(148,163,184,0.6);
            border-radius: 6px;
        }
    </style>

</head>

<body>

    <%@ include file="header.jsp" %>
    <%@ include file="sidebar.jsp" %>

    <main class="main">
        <div class="dashboard-outer-wrapper">
            <div class="dashboard-outer">

                <div class="dashboard-top-pill">
                    <div style="display:flex; align-items:center; gap:12px;">
                        <h5>Dashboard</h5>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <span class="btn-outline-soft" style="border-radius:999px; display:inline-flex; align-items:center; gap:6px;">
                            <i class="bi bi-calendar-event"></i>
                            <span>Today</span>
                        </span>
                        <span class="btn-outline-soft" style="display:inline-flex; align-items:center; gap:8px; border-radius:999px;">
                            <i class="bi bi-person-circle"></i>
                            <span style="font-weight:600; color:#e2f3f3;">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.user and not empty sessionScope.user.username}">
                                        <c:out value="${sessionScope.user.username}" />
                                    </c:when>
                                    <c:otherwise>
                                        admin
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </span>
                    </div>
                </div>

                <div class="dashboard-inner">

                    <!-- Row 1: Today's Counts -->
                    <div class="kpi-row">
                        <div class="kpi sales">
                            <div class="kpi-header">Today's Sales Count</div>
                            <div class="kpi-number">
                                <span class="value">
                                    <fmt:formatNumber value="${todaySalesCount}" type="number" groupingUsed="true"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Total orders generated today</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-header">Today's Purchase Count</div>
                            <div class="kpi-number">
                                <span class="value">
                                    <fmt:formatNumber value="${todayPurchaseCount}" type="number" groupingUsed="true"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Materials/items purchased today</div>
                        </div>
                    </div>

                    <!-- Row 2: Weekly / Monthly Counts -->
                    <div class="kpi-row">
                        <div class="kpi sales">
                            <div class="kpi-header">Weekly Sales Count</div>
                            <div class="kpi-number">
                                <span class="value">
                                    <fmt:formatNumber value="${weeklySalesCount}" type="number" groupingUsed="true"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Completed sales in current week</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-header">Weekly Purchase Count</div>
                            <div class="kpi-number">
                                <span class="value">
                                    <fmt:formatNumber value="${weeklyPurchaseCount}" type="number" groupingUsed="true"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Invoices processed this week</div>
                        </div>
                        <div class="kpi sales">
                            <div class="kpi-header">Monthly Sales Count</div>
                            <div class="kpi-number">
                                <span class="value">
                                    <fmt:formatNumber value="${monthlySalesCount}" type="number" groupingUsed="true"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Orders completed this month</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-header">Monthly Purchase Count</div>
                            <div class="kpi-number">
                                <span class="value">
                                    <fmt:formatNumber value="${monthlyPurchaseCount}" type="number" groupingUsed="true"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Invoices processed this month</div>
                        </div>
                    </div>

                    <!-- Row 3: Daily/Weekly Sales & Purchase Amounts -->
                    <div class="kpi-row">
                        <div class="kpi sales">
                            <div class="kpi-header">Today's Sales Amount</div>
                            <div class="kpi-number">
                                <span class="currency">₹</span>
                                <span class="value">
                                    <fmt:formatNumber value="${todaySalesAmount}" type="number"
                                                      groupingUsed="true" maxFractionDigits="0"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Total value of sales today</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-header">Today's Purchase Amount</div>
                            <div class="kpi-number">
                                <span class="currency">₹</span>
                                <span class="value">
                                    <fmt:formatNumber value="${todayPurchaseAmount}" type="number"
                                                      groupingUsed="true" maxFractionDigits="0"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Total value of procurement today</div>
                        </div>
                        <div class="kpi sales">
                            <div class="kpi-header">Weekly Sales Amount</div>
                            <div class="kpi-number">
                                <span class="currency">₹</span>
                                <span class="value">
                                    <fmt:formatNumber value="${weeklySalesAmount}" type="number"
                                                      groupingUsed="true" maxFractionDigits="0"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Total revenue this week</div>
                        </div>
                        <div class="kpi purchase">
                            <div class="kpi-header">Weekly Purchase Amount</div>
                            <div class="kpi-number">
                                <span class="currency">₹</span>
                                <span class="value">
                                    <fmt:formatNumber value="${weeklyPurchaseAmount}" type="number"
                                                      groupingUsed="true" maxFractionDigits="0"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Total spend this week</div>
                        </div>
                    </div>

                    <!-- Row 4: Monthly Amounts -->
                    <div class="kpi-row">
                        <div class="kpi sales" style="flex:2;">
                            <div class="kpi-header">Monthly Sales Amount</div>
                            <div class="kpi-number">
                                <span class="currency">₹</span>
                                <span class="value">
                                    <fmt:formatNumber value="${monthlySalesAmount}" type="number"
                                                      groupingUsed="true" maxFractionDigits="0"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Total revenue generated in the current month</div>
                        </div>
                        <div class="kpi purchase" style="flex:2;">
                            <div class="kpi-header">Monthly Purchase Amount</div>
                            <div class="kpi-number">
                                <span class="currency">₹</span>
                                <span class="value">
                                    <fmt:formatNumber value="${monthlyPurchaseAmount}" type="number"
                                                      groupingUsed="true" maxFractionDigits="0"/>
                                </span>
                            </div>
                            <div class="kpi-sub">Total value of all material purchases this month</div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </main>

    <%@ include file="footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>