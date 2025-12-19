package org.vijaytech.oilshop;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.compiere.model.MProduct;
import org.compiere.model.PO;
import org.compiere.model.Query;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.MPriceListUOM;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;

public class LoadBillInfo extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
    	 response.setContentType("application/json");
         response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("ctx") == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print(new JSONObject().put("error", "Session expired"));
                return;
            }
            System.out.println("org id : "+request.getParameter("AD_Org_ID"));
            Properties ctx = (Properties) session.getAttribute("ctx");
	         Env.setCtx(ctx);

            int AD_Org_ID = Integer.parseInt(request.getParameter("AD_Org_ID"));
            int AD_Client_ID = Integer.parseInt(session.getAttribute("AD_Client_ID").toString());
            String barcode = request.getParameter("barcode"); // optional
            System.out.println("org id : "+AD_Org_ID);
            System.out.println("AD_Client_ID : "+AD_Client_ID);

            JSONObject resultJSON = new JSONObject();
            JSONArray productArray = new JSONArray();

            if (barcode != null && !barcode.trim().isEmpty()) {
                // Fetch product by barcode
               TF_MProduct prod = new Query(ctx, TF_MProduct.Table_Name, "Value=?", null)
                        .setParameters(barcode.trim())
                        .first();
                if (prod != null) {
                    JSONObject p = new JSONObject();
                    p.put("productName", prod.getName());
                    p.put("rate", prod.getUnitsPerPack());
                    p.put("uom", prod.getC_UOM_ID());
                    productArray.put(p);
                }
            } else {
                // Fetch all active products for the org
                List<TF_MProduct> prod = new Query(ctx, TF_MProduct.Table_Name,
                        "AD_Org_ID=? AND AD_Client_ID=? AND IsActive='Y'", null)
                        .setParameters(AD_Org_ID, AD_Client_ID)
                        .list();
               
                        for(MProduct pro:prod ) {
                        	 BigDecimal priceByUom = MPriceListUOM.getPrice( ctx,  pro.get_ID(),pro.getC_UOM_ID(), 0,true);
                    JSONObject p = new JSONObject();
                    p.put("productName", pro.getName());
                    p.put("productId", pro.get_ID());
                    p.put("rate", priceByUom);
                    p.put("uom", pro.getC_UOM_ID());
                    productArray.put(p);
                        }
                }
            resultJSON.put("productRates", productArray);
            resultJSON.put("orgName", Env.getContext(ctx, "#AD_Org_Name"));
            resultJSON.put("date", new java.util.Date().toString());
            System.out.println("load product : "+resultJSON.toString());
            out.print(resultJSON.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(new JSONObject().put("error", e.getMessage()));
        } finally {
            out.flush();
            out.close();
        }
    }
}
