package org.vijaytech.oilshop;

import java.io.BufferedReader; 
import java.io.IOException;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.compiere.model.MProductCategory;
import org.compiere.model.Query;
import org.compiere.util.Env;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MProductCategory;

public class ProductCategory extends HttpServlet{

	    private static final long serialVersionUID = 1L;

	    @Override
	    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
	            throws ServletException, IOException {

	        resp.setContentType("application/json");
	        resp.setCharacterEncoding("UTF-8");

	        HttpSession session = req.getSession(false);
	        System.out.println("data income");
	        // ðŸ”’ SESSION CHECK
	        if (session == null || session.getAttribute("ctx") == null) {
	            resp.getWriter().write("{\"error\":\"Session expired\"}");
	            return;
	        }

	        // ============================
	        // 1ï¸�âƒ£ Read JSON Body
	        // ============================
	        StringBuilder sb = new StringBuilder();
	        try (BufferedReader reader = req.getReader()) {
	            String line;
	            while ((line = reader.readLine()) != null)
	                sb.append(line);
	        }

	        String jsonInput = sb.toString();
	        System.out.println("ðŸ“¥ Received JSON: " + jsonInput);

	        JSONObject json = new JSONObject(jsonInput);

	        // Extract fields
	        String name = json.optString("Name");
	        String value = json.optString("Value");
	        String description = json.optString("Description");

	        if (name == null || name.trim().equals("")) {
	            resp.getWriter().write("{\"error\":\"Name is required\"}");
	            return;
	        }

	        // ============================
	        // 2ï¸�âƒ£ Get Context
	        // ============================
	        Properties ctx = (Properties) session.getAttribute("ctx");
	         Env.setCtx(ctx);

	        if (ctx == null)
	            ctx = Env.getCtx();

	        if (Env.getAD_Client_ID(ctx) == 0)
	            Env.setContext(ctx, "#AD_Client_ID", 1000000);
	        if (Env.getAD_Org_ID(ctx) == 0)
	            Env.setContext(ctx, "#AD_Org_ID", 1000000);
	        if (Env.getAD_User_ID(ctx) == 0)
	            Env.setContext(ctx, "#AD_User_ID", 100);
	        if (Env.getContextAsInt(ctx, "#M_Warehouse_ID") == 0)
	            Env.setContext(ctx, "#M_Warehouse_ID", 1000113);
	        
	        MProductCategory exist= new Query(
	                ctx,
	                MProductCategory.Table_Name,
	                "Value = ?",
	                null
	        )
	        .setClient_ID()
	        .setParameters(value)
	        .firstOnly();
	         
	        if(exist != null) {
	        	 JSONObject error = new JSONObject();
		            error.put("error", true);
		            error.put("details","category value already Exist");
		            resp.setStatus(HttpServletResponse.SC_CONFLICT); // 409
		            resp.setContentType("application/json");
		            resp.setCharacterEncoding("UTF-8");
		            resp.getWriter().write(error.toString());
	        }else {

	        // ============================
	        // 3ï¸�âƒ£ SAVE PRODUCT CATEGORY
	        // ============================
	        try {
	            TF_MProductCategory category = new TF_MProductCategory(ctx, 0, null);

	            category.setName(name);
	            category.setValue(value);
	            category.setDescription(description);

	            category.saveEx();  // ðŸš€ saves to database

	            JSONObject success = new JSONObject();
	            success.put("success", true);
	            success.put("error", false);
	            success.put("message", "Category Saved Successfully");
	            success.put("M_Product_Category_ID", category.get_ID());

	            resp.getWriter().write(success.toString());
	            System.out.println(" Category saved successfully");

	        } catch (Exception e) {
	            e.printStackTrace();
	            JSONObject error = new JSONObject();
	            error.put("error", true);
	            error.put("details", e.getMessage());
	            resp.setStatus(HttpServletResponse.SC_CONFLICT); // 409
	            resp.setContentType("application/json");
	            resp.setCharacterEncoding("UTF-8");

	            resp.getWriter().write(error.toString());
	        }
	    }
	    }


}
