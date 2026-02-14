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
import org.compiere.model.MTax;
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
    
    // =====================================================
    // DEFAULT GST RATE FOR EDIBLE OIL = 5%
    // CGST = 2.5%, SGST = 2.5% (for intra-state)
    // This is ONLY used as fallback when product has no tax configured
    // =====================================================
    private static final BigDecimal DEFAULT_GST_RATE = new BigDecimal("5");
    
    // Rounding mode for all calculations - HALF_UP for standard rounding
    private static final RoundingMode ROUNDING_MODE = RoundingMode.HALF_UP;
    
    // Scale for decimal places
    private static final int DECIMAL_SCALE = 2;

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

            List<TF_MProduct> prodList = new Query(ctx, TF_MProduct.Table_Name,
                    "IsSold='Y' AND WeighmentEnabled='Y' AND IsActive='Y' AND ProductType='I' AND AD_Org_ID=?",
                    null)
                    .setClient_ID()
                    .setParameters(1000000)
                    .list();

            List<Map<String, Object>> productData = new ArrayList<>();

            for (TF_MProduct pro : prodList) {
                Map<String, Object> p = new HashMap<>();
                p.put("value", pro.getValue());
                p.put("name", pro.getName());
                p.put("rate", pro.getBillPrice());
                p.put("uom", pro.getC_UOM().getName());
                p.put("prodId", pro.get_ID());
                
                // Get GST Rate from product's tax category or use default
                BigDecimal gstRate = getGSTRateFromProduct(ctx, pro);
                p.put("gstRate", gstRate);
                
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

    /**
     * Get GST rate percentage from Product
     * Returns the GST rate from product's tax category or default (5%)
     */
    private BigDecimal getGSTRateFromProduct(Properties ctx, TF_MProduct product) {
        try {
            // Try to get tax from product's tax category
            int taxCategoryID = product.getC_TaxCategory_ID();
            if (taxCategoryID > 0) {
                // Get the tax rate from tax category's default tax
                MTax[] taxes = MTax.getAll(ctx);
                for (MTax tax : taxes) {
                    if (tax.getC_TaxCategory_ID() == taxCategoryID && tax.isActive()) {
                        BigDecimal rate = tax.getRate();
                        if (rate != null && rate.compareTo(BigDecimal.ZERO) > 0) {
                            return rate;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error getting GST rate for product " + product.getValue() + ": " + e.getMessage());
        }
        
        // Return default GST rate (5% for Edible Oil)
        return DEFAULT_GST_RATE;
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

            System.out.println("Customer: " + name + " | Phone: " + phone + " (Optional)");

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

            // ---- Items Processing ----
            JSONArray items = salesData.getJSONArray("items");

            // Create/Update Business Partner
            TF_MBPartner bp = new TF_MBPartner(ctx, 0, null);
            bp.setAD_Org_ID(1000000);
            bp.setName(name != null ? name : "Walk-in");
            bp.setPhone(phone);
            bp.setContactName(name);
            bp.setCity("NA");
            bp.setDesignation(address);
            bp.setAddress1(address != null ? address : "NA");
            bp.setSOCreditStatus("X");
            bp.setSO_CreditLimit(BigDecimal.ZERO);
            bp.setIsCustomer(true);
            bp.setIsActive(true);
            bp.saveEx();

            // Update context IDs from BP if needed
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
            ordH.setC_BPartner_ID(bp.getC_BPartner_ID());
            ordH.saveEx();

            System.out.println("Order Header Created: " + ordH.get_ID());

            // Variables for GST calculation summary
            BigDecimal totalTaxableAmount = BigDecimal.ZERO;
            BigDecimal totalCGST = BigDecimal.ZERO;
            BigDecimal totalSGST = BigDecimal.ZERO;
            BigDecimal currentGstRate = DEFAULT_GST_RATE;
            Map<BigDecimal, BigDecimal> gstSummaryMap = new HashMap<>();

            // Create Order Lines
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);

                int prodId = item.getInt("prodId");
                
                // Get GST rate from item data (dynamic, not constant)
                BigDecimal gstRate = new BigDecimal(item.optString("gstRate", "5"));
                currentGstRate = gstRate;
                
                // Parsing values safely
                BigDecimal qty = new BigDecimal(item.get("qty").toString());
                BigDecimal amount = new BigDecimal(item.get("amount").toString()).setScale(DECIMAL_SCALE, ROUNDING_MODE);
                
                // =====================================================
                // INCLUSIVE GST CALCULATION WITH PROPER ROUNDING
                // 
                // FORMULA:
                // Taxable Amount = Total Amount × (100 / (100 + GST Rate))
                // GST Amount = Total Amount - Taxable Amount
                // CGST = GST Amount / 2 (for intra-state)
                // SGST = GST Amount / 2 (for intra-state)
                // 
                // EXAMPLE for 5% GST (Edible Oil):
                // Total Amount = Rs. 105.00
                // Taxable = 105 × (100/105) = Rs. 100.00
                // GST = 105 - 100 = Rs. 5.00
                // CGST (2.5%) = 5/2 = Rs. 2.50
                // SGST (2.5%) = 5/2 = Rs. 2.50
                // =====================================================
                
                // Calculate divisor (100 + GST Rate)
                BigDecimal gstDivisor = BigDecimal.valueOf(100).add(gstRate);
                
                // Calculate taxable amount with proper rounding
                BigDecimal taxableAmount = amount.multiply(BigDecimal.valueOf(100))
                        .divide(gstDivisor, DECIMAL_SCALE, ROUNDING_MODE);
                
                // Calculate GST amount
                BigDecimal gstAmount = amount.subtract(taxableAmount);
                
                // Calculate rate per unit (taxable)
                BigDecimal ratePerUnit = taxableAmount.divide(qty, DECIMAL_SCALE, ROUNDING_MODE);
                
                // Split GST into CGST and SGST (for intra-state transactions)
                // CGST = SGST = GST Amount / 2
                BigDecimal cgstAmount = gstAmount.divide(BigDecimal.valueOf(2), DECIMAL_SCALE, ROUNDING_MODE);
                BigDecimal sgstAmount = gstAmount.subtract(cgstAmount).setScale(DECIMAL_SCALE, ROUNDING_MODE);
                
                // Accumulate totals with proper rounding
                totalTaxableAmount = totalTaxableAmount.add(taxableAmount);
                totalCGST = totalCGST.add(cgstAmount);
                totalSGST = totalSGST.add(sgstAmount);
                
                // Track GST summary by rate
                BigDecimal currentTaxable = gstSummaryMap.getOrDefault(gstRate, BigDecimal.ZERO);
                gstSummaryMap.put(gstRate, currentTaxable.add(taxableAmount));

                TF_MProduct prod = new TF_MProduct(ctx, prodId, null);
                
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
                // Set taxable price (price before GST)
                ordLine.setPrice(ratePerUnit);
                ordLine.setPriceActual(ratePerUnit);
                ordLine.setPriceList(ratePerUnit);
                ordLine.setC_Tax_ID(1000017);
                // Set line net amount (taxable)
                ordLine.setLineNetAmt(taxableAmount);
                ordLine.saveEx();
                
                // Log each line with GST details
                System.out.println("Line " + (i+1) + ": Product=" + prod.getName() + 
                        ", Qty=" + qty + 
                        ", Amount=" + amount + 
                        ", Taxable=" + taxableAmount + 
                        ", CGST(" + (gstRate.divide(BigDecimal.valueOf(2)).setScale(2, ROUNDING_MODE)) + "%)=" + cgstAmount + 
                        ", SGST(" + (gstRate.divide(BigDecimal.valueOf(2)).setScale(2, ROUNDING_MODE)) + "%)=" + sgstAmount);
            }

            // Complete Document
            ordH.setDocAction(MOrder.DOCACTION_Complete);

            if (!ordH.processIt(MOrder.DOCACTION_Complete)) {
                throw new AdempiereException("Could not complete order: " + ordH.getProcessMsg());
            }
            ordH.saveEx();

            String docNo = ordH.getDocumentNo();
            System.out.println("Order Completed. Document No: " + docNo);
            
            // Log GST Summary
            System.out.println("=== GST SUMMARY ===");
            System.out.println("GST Rate: " + currentGstRate + "%");
            System.out.println("CGST Rate: " + currentGstRate.divide(BigDecimal.valueOf(2)).setScale(2, ROUNDING_MODE) + "%");
            System.out.println("SGST Rate: " + currentGstRate.divide(BigDecimal.valueOf(2)).setScale(2, ROUNDING_MODE) + "%");
            System.out.println("Total Taxable Amount: Rs." + totalTaxableAmount.setScale(DECIMAL_SCALE, ROUNDING_MODE));
            System.out.println("Total CGST: Rs." + totalCGST.setScale(DECIMAL_SCALE, ROUNDING_MODE));
            System.out.println("Total SGST: Rs." + totalSGST.setScale(DECIMAL_SCALE, ROUNDING_MODE));
            System.out.println("Total GST: Rs." + totalCGST.add(totalSGST).setScale(DECIMAL_SCALE, ROUNDING_MODE));

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

            // Send WhatsApp (Non-blocking on error) - Only if phone exists
            try {
                if (phone != null && !phone.trim().isEmpty()) {
                    String phoneToSend = phone.replaceAll("[\\s\\+\\-\\(\\)]", "");
                    String caption = "Invoice #" + docNo;
                    WhatsAppSender.sendDocument(phoneToSend, pdfInfo, caption);
                }
            } catch (Exception waex) {
                System.err.println("WhatsApp sending failed (or skipped) for " + docNo);
                waex.printStackTrace();
            }

            // Calculate CGST and SGST rates
            BigDecimal cgstRate = currentGstRate.divide(BigDecimal.valueOf(2)).setScale(2, ROUNDING_MODE);
            BigDecimal sgstRate = currentGstRate.divide(BigDecimal.valueOf(2)).setScale(2, ROUNDING_MODE);

            // Return JSON with docNo and GST summary
            JSONObject jsonResp = new JSONObject();
            jsonResp.put("status", "success");
            jsonResp.put("docNo", docNo);
            jsonResp.put("gstRate", currentGstRate.setScale(2, ROUNDING_MODE).toString());
            jsonResp.put("cgstRate", cgstRate.toString());
            jsonResp.put("sgstRate", sgstRate.toString());
            jsonResp.put("totalTaxableAmount", totalTaxableAmount.setScale(DECIMAL_SCALE, ROUNDING_MODE).toString());
            jsonResp.put("totalCGST", totalCGST.setScale(DECIMAL_SCALE, ROUNDING_MODE).toString());
            jsonResp.put("totalSGST", totalSGST.setScale(DECIMAL_SCALE, ROUNDING_MODE).toString());
            jsonResp.put("totalGST", totalCGST.add(totalSGST).setScale(DECIMAL_SCALE, ROUNDING_MODE).toString());
            response.getWriter().write(jsonResp.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            // Return error in perfect JSON format
            String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown Error";
            try {
                response.getWriter().write("{\"status\":\"error\", \"error\":\"" + errorMsg + "\"}");
            } catch(Exception io) {
                // Fallback if response is already committed
            }
        }
    }
}