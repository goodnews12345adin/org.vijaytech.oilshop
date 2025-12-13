package org.vijaytech.textile;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.servlet.*;
import javax.servlet.http.*;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MOrder;
import org.compiere.model.Query;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrder;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrderLine;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;
import org.vijaytech.textile.utils.GenerateTextileBillPDF;
import org.vijaytech.textile.utils.WhatsAppSender;

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
            Env.setCtx(ctx);

            // 🔹 Get org/client info
            int AD_Org_ID = Integer.parseInt(session.getAttribute("AD_Org_ID").toString());
            int AD_Client_ID = Integer.parseInt(session.getAttribute("AD_Client_ID").toString());

            // 🔹 Fetch product list
            List<TF_MProduct> prodList = new Query(ctx, TF_MProduct.Table_Name,
                    "IsSold ='Y' AND WeighmentEnabled ='Y' AND  isActive ='Y' AND ProductType ='I' AND AD_Org_ID = ? ", null)
                    .setClient_ID()
                    .setParameters(AD_Org_ID)
                    .list();

            List<Map<String, Object>> productData = new ArrayList<>();

            for (TF_MProduct pro : prodList) {
                Map<String, Object> p = new HashMap<>();
                p.put("value", pro.getValue());
                p.put("name", pro.getName());
                p.put("rate", pro.getBillPrice());
                p.put("uom", pro.getC_UOM().getName());
                p.put("prodId", pro.get_ID());
                productData.add(p);
            }
            System.out.println("product data :" + productData);

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
            RequestDispatcher rd = request.getRequestDispatcher("/pages/sales.jsp");
            rd.forward(request, response);
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
            // 1️⃣ Read JSON from request body
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null)
                    sb.append(line);
            }

            String json = sb.toString();
            System.out.println("Received JSON: " + json);

            JSONObject root = new JSONObject(json);
            JSONObject salesData = root.getJSONObject("salesData");

            Properties ctx = (Properties) session.getAttribute("ctx");
            if (ctx == null)
                ctx = Env.getCtx();

            // 🧩 Ensure mandatory context keys exist
            if (Env.getAD_Client_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Client_ID", 1000000); // your tenant
            if (Env.getAD_Org_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Org_ID", 1000000);
            if (Env.getAD_User_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_User_ID", 100); // your user
            if (Env.getContextAsInt(ctx, "#M_Warehouse_ID") == 0)
                Env.setContext(ctx, "#M_Warehouse_ID", 1000113);

            int adClientId = Env.getAD_Client_ID(ctx);
            int adOrgId = Env.getAD_Org_ID(ctx);

            // ---- Customer ----
            JSONObject customer = salesData.getJSONObject("customer");
            String name = customer.optString("name", "Walk-in");
            String address = customer.optString("address", "");
            String phone = customer.optString("phone", "");

            // Safe discount parsing
            BigDecimal discount = BigDecimal.ZERO;
            try {
                String dStr = salesData.optString("discount", "0").trim();
                if (!dStr.isEmpty()) {
                    discount = new BigDecimal(dStr);
                }
            } catch (Exception e) {
                discount = BigDecimal.ZERO;
            }

            String subtotal = salesData.optString("subtotal", "");
            String total = salesData.optString("total", "");

            System.out.println("Customer Details:");
            System.out.println("Name: " + name);
            System.out.println("Address: " + address);
            System.out.println("Phone: " + phone);
			if(phone.isEmpty() || phone.isBlank() || phone.equals(null)) {
				throw new AdempiereException("Please fill Phone Number ");
				
			}
            // ---- Items ----
            JSONArray items = salesData.getJSONArray("items");
            System.out.println("\nItems:");

            // ✅ Create Order Header (using existing BP for now)
            TF_MBPartner bp = new TF_MBPartner(ctx, 0, null); // existing partner
            bp.setAD_Org_ID(1000000);
            bp.setName(name!=null ? name :"NA");
            bp.setPhone(phone!=null ? phone :"NA");
            bp.setContactName(name!=null ? name :"NA");
            bp.setCity("NA");
            bp.setAddress1(address != null ? address : "NA");
            bp.setSOCreditStatus("X");
            bp.setSO_CreditLimit(BigDecimal.ZERO);
            bp.setIsCustomer(true);
            bp.setIsActive(true);
            bp.saveEx();
            if (adClientId == 0) {
                adClientId = bp.getAD_Client_ID();
                Env.setContext(ctx, "#AD_Client_ID", adClientId);
            }
            if (adOrgId == 0) {
                adOrgId = bp.getAD_Org_ID();
                if (adOrgId == 0)
                    adOrgId = 1000000;
                Env.setContext(ctx, "#AD_Org_ID", adOrgId);
            }

            TF_MOrder ordH = new TF_MOrder(ctx, 0, null);
//            ordH.setAD_Client_ID(adClientId);
            ordH.setAD_Org_ID(adOrgId);
            ordH.setBPartner(bp);
            ordH.setC_DocType_ID(1000041);
            ordH.setC_DocTypeTarget_ID(1000041);
            ordH.setM_Warehouse_ID(Env.getContextAsInt(ctx, "#M_Warehouse_ID"));
            ordH.setPaymentRule("B");
            ordH.setC_BankAccount_ID(1000094);
            ordH.setDateAcct(new Timestamp(System.currentTimeMillis()));
            ordH.setDateOrdered(new Timestamp(System.currentTimeMillis()));
            ordH.setDocStatus(MOrder.DOCSTATUS_Drafted);
            ordH.saveEx();

            System.out.println("order header : " + ordH.get_ID());

            // ✅ Create Order Lines
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);

                int prodId = item.getInt("prodId");
                String product = item.optString("product", "");
                String unit = item.optString("unit", "");

                // Safer BigDecimal parsing
                BigDecimal qty = new BigDecimal(item.get("qty").toString());
                BigDecimal rate = new BigDecimal(item.get("rate").toString()).setScale(2, RoundingMode.HALF_UP);
                BigDecimal amount = new BigDecimal(item.get("amount").toString()).setScale(2, RoundingMode.HALF_UP);

                System.out.println("Item " + (i + 1) + " => Product: " + product +
                        ", Unit: " + unit +
                        ", Qty: " + qty +
                        ", Rate: " + rate +
                        ", Amount: " + amount +
                        ", prodId: " + prodId +
                        ",discount " + discount);

                TF_MProduct prod = new TF_MProduct(ctx, prodId, null);
                prod.setBillPrice(rate);
                prod.saveEx();
                if (prod.getAD_Client_ID() != adClientId) {
                    throw new AdempiereException("Product " + prod.getName() + " belongs to another tenant!");
                }

                TF_MOrderLine ordLine = new TF_MOrderLine(ctx, 0, null);
//                ordLine.setAD_Client_ID(adClientId);
                ordLine.setAD_Org_ID(adOrgId);
                ordLine.setC_Order_ID(ordH.get_ID());
                ordLine.setM_Product_ID(prod.get_ID());
                ordLine.setC_UOM_ID(prod.getC_UOM_ID());
                ordLine.setDiscount(discount); // ✅ FIXED: pass discount value
                ordLine.setQty(qty);
                ordLine.setQtyOrdered(qty);
                ordLine.setPrice(rate);
                ordLine.setPriceActual(rate);
                // Set tax (fixed for now)
                ordLine.setC_Tax_ID(1000017);
                ordLine.saveEx();
            }

            // ✅ Properly Complete the Document
            ordH.setDocAction(MOrder.DOCACTION_Complete);

            if (!ordH.processIt(MOrder.DOCACTION_Complete)) {
                throw new AdempiereException("❌ Could not complete order: " + ordH.getProcessMsg());
            }
            ordH.saveEx();

            // ===== Generate PDF and send WhatsApp =====

            String filename = "invoice_" + ordH.getDocumentNo() + ".pdf";

            String invoicesFolder = request.getServletContext().getRealPath("/invoices");
            if (invoicesFolder == null) {
                // fallback if running from packed WAR with no realPath
                invoicesFolder = System.getProperty("user.dir") + File.separator + "invoices";
            }
            Files.createDirectories(Paths.get(invoicesFolder));

            File pdfFile = new File(invoicesFolder, filename);

            // Generate PDF (returns some info - path / URL)
            String pdfInfo = GenerateTextileBillPDF.generate(pdfFile, ordH.get_ID(),phone, ctx);

            // determine customer phone to send: try partner phone from order, fallback to posted phone variable
            String phoneToSend = phone;
            try {
                if (ordH.getC_BPartner_ID() > 0) {
                    TF_MBPartner bpObj = new TF_MBPartner(ctx, ordH.getC_BPartner_ID(), null);
                    String bpPhone = bpObj.getPhone();
                    if (bpPhone != null && bpPhone.trim().length() > 0)
                        phoneToSend = bpPhone;
                }
            } catch (Exception e) {
                // ignore, fallback to posted phone
            }

            // normalize phone: remove spaces, plus signs, etc.
            if (phoneToSend != null)
                phoneToSend = phoneToSend.replaceAll("[\\s\\+\\-\\(\\)]", "");

            // caption for the document
            String caption = "Invoice #" + (ordH.getDocumentNo() != null ? ordH.getDocumentNo() : ordH.get_ID());

            // Send via WhatsApp
            try {
                WhatsAppSender.sendDocument(phoneToSend, pdfInfo, caption);
            } catch (Exception waex) {
                // log error but do not fail the entire request
            		
                waex.printStackTrace();
                throw new AdempiereException("Whatts App Error");
            }

            response.getWriter().write("{\"status\":\"success\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter()
                    .write("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}
