package org.vijaytech.oilshop;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MOrder;
import org.compiere.model.Query;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrder;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrderLine;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;
import org.vijaytech.oilshop.utils.GenerateTextileBillPDF;
import org.vijaytech.oilshop.utils.WhatsAppSender;

public class SalesServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check login/session
        if (session == null || session.getAttribute("ctx") == null) {
            response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
            return;
        }

        try {
            Properties ctx = (Properties) session.getAttribute("ctx");
            Env.setCtx(ctx);

            // Get org/client info
            int AD_Org_ID = Integer.parseInt(session.getAttribute("AD_Org_ID").toString());
            int AD_Client_ID = Integer.parseInt(session.getAttribute("AD_Client_ID").toString());

            // Fetch product list
            List<TF_MProduct> prodList = new Query(ctx, TF_MProduct.Table_Name,
                    "IsSold ='Y' AND WeighmentEnabled ='Y' AND  isActive ='Y' AND ProductType ='I' ", null)
                    .setClient_ID()
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
            System.out.println("Product data loaded: " + productData.size());

            // Set attributes to send to JSP
            request.setAttribute("productList", productData);
            request.setAttribute("orgName", Env.getContext(ctx, "#AD_Org_Name"));
            request.setAttribute("pageTitle", "Sales Dashboard");

            // Forward to JSP
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

        // Check login/session
        if (session == null || session.getAttribute("ctx") == null) {
            response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
            return;
        }

        try {
            // 1. Read JSON from request body
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

            // Ensure mandatory context keys exist
            if (Env.getAD_Client_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Client_ID", 1000000);
            if (Env.getAD_Org_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Org_ID", 1000000);
            if (Env.getAD_User_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_User_ID", 100);
            if (Env.getContextAsInt(ctx, "#M_Warehouse_ID") == 0)
                Env.setContext(ctx, "#M_Warehouse_ID", 1000113);

            int adClientId = Env.getAD_Client_ID(ctx);
            int adOrgId = Env.getAD_Org_ID(ctx);

            // ---- Customer Details ----
            JSONObject customer = salesData.getJSONObject("customer");
            String name = customer.optString("name", "Walk-in");
            String address = customer.optString("address", "");
            String phone = customer.optString("phone", "");

            if (phone == null || phone.trim().isEmpty()) {
                throw new AdempiereException("Please fill Phone Number");
            }

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

            System.out.println("Customer: " + name + " | Phone: " + phone);

            // ---- Items Processing ----
            JSONArray items = salesData.getJSONArray("items");

            // Create/Update Business Partner
            TF_MBPartner bp = new TF_MBPartner(ctx, 0, null);
            bp.setAD_Org_ID(1000000);
            bp.setName(name != null ? name : "NA");
            bp.setPhone(phone);
            bp.setContactName(name);
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

            // Create Order Header
            TF_MOrder ordH = new TF_MOrder(ctx, 0, null);
            ordH.setC_DocType_ID(1000041);
            ordH.setC_DocTypeTarget_ID(1000041);
            ordH.setM_Warehouse_ID(Env.getContextAsInt(ctx, "#M_Warehouse_ID"));
            ordH.setPaymentRule("B");
            ordH.setM_PriceList_ID(1000058);
            ordH.setC_BankAccount_ID(1000094);
            ordH.setDateAcct(new Timestamp(System.currentTimeMillis()));
            ordH.setDateOrdered(new Timestamp(System.currentTimeMillis()));
            ordH.setDocStatus(MOrder.DOCSTATUS_Drafted);
            ordH.saveEx();

            System.out.println("Order Header Created: " + ordH.get_ID());

            // Create Order Lines
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);

                int prodId = item.getInt("prodId");
                // String product = item.optString("product", ""); // Not strictly needed if ID is valid
                
                // Parsing values safely
                BigDecimal qty = new BigDecimal(item.get("qty").toString());
                BigDecimal rate = new BigDecimal(item.get("rate").toString()).setScale(2, RoundingMode.HALF_UP);
                BigDecimal amount = new BigDecimal(item.get("amount").toString()).setScale(2, RoundingMode.HALF_UP);

                TF_MProduct prod = new TF_MProduct(ctx, prodId, null);
                prod.setBillPrice(rate);
                prod.saveEx();
                
                if (prod.getAD_Client_ID() != adClientId) {
                    throw new AdempiereException("Product " + prod.getName() + " belongs to another tenant!");
                }

                TF_MOrderLine ordLine = new TF_MOrderLine(ctx, 0, null);
                ordLine.setAD_Org_ID(adOrgId);
                ordLine.setC_Order_ID(ordH.get_ID());
                ordLine.setM_Product_ID(prod.get_ID());
                ordLine.setC_UOM_ID(prod.getC_UOM_ID());
                ordLine.setDiscount(discount);
                ordLine.setQty(qty);
                ordLine.setQtyOrdered(qty);
                ordLine.setPrice(rate);
                ordLine.setPriceActual(rate);
                ordLine.setC_Tax_ID(1000017);
                ordLine.saveEx();
            }

            // Complete the Document
            ordH.setDocAction(MOrder.DOCACTION_Complete);

            if (!ordH.processIt(MOrder.DOCACTION_Complete)) {
                throw new AdempiereException("Could not complete order: " + ordH.getProcessMsg());
            }
            ordH.saveEx();

            String docNo = ordH.getDocumentNo(); // CRITICAL: Get the document number
            System.out.println("Order Completed. Document No: " + docNo);

            // ===== Generate PDF and send WhatsApp =====
            String filename = "invoice_" + docNo + ".pdf";
            String invoicesFolder = request.getServletContext().getRealPath("/invoices");
            
            if (invoicesFolder == null) {
                invoicesFolder = System.getProperty("user.dir") + File.separator + "invoices";
            }
            Files.createDirectories(Paths.get(invoicesFolder));
            File pdfFile = new File(invoicesFolder, filename);

            // Generate PDF
            String pdfInfo = GenerateTextileBillPDF.generate(pdfFile, ordH.get_ID(), phone, ctx);

            // Send WhatsApp (Non-blocking on error)
            try {
                String phoneToSend = phone.replaceAll("[\\s\\+\\-\\(\\)]", "");
                String caption = "Invoice #" + docNo;
                WhatsAppSender.sendDocument(phoneToSend, pdfInfo, caption);
            } catch (Exception waex) {
                // Do not fail the transaction if WA fails. Just log it.
                System.err.println("WhatsApp sending failed for " + docNo);
                waex.printStackTrace();
            }

            // Return JSON with docNo
            JSONObject jsonResp = new JSONObject();
            jsonResp.put("status", "success");
            jsonResp.put("docNo", docNo);
            response.getWriter().write(jsonResp.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            // Escape quotes in error message
            String errorMsg = e.getMessage().replace("\"", "'");
            response.getWriter().write("{\"status\":\"error\", \"error\":\"" + errorMsg + "\"}");
        }
    }
}