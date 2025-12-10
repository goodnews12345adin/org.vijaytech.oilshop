<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%@ page import="org.compiere.util.DB,org.compiere.util.Env,java.math.BigDecimal" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<fmt:setLocale value="en_IN" />

<%
    int AD_Client_ID = Env.getAD_Client_ID(Env.getCtx());
    int AD_Org_ID    = Env.getAD_Org_ID(Env.getCtx());

    if (AD_Client_ID == 0) AD_Client_ID = 1000000;
    if (AD_Org_ID == 0)    AD_Org_ID    = 1000000;

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
        String baseSales =
            " FROM C_Order " +
            "WHERE IsActive='Y' " +
            "AND IsSOTrx='Y' " +
            "AND DocStatus='CO' " +
            "AND AD_Client_ID=" + AD_Client_ID +
            " AND AD_Org_ID=" + AD_Org_ID + " ";

        String basePurchase =
            " FROM C_Order " +
            "WHERE IsActive='Y' " +
            "AND IsSOTrx='N' " +
            "AND DocStatus='CO' " +
            "AND AD_Client_ID=" + AD_Client_ID +
            " AND AD_Org_ID=" + AD_Org_ID + " ";

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

        String SQL_TODAY_EXPENSE_AMOUNT =
            "SELECT COALESCE(SUM(amount),0) FROM EXPENSES " +
            "WHERE expense_date::date = CURRENT_DATE";
        String SQL_WEEKLY_EXPENSE_AMOUNT =
            "SELECT COALESCE(SUM(amount),0) FROM EXPENSES " +
            "WHERE date_trunc('week', expense_date) = date_trunc('week', CURRENT_DATE)";
        String SQL_MONTHLY_EXPENSE_AMOUNT =
            "SELECT COALESCE(SUM(amount),0) FROM EXPENSES " +
            "WHERE date_trunc('month', expense_date) = date_trunc('month', CURRENT_DATE)";

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

        bd = DB.getSQLValueBD(null, SQL_TODAY_EXPENSE_AMOUNT);
        if (bd != null) todayExpenseAmount = bd.doubleValue();
        bd = DB.getSQLValueBD(null, SQL_WEEKLY_EXPENSE_AMOUNT);
        if (bd != null) weeklyExpenseAmount = bd.doubleValue();
        bd = DB.getSQLValueBD(null, SQL_MONTHLY_EXPENSE_AMOUNT);
        if (bd != null) monthlyExpenseAmount = bd.doubleValue();

    } catch (Exception e) {
        e.printStackTrace();
    }

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
    <!-- IMPORTANT for mobile responsiveness -->
    <meta name="viewport" content="width=device-width, initial-scale=1">

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

            --kpi-number:#19b6b0;
            --kpi-purchase:#ffc107;
            --kpi-expense:#ef4444;
        }

        *{box-sizing:border-box;}
        html,body{height:100%;}

        body{
            margin:0;
            padding:0;
            padding-top:var(--navbar-height);
            font-family:'Poppins',system-ui,-apple-system,'Segoe UI',sans-serif;
            color:#fff;
            background:
                radial-gradient(ellipse at center,
                    rgba(8,20,58,0.6),
                    rgba(3,10,28,0.9)),
                url('${pageContext.request.contextPath}/pages/img/bg-textile.jpg')
                    center/cover no-repeat fixed;
            -webkit-font-smoothing:antialiased;
        }

        /* main wrapper */
        main.main{
            min-height:calc(100vh - var(--navbar-height));
            padding:24px 24px 96px;
            display:flex;
            justify-content:center;
        }

        .dashboard-outer-wrapper{
            width:100%;
            max-width:1200px;
        }

        .dashboard-outer{
            border-radius:var(--outer-radius);
            padding:18px;
            background:linear-gradient(180deg,
                rgba(255,255,255,0.03),
                rgba(255,255,255,0.015));
            border:1px solid rgba(255,255,255,0.14);
            box-shadow:
                0 22px 40px rgba(0,0,0,0.55);
            backdrop-filter:blur(10px);
        }

        .dashboard-top-pill{
            background:linear-gradient(180deg,
                rgba(255,255,255,0.08),
                rgba(255,255,255,0.02));
            border-radius:16px;
            padding:12px 16px;
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:18px;
            border:1px solid rgba(255,255,255,0.18);
        }

        .dashboard-top-pill h5{
            margin:0;
            font-weight:600;
            letter-spacing:.03em;
        }

        .dashboard-inner{
            border-radius:14px;
            padding:18px;
            border:1px solid rgba(255,255,255,0.08);
        }

        /* KPI cards */
        .kpi-grid{
            display:grid;
            grid-template-columns:repeat(4,1fr);
            gap:18px;
        }

        .kpi{
            position:relative;
            background:#fff;
            border-radius:12px;
            padding:16px 18px;
            box-shadow:0 18px 38px rgba(15,23,42,.18);
            color:#102a43;
            overflow:hidden;
        }

        .kpi.sales::before,
        .kpi.purchase::before,
        .kpi.expense::before{
            content:"";
            position:absolute;
            inset:0;
            pointer-events:none;
            mix-blend-mode:screen;
        }

        .kpi.sales::before{
            background:radial-gradient(circle at top left,
                rgba(25,182,176,.28),transparent 60%);
        }
        .kpi.purchase::before{
            background:radial-gradient(circle at top left,
                rgba(255,193,7,.28),transparent 60%);
        }
        .kpi.expense::before{
            background:radial-gradient(circle at top left,
                rgba(239,68,68,.28),transparent 60%);
        }

        .kpi-header{
            font-size:.9rem;
            font-weight:700;
            letter-spacing:.04em;
            text-transform:uppercase;
            color:#1f2937;
            position:relative;
            z-index:1;
        }

        .kpi-number{
            margin-top:6px;
            display:flex;
            align-items:baseline;
            gap:6px;
            position:relative;
            z-index:1;
        }

        .kpi-number .currency{
            font-size:1.2rem;
            font-weight:700;
        }

        .kpi-number .value{
            font-size:1.9rem;
            font-weight:800;
            line-height:1.05;
        }

        .kpi.sales .value{color:var(--kpi-number);}
        .kpi.purchase .value{color:var(--kpi-purchase);}
        .kpi.expense .value{color:var(--kpi-expense);}

        .kpi-sub{
            margin-top:4px;
            font-size:.8rem;
            color:#6b7280;
            position:relative;
            z-index:1;
        }

        .kpi:hover{
            transform:translateY(-3px);
            box-shadow:0 26px 50px rgba(15,23,42,.26);
            transition:.18s ease-out;
        }

        /* FOOTER */
        .bottom-footer{
            position:fixed;
            left:0;
            right:0;
            bottom:0;
            height:54px;
            background:#ffffff;
            display:flex;
            align-items:center;
            justify-content:center;
            box-shadow:0 -8px 24px rgba(15,23,42,.35);
        }
        .footer-inner{
            font-size:.85rem;
            color:#334155;
        }
        .footer-link{
            color:var(--accent-b);
            text-decoration:none;
            font-weight:600;
        }
        .footer-link:hover{text-decoration:underline;}

        /* ========= RESPONSIVE ========= */

        /* Phones: 1 column, full-width card like your screenshot */
        @media (max-width: 575.98px){
            main.main{
                padding:16px 10px 80px;
            }
            .dashboard-outer-wrapper{
                max-width:100%;
            }
            .dashboard-outer{
                padding:14px;
                border-radius:18px;
            }
            .dashboard-top-pill{
                flex-direction:column;
                align-items:flex-start;
                gap:8px;
            }
            .kpi-grid{
                grid-template-columns:1fr;
            }
            .kpi-number .value{
                font-size:1.6rem;
            }
        }

        /* Small tablets: 2 columns */
        @media (min-width: 576px) and (max-width: 991.98px){
            main.main{
                padding:20px 16px 90px;
            }
            .dashboard-outer-wrapper{
                max-width:720px;
            }
            .kpi-grid{
                grid-template-columns:repeat(2,1fr);
            }
        }

        /* Large screens: 4 columns (desktop view similar to design) */
        @media (min-width: 992px){
            .dashboard-outer-wrapper{
                max-width:1150px;
            }
            .kpi-grid{
                grid-template-columns:repeat(4,1fr);
            }
        }

    </style>
</head>

<body>

<%@ include file="header.jsp" %>
<%@ include file="sidebar.jsp" %>

<main class="main" role="main" aria-labelledby="dashboardTitle">
    <div class="dashboard-outer-wrapper">
        <div class="dashboard-outer">
            <div class="dashboard-top-pill">
                <h5 id="dashboardTitle">Dashboard</h5>
                <div class="d-flex align-items-center gap-2">
                    <span class="badge rounded-pill bg-light text-dark px-3 py-2 d-flex align-items-center gap-1">
                        <i class="bi bi-calendar-event"></i> Today
                    </span>
                    <span class="badge rounded-pill bg-dark text-light px-3 py-2 d-flex align-items-center gap-2">
                        <i class="bi bi-person-circle"></i>
                        <span>
                            <c:choose>
                                <c:when test="${not empty sessionScope.user and not empty sessionScope.user.username}">
                                    <c:out value="${sessionScope.user.username}" />
                                </c:when>
                                <c:otherwise>admin</c:otherwise>
                            </c:choose>
                        </span>
                    </span>
                </div>
            </div>

            <div class="dashboard-inner">
                <div class="kpi-grid">

                    <!-- counts -->
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

                    <!-- amounts -->
                    <div class="kpi sales">
                        <div class="kpi-header">Today's Sales Amount</div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${todaySalesAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total value of sales today</div>
                    </div>

                    <div class="kpi purchase">
                        <div class="kpi-header">Today's Purchase Amount</div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${todayPurchaseAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total value of procurement today</div>
                    </div>

                    <div class="kpi sales">
                        <div class="kpi-header">Weekly Sales Amount</div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${weeklySalesAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total revenue this week</div>
                    </div>

                    <div class="kpi purchase">
                        <div class="kpi-header">Weekly Purchase Amount</div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${weeklyPurchaseAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total spend this week</div>
                    </div>

                    <div class="kpi sales">
                        <div class="kpi-header">Monthly Sales Amount</div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${monthlySalesAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total revenue generated this month</div>
                    </div>

                    <div class="kpi purchase">
                        <div class="kpi-header">Monthly Purchase Amount</div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${monthlyPurchaseAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total value of all purchases this month</div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</main>

<div class="bottom-footer">
    <div class="footer-inner">
        © <%= java.time.Year.now().getValue() %> Vijay Tech · <a href="#" class="footer-link">Help</a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
