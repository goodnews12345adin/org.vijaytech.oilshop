package org.vijaytech.oilshop;

import java.io.IOException;
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
import org.compiere.util.Env;

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
	            List<Map<String, Object>> categoryList = new ArrayList<>();
	            List<Map<String, Object>> productList = new ArrayList<>();

	            // Using MProductCategory (Standard)
	            List<MProductCategory> cats = new Query(ctx, MProductCategory.Table_Name, "IsActive='Y'", null)
	                    .setClient_ID()
	                    .list();

	            for (MProductCategory c : cats) {
	                Map<String, Object> m = new HashMap<>();
	                m.put("id", c.get_ID());
	                m.put("name", c.getName());
	                categoryList.add(m);
	            }
	            
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

	            req.setAttribute("categoryList", categoryList);
	            req.setAttribute("productList", productList);

	            RequestDispatcher rd = req.getRequestDispatcher("/pages/profitandloss.jsp");
	            rd.forward(req, resp);

	        } catch (Exception e) {
	            e.printStackTrace();
	            throw new ServletException("Error loading Report", e);
	        }
	    }
}
