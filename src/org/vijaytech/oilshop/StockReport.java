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
            
//	        // ---- SINGLE INVOICE PDF CHECK ----
//	        String docNo = req.getParameter("docNo");
//	        if (docNo != null && !docNo.isEmpty()) {
//	            try {
//	                generateSingleInvoicePDF(req, resp, docNo);
//	                return;
//	            } catch (Exception e) {
//	                e.printStackTrace();
//	                sendErrorJSON(resp, "PDF Generation Failed", e);
//	            }
//	        }

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
                // Load Dropdown Data using STANDARD ADempiere Models
                List<Map<String, Object>> productList = new ArrayList<>();

                // Using MProductCategory (Standard)
              
                // Using MProduct (Standard)
                List<MProduct> prods = new Query(ctx, MProduct.Table_Name, "IsActive='Y'", null)
                        .setClient_ID()
                        .list();
                for (MProduct p : prods) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", p.get_ID());
                    m.put("name", p.getName());
                    productList.add(m);
                }
                req.setAttribute("productList", productList);

                RequestDispatcher rd = req.getRequestDispatcher("/pages/StockReport.jsp");
                rd.forward(req, resp);

            } catch (Exception e) {
                e.printStackTrace();
                throw new ServletException("Error loading Report", e);
            }
        }
        
        @Override
        protected void doPost(HttpServletRequest req, HttpServletResponse resp)
                throws ServletException, IOException {

            String productIdStr = req.getParameter("productId");
            String fromDateStr  = req.getParameter("fromDate");
            String toDateStr    = req.getParameter("toDate");

            JSONArray result = new JSONArray();

            // ✅ Dates are mandatory
            if (fromDateStr == null || fromDateStr.isEmpty() ||
                toDateStr == null || toDateStr.isEmpty()) {

                resp.setContentType("application/json");
                resp.getWriter().write("{\"error\":\"From Date and To Date are required\"}");
                return;
            }

            // ✅ Base Query
            // Added PARTITION BY p.M_Product_ID to ensure Balance calculation is correct for multiple products
            String sql =
                    "SELECT p.Value AS ProductCode, p.Name AS ProductName, " +
                    "MAX(t.MovementDate) AS MovementDate, " + 
                    "u.Name AS UOM, " +
                    "SUM(CASE WHEN t.MovementQty > 0 THEN t.MovementQty ELSE 0 END) AS InQty, " +
                    "SUM(CASE WHEN t.MovementQty < 0 THEN ABS(t.MovementQty) ELSE 0 END) AS OutQty, " +
                    "SUM(t.MovementQty) AS BalanceQty " + 
                    "FROM M_Transaction t " +
                    "JOIN M_Product p ON t.M_Product_ID = p.M_Product_ID " +
                    "JOIN C_UOM u ON p.C_UOM_ID = u.C_UOM_ID " +
                    "WHERE t.MovementDate BETWEEN ? AND ? ";

                // ✅ Product filter only if provided
                boolean hasProduct = (productIdStr != null && !productIdStr.trim().isEmpty());

                if (hasProduct) {
                    sql += " AND p.M_Product_ID = ? ";
                }

                sql += " GROUP BY p.M_Product_ID, p.Value, p.Name, u.Name ORDER BY p.Name";

                
                try (Connection con = DB.getConnectionRW();
                     PreparedStatement ps = con.prepareStatement(sql)) {

                    // ✅ Convert dates properly
                    Timestamp fromTs = Timestamp.valueOf(fromDateStr + " 00:00:00");
                    Timestamp toTs   = Timestamp.valueOf(toDateStr + " 23:59:59");

                    // ✅ Bind mandatory params
                    ps.setTimestamp(1, fromTs);
                    ps.setTimestamp(2, toTs);

                    // ✅ Bind optional product
                    if (hasProduct) {
                        ps.setInt(3, Integer.parseInt(productIdStr));
                    }

                    // ✅ Execute query
                    try (ResultSet rs = ps.executeQuery()) {

                        while (rs.next()) {
                            JSONObject row = new JSONObject();

                            // This will now read the MAX(MovementDate) successfully
                            row.put("date", rs.getTimestamp("MovementDate").toString());
                            row.put("productCode", rs.getString("ProductCode"));
                            row.put("productName", rs.getString("ProductName"));
                            row.put("uom", rs.getString("UOM"));

                            row.put("inQty", rs.getBigDecimal("InQty"));
                            row.put("outQty", rs.getBigDecimal("OutQty"));
                            row.put("balanceQty", rs.getBigDecimal("BalanceQty"));

                            result.put(row);
                        }
                        System.out.println("row of data "+result.length());
                    }

            } catch (Exception e) {
                e.printStackTrace();
                resp.setContentType("application/json");
                resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
                return;
            }

            // ✅ Response
            resp.setContentType("application/json");
            resp.getWriter().write(result.toString());
        }
        
        private Timestamp toTs(String dateStr) {
            try {
                return Timestamp.valueOf(dateStr + " 00:00:00");
            } catch (Exception e) {
                return null;
            }
        }

        private Timestamp toTsEnd(String dateStr) {
            try {
                return Timestamp.valueOf(dateStr + " 23:59:59");
            } catch (Exception e) {
                return null;
            }
        }
}