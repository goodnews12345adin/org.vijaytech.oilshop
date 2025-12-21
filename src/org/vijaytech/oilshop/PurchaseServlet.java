package org.vijaytech.oilshop;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.*;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MOrder;
import org.compiere.model.MProduct;
import org.compiere.model.Query;
import org.compiere.util.Env;
import org.compiere.util.Trx;
import org.json.JSONArray;
import org.json.JSONObject;
import org.vijaytech.model.MPriceListUOM;
import org.vijaytech.model.TF_MBPartner;
import org.vijaytech.model.TF_MOrder;
import org.vijaytech.model.TF_MOrderLine;
import org.vijaytech.model.TF_MProduct;

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

        // Ensure mandatory context keys
        if (Env.getAD_Client_ID(ctx) == 0) Env.setContext(ctx, "#AD_Client_ID", 1000000);
        if (Env.getAD_Org_ID(ctx) == 0)    Env.setContext(ctx, "#AD_Org_ID", 1000000);
        if (Env.getAD_User_ID(ctx) == 0)   Env.setContext(ctx, "#AD_User_ID", 100);
        if (Env.getContextAsInt(ctx, "#AD_Role_ID") == 0) Env.setContext(ctx, "#AD_Role_ID", 102);

        String action = request.getParameter("action");

        // ============ AJAX: Get Products ============
        if ("getProducts".equalsIgnoreCase(action)) {
            try {
                // Only purchased, active, weighing-enabled items for this org
                List<TF_MProduct> prodList = new Query(ctx, TF_MProduct.Table_Name,
                        "IsPurchased='Y' AND WeighmentEnabled='Y' AND IsActive='Y' AND ProductType='I' AND AD_Org_ID=?",
                        null)
                        .setClient_ID()         // tenant-safe
                        .setParameters(1000000) // your org; change to Env.getAD_Org_ID(ctx) if needed
                        .list();

                JSONArray arr = new JSONArray();
                for (TF_MProduct prod : prodList) {
                    JSONObject obj = new JSONObject();
                    obj.put("id", prod.get_ID());              // This ID is sent back as prodId
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

        // ============ Normal JSP Load ============
        List<Map<String, Object>> supplierList = new ArrayList<>();
        List<TF_MBPartner> partners = new Query(ctx, TF_MBPartner.Table_Name, "IsVendor='Y'", null)
                .setClient_ID()
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
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("ctx") == null) {
            response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
            return;
        }

        Trx trx = null;

        try {
            // Ensure context
            Properties ctx = (Properties) session.getAttribute("ctx");
            if (ctx == null)
                ctx = Env.getCtx();

            if (Env.getAD_Client_ID(ctx) == 0)          Env.setContext(ctx, "#AD_Client_ID", 1000000);
            if (Env.getAD_Org_ID(ctx) == 0)             Env.setContext(ctx, "#AD_Org_ID", 1000000);
            if (Env.getAD_User_ID(ctx) == 0)            Env.setContext(ctx, "#AD_User_ID", 100);
            if (Env.getContextAsInt(ctx, "#AD_Role_ID") == 0)
                Env.setContext(ctx, "#AD_Role_ID", 102);
            if (Env.getContextAsInt(ctx, "#M_Warehouse_ID") == 0)
                Env.setContext(ctx, "#M_Warehouse_ID", 1000113);

            Timestamp now = new Timestamp(System.currentTimeMillis());
            Env.setContext(ctx, "#Date", now);
            Env.setContext(ctx, "#DateAcct", now);

            // Transaction
            String trxName = Trx.createTrxName("PurchaseSave");
            trx = Trx.get(trxName, true);

            // Read JSON body
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }

            JSONObject root = new JSONObject(sb.toString());
            JSONObject purchaseData = root.getJSONObject("purchaseData");

            int supplierId = purchaseData.getInt("supplierId");
            JSONArray items = purchaseData.getJSONArray("items");

            // ============ Create Purchase Order Header ============
            TF_MOrder order = new TF_MOrder(ctx, 0, trxName);
            TF_MBPartner vendor = new TF_MBPartner(ctx, supplierId, trxName);

            order.setIsSOTrx(false);          // Purchase
            order.setAD_Org_ID(1000000);
            order.setBPartner(vendor);

            order.setM_PriceList_ID(1000059);     // purchase price list (IsSOPriceList = 'N')
            order.setC_DocTypeTarget_ID(1000050); // purchase doc type
            order.setM_Warehouse_ID(1000113);
            order.setDateOrdered(now);
            order.setPaymentRule("B");
            order.setC_BankAccount_ID(1000094);
            order.setDocStatus(MOrder.DOCSTATUS_Drafted);

            Env.setContext(ctx, "#M_Warehouse_ID", order.getM_Warehouse_ID());

            order.saveEx();

            System.out.println("Purchase Order ID: " + order.get_ID());

            // ============ Order Lines ============
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);

                int prodId = item.getInt("prodId");      // sent from getProducts(): TF_MProduct ID
                int uomId = item.getInt("uomId");
                BigDecimal qty = item.getBigDecimal("qty");
                BigDecimal rate = item.getBigDecimal("rate");

                TF_MOrderLine line = new TF_MOrderLine(ctx, 0, trxName);

                // ✅ FIX: load product directly by ID, no extra filter that can hide valid products
                TF_MProduct prod = new TF_MProduct(ctx, prodId, trxName);
                if (prod.get_ID() == 0) {
                    throw new AdempiereException("Product not found for id=" + prodId);
                }

                line.setC_Order_ID(order.getC_Order_ID());
                line.setM_Product_ID(prod.get_ID());
                line.setC_UOM_ID(uomId);
                line.setQty(qty);
                line.setQtyEntered(qty);
                line.setPrice(rate);
                line.setUnitPrice(rate);
                // Optional: set line no
                // line.setLine((i + 1) * 10);

                line.saveEx();
            }

            // ============ Complete the Document ============
            order.setDocAction(MOrder.DOCACTION_Complete);

            if (!order.processIt(MOrder.DOCACTION_Complete)) {
                throw new AdempiereException("Could not complete order: " + order.getProcessMsg());
            }
            order.saveEx();

            // Commit
            trx.commit(true);

            response.getWriter().write(
                    "{\"status\":\"success\",\"orderId\":" + order.getC_Order_ID() + "}");
        } catch (Exception e) {
            e.printStackTrace();
            if (trx != null) {
                try {
                    trx.rollback();
                } catch (Exception ignore) {}
            }
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            if (trx != null) {
                try {
                    trx.close();
                } catch (Exception ignore) {}
            }
        }
    }
}