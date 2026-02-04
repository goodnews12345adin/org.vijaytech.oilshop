package org.vijaytech.oilshop;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MBPartnerLocation;
import org.compiere.model.MOrder;
import org.compiere.model.MWarehouse;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrder;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrderLine;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;
import org.vijaytech.oilshop.utils.GenerateTextileBillPDF;
import org.vijaytech.oilshop.utils.WhatsAppSender;
import org.vijaytech.oilshop.utils.ThermalPrintServer;
import org.vijaytech.oilshop.utils.TvsRawPdfPrinter;

import com.google.gson.Gson;

public class SalesSaveServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        PrintWriter out = resp.getWriter();

        try {
            // 1. Check Session
            if (session == null || session.getAttribute("ctx") == null) {
                resp.sendRedirect(req.getContextPath() + "/userlogin.jsp?error=session_expired");
                return;
            }

            // 2. Read JSON
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }

            String json = sb.toString();
            System.out.println("Received JSON: " + json);

            JSONObject root = new JSONObject(json);
            JSONObject salesData = root.getJSONObject("salesData");

            Properties ctx = (Properties) session.getAttribute("ctx");
            if (ctx == null) {
                ctx = Env.getCtx();
            }

            // 3. Context Setup
            if (Env.getAD_Client_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Client_ID", 1000000);
            if (Env.getAD_Org_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Org_ID", 1000000);
            if (Env.getAD_User_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_User_ID", 100);

            int adClientId = Env.getAD_Client_ID(ctx);
            int adOrgId = Env.getAD_Org_ID(ctx);

            // 4. FIX: Validate Warehouse ID
            // The log shows "NO Data found for M_Warehouse_ID=1000113".
            // We check if the hardcoded ID exists, if not, we find a valid one.
            int warehouseId = 1000001;
            MWarehouse wh = MWarehouse.get(ctx, warehouseId);
            
            if (wh == null || wh.get_ID() == 0) {
                // Try to find a valid warehouse for this Client/Org
                int validWhId = DB.getSQLValue(null, 
                    "SELECT M_Warehouse_ID FROM M_Warehouse WHERE AD_Client_ID=? AND AD_Org_ID=? AND IsActive='Y'", 
                    adClientId, adOrgId);
                
                if (validWhId > 0) {
                    warehouseId = validWhId;
                    System.out.println("Corrected warehouse ID to: " + warehouseId);
                } else {
                    // If still no warehouse, try getting any warehouse for the client
                    validWhId = DB.getSQLValue(null, "SELECT M_Warehouse_ID FROM M_Warehouse WHERE AD_Client_ID=? AND IsActive='Y'", adClientId);
                    if (validWhId > 0) {
                        warehouseId = validWhId;
                        System.out.println("Corrected warehouse ID to: " + warehouseId);
                    } else {
                        throw new AdempiereException("No valid Warehouse found for Client " + adClientId);
                    }
                }
            }
            Env.setContext(ctx, "#M_Warehouse_ID", warehouseId);

            // 5. Customer Details
            JSONObject customer = salesData.getJSONObject("customer");
            String name = customer.optString("name", "Walk-in").trim();
            String address = customer.optString("address", "").trim();
            String phone = customer.optString("phone", "").trim();
            
            // Fix: Defaults for null/empty values
            if (address == null || address.isBlank()) address = "NA";
            
            System.out.println("Customer: " + name + " | Phone: " + phone + " (Optional)");

            // 6. Discount Parsing
            BigDecimal discount = BigDecimal.ZERO;
            try {
                String dStr = salesData.optString("discount", "0").trim();
                if (!dStr.isEmpty()) {
                    discount = new BigDecimal(dStr);
                }
            } catch (Exception e) {
                discount = BigDecimal.ZERO;
            }
            boolean printRequired =
            		salesData.getBoolean("printRequired");

            // 7. Business Partner (BP) Logic
            TF_MBPartner bp;
            int existingBP_ID = 0;

            // Only search by phone if phone is provided and not empty
            if (phone != null && !phone.isEmpty()) {
                existingBP_ID = DB.getSQLValue(
                    null,
                    "SELECT C_BPartner_ID FROM C_BPartner WHERE Phone=? AND AD_Client_ID=?",
                    phone,
                    adClientId
                );
            }

            if (existingBP_ID > 0) {
                bp = new TF_MBPartner(ctx, existingBP_ID, null);
            } else {
                bp = new TF_MBPartner(ctx, 0, null);
            }

            bp.setAD_Org_ID(adOrgId);
            bp.setIsCustomer(true);
            bp.setIsVendor(false);
            bp.setIsPermitSales(false);
            bp.setIsInterState(false);
            bp.setName(name != null && !name.isEmpty() ? name : "Walk-in");
            bp.setContactName(name != null && !name.isEmpty() ? name : "Walk-in");
            bp.setPhone(phone != null && !phone.isEmpty() ? phone : "");
            bp.setAddress1(address);
            bp.setAddress2(address);
            bp.setAddress3(address);
            bp.setAddress4(address);
            bp.setCity(address); // Or city from DB if needed
            bp.setRegionName("Tamil Nadu");
            bp.setPostal("600001");
            bp.setC_Country_ID(208);
            
            if (bp.getC_BP_Group_ID() == 0) {
                bp.setC_BP_Group_ID(1000001);
            }

            // FIX: Set the BP Value (Search Key) to avoid "FillMandatory - Value" error
            if (bp.getValue() == null || bp.getValue().isEmpty()) {
                if (phone != null && !phone.isEmpty()) {
                    bp.setValue(phone);
                } else {
                    // Generate a unique value for Walk-in customers
                    bp.setValue("WALKIN-" + System.currentTimeMillis());
                }
            }

            try {
                bp.saveEx();
            } catch (Exception e) {
                throw new AdempiereException("Failed to save Business Partner: " + e.getMessage(), e);
            }

            // Update Context IDs from BP
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

            // 8. Handle Location
            MBPartnerLocation primaryLoc = null;
            try {
                int primaryLocId = bp.getPrimaryC_BPartner_Location_ID();
                if (primaryLocId > 0) {
                    primaryLoc = new MBPartnerLocation(bp.getCtx(), primaryLocId, null);
                }
            } catch (Exception ex) {
                // ignore location fetch errors
            }

            // 9. Create Order Header
            TF_MOrder ordH = new TF_MOrder(ctx, 0, null);
            ordH.setAD_Org_ID(adOrgId);
            ordH.setC_BPartner_ID(bp.getC_BPartner_ID());
            
            // Set Location ID if available
            if (primaryLoc != null) {
                ordH.setC_BPartner_Location_ID(primaryLoc.getC_BPartner_Location_ID());
            } else {
                ordH.setC_BPartner_Location_ID(bp.getPrimaryC_BPartner_Location_ID());
            }
            
            ordH.setC_DocType_ID(1000041);
            ordH.setC_DocTypeTarget_ID(1000041);
            // Use the validated warehouseId variable instead of blindly reading context
            ordH.setM_Warehouse_ID(warehouseId);
            ordH.setPaymentRule("B");
            ordH.setM_PriceList_ID(1000058);
            ordH.setSalesDiscountAmt(discount);
            ordH.setIsTaxIncluded(true);
            ordH.setC_BankAccount_ID(1000094);
            ordH.setDateAcct(new Timestamp(System.currentTimeMillis()));
            ordH.setDateOrdered(new Timestamp(System.currentTimeMillis()));
            ordH.setDocStatus(MOrder.DOCSTATUS_Drafted);
            ordH.saveEx();

            System.out.println("Order Header Created: " + ordH.get_ID());

            // 10. Create Order Lines
            JSONArray items = salesData.getJSONArray("items");

            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);

                int prodId = item.getInt("prodId");
                BigDecimal qty = new BigDecimal(item.get("qty").toString());
                BigDecimal rate = new BigDecimal(item.get("rate").toString()).setScale(2, RoundingMode.HALF_UP);
                BigDecimal amount = new BigDecimal(item.get("amount").toString()).setScale(2, RoundingMode.HALF_UP);

                TF_MProduct prod = new TF_MProduct(ctx, prodId, null);
                
                // Validate Product Tenant
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
                ordLine.setIsTaxIncluded(true);
                ordLine.setPriceActual(rate); // Use priceactual as per snippet
                ordLine.setC_Tax_ID(1000021); // Specific Tax ID from snippet
                ordLine.saveEx();
            }

            // 11. Complete Document
            ordH.setDocAction(MOrder.DOCACTION_Complete);

            if (!ordH.processIt(MOrder.DOCACTION_Complete)) {
                throw new AdempiereException("Could not complete order: " + ordH.getProcessMsg());
            }
            ordH.saveEx();

            String docNo = ordH.getDocumentNo();
            System.out.println("Order Completed. Document No: " + docNo);

            // 12. Generate PDF and Printing
            String filename = "invoice_" + docNo + ".pdf";
            String invoicesFolder = req.getServletContext().getRealPath("/invoices");
            
            if (invoicesFolder == null) {
                invoicesFolder = System.getProperty("user.dir") + File.separator + "invoices";
            }
            Files.createDirectories(Paths.get(invoicesFolder));
            File pdfFile = new File(invoicesFolder, filename);

            // Use generate80mm as requested in snippet
            String pdfUrl = "";
            try {
                pdfUrl = GenerateTextileBillPDF.generate80mm(pdfFile, ordH.get_ID(), ctx);
                
                // Send WhatsApp
                if (phone != null && !phone.isEmpty()) {
                    String phoneToSend = phone.replaceAll("[\\s\\+\\-\\(\\)]", "");
                    String caption = "Invoice #" + docNo;
                    WhatsAppSender.sendDocument(phoneToSend, pdfUrl, caption);
                }
            } catch (Exception pdfEx) {
                System.err.println("PDF Generation Error (Non-blocking): " + pdfEx.getMessage());
            }
            if(printRequired) {
            // Thermal Print Server
            try {
                ThermalPrintServer.printGstBill(ordH.get_ID());
            } catch (Exception printEx) {
                System.err.println("Thermal Print Error (Non-blocking): " + printEx.getMessage());
            }
            }
            // 13. Return JSON Response
            String publicPdfUrl = req.getContextPath() + "/invoices/" + filename;
            
            JSONObject result = new JSONObject();
            result.put("status", "success");
            result.put("pdfUrl", publicPdfUrl);
            result.put("docNo", docNo);
            result.put("message", "Saved successfully");

            resp.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            // Return error in perfect JSON format
            String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown Error";
            out.write("{\"status\":\"error\", \"message\":\"" + errorMsg + "\"}");
        }
    }
}