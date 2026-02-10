<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%@ page import="org.compiere.util.DB,org.compiere.util.Env,java.math.BigDecimal" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<fmt:setLocale value="en_IN" />

<%
    // Context Initialization
    int AD_Client_ID = Env.getAD_Client_ID(Env.getCtx());
    int AD_Org_ID    = Env.getAD_Org_ID(Env.getCtx());

    if (AD_Client_ID == 0) AD_Client_ID = 1000000;
    if (AD_Org_ID == 0)    AD_Org_ID    = 1000000;

    // Variable Initialization
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
        // Base SQL for Sales and Purchase (C_Order Table)
        // Uses PostgreSQL specific syntax (::date, date_trunc)
        String baseOrder =
            " FROM C_Order " +
            "WHERE IsActive='Y' " +
            "AND DocStatus='CO' " + // Completed
            "AND AD_Client_ID=" + AD_Client_ID +
            " AND AD_Org_ID=" + AD_Org_ID + " ";

        String baseSales = baseOrder + "AND IsSOTrx='Y' "; // Sales Order
        String basePurchase = baseOrder + "AND IsSOTrx='N' "; // Purchase Order

        // --- COUNTS QUERIES ---
        
        String SQL_TODAY_SALES_COUNT =
            "SELECT COUNT(*) " + baseSales + "AND DateOrdered::date = CURRENT_DATE";
            
        String SQL_TODAY_PURCHASE_COUNT =
            "SELECT COUNT(*) " + basePurchase + "AND DateOrdered::date = CURRENT_DATE";
            
        String SQL_WEEKLY_SALES_COUNT =
            "SELECT COUNT(*) " + baseSales + "AND date_trunc('week', DateOrdered) = date_trunc('week', CURRENT_DATE)";
            
        String SQL_WEEKLY_PURCHASE_COUNT =
            "SELECT COUNT(*) " + basePurchase + "AND date_trunc('week', DateOrdered) = date_trunc('week', CURRENT_DATE)";
            
        String SQL_MONTHLY_SALES_COUNT =
            "SELECT COUNT(*) " + baseSales + "AND date_trunc('month', DateOrdered) = date_trunc('month', CURRENT_DATE)";
            
        String SQL_MONTHLY_PURCHASE_COUNT =
            "SELECT COUNT(*) " + basePurchase + "AND date_trunc('month', DateOrdered) = date_trunc('month', CURRENT_DATE)";

        // --- AMOUNT QUERIES (ORDERS) ---

        String SQL_TODAY_SALES_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + baseSales + "AND DateOrdered::date = CURRENT_DATE";
            
        String SQL_TODAY_PURCHASE_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + basePurchase + "AND DateOrdered::date = CURRENT_DATE";
            
        String SQL_WEEKLY_SALES_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + baseSales + "AND date_trunc('week', DateOrdered) = date_trunc('week', CURRENT_DATE)";
            
        String SQL_WEEKLY_PURCHASE_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + basePurchase + "AND date_trunc('week', DateOrdered) = date_trunc('week', CURRENT_DATE)";
            
        String SQL_MONTHLY_SALES_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + baseSales + "AND date_trunc('month', DateOrdered) = date_trunc('month', CURRENT_DATE)";
            
        String SQL_MONTHLY_PURCHASE_AMOUNT =
            "SELECT COALESCE(SUM(GrandTotal),0) " + basePurchase + "AND date_trunc('month', DateOrdered) = date_trunc('month', CURRENT_DATE)";

        // --- EXPENSE QUERIES (C_PAYMENT) ---
        // CORRECTED LOGIC: 
        // Removed 'TenderType = X' restriction. 
        // Now captures ALL outgoing payments (Cash, Cheque, Transfer, etc.) which are complete.
        
        String baseExpense =
            "FROM C_Payment " +
            "WHERE AD_Client_ID = " + AD_Client_ID + " " +
            "AND AD_Org_ID = " + AD_Org_ID + " " +
            "AND IsReceipt = 'N' " + // Payment Out (Expense)
            "AND DocStatus = 'CO' ";   // Completed

        String SQL_TODAY_EXPENSE_AMOUNT =
            "SELECT COALESCE(SUM(PayAmt),0) " + baseExpense + "AND DateTrx::date = CURRENT_DATE";

        String SQL_WEEKLY_EXPENSE_AMOUNT =
            "SELECT COALESCE(SUM(PayAmt),0) " + baseExpense + "AND date_trunc('week', DateTrx) = date_trunc('week', CURRENT_DATE)";

        String SQL_MONTHLY_EXPENSE_AMOUNT =
            "SELECT COALESCE(SUM(PayAmt),0) " + baseExpense + "AND date_trunc('month', DateTrx) = date_trunc('month', CURRENT_DATE)";

        // --- EXECUTE QUERIES ---

        int iVal;
        BigDecimal bd;

        // 1. Fetch Counts
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

        // 2. Fetch Order Amounts
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

        // 3. Fetch Expense Amounts (Corrected Logic)
        bd = DB.getSQLValueBD(null, SQL_TODAY_EXPENSE_AMOUNT);
        if (bd != null) todayExpenseAmount = bd.doubleValue();
        
        bd = DB.getSQLValueBD(null, SQL_WEEKLY_EXPENSE_AMOUNT);
        if (bd != null) weeklyExpenseAmount = bd.doubleValue();
        
        bd = DB.getSQLValueBD(null, SQL_MONTHLY_EXPENSE_AMOUNT);
        if (bd != null) monthlyExpenseAmount = bd.doubleValue();

    } catch (Exception e) {
        e.printStackTrace();
    }

    // Set Request Attributes for JSTL access
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
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    
    <title>Dashboard | Vijay Tech</title>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
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

            /* KPI Colors */
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

        /* Main Wrapper */
        main.main{
            min-height:calc(100vh - var(--navbar-height));
            padding:24px 24px 96px; /* Bottom padding for footer */
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

        /* KPI Grid & Cards */
        .kpi-grid{
            display:grid;
            /* Auto-fit with min-width for better responsive flow */
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
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
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        /* Gradients for Card Types */
        .kpi.sales::before,
        .kpi.purchase::before,
        .kpi.expense::before{
            content:"";
            position:absolute;
            top:0; right:0;
            width:100px; height:100px;
            background:radial-gradient(circle at top right, rgba(255,255,255,0.4), transparent 70%);
            pointer-events:none;
        }

        .kpi.sales{ border-bottom: 4px solid var(--kpi-number); }
        .kpi.purchase{ border-bottom: 4px solid var(--kpi-purchase); }
        .kpi.expense{ border-bottom: 4px solid var(--kpi-expense); }

        .kpi-header{
            font-size:.85rem;
            font-weight:700;
            letter-spacing:.04em;
            text-transform:uppercase;
            color:#64748b;
            position:relative;
            z-index:1;
            display:flex;
            align-items:center;
            justify-content:space-between;
        }
        
        /* --- COLORFUL ICONS --- */
        .kpi-icon {
            font-size: 1.2rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: #f1f5f9;
            opacity: 1; /* Fully visible */
            transition: transform 0.3s ease;
        }

        /* Sales Icon Style */
        .kpi.sales .kpi-icon {
            color: #fff;
            background: linear-gradient(135deg, var(--kpi-number), #0d9488);
            box-shadow: 0 4px 12px rgba(25, 182, 176, 0.3);
        }

        /* Purchase Icon Style */
        .kpi.purchase .kpi-icon {
            color: #fff;
            background: linear-gradient(135deg, var(--kpi-purchase), #d97706);
            box-shadow: 0 4px 12px rgba(255, 193, 7, 0.3);
        }

        /* Expense Icon Style */
        .kpi.expense .kpi-icon {
            color: #fff;
            background: linear-gradient(135deg, var(--kpi-expense), #dc2626);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        }

        /* Icon Animation on Hover */
        .kpi:hover .kpi-icon {
            transform: rotate(15deg) scale(1.1);
        }

        .kpi-number{
            margin-top:8px;
            display:flex;
            align-items:baseline;
            gap:4px;
            position:relative;
            z-index:1;
        }

        .kpi-number .currency{
            font-size:1.1rem;
            font-weight:600;
        }

        .kpi-number .value{
            font-size:1.8rem;
            font-weight:800;
            line-height:1.1;
        }

        .kpi.sales .value{color:var(--kpi-number);}
        .kpi.purchase .value{color:var(--kpi-purchase);}
        .kpi.expense .value{color:var(--kpi-expense);}

        .kpi-sub{
            margin-top:6px;
            font-size:.75rem;
            color:#94a3b8;
            position:relative;
            z-index:1;
        }

        .kpi:hover{
            transform:translateY(-4px);
            box-shadow:0 26px 50px rgba(15,23,42,.26);
        }

        /* Footer */
        .bottom-footer{
            position:fixed;
            left:0; right:0; bottom:0;
            height:54px;
            background:#ffffff;
            display:flex;
            align-items:center;
            justify-content:center;
            box-shadow:0 -8px 24px rgba(15,23,42,.35);
            z-index: 1000;
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

        /* =========================================
           RESPONSIVE MEDIA QUERIES 
           ========================================= */

        /* Mobile Devices (< 576px) */
        @media (max-width: 575.98px){
            main.main{
                padding:16px 12px 80px;
            }
            .dashboard-outer{
                padding:14px;
                border-radius:16px;
            }
            .dashboard-top-pill{
                flex-direction:column;
                align-items:flex-start;
                gap:10px;
            }
            /* Force single column on very small screens */
            .kpi-grid{
                grid-template-columns: 1fr; 
            }
            .kpi-number .value{
                font-size:1.6rem;
            }
        }

        /* Tablets (576px - 991px) */
        @media (min-width: 576px) and (max-width: 991.98px){
            main.main{
                padding:20px 16px 90px;
            }
            .dashboard-outer-wrapper{
                max-width:100%;
            }
            /* 2 Columns for tablets */
            .kpi-grid{
                grid-template-columns: repeat(2, 1fr);
            }
        }

        /* Desktop (>= 992px) */
        @media (min-width: 992px){
            .dashboard-outer-wrapper{
                max-width:1200px;
            }
            /* 4 Columns for desktop */
            .kpi-grid{
                grid-template-columns: repeat(4, 1fr);
            }
        }
    </style>
</head>

<body>

<!-- Header and Sidebar Include -->
<%@ include file="header.jsp" %>
<%@ include file="sidebar.jsp" %>

<main class="main" role="main" aria-labelledby="dashboardTitle">
    <div class="dashboard-outer-wrapper">
        <div class="dashboard-outer">
            
            <!-- Top Pill Header -->
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
                                <c:otherwise>Admin</c:otherwise>
                            </c:choose>
                        </span>
                    </span>
                </div>
            </div>

            <!-- KPI Grid -->
            <div class="dashboard-inner">
                <div class="kpi-grid">

                    <!-- 1. COUNTS -->

                    <div class="kpi sales">
                        <div class="kpi-header">Today's Sales Count <i class="bi bi-cart-check kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="value">
                                <fmt:formatNumber value="${todaySalesCount}" type="number" groupingUsed="true"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total orders generated today</div>
                    </div>

                    <div class="kpi purchase">
                        <div class="kpi-header">Today's Purchase Count <i class="bi bi-cart-x kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="value">
                                <fmt:formatNumber value="${todayPurchaseCount}" type="number" groupingUsed="true"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Materials/items purchased today</div>
                    </div>

                    <div class="kpi sales">
                        <div class="kpi-header">Weekly Sales Count <i class="bi bi-calendar-week kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="value">
                                <fmt:formatNumber value="${weeklySalesCount}" type="number" groupingUsed="true"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Completed sales in current week</div>
                    </div>

                    <div class="kpi purchase">
                        <div class="kpi-header">Weekly Purchase Count <i class="bi bi-bag kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="value">
                                <fmt:formatNumber value="${weeklyPurchaseCount}" type="number" groupingUsed="true"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Invoices processed this week</div>
                    </div>

                    <div class="kpi sales">
                        <div class="kpi-header">Monthly Sales Count <i class="bi bi-calendar-month kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="value">
                                <fmt:formatNumber value="${monthlySalesCount}" type="number" groupingUsed="true"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Orders completed this month</div>
                    </div>

                    <div class="kpi purchase">
                        <div class="kpi-header">Monthly Purchase Count <i class="bi bi-receipt kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="value">
                                <fmt:formatNumber value="${monthlyPurchaseCount}" type="number" groupingUsed="true"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Invoices processed this month</div>
                    </div>

                    <!-- 2. AMOUNTS (SALES & PURCHASE) -->

                    <div class="kpi sales">
                        <div class="kpi-header">Today's Sales Amount <i class="bi bi-cash-coin kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${todaySalesAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total value of sales today</div>
                    </div>

                    <div class="kpi purchase">
                        <div class="kpi-header">Today's Purchase Amount <i class="bi bi-cash kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${todayPurchaseAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total value of procurement today</div>
                    </div>

                    <div class="kpi sales">
                        <div class="kpi-header">Weekly Sales Amount <i class="bi bi-graph-up-arrow kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${weeklySalesAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total revenue this week</div>
                    </div>

                    <div class="kpi purchase">
                        <div class="kpi-header">Weekly Purchase Amount <i class="bi bi-graph-down-arrow kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${weeklyPurchaseAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total spend this week</div>
                    </div>

                    <div class="kpi sales">
                        <div class="kpi-header">Monthly Sales Amount <i class="bi bi-piggy-bank kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${monthlySalesAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total revenue generated this month</div>
                    </div>

                    <div class="kpi purchase">
                        <div class="kpi-header">Monthly Purchase Amount <i class="bi bi-wallet2 kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${monthlyPurchaseAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total value of all purchases this month</div>
                    </div>
                    
                    <!-- 3. EXPENSE AMOUNTS (CORRECTED) -->

                    <div class="kpi expense">
                        <div class="kpi-header">Today's Expense Amount <i class="bi bi-currency-rupee kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${todayExpenseAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total expenses incurred today</div>
                    </div>

                    <div class="kpi expense">
                        <div class="kpi-header">Weekly Expense Amount <i class="bi bi-calendar3 kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${weeklyExpenseAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total expenses this week</div>
                    </div>

                    <div class="kpi expense">
                        <div class="kpi-header">Monthly Expense Amount <i class="bi bi-calendar-check kpi-icon"></i></div>
                        <div class="kpi-number">
                            <span class="currency">₹</span>
                            <span class="value">
                                <fmt:formatNumber value="${monthlyExpenseAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="kpi-sub">Total expenses this month</div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</main>

<!-- Footer -->
<div class="bottom-footer">
    <div class="footer-inner">
        © <%= java.time.Year.now().getValue() %> Vijay Tech · <a href="#" class="footer-link">Help</a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>