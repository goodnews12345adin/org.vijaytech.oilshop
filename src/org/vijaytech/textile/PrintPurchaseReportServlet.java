package org.vijaytech.textile;

import java.awt.Color;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.*;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.compiere.model.Query;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

public class PrintPurchaseReportServlet extends HttpServlet {

    private static final int PAGE_SIZE = 200;

    private static Timestamp toTs(String ymd) {
        return Timestamp.valueOf(LocalDate.parse(ymd).atStartOfDay());
    }

    private static Timestamp toTsEnd(String ymd) {
        return Timestamp.valueOf(LocalDate.parse(ymd).plusDays(1).atStartOfDay().minusNanos(1_000_000));
    }

    private static String safe(BigDecimal bd) {
        return bd == null ? " " : bd.toPlainString();
    }

    // ==================================================
    // ================ DO GET (PAGE + PDF) =============
    // ==================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        // ---- PAGE LOAD ----
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("ctx") == null) {
            resp.sendRedirect(req.getContextPath() + "/userlogin.jsp?error=session_expired");
            return;
        }

        Properties ctx = (Properties) session.getAttribute("ctx");
        Env.setCtx(ctx);

        if (Env.getAD_Client_ID(ctx) == 0) Env.setContext(ctx, "#AD_Client_ID", 1000000);
        if (Env.getAD_Org_ID(ctx) == 0)    Env.setContext(ctx, "#AD_Org_ID", 1000000);
        if (Env.getAD_User_ID(ctx) == 0)   Env.setContext(ctx, "#AD_User_ID", 100);
        if (Env.getContextAsInt(ctx, "#AD_Role_ID") == 0)
            Env.setContext(ctx, "#AD_Role_ID", 102);

        try {
            List<Map<String, Object>> supplierList = new ArrayList<>();
            List<TF_MBPartner> partners = new Query(ctx, TF_MBPartner.Table_Name, "IsActive='Y' AND isEmployee='N'", null)
                    .setClient_ID()
                    .list();

            for (TF_MBPartner bp : partners) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", bp.get_ID());
                m.put("name", bp.getName());
                supplierList.add(m);
            }

            req.setAttribute("supplierList", supplierList);

            RequestDispatcher rd = req.getRequestDispatcher("/pages/purchaseReport.jsp");
            rd.forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading Purchase Report", e);
        }
    }

    // ==================================================
    // ================ DO POST (JSON DATA) =============
    // ==================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = request.getReader()) {
            String line; while ((line = br.readLine()) != null) sb.append(line);
        }

        JSONObject json = new JSONObject(sb.toString());

        String from = json.optString("from");
        String to = json.optString("to");
        String type = json.optString("type");
        String org = json.optString("org");
        String bp = json.optString("bp");
        String summary = json.optString("summary", "N");
        int page = json.optInt("page", 1);

        boolean isSOTrx = type.equalsIgnoreCase("sales");

        JSONArray result = new JSONArray();

        StringBuilder sql = new StringBuilder();

        if (summary.equals("Y")) {
            // ===================== SUMMARY QUERY ======================
            sql.append("SELECT i.DateInvoiced, bp.Name AS BPartner, p.Name AS Product, ")
               .append("SUM(il.QtyInvoiced) AS Qty, AVG(il.PriceActual) AS Price, SUM(il.LineNetAmt) AS Amount ")
               .append("FROM C_Invoice i ")
               .append("JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID ")
               .append("LEFT JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID ")
               .append("LEFT JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID ")
               .append("WHERE i.IsSOTrx=? AND i.DocStatus IN ('CO','CL') ")
               .append("AND i.DateInvoiced BETWEEN ? AND ? ");

            if (org != null && !org.isEmpty())
                sql.append("AND i.AD_Org_ID=").append(org);
            if (bp != null && !bp.isEmpty())
                sql.append("AND i.C_BPartner_ID=").append(bp);

            sql.append(" GROUP BY i.DateInvoiced, bp.Name, p.Name ")
               .append(" ORDER BY i.DateInvoiced");

        } else {
            // ===================== DETAIL QUERY ======================
            sql.append("SELECT i.DateInvoiced, i.DocumentNo, bp.Name AS BPartner, p.Name AS Product, ")
               .append("il.QtyInvoiced AS Qty, il.PriceActual AS Price, il.LineNetAmt AS Amount ")
               .append("FROM C_Invoice i ")
               .append("JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID ")
               .append("LEFT JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID ")
               .append("LEFT JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID ")
               .append("WHERE i.IsSOTrx=? AND i.DocStatus IN ('CO','CL') ")
               .append("AND i.DateInvoiced BETWEEN ? AND ? ");

            if (org != null && !org.isEmpty())
                sql.append("AND i.AD_Org_ID=").append(org);
            if (bp != null && !bp.isEmpty())
                sql.append("AND i.C_BPartner_ID=").append(bp);

            sql.append(" ORDER BY i.DateInvoiced ")
               .append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        }


        try (Connection conn = DB.getConnectionRW();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;

            ps.setString(idx++, isSOTrx ? "Y" : "N");
            ps.setTimestamp(idx++, toTs(from));
            ps.setTimestamp(idx++, toTsEnd(to));

            if (summary.equals("N")) {
                int offset = (page - 1) * PAGE_SIZE;
                ps.setInt(idx++, offset);
                ps.setInt(idx++, PAGE_SIZE);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                JSONObject row = new JSONObject();

                row.put("Date", rs.getTimestamp("DateInvoiced").toString());
                if (summary.equals("N")) row.put("DocumentNo", rs.getString("DocumentNo"));
                row.put("BPartner", rs.getString("BPartner"));
                row.put("Product", rs.getString("Product"));
                row.put("Qty", safe(rs.getBigDecimal("Qty")));
                row.put("Price", safe(rs.getBigDecimal("Price")));
                row.put("Amount", safe(rs.getBigDecimal("Amount")));

                result.put(row);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            JSONObject err = new JSONObject();
            err.put("error", ex.getMessage());
            response.getWriter().write(err.toString());
            return;
        }

        response.setContentType("application/json");
        response.getWriter().write(result.toString());
    }


    // ==================================================
    // ============ SINGLE INVOICE PDF (IMPROVED) ========
    // ==================================================

       
}
