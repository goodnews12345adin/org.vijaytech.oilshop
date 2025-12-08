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

    long todaySalesCount = 0L, todayPurchaseCount = 0L;
    long weeklySalesCount = 0L, weeklyPurchaseCount = 0L;
    long monthlySalesCount = 0L, monthlyPurchaseCount = 0L;

    double todaySalesAmount = 0, todayPurchaseAmount = 0;
    double weeklySalesAmount = 0, weeklyPurchaseAmount = 0;
    double monthlySalesAmount = 0, monthlyPurchaseAmount = 0;

    double todayExpenseAmount = 0, weeklyExpenseAmount = 0, monthlyExpenseAmount = 0;

    try {

        String baseSales =
        " FROM C_Order WHERE IsActive='Y' AND IsSOTrx='Y' AND DocStatus='CO' " +
        "AND AD_Client_ID=" + AD_Client_ID + " AND AD_Org_ID=" + AD_Org_ID + " ";

        String basePurchase =
        " FROM C_Order WHERE IsActive='Y' AND IsSOTrx='N' AND DocStatus='CO' " +
        "AND AD_Client_ID=" + AD_Client_ID + " AND AD_Org_ID=" + AD_Org_ID + " ";

        todaySalesCount = DB.getSQLValue(null,
            "SELECT COUNT(*) " + baseSales + "AND DateOrdered::date = CURRENT_DATE");

        todayPurchaseCount = DB.getSQLValue(null,
            "SELECT COUNT(*) " + basePurchase + "AND DateOrdered::date = CURRENT_DATE");

        weeklySalesCount = DB.getSQLValue(null,
            "SELECT COUNT(*) " + baseSales +
            "AND date_trunc('week', DateOrdered)=date_trunc('week',CURRENT_DATE)");

        weeklyPurchaseCount = DB.getSQLValue(null,
            "SELECT COUNT(*) " + basePurchase +
            "AND date_trunc('week', DateOrdered)=date_trunc('week',CURRENT_DATE)");

        monthlySalesCount = DB.getSQLValue(null,
            "SELECT COUNT(*) " + baseSales +
            "AND date_trunc('month', DateOrdered)=date_trunc('month',CURRENT_DATE)");

        monthlyPurchaseCount = DB.getSQLValue(null,
            "SELECT COUNT(*) " + basePurchase +
            "AND date_trunc('month', DateOrdered)=date_trunc('month',CURRENT_DATE)");

        todaySalesAmount = DB.getSQLValueBD(null,
            "SELECT COALESCE(SUM(GrandTotal),0) " + baseSales +
            "AND DateOrdered::date = CURRENT_DATE").doubleValue();

        todayPurchaseAmount = DB.getSQLValueBD(null,
            "SELECT COALESCE(SUM(GrandTotal),0) " + basePurchase +
            "AND DateOrdered::date = CURRENT_DATE").doubleValue();

        weeklySalesAmount = DB.getSQLValueBD(null,
            "SELECT COALESCE(SUM(GrandTotal),0) " + baseSales +
            "AND date_trunc('week', DateOrdered)=date_trunc('week',CURRENT_DATE)").doubleValue();

        weeklyPurchaseAmount = DB.getSQLValueBD(null,
            "SELECT COALESCE(SUM(GrandTotal),0) " + basePurchase +
            "AND date_trunc('week', DateOrdered)=date_trunc('week',CURRENT_DATE)").doubleValue();

        monthlySalesAmount = DB.getSQLValueBD(null,
            "SELECT COALESCE(SUM(GrandTotal),0) " + baseSales +
            "AND date_trunc('month', DateOrdered)=date_trunc('month',CURRENT_DATE)").doubleValue();

        monthlyPurchaseAmount = DB.getSQLValueBD(null,
            "SELECT COALESCE(SUM(GrandTotal),0) " + basePurchase +
            "AND date_trunc('month', DateOrdered)=date_trunc('month',CURRENT_DATE)").doubleValue();

        todayExpenseAmount = DB.getSQLValueBD(null,
            "SELECT COALESCE(SUM(amount),0) FROM EXPENSES WHERE expense_date::date=CURRENT_DATE").doubleValue();

        weeklyExpenseAmount = DB.getSQLValueBD(null,
            "SELECT COALESCE(SUM(amount),0) FROM EXPENSES WHERE date_trunc('week',expense_date)=date_trunc('week',CURRENT_DATE)").doubleValue();

        monthlyExpenseAmount = DB.getSQLValueBD(null,
            "SELECT COALESCE(SUM(amount),0) FROM EXPENSES WHERE date_trunc('month',expense_date)=date_trunc('month',CURRENT_DATE)").doubleValue();

    } catch(Exception e){ e.printStackTrace(); }

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

<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">

<style>

/* ---------------- GLOBAL ---------------- */
:root{
    --sidebar-width:260px;
}

body{
    margin:0;
    padding:0;
    font-family:'Poppins',sans-serif;
    background:
      radial-gradient(ellipse at center,rgba(8,20,58,0.6),rgba(3,10,28,0.9)),
      url('${pageContext.request.contextPath}/pages/img/bg-textile.jpg')
      center/cover no-repeat fixed;
    overflow-x:hidden;
}

/* Sidebar pushes content only in desktop */
@media(min-width:1025px){
    .main{
        margin-left:var(--sidebar-width) !important;
    }
}

/* Mobile → full width */
@media(max-width:1024px){
    .main{
        margin-left:0 !important;
    }
}

/* ---------------- MAIN CONTENT ---------------- */
.main{
    padding:22px;
    transition:0.3s ease;
}

.dashboard-outer-wrapper{
    max-width:1380px;
    margin:auto;
}

.dashboard-outer{
    border-radius:16px;
    padding:20px;
    background:rgba(255,255,255,0.07);
    border:1px solid rgba(255,255,255,0.15);
    backdrop-filter:blur(10px);
}

.dashboard-inner{
    border-radius:14px;
    padding:20px;
    background:rgba(255,255,255,0.03);
}

/* ---------------- KPI CARDS ---------------- */
.kpi-row{
    display:flex;
    gap:20px;
    flex-wrap:wrap;
}

.kpi{
    flex:1;
    min-width:260px;
    background:#fff;
    color:#1b1b1b;
    padding:20px;
    border-radius:14px;
}

.kpi .value{
    font-size:2.4rem;
    font-weight:800;
}

.kpi.sales .value{ color:#19b6b0; }
.kpi.purchase .value{ color:#ffc107; }
.kpi.expense .value{ color:#ef4444; }

@media(max-width:768px){
    .kpi{ min-width:100%; }
}

</style>
</head>

<body>

<!-- Sidebar fixed -->
<%@ include file="sidebar.jsp" %>

<!-- Header inside content -->
<header style="margin-left:0; margin-bottom:20px; color:white; padding:10px 5px;">
    <h3 style="font-weight:600;">Dashboard</h3>
</header>

<main class="main">

<div class="dashboard-outer-wrapper">
<div class="dashboard-outer">
<div class="dashboard-inner">

<!-- ---------------- ROW 1 ---------------- -->
<div class="kpi-row">

    <div class="kpi sales">
        <div>Today's Sales Count</div>
        <div class="value">${todaySalesCount}</div>
    </div>

    <div class="kpi purchase">
        <div>Today's Purchase Count</div>
        <div class="value">${todayPurchaseCount}</div>
    </div>

</div>

<!-- ---------------- ROW 2 ---------------- -->
<div class="kpi-row">

    <div class="kpi sales">
        <div>Weekly Sales</div>
        <div class="value">${weeklySalesCount}</div>
    </div>

    <div class="kpi purchase">
        <div>Weekly Purchase</div>
        <div class="value">${weeklyPurchaseCount}</div>
    </div>

    <div class="kpi sales">
        <div>Monthly Sales</div>
        <div class="value">${monthlySalesCount}</div>
    </div>

    <div class="kpi purchase">
        <div>Monthly Purchase</div>
        <div class="value">${monthlyPurchaseCount}</div>
    </div>

</div>

<!-- ---------------- ROW 3 ---------------- -->
<div class="kpi-row">

    <div class="kpi sales">
        <div>Today's Sales Amount</div>
        <div class="value">
            <fmt:formatNumber value="${todaySalesAmount}" groupingUsed="true"/>
        </div>
    </div>

    <div class="kpi purchase">
        <div>Today's Purchase Amount</div>
        <div class="value">
            <fmt:formatNumber value="${todayPurchaseAmount}" groupingUsed="true"/>
        </div>
    </div>

    <div class="kpi sales">
        <div>Weekly Sales Amount</div>
        <div class="value">
            <fmt:formatNumber value="${weeklySalesAmount}" groupingUsed="true"/>
        </div>
    </div>

    <div class="kpi purchase">
        <div>Weekly Purchase Amount</div>
        <div class="value">
            <fmt:formatNumber value="${weeklyPurchaseAmount}" groupingUsed="true"/>
        </div>
    </div>

</div>

<!-- ---------------- ROW 4 ---------------- -->
<div class="kpi-row">

    <div class="kpi sales" style="flex:2;">
        <div>Monthly Sales Amount</div>
        <div class="value">
            <fmt:formatNumber value="${monthlySalesAmount}" groupingUsed="true"/>
        </div>
    </div>

    <div class="kpi purchase" style="flex:2;">
        <div>Monthly Purchase Amount</div>
        <div class="value">
            <fmt:formatNumber value="${monthlyPurchaseAmount}" groupingUsed="true"/>
        </div>
    </div>

</div>

<!-- ---------------- ROW 5 ---------------- -->
<div class="kpi-row">

    <div class="kpi expense">
        <div>Today's Expense</div>
        <div class="value">
            <fmt:formatNumber value="${todayExpenseAmount}" groupingUsed="true"/>
        </div>
    </div>

    <div class="kpi expense">
        <div>Weekly Expense</div>
        <div class="value">
            <fmt:formatNumber value="${weeklyExpenseAmount}" groupingUsed="true"/>
        </div>
    </div>

    <div class="kpi expense">
        <div>Monthly Expense</div>
        <div class="value">
            <fmt:formatNumber value="${monthlyExpenseAmount}" groupingUsed="true"/>
        </div>
    </div>

</div>

</div>
</div>
</div>

</main>

</body>
</html>