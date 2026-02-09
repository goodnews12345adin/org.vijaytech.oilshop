package org.vijaytech.oilshop;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.compiere.model.MProduct;
import org.compiere.model.MProductCategory;
import org.compiere.model.Query;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;

public class StockReport extends HttpServlet{
    
    private static final long serialVersionUID = 1L;

    // -------------------------------------------------
    // ================ DO GET =============
    // -------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        
        // ---- SESSION CHECK ----
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("ctx") == null) {
            resp.sendRedirect("userlogin.jsp?error=session_expired");
            return;
        }

        Properties ctx = (Properties) session.getAttribute("ctx");
        Env.setCtx(ctx);

        // Set Context Defaults if missing
        if (Env.getAD_Client_ID(ctx) == 0) Env.setContext(ctx, "#AD_Client_ID", 1000000);
        if (Env.getAD_Org_ID(ctx) == 0) Env.setContext(ctx, "#AD_Org_ID", 1000000);
        if (Env.getAD_User_ID(ctx) == 0) Env.setContext(ctx, "#AD_User_ID", 100);
        if (Env.getContextAsInt(ctx, "#AD_Role_ID") == 0) Env.setContext(ctx, "#AD_Role_ID", 102);

        try {

            /* ✅ Load Category Dropdown */
            List<Map<String, Object>> categoryList = new ArrayList<>();

            List<MProductCategory> cats =
                    new Query(ctx, MProductCategory.Table_Name, "IsActive='Y'", null)
                            .setClient_ID()
                            .setOrderBy("Name")
                            .list();

            for (MProductCategory c : cats) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", c.get_ID());
                m.put("name", c.getName());
                categoryList.add(m);
            }

            req.setAttribute("categoryList", categoryList);

            /* ✅ Optional Product Dropdown also */
            List<Map<String, Object>> productList = new ArrayList<>();

            List<MProduct> prods =
                    new Query(ctx, MProduct.Table_Name, "IsActive='Y'", null)
                            .setClient_ID()
                            .setOrderBy("Name")
                            .list();

            for (MProduct p : prods) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", p.get_ID());
                m.put("name", p.getName());
                productList.add(m);
            }

            req.setAttribute("productList", productList);

            /* ✅ Forward JSP */
            RequestDispatcher rd =
                    req.getRequestDispatcher("/pages/StockReport.jsp");
            rd.forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading Report", e);
        }

    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String productCatIdStr = req.getParameter("productcatId");
        String productIdStr = req.getParameter("productId"); // Added Product filter
        String fromDateStr  = req.getParameter("fromDate");
        String toDateStr    = req.getParameter("toDate");

        resp.setContentType("application/json");
        JSONArray result = new JSONArray();

        /* ✅ Validate Dates */
        if (fromDateStr == null || fromDateStr.isEmpty() ||
            toDateStr == null || toDateStr.isEmpty()) {

            try {
                resp.getWriter().write("{\"error\":\"From Date and To Date required\"}");
            } catch (IOException e) {
                e.printStackTrace();
            }
            return;
        }

        /* ✅ UPDATED SQL: Select Transactions for Date-Based Ledger */
        // We remove GROUP BY to show individual daily transactions
        String sql =
            "SELECT " +
            " t.MovementDate AS Date, " +
            " p.Value AS ProductCode, " +
            " p.Name AS ProductName, " +
            " u.Name AS UOM, " +
            " CASE WHEN t.MovementQty > 0 THEN t.MovementQty ELSE 0 END AS InQty, " +
            " CASE WHEN t.MovementQty < 0 THEN ABS(t.MovementQty) ELSE 0 END AS OutQty " +

            "FROM M_Transaction t " +
            "JOIN M_Product p ON t.M_Product_ID = p.M_Product_ID " +
            "JOIN M_Product_Category pc ON p.M_Product_Category_ID = pc.M_Product_Category_ID " +
            "JOIN C_UOM u ON p.C_UOM_ID = u.C_UOM_ID " +

            "WHERE t.MovementDate BETWEEN ? AND ? ";

        boolean hasCategory = (productCatIdStr != null && !productCatIdStr.trim().isEmpty());
        boolean hasProduct  = (productIdStr != null && !productIdStr.trim().isEmpty());

        if (hasCategory) {
            sql += " AND pc.M_Product_Category_ID = ? ";
        }
        if (hasProduct) {
            sql += " AND p.M_Product_ID = ? ";
        }

        sql += " ORDER BY t.MovementDate, p.Name";

        try (Connection con = DB.getConnectionRW();
             PreparedStatement ps = con.prepareStatement(sql)) {

            Timestamp fromTs = Timestamp.valueOf(fromDateStr + " 00:00:00");
            Timestamp toTs   = Timestamp.valueOf(toDateStr + " 23:59:59");

            ps.setTimestamp(1, fromTs);
            ps.setTimestamp(2, toTs);

            int paramIndex = 3;
            if (hasCategory) {
                ps.setInt(paramIndex++, Integer.parseInt(productCatIdStr));
            }
            if (hasProduct) {
                ps.setInt(paramIndex++, Integer.parseInt(productIdStr));
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                JSONObject row = new JSONObject();
                row.put("date", rs.getString("Date")); // Key used in JSP
                row.put("productCode", rs.getString("ProductCode"));
                row.put("productName", rs.getString("ProductName"));
                row.put("uom", rs.getString("UOM"));
                row.put("inQty", rs.getDouble("InQty"));
                row.put("outQty", rs.getDouble("OutQty"));
                
                result.put(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
            try {
                resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            } catch (IOException ioException) {
                ioException.printStackTrace();
            }
            return;
        }

        // ✅ Response
        resp.setContentType("application/json");
        try {
            resp.getWriter().write(result.toString());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}