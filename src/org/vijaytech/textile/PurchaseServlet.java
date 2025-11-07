package org.vijaytech.textile;


import java.io.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.compiere.model.*;
import org.compiere.util.*;
import org.json.*;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrder;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrderLine;

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

        List<Map<String, Object>> supplierList = new ArrayList<>();
        List<TF_MBPartner> partners = new Query(ctx, TF_MBPartner.Table_Name, "IsVendor='Y'", null).list();
        for (TF_MBPartner bp : partners) {
            Map<String, Object> s = new HashMap<>();
            s.put("id", bp.get_ID());
            s.put("name", bp.getName());
            supplierList.add(s);
        }

        List<Map<String, Object>> productList = new ArrayList<>();
        List<MProduct> prods = new Query(ctx, MProduct.Table_Name, "IsActive='Y'", null).list();
        for (MProduct p : prods) {
            Map<String, Object> prod = new HashMap<>();
            prod.put("id", p.get_ID());
            prod.put("name", p.getName());
            productList.add(prod);
        }
System.out.println("products   "+productList);
        request.setAttribute("supplierList", supplierList);
        request.setAttribute("productList", productList);
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

        try {
            Properties ctx = (Properties) session.getAttribute("ctx");
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
            TF_MOrder order = new TF_MOrder(ctx, 0, null);
            TF_MBPartner vendor = new TF_MBPartner(ctx, supplierId, null);
            order.setAD_Org_ID(1000000);
            order.setBPartner(vendor);
            order.setC_DocTypeTarget_ID(1000061); // Purchase type
            order.setM_Warehouse_ID(1000113);
            order.setDateOrdered(new Timestamp(System.currentTimeMillis()));
            order.setPaymentRule("B");
            order.saveEx();

            // Order Lines
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);
                int prodId = item.getInt("prodId");
                BigDecimal qty = item.getBigDecimal("qty");
                BigDecimal rate = item.getBigDecimal("rate");

                TF_MOrderLine line = new TF_MOrderLine(ctx, 0, null);
                line.setC_Order_ID(order.getC_Order_ID());
                line.setM_Product_ID(prodId);
                line.setQty(qty);
                line.setPrice(rate);
                line.setLine((i + 1) * 10);
                line.saveEx();
            }

            response.getWriter().write("{\"status\":\"success\",\"orderId\":" + order.getC_Order_ID() + "}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}

