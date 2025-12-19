package org.vijaytech.oilshop;

import java.io.IOException;
import java.math.BigDecimal;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.compiere.util.DB;
import org.compiere.util.Env;

public class DashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ========= Get Client & Org from iDempiere Context =========
        int AD_Client_ID = Env.getAD_Client_ID(Env.getCtx());
        int AD_Org_ID    = Env.getAD_Org_ID(Env.getCtx());

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

        String fmtTodaySalesAmount      = "0";
        String fmtTodayPurchaseAmount   = "0";
        String fmtWeeklySalesAmount     = "0";
        String fmtWeeklyPurchaseAmount  = "0";
        String fmtMonthlySalesAmount    = "0";
        String fmtMonthlyPurchaseAmount = "0";
        String fmtTodayExpenseAmount    = "0";
        String fmtWeeklyExpenseAmount   = "0";
        String fmtMonthlyExpenseAmount  = "0";

        try {
            // ========= Base filters (TF_MOrder) =========
            String baseSales =
                " FROM TF_MOrder " +
                "WHERE IsActive='Y' AND IsSOTrx='Y' AND DocStatus='CO' " +
                "AND AD_Client_ID=" + AD_Client_ID +
                " AND AD_Org_ID=" + AD_Org_ID + " ";

            String basePurchase =
                " FROM TF_MOrder " +
                "WHERE IsActive='Y' AND IsSOTrx='N' AND DocStatus='CO' " +
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

            // ========= EXECUTE COUNTS =========
            todaySalesCount      = DB.getSQLValue(null, SQL_TODAY_SALES_COUNT);
            todayPurchaseCount   = DB.getSQLValue(null, SQL_TODAY_PURCHASE_COUNT);
            weeklySalesCount     = DB.getSQLValue(null, SQL_WEEKLY_SALES_COUNT);
            weeklyPurchaseCount  = DB.getSQLValue(null, SQL_WEEKLY_PURCHASE_COUNT);
            monthlySalesCount    = DB.getSQLValue(null, SQL_MONTHLY_SALES_COUNT);
            monthlyPurchaseCount = DB.getSQLValue(null, SQL_MONTHLY_PURCHASE_COUNT);

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

            // ========= FORMAT AMOUNTS =========
            fmtTodaySalesAmount      = String.format("%,.0f", todaySalesAmount);
            fmtTodayPurchaseAmount   = String.format("%,.0f", todayPurchaseAmount);
            fmtWeeklySalesAmount     = String.format("%,.0f", weeklySalesAmount);
            fmtWeeklyPurchaseAmount  = String.format("%,.0f", weeklyPurchaseAmount);
            fmtMonthlySalesAmount    = String.format("%,.0f", monthlySalesAmount);
            fmtMonthlyPurchaseAmount = String.format("%,.0f", monthlyPurchaseAmount);
            fmtTodayExpenseAmount    = String.format("%,.0f", todayExpenseAmount);
            fmtWeeklyExpenseAmount   = String.format("%,.0f", weeklyExpenseAmount);
            fmtMonthlyExpenseAmount  = String.format("%,.0f", monthlyExpenseAmount);

        } catch (Exception e) {
            e.printStackTrace();
        }

        // ========= Set attributes for JSP =========
        req.setAttribute("todaySalesCount", todaySalesCount);
        req.setAttribute("todayPurchaseCount", todayPurchaseCount);
        req.setAttribute("weeklySalesCount", weeklySalesCount);
        req.setAttribute("weeklyPurchaseCount", weeklyPurchaseCount);
        req.setAttribute("monthlySalesCount", monthlySalesCount);
        req.setAttribute("monthlyPurchaseCount", monthlyPurchaseCount);

        req.setAttribute("fmtTodaySalesAmount", fmtTodaySalesAmount);
        req.setAttribute("fmtTodayPurchaseAmount", fmtTodayPurchaseAmount);
        req.setAttribute("fmtWeeklySalesAmount", fmtWeeklySalesAmount);
        req.setAttribute("fmtWeeklyPurchaseAmount", fmtWeeklyPurchaseAmount);
        req.setAttribute("fmtMonthlySalesAmount", fmtMonthlySalesAmount);
        req.setAttribute("fmtMonthlyPurchaseAmount", fmtMonthlyPurchaseAmount);

        req.setAttribute("fmtTodayExpenseAmount", fmtTodayExpenseAmount);
        req.setAttribute("fmtWeeklyExpenseAmount", fmtWeeklyExpenseAmount);
        req.setAttribute("fmtMonthlyExpenseAmount", fmtMonthlyExpenseAmount);

        // ========= Forward to JSP =========
        RequestDispatcher rd = req.getRequestDispatcher("/pages/dashboard.jsp");
        rd.forward(req, resp);
    }
}
