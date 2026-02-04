package org.vijaytech.oilshop;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
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
        	String fromDateStr  = req.getParameter("fromDate");
        	String toDateStr    = req.getParameter("toDate");

        	resp.setContentType("application/json");

        	JSONArray result = new JSONArray();

        	/* ✅ Validate Dates */
        	if (fromDateStr == null || fromDateStr.isEmpty() ||
        	    toDateStr == null || toDateStr.isEmpty()) {

        	    resp.getWriter().write("{\"error\":\"From Date and To Date required\"}");
        	    return;
        	}

        	/* ✅ SQL Category + Product */
        	String sql =
        	    "SELECT " +
        	    " pc.Name AS CategoryName, " +
        	    " p.Value AS ProductCode, " +
        	    " p.Name AS ProductName, " +
        	    " u.Name AS UOM, " +

        	    " SUM(CASE WHEN t.MovementQty > 0 THEN t.MovementQty ELSE 0 END) AS InQty, " +
        	    " SUM(CASE WHEN t.MovementQty < 0 THEN ABS(t.MovementQty) ELSE 0 END) AS OutQty, " +
        	    " SUM(t.MovementQty) AS BalanceQty " +

        	    "FROM M_Transaction t " +
        	    "JOIN M_Product p ON t.M_Product_ID = p.M_Product_ID " +
        	    "JOIN M_Product_Category pc ON p.M_Product_Category_ID = pc.M_Product_Category_ID " +
        	    "JOIN C_UOM u ON p.C_UOM_ID = u.C_UOM_ID " +

        	    "WHERE t.MovementDate BETWEEN ? AND ? ";

        	boolean hasCategory =
        	        (productCatIdStr != null && !productCatIdStr.trim().isEmpty());

        	if (hasCategory) {
        	    sql += " AND pc.M_Product_Category_ID = ? ";
        	}

        	sql +=
        	    "GROUP BY pc.Name, p.Value, p.Name, u.Name " +
        	    "ORDER BY pc.Name, p.Name";

        	/* ✅ Nested JSON Map */
        	Map<String, JSONObject> categoryMap = new LinkedHashMap<>();

        	try (Connection con = DB.getConnectionRW();
        	     PreparedStatement ps = con.prepareStatement(sql)) {

        	    Timestamp fromTs = Timestamp.valueOf(fromDateStr + " 00:00:00");
        	    Timestamp toTs   = Timestamp.valueOf(toDateStr + " 23:59:59");

        	    ps.setTimestamp(1, fromTs);
        	    ps.setTimestamp(2, toTs);

        	    if (hasCategory) {
        	        ps.setInt(3, Integer.parseInt(productCatIdStr));
        	    }

        	    ResultSet rs = ps.executeQuery();

        	    while (rs.next()) {

        	        String categoryName = rs.getString("CategoryName");

        	        /* ✅ Create Category if not exists */
        	        JSONObject categoryObj = categoryMap.get(categoryName);

        	        if (categoryObj == null) {

        	            categoryObj = new JSONObject();
        	            categoryObj.put("categoryName", categoryName);
        	            categoryObj.put("totalIn", 0);
        	            categoryObj.put("totalOut", 0);
        	            categoryObj.put("totalBalance", 0);

        	            categoryObj.put("products", new JSONArray());

        	            categoryMap.put(categoryName, categoryObj);
        	        }

        	        /* ✅ Product Object */
        	        JSONObject prod = new JSONObject();
        	        prod.put("productCode", rs.getString("ProductCode"));
        	        prod.put("productName", rs.getString("ProductName"));
        	        prod.put("uom", rs.getString("UOM"));

        	        double inQty  = rs.getDouble("InQty");
        	        double outQty = rs.getDouble("OutQty");
        	        double balQty = rs.getDouble("BalanceQty");

        	        prod.put("inQty", inQty);
        	        prod.put("outQty", outQty);
        	        prod.put("balanceQty", balQty);

        	        categoryObj.getJSONArray("products").put(prod);

        	        /* ✅ Update Category Totals */
        	        categoryObj.put("totalIn",
        	                categoryObj.getDouble("totalIn") + inQty);

        	        categoryObj.put("totalOut",
        	                categoryObj.getDouble("totalOut") + outQty);

        	        categoryObj.put("totalBalance",
        	                categoryObj.getDouble("totalBalance") + balQty);
        	    }

        	    result = new JSONArray(categoryMap.values());

        	} catch (Exception e) {
        	    e.printStackTrace();
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