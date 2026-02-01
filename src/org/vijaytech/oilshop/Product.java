package org.vijaytech.oilshop;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Properties;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MProduct;
import org.compiere.model.MProductCategory;
import org.compiere.model.MUOM;
import org.compiere.model.Query;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;
import org.syvasoft.tallyfrontcrusher.model.TF_MProductCategory;

public class Product extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Helper: safe int parser
    private int safeInt(Object o, int fallback) {
        if (o == null) return fallback;
        try {
            return Integer.parseInt(o.toString());
        } catch (Exception e) {
            return fallback;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("ctx") == null) {  // *** FIXED: null check before use ***
            resp.getWriter().write("{\"error\":\"Session expired\"}");
            return;
        }

        int AD_Org_ID = Integer.parseInt(session.getAttribute("AD_Org_ID").toString());
        int AD_Client_ID = Integer.parseInt(session.getAttribute("AD_Client_ID").toString());

        Properties ctx = (Properties) session.getAttribute("ctx");
        if (ctx == null) ctx = Env.getCtx();
        Env.setCtx(ctx);

        try {
            // Load active product categories
            List<TF_MProductCategory> cats = new Query(ctx, TF_MProductCategory.Table_Name, "IsActive='Y'", null)
                    .setClient_ID()
                    .list();

            JSONArray jCats = new JSONArray();
            for (MProductCategory c : cats) {
                JSONObject o = new JSONObject();
                o.put("M_Product_Category_ID", c.getM_Product_Category_ID());
                o.put("Name", c.getName());
                jCats.put(o);
            }

            // Load UOMs (active)
            List<MUOM> uoms = new Query(ctx, MUOM.Table_Name, "IsActive='Y'", null)
                    .setClient_ID()
                    .list();

            JSONArray jUoms = new JSONArray();
            for (MUOM u : uoms) {
                JSONObject o = new JSONObject();
                o.put("C_UOM_ID", u.getC_UOM_ID());
                o.put("Name", u.getName());
                jUoms.put(o);
            }

            // Build response
            JSONObject out = new JSONObject();
            out.put("categories", jCats);
            out.put("uoms", jUoms);

            System.out.println("product data :" + out);

            // Set attributes to send to JSP
            req.setAttribute("productList", jCats);
            req.setAttribute("uom", jUoms);
            req.setAttribute("orgName", Env.getContext(ctx, "#AD_Org_Name"));
            req.setAttribute("pageTitle", "Sales Dashboard");

            // Forward to JSP
            RequestDispatcher rd = req.getRequestDispatcher("/pages/product.jsp");
            rd.forward(req, resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            JSONObject err = new JSONObject();
            err.put("error", ex.getMessage());
            resp.getWriter().write(err.toString());
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("ctx") == null) {
            resp.getWriter().write("{\"error\":\"Session expired\"}");
            return;
        }

        // Read JSON body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null)
                sb.append(line);
        }
        String input = sb.toString();
        System.out.println("📥 Product JSON: " + input);

        JSONObject json = new JSONObject(input);

        // Context
        Properties ctx = (Properties) session.getAttribute("ctx");
        if (ctx == null) ctx = Env.getCtx();

        if (Env.getAD_Client_ID(ctx) == 0)
            Env.setContext(ctx, "#AD_Client_ID", 1000000);
        if (Env.getAD_Org_ID(ctx) == 0)
            Env.setContext(ctx, "#AD_Org_ID", 1000000);
        if (Env.getAD_User_ID(ctx) == 0)
            Env.setContext(ctx, "#AD_User_ID", 100);
        if (Env.getContextAsInt(ctx, "#M_Warehouse_ID") == 0)
            Env.setContext(ctx, "#M_Warehouse_ID", 1000113);
        int clientId = Env.getAD_Client_ID(ctx);   // *** NEW: use for unique check ***
        Env.setCtx(ctx);

        // AD_Org_ID from session fallback
        int sessionOrg = 0;
        try {
            Object o = session.getAttribute("AD_Org_ID");
            if (o != null) sessionOrg = Integer.parseInt(o.toString());
        } catch (Exception e) {
            sessionOrg = 0;
        }

        try {
            // Validate category
            int categoryID = json.optInt("M_Product_Category_ID", 0);
            if (categoryID == 0) {
                resp.getWriter().write("{\"error\":\"Product Category is required\"}");
                return;
            }

            TF_MProductCategory cat = new TF_MProductCategory(ctx, categoryID, null);
            if (cat == null || cat.get_ID() == 0) {
                resp.getWriter().write("{\"error\":\"Invalid Category\"}");
                return;
            }

            int productId = json.optInt("productId", 0);

            // *** NEW: Read Value & Name early ***
            String value = json.optString("Value", null);
            String name = json.optString("Name", null);
            if ((name == null || name.trim().isEmpty()) && value != null) {
                name = value;
            }

            // *** NEW: prevent duplicate product VALUE for new records ***
            if (productId == 0 && value != null && !value.trim().isEmpty()) {
                TF_MProduct existing = new Query(ctx, TF_MProduct.Table_Name,
                        "AD_Client_ID=? AND Value=?", null)
                        .setParameters(clientId, value.trim())
                        .first();

                if (existing != null && existing.get_ID() > 0) {
                    // There is already a product with same Value for this client
                    JSONObject out = new JSONObject();
                    out.put("success", false);
                    out.put("errorCode", "DUPLICATE_VALUE");
                    out.put("message", "Product code already exists: " + value);
                    out.put("existingProductId", existing.get_ID());
                    resp.getWriter().write(out.toString());
                    return;
                }
            }

            // Create or load product
            TF_MProduct product = new TF_MProduct(ctx, productId, null);

            // If creating new product, set default flags first
            if (productId == 0) {
                product.setAD_Org_ID(sessionOrg > 0 ? sessionOrg : Env.getAD_Org_ID(ctx));
            }

            // Map fields: Value and Name
            if (value != null) product.setValue(value.trim());
            if (name != null) product.setName(name.trim());

            // Always set category and org if provided
            product.setM_Product_Category_ID(categoryID);

            int orgFromJson = json.optInt("AD_Org_ID", 0);
            if (orgFromJson > 0) product.setAD_Org_ID(orgFromJson);
            else if (product.getAD_Org_ID() == 0 && sessionOrg > 0) product.setAD_Org_ID(sessionOrg);

            // UOM
            int uom = json.optInt("C_UOM_ID", 0);
            if (uom == 0) {
                // fallback: try a common UOM id or leave as is
                uom = 1000083; // your default UOM id (adjust as needed)
            }
            product.setC_UOM_ID(uom);

            // Optional fields
            if (json.has("Description")) product.setDescription(json.optString("Description", null));
            if (json.has("HSNCode")) product.setHSNCode(json.optString("HSNCode", null));
          

			/*
			 * if (json.has("Barcode")) { String bar = json.optString("Barcode", null); if
			 * (bar != null && !bar.trim().isEmpty()) { product.setUPC(bar);
			 * product.setSKU(bar); } }
			 */

            // BillPrice with proper BigDecimal scale(2)
            if (json.has("BillPrice")) {
                try {
                    double d = json.optDouble("BillPrice", 0.0);
                    BigDecimal billPrice = BigDecimal.valueOf(d).setScale(2, RoundingMode.HALF_UP);
                    product.setBillPrice(billPrice);
                } catch (Exception e) {
                    throw new AdempiereException("Please fill product price !!");
                }
            }

            // Qty (custom column) with scale(3)
			/*
			 * if (json.has("Qty")) { try { double q = json.optDouble("Qty", 0.0);
			 * BigDecimal qty = BigDecimal.valueOf(q).setScale(3, RoundingMode.HALF_UP);
			 * product.set_CustomColumn("Qty", qty); } catch (Exception e) { throw new
			 * AdempiereException("Invalid Qty format!"); } }
			 */

            // Rate (custom column) with scale(2)
            if (json.has("Rate")) {
                try {
                    double r = json.optDouble("Rate", 0.0);
                    BigDecimal rate = BigDecimal.valueOf(r).setScale(2, RoundingMode.HALF_UP);
                    product.set_CustomColumn("Rate", rate);
                } catch (Exception e) {
                    throw new AdempiereException("Invalid Rate format!");
                }
            }
            if (json.has("TaxRate")) {
                try {
                    double r = json.optDouble("TaxRate", 0.0);
                    BigDecimal rate = BigDecimal.valueOf(r).setScale(2, RoundingMode.HALF_UP);
                    product.setGSTRate(rate);
                } catch (Exception e) {
                    throw new AdempiereException("Invalid Rate format!");
                }
            }

            product.setIsSummary(false);
            product.setProductType(MProduct.PRODUCTTYPE_Item);
            product.setC_TaxCategory_ID(1000005);
            product.setC_Activity_ID(1000000);
            product.setIsStocked(true);

            String entryType = json.optString("EntryType", "").trim();

            if (entryType.isEmpty()) {
                resp.getWriter().write("{\"error\":\"Entry Type is required\"}");
                return;
            }

            if (entryType.equalsIgnoreCase("Purchase")) {
                product.setIsPurchased(true);
                product.setIsSold(false);

            } else if (entryType.equalsIgnoreCase("Sales")) {
                product.setIsSold(true);
                product.setIsPurchased(false);

            } else if (entryType.equalsIgnoreCase("Both")) {
                product.setIsPurchased(true);
                product.setIsSold(true);

            } else {
                resp.getWriter().write("{\"error\":\"Invalid Entry Type\"}");
                return;
            }


            // WeighmentEnabled always true (Y)
            product.set_CustomColumn("WeighmentEnabled", Boolean.TRUE);

            product.setIsActive(true);

            // Save product
            product.saveEx();

            // Response
            JSONObject out = new JSONObject();
            out.put("success", true);
            out.put("M_Product_ID", product.get_ID());
            out.put("message", "Product saved successfully");
            resp.getWriter().write(out.toString());

        } catch (Exception ex) {
            ex.printStackTrace();
            JSONObject err = new JSONObject();
            err.put("success", false);
            err.put("error", ex.getMessage());
            resp.getWriter().write(err.toString());
        }
    }
}
