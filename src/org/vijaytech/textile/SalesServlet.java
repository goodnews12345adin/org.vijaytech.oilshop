package org.vijaytech.textile;



import java.io.BufferedReader;
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
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrder;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrderLine;
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


	            // 🔹 Fetch product list
	            List<MPriceListUOM> prodList = new Query(ctx, MPriceListUOM.Table_Name,
	                    "IsSOTrx ='Y' AND AD_Org_ID =? ", null)
	            		.setClient_ID()
	                    .setParameters(1000000)
	                    .list();
	            List<Map<String, Object>> productData = new ArrayList<>();

	            for (MPriceListUOM pro : prodList) {
	                BigDecimal priceByUom = MPriceListUOM.getPrice(ctx, pro.get_ID(), pro.getC_UOM_ID(), 0, true);

	                Map<String, Object> p = new HashMap<>();
	          
	                p.put("name", pro.getM_Product().getName());
	                p.put("rate", pro.getPrice());
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
	            throws IOException {
	        response.setContentType("application/json");
	        HttpSession session = request.getSession(false);

	        // 🔒 Check login/session
	        if (session == null || session.getAttribute("ctx") == null) {
	            response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
	            return;
	        }
	        try {
            Properties ctx = (Properties) session.getAttribute("ctx");

	        // Read JSON body
	        StringBuilder sb = new StringBuilder();
	        String line;
	        try (BufferedReader reader = request.getReader()) {
	            while ((line = reader.readLine()) != null) {
	                sb.append(line);
	            }
	        }

	        String json = sb.toString();
	        System.out.println("Received JSON: " + json);
	        JSONObject root = new JSONObject(json);
	        JSONObject salesData = root.getJSONObject("salesData");

	        // ---- Customer ----
	        JSONObject customer = salesData.getJSONObject("customer");
	        String name = customer.getString("name");
	        String address = customer.getString("address");
	        String phone = customer.getString("phone");

	        System.out.println("Customer Details:");
	        System.out.println("Name: " + name);
	        System.out.println("Address: " + address);
	        System.out.println("Phone: " + phone);

	        // ---- Items ----
	        JSONArray items = salesData.getJSONArray("items");
	        System.out.println("\nItems:");
	        for (int i = 0; i < items.length(); i++) {
	            JSONObject item = items.getJSONObject(i);
	            int qty = item.getInt("qty");
	            double rate = item.getDouble("rate");
	            double amount = item.getDouble("amount");

	            System.out.println("Qty: " + qty + ", Rate: " + rate + ", Amount: " + amount);
	        }
	        
	        TF_MOrder ordH = new TF_MOrder(ctx, 0, null);
	        TF_MBPartner bp = new TF_MBPartner(ctx, 1005586, null);
	        ordH.setAD_Org_ID(1000000);
	        ordH.setBPartner(bp);
	        ordH.setC_DocType_ID(1000062);
	        ordH.setM_Warehouse_ID(1000113);
	        ordH.setPaymentRule("B");
	        ordH.saveEx();
	        TF_MOrderLine  ordLine = new TF_MOrderLine(ctx, 0, null);
	        ordLine.setOrder(ordH);
	        
	        
	        response.getWriter().write("{\"status\":\"success\"}");
	    }catch(Exception e) {
	    	e.printStackTrace();
	    }
}
	 }



