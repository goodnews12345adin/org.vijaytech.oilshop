package org.vijaytech.textile;

import java.io.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.*;
import org.compiere.process.DocAction;
import org.compiere.util.*;
import org.json.*;
import org.syvasoft.tallyfrontcrusher.model.MPriceListUOM;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrder;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrderLine;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;

public class PurchaseServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
	        throws IOException, ServletException {

	    HttpSession session = request.getSession(false);
	    if (session == null || session.getAttribute("ctx") == null) {
	        response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
	        return;
	    }

	    Properties ctx = (Properties) session.getAttribute("ctx");
        Env.setCtx(ctx);

	    // FIX: ensure mandatory context keys (guards cross-tenant/context lost during reads)
	    if (Env.getAD_Client_ID(ctx) == 0) Env.setContext(ctx, "#AD_Client_ID", 1000000);
	    if (Env.getAD_Org_ID(ctx) == 0)    Env.setContext(ctx, "#AD_Org_ID", 1000000);
	    if (Env.getAD_User_ID(ctx) == 0)   Env.setContext(ctx, "#AD_User_ID", 100);
	    if (Env.getContextAsInt(ctx, "#AD_Role_ID") == 0) Env.setContext(ctx, "#AD_Role_ID", 102);

	    String action = request.getParameter("action");

	    // ✅ Step 1: Handle AJAX request first
	    if ("getProducts".equalsIgnoreCase(action)) {
	        try {
	            // FIX: also filter by client to avoid cross-tenant reads
	            List<TF_MProduct> prodList = new Query(ctx, TF_MProduct.Table_Name,
	                    "IsPurchased='Y' AND IsSold ='N' AND AD_Org_ID=?", null)
	                    .setClient_ID() // adds AD_Client filter
	                    .setParameters(1000000) // your org
	                    .list();

	            JSONArray arr = new JSONArray();
	            for (TF_MProduct prod : prodList) {
	                JSONObject obj = new JSONObject();
	                obj.put("id", prod.get_ID());
	                obj.put("uom", prod.getC_UOM().getName());
	                obj.put("uomId", prod.getC_UOM_ID());
	                obj.put("name", prod.getName());
	                obj.put("rate", prod.getBillPrice());
	                arr.put(obj);
	            }

	            response.setContentType("application/json");
	            response.setCharacterEncoding("UTF-8");
	            response.getWriter().write(arr.toString());
	        } catch (Exception e) {
	            e.printStackTrace();
	            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
	            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
	        }
	        return; // stop here, don’t forward
	    }

	    // ✅ Step 2: Normal JSP load
	    List<Map<String, Object>> supplierList = new ArrayList<>();
	    List<TF_MBPartner> partners = new Query(ctx, TF_MBPartner.Table_Name, "IsVendor='Y'", null)
	            .setClient_ID() // FIX: tenant-safe
	            .list();
	    for (TF_MBPartner bp : partners) {
	        Map<String, Object> s = new HashMap<>();
	        s.put("id", bp.get_ID());
	        s.put("name", bp.getName());
	        supplierList.add(s);
	    }

	    request.setAttribute("supplierList", supplierList);
	    RequestDispatcher rd = request.getRequestDispatcher("/pages/Purchase.jsp");
	    rd.forward(request, response);
	}

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json");
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("ctx") == null) {
            response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
            return;
        }

        // We'll manage a transaction for the whole save + complete flow
        Trx trx = null;

        try {
            // ✅ Ensure context is valid
            Properties ctx = (Properties) session.getAttribute("ctx");
            if (ctx == null) ctx = Env.getCtx();

            // 🧩 Ensure mandatory context keys exist (Context lost if any missing)
            if (Env.getAD_Client_ID(ctx) == 0)          Env.setContext(ctx, "#AD_Client_ID", 1000000); // your tenant
            if (Env.getAD_Org_ID(ctx) == 0)             Env.setContext(ctx, "#AD_Org_ID", 1000000);
            if (Env.getAD_User_ID(ctx) == 0)            Env.setContext(ctx, "#AD_User_ID", 100);       // your user
            if (Env.getContextAsInt(ctx, "#AD_Role_ID") == 0) Env.setContext(ctx, "#AD_Role_ID", 102);
            if (Env.getContextAsInt(ctx, "#M_Warehouse_ID") == 0)
                Env.setContext(ctx, "#M_Warehouse_ID", 1000113);
            // FIX: add dates in context (some flows rely on these)
            Timestamp now = new Timestamp(System.currentTimeMillis());
            Env.setContext(ctx, "#Date", now);
            Env.setContext(ctx, "#DateAcct", now);

            // Create a transaction and pass its name to all model operations
            String trxName = Trx.createTrxName("PurchaseSave");
            trx = Trx.get(trxName, true);

            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null)
                    sb.append(line);
            }

            JSONObject root = new JSONObject(sb.toString());
            JSONObject purchaseData = root.getJSONObject("purchaseData");

            int supplierId = purchaseData.getInt("supplierId");
            JSONArray items = purchaseData.getJSONArray("items");

            // Create Purchase Order Header
            TF_MOrder order = new TF_MOrder(ctx, 0, trxName);
            TF_MBPartner vendor = new TF_MBPartner(ctx, supplierId, trxName);

            order.setIsSOTrx(false); // FIX: this is a purchase document
            order.setAD_Org_ID(1000000);
            order.setBPartner(vendor);

            order.setM_PriceList_ID(1000059);   // purchase price list (IsSOPriceList = 'N')
            order.setC_DocTypeTarget_ID(1000050); // purchase doc type
            order.setM_Warehouse_ID(1000113);
            order.setDateOrdered(now);
            order.setPaymentRule("B");
            order.setC_BankAccount_ID(1000094);
            order.setDocStatus(MOrder.DOCSTATUS_Drafted);

            // Keep context warehouse consistent with header for reserveStock()
            Env.setContext(ctx, "#M_Warehouse_ID", order.getM_Warehouse_ID());

            order.saveEx(); // will use trxName internally

            System.out.println("purchase Id :" + order.get_ID());

            // Order Lines
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);
                int prodId = item.getInt("prodId");   // This is TF_PriceListUOM_ID as per your JSON mapping
                int uomId = item.getInt("uomId");
                BigDecimal qty = item.getBigDecimal("qty");
                BigDecimal rate = item.getBigDecimal("rate");

                TF_MOrderLine line = new TF_MOrderLine(ctx, 0, trxName);

                // Load the product via PriceListUOM entry (tenant-safe)
                TF_MProduct priceList = new Query(ctx, TF_MProduct.Table_Name,
                        "IsSold='N' AND M_Product_ID=?", trxName)
                        .setClient_ID()
                        .setParameters(prodId)
                        .firstOnly();
                if (priceList == null) {
                    throw new AdempiereException("product not found for id=" + prodId);
                }

                MProduct prod = new MProduct(ctx, priceList.getM_Product_ID(), trxName);

                line.setC_Order_ID(order.getC_Order_ID());
                line.setM_Product_ID(prod.get_ID());
                line.setC_UOM_ID(uomId);
                line.setQty(qty);
                line.setPrice(rate);
                line.setQtyEntered(qty);
                line.setUnitPrice(rate);
                // line.setLine((i + 1) * 10);
                line.saveEx();
            }

            // ✅ Properly Complete the Document
            order.setDocAction(MOrder.DOCACTION_Complete);

            if (!order.processIt(MOrder.DOCACTION_Complete)) {
                throw new AdempiereException("Could not complete order: " + order.getProcessMsg());
            }
            order.saveEx();

            // Commit the transaction
            trx.commit(true);

            response.getWriter().write("{\"status\":\"success\",\"orderId\":" + order.getC_Order_ID() + "}");
        } catch (Exception e) {
            e.printStackTrace();
            if (trx != null) {
                try { trx.rollback(); } catch (Exception ignore) {}
            }
            // Return HTTP 500
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            if (trx != null) {
                try { trx.close(); } catch (Exception ignore) {}
            }
        }
    }
}
