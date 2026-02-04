package org.vijaytech.oilshop;

import java.io.IOException;
import java.util.List;
import java.util.Properties;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.compiere.model.Query;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;

public class ProductEditAndUpdate extends HttpServlet {

    // ✅ GET = List Products OR Fetch Single Product for Edit
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Properties ctx = Env.getCtx();

        try {

            // ✅ CASE 1: Edit Request (Single Product)
            String idParam = req.getParameter("id");

            if (idParam != null && !idParam.isEmpty()) {

                int productId = Integer.parseInt(idParam);

                TF_MProduct p = new TF_MProduct(ctx, productId, null);

                JSONObject obj = new JSONObject();
                obj.put("productId", p.getM_Product_ID());
                obj.put("Value", p.getValue());
                obj.put("Name", p.getName());
                obj.put("M_Product_Category_ID", p.getM_Product_Category_ID());
                obj.put("C_UOM_ID", p.getC_UOM_ID());
                obj.put("HSNCode", p.getUPC());
                obj.put("BillPrice", p.getBillPrice());
                obj.put("Description", p.getDescription());

                resp.getWriter().write(obj.toString());
                return;
            }

            // ✅ CASE 2: Product List Request (All Products)

            JSONArray arr = new JSONArray();

            List<TF_MProduct> products = new Query(ctx, TF_MProduct.Table_Name,
                    "IsActive='Y'", null)
                    .setClient_ID()
                    .list();

            for (TF_MProduct p : products) {

                JSONObject o = new JSONObject();
                o.put("productId", p.getM_Product_ID());
                o.put("Value", p.getValue());
                o.put("Name", p.getName());
                o.put("BillPrice", p.getBillPrice());

                arr.put(o);
            }

            resp.getWriter().write(arr.toString());

        } catch (Exception ex) {
            ex.printStackTrace();

            JSONObject err = new JSONObject();
            err.put("error", ex.getMessage());

            resp.getWriter().write(err.toString());
        }
    }

    // ✅ POST = Insert OR Update Product
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Properties ctx = Env.getCtx();

        try {

            JSONObject json = new JSONObject(
                    req.getReader().lines().collect(java.util.stream.Collectors.joining())
            );

            int productId = json.getInt("productId");

            TF_MProduct product;

            // ✅ INSERT
            if (productId == 0) {
                product = new TF_MProduct(ctx, 0, null);
            }
            // ✅ UPDATE
            else {
                product = new TF_MProduct(ctx, productId, null);
            }

            product.setValue(json.getString("Value"));
            product.setName(json.getString("Name"));
            product.setM_Product_Category_ID(json.getInt("M_Product_Category_ID"));
            product.setC_UOM_ID(json.getInt("C_UOM_ID"));
            product.setUPC(json.optString("HSNCode"));
            product.setBillPrice(json.getBigDecimal("BillPrice"));
            product.setDescription(json.optString("Description"));

            product.saveEx();

            JSONObject out = new JSONObject();
            out.put("success", true);
            out.put("message",
                    productId == 0 ? "Product Inserted Successfully" : "Product Updated Successfully");

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