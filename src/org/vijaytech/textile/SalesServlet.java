package org.vijaytech.textile;



import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.servlet.*;
import javax.servlet.http.*;

import org.compiere.model.MProduct;
import org.compiere.model.Query;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.MPriceListUOM;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;


public class SalesServlet extends HttpServlet {

	 @Override
	    protected void doGet(HttpServletRequest request, HttpServletResponse response)
	            throws ServletException, IOException {

	        HttpSession session = request.getSession(false);

	        // 🔒 Check login/session
	        if (session == null || session.getAttribute("ctx") == null) {
	            response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
	            return;
	        }

	        try {
	            Properties ctx = (Properties) session.getAttribute("ctx");

	            // 🔹 Get org/client info
	            int AD_Org_ID = Integer.parseInt(session.getAttribute("AD_Org_ID").toString());
	            int AD_Client_ID = Integer.parseInt(session.getAttribute("AD_Client_ID").toString());

	            System.out.println("Loading products for Org: " + AD_Org_ID + ", Client: " + AD_Client_ID);

	            // 🔹 Fetch product list
	            List<TF_MProduct> prodList = new Query(ctx, TF_MProduct.Table_Name,
	                    "AD_Org_ID=?", null)
	            		.setClient_ID()
	                    .setParameters(AD_Org_ID)
	                    .list();
	            System.out.println("data : "+prodList.size());
	            List<Map<String, Object>> productData = new ArrayList<>();

	            for (TF_MProduct pro : prodList) {
	                BigDecimal priceByUom = MPriceListUOM.getPrice(ctx, pro.get_ID(), pro.getC_UOM_ID(), 0, true);

	                Map<String, Object> p = new HashMap<>();
	                p.put("id", pro.get_ID());
	                p.put("name", pro.getName());
	                p.put("rate", priceByUom);
	                p.put("uom", pro.getC_UOM_ID());
	                productData.add(p);
	            }

	            // 🔹 Set attributes to send to JSP
	            request.setAttribute("productList", productData);
	            request.setAttribute("orgName", Env.getContext(ctx, "#AD_Org_Name"));
	            request.setAttribute("pageTitle", "Sales Dashboard");

	            // 🔹 Forward to JSP
	            RequestDispatcher rd = request.getRequestDispatcher("/pages/sales.jsp");
	            rd.forward(request, response);

	        } catch (Exception e) {
	            e.printStackTrace();
	            request.setAttribute("errorMessage", e.getMessage());
	            request.getRequestDispatcher("/error.jsp").forward(request, response);
	        }
	    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("✅ SalesServlet POST called");

        // Example: Get form input fields from JSP
        String customerName = request.getParameter("customerName");
        String product = request.getParameter("product");
        String qty = request.getParameter("qty");

        // Do your logic here — save to DB, validate, etc.
        System.out.println("Customer: " + customerName + ", Product: " + product + ", Qty: " + qty);

        // You can pass data back to JSP for confirmation
        request.setAttribute("message", "Sale saved successfully for " + customerName);

        // Forward or redirect after POST
        RequestDispatcher rd = request.getRequestDispatcher("/pages/sales.jsp");
        rd.forward(request, response);
    }
}



