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
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrder;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrderLine;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;
import org.vijaytech.oilshop.utils.GenerateTextileBillPDF;

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
            if (session == null || session.getAttribute("ctx") == null) {
                resp.sendRedirect(req.getContextPath() + "/userlogin.jsp?error=session_expired");
                return;
            }

            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) sb.append(line);
            }
            String json = sb.toString();

            JSONObject root = new JSONObject(json);
            JSONObject salesData = root.getJSONObject("salesData");

            Properties ctx = (Properties) session.getAttribute("ctx");
            Env.setCtx(ctx);


            if (Env.getAD_Client_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Client_ID", 1000000);
            if (Env.getAD_Org_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Org_ID", 1000000);
            if (Env.getAD_User_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_User_ID", 100);
            if (Env.getContextAsInt(ctx, "#M_Warehouse_ID") == 0)
                Env.setContext(ctx, "#M_Warehouse_ID", 1000113);
            if (ctx == null) ctx = Env.getCtx();
            JSONObject customer = salesData.getJSONObject("customer");
            String name = customer.optString("name", "Walk-in").trim();
            String address = customer.optString("address", "NA").trim();
            String phone = customer.optString("phone", "").trim();

            if (address == null || address.isBlank()) address = "NA";
            if (phone == null || phone.isBlank()) throw new AdempiereException("Please fill Phone Number");

            BigDecimal discount = new BigDecimal(salesData.optString("discount", "0"));
            JSONArray items = salesData.getJSONArray("items");

            int existingBP_ID = DB.getSQLValue(
            	    null,
            	    "SELECT C_BPartner_ID FROM C_BPartner WHERE Phone=? AND AD_Client_ID=?",
            	    phone,
            	    Env.getAD_Client_ID(ctx)
            	);

            TF_MBPartner bp;
            if (existingBP_ID > 0) {
                bp = new TF_MBPartner(ctx, existingBP_ID, null);
            } else {
                bp = new TF_MBPartner(ctx, 0, null);
            }

            bp.setAD_Org_ID(Env.getAD_Org_ID(ctx));
            bp.setIsCustomer(true);
            bp.setIsVendor(false);
            bp.setIsPermitSales(false);
            bp.setIsInterState(false);
            bp.setName(name != null && !name.isBlank() ? name : "Walk-in");
            bp.setContactName(name != null && !name.isBlank() ? name : "Walk-in");
            bp.setPhone(phone);
            bp.setAddress1(address);
            bp.setAddress2(address);
            bp.setAddress3(address);
            bp.setAddress4("Tamil Nadu");
            bp.setCity(address);
            bp.setRegionName("Tamil Nadu");
            bp.setPostal("600001");
            bp.setC_Country_ID(208);
            if (bp.getC_BP_Group_ID() == 0) {
                bp.setC_BP_Group_ID(1000001);
            }

            try {
                bp.saveEx();
            } catch (Exception e) {
                throw new AdempiereException("Failed to save Business Partner: " + e.getMessage(), e);
            }

            MBPartnerLocation primaryLoc = null;
            try {
                int primaryLocId = bp.getPrimaryC_BPartner_Location_ID();
                if (primaryLocId > 0) {
                    primaryLoc = new MBPartnerLocation(bp.getCtx(), primaryLocId, null);
                }
            } catch (Exception ex) {
                // ignore, not critical
            }

            TF_MOrder ordH = new TF_MOrder(ctx, 0, null);
            ordH.setAD_Org_ID(Env.getAD_Org_ID(ctx));
            ordH.setC_BPartner_ID(bp.getC_BPartner_ID());
            if (primaryLoc != null) {
                ordH.setC_BPartner_Location_ID(primaryLoc.getC_BPartner_Location_ID());
            } else {
                ordH.setC_BPartner_Location_ID(bp.getPrimaryC_BPartner_Location_ID());
            }
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

            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);

                int prodId = item.getInt("prodId");
                BigDecimal qty = new BigDecimal(item.get("qty").toString());
                BigDecimal rate = new BigDecimal(item.get("rate").toString()).setScale(2, RoundingMode.HALF_UP);

                TF_MOrderLine ordLine = new TF_MOrderLine(ctx, 0, null);
                TF_MProduct prod = new TF_MProduct(ctx, prodId, null);

                if (prod.getAD_Client_ID() != Env.getAD_Client_ID(ctx)) {
                    throw new AdempiereException(
                        "Product belongs to another client"
                    );
                }
                ordLine.setC_Order_ID(ordH.get_ID());
                ordLine.setM_Product_ID(prod.get_ID());
                ordLine.setC_UOM_ID(prod.getC_UOM_ID());
                ordLine.setDiscount(discount);
                ordLine.setQty(qty);
                ordLine.setQtyOrdered(qty);
                ordLine.setPrice(rate);
                ordLine.setPriceActual(rate);
                
//                ordLine.setC_Tax_ID(1000021);
                ordLine.setC_Tax_ID(1000021);
                ordLine.saveEx();
            }

            ordH.setDocAction(MOrder.DOCACTION_Complete);
            if (!ordH.processIt(MOrder.DOCACTION_Complete)) {
                throw new AdempiereException("Could not complete order: " + ordH.getProcessMsg());
            }
            ordH.saveEx();

            String filename = "invoice_" + ordH.getDocumentNo() + ".pdf";
            String invoicesFolder = req.getServletContext().getRealPath("/invoices");
            if (invoicesFolder == null) {
                invoicesFolder = System.getProperty("user.dir") + File.separator + "invoices";
            }
            Files.createDirectories(Paths.get(invoicesFolder));
            File pdfFile = new File(invoicesFolder, filename);
             
            
            String  pdfUrl =GenerateTextileBillPDF.generate80mm(pdfFile, ordH.get_ID(), ctx);
           
              String publicPdfUrl = req.getContextPath() + "/invoices/" + filename;

              // Single JSON response
              JSONObject result = new JSONObject();
              result.put("status", "success");
              result.put("pdfUrl", publicPdfUrl);
              result.put("docNo", ordH.getDocumentNo());
              result.put("message", "Saved successfully");

              resp.setContentType("application/json");
              resp.setCharacterEncoding("UTF-8");
              resp.getWriter().write(result.toString());


        } catch (Exception e) {
            out.write("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }

//    @SuppressWarnings("unused")
//    private void generateInvoicePDF(File outFile, int orderId) throws IOException, SQLException {
//
//        if (outFile.getParentFile() != null && !outFile.getParentFile().exists()) {
//            outFile.getParentFile().mkdirs();
//        }
//
//        String sqlHeader =
//            "SELECT o.documentno, " +
//            "       bp.name AS customer_name, " +
//            "       bp.taxid AS customer_gstin, " +
//            "       COALESCE(l.address1,'') || " +
//            "       CASE WHEN l.address2 IS NOT NULL THEN ', ' || l.address2 ELSE '' END || " +
//            "       CASE WHEN l.city IS NOT NULL THEN ', ' || l.city ELSE '' END || " +
//            "       CASE WHEN l.postal IS NOT NULL THEN '-' || l.postal ELSE '' END AS customer_address, " +
//            "       o.dateordered, " +
//            "       org.name AS org_name, " +
//            "       COALESCE(orgloc.address1,'') || " +
//            "       CASE WHEN orgloc.address2 IS NOT NULL THEN ', ' || orgloc.address2 ELSE '' END || " +
//            "       CASE WHEN orgloc.city IS NOT NULL THEN ', ' || orgloc.city ELSE '' END || " +
//            "       CASE WHEN orgloc.postal IS NOT NULL THEN '-' || orgloc.postal ELSE '' END AS org_address, " +
//            "       oi.taxid AS org_gstin, " +
//            "       oi.phone AS org_phone, " +
//            "       oi.email AS org_email " +
//            "FROM c_order o " +
//            "JOIN c_bpartner bp ON bp.c_bpartner_id = o.c_bpartner_id " +
//            "LEFT JOIN c_bpartner_location bpl ON (bpl.c_bpartner_id = bp.c_bpartner_id AND bpl.isbillto = 'Y') " +
//            "LEFT JOIN c_location l ON l.c_location_id = bpl.c_location_id " +
//            "JOIN ad_org org ON org.ad_org_id = o.ad_org_id " +
//            "JOIN ad_orginfo oi ON oi.ad_org_id = org.ad_org_id " +
//            "LEFT JOIN c_location orgloc ON orgloc.c_location_id = oi.c_location_id " +
//            "WHERE o.c_order_id = ?";
//
//        PreparedStatement ps = DB.prepareStatement(sqlHeader, null);
//        ps.setInt(1, orderId);
//        ResultSet rs = ps.executeQuery();
//        String docNo="", customer="", customerGST="", customerAddr="", date="";
//        String orgName="", orgAddress="", orgGST="", orgPhone="", orgEmail="";
//
//        if (rs.next()) {
//            docNo = rs.getString("documentno");
//            customer = rs.getString("customer_name");
//            customerGST = rs.getString("customer_gstin");
//            customerAddr = rs.getString("customer_address");
//            date = String.valueOf(rs.getTimestamp("dateordered"));
//
//            orgName = rs.getString("org_name");
//            orgAddress = rs.getString("org_address");
//            orgGST = rs.getString("org_gstin");
//            orgPhone = rs.getString("org_phone");
//            orgEmail = rs.getString("org_email");
//        }
//        rs.close();
//        ps.close();
//
//        String sqlLines =
//            "SELECT p.name AS item, p.hsncode, ol.qtyordered, ol.priceactual, " +
//            "       ol.discount, " +
//            "       (ol.qtyordered * ol.priceactual) AS grossamount " +
//            "FROM c_orderline ol " +
//            "JOIN m_product p ON p.m_product_id = ol.m_product_id " +
//            "WHERE ol.c_order_id = ?";
//
//        PreparedStatement ps2 = DB.prepareStatement(sqlLines, null);
//        ps2.setInt(1, orderId);
//        ResultSet rs2 = ps2.executeQuery();
//
//        class Line {
//            String item;
//            BigDecimal qty, rate, discount, gross, discAmt, netAmt;
//        }
//        List<Line> lines = new ArrayList<>();
//
//        BigDecimal subTotal = BigDecimal.ZERO;
//        BigDecimal totalDiscount = BigDecimal.ZERO;
//        BigDecimal grandTotal = BigDecimal.ZERO;
//
//        while (rs2.next()) {
//            Line ln = new Line();
//            ln.item = rs2.getString("item");
//            ln.qty = rs2.getBigDecimal("qtyordered");
//            ln.rate = rs2.getBigDecimal("priceactual");
//            ln.discount = rs2.getBigDecimal("discount");
//            ln.gross = ln.qty.multiply(ln.rate);
//            ln.discAmt = ln.discount;
//            ln.netAmt = ln.gross.subtract(ln.discAmt);
//
//            subTotal = subTotal.add(ln.gross);
//            totalDiscount = totalDiscount.add(ln.discAmt);
//            grandTotal = grandTotal.add(ln.netAmt);
//
//            lines.add(ln);
//        }
//        rs2.close();
//        ps2.close();
//
//        Rectangle receiptSize = new Rectangle(227, 1200);
//        Document doc = new Document(receiptSize, 5, 5, 5, 5);
//
//        try {
//            PdfWriter.getInstance(doc, new FileOutputStream(outFile));
//            doc.open();
//
//            Font bold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8);
//            Font normal = FontFactory.getFont(FontFactory.HELVETICA, 7);
//
//            Paragraph title = new Paragraph(orgName + "\n", bold);
//            title.setAlignment(Paragraph.ALIGN_CENTER);
//            doc.add(title);
//
//            Paragraph addr = new Paragraph(orgAddress + "\n", normal);
//            addr.setAlignment(Paragraph.ALIGN_CENTER);
//            doc.add(addr);
//
//            doc.add(new Paragraph("GSTIN: " + orgGST, normal));
//            doc.add(new Paragraph("Phone: " + orgPhone, normal));
//            doc.add(new Paragraph("----------------------------------------", normal));
//
//            doc.add(new Paragraph("Bill No: " + docNo, normal));
//            doc.add(new Paragraph("Date   : " + date, normal));
//            doc.add(new Paragraph("Customer: " + customer, normal));
//            doc.add(new Paragraph(customerAddr, normal));
//            doc.add(new Paragraph("GSTIN: " + customerGST, normal));
//
//            doc.add(new Paragraph("----------------------------------------", normal));
//
//            PdfPTable table = new PdfPTable(5);
//            table.setWidthPercentage(100);
//            table.setWidths(new float[]{3f, 1f, 1f, 1f, 1.5f});
//
//            addHeader(table, "Item");
//            addHeader(table, "Qty");
//            addHeader(table, "Rate");
//            addHeader(table, "Disc");
//            addHeader(table, "Amt");
//
//            for (Line ln : lines) {
//                addCell(table, ln.item, normal);
//                addCell(table, ln.qty.stripTrailingZeros().toPlainString(), normal);
//                addCell(table, ln.rate.toPlainString(), normal);
//                addCell(table, ln.discAmt.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString(), normal);
//                addCell(table, ln.netAmt.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString(), normal);
//            }
//
//            doc.add(table);
//
//            doc.add(new Paragraph("----------------------------------------", normal));
//
//            doc.add(new Paragraph("Sub Total     : ₹ " + subTotal.setScale(2), normal));
//            doc.add(new Paragraph("Discount      : ₹ " + totalDiscount.setScale(2), normal));
//
//            Paragraph gTot = new Paragraph("Grand Total   : ₹ " + grandTotal.setScale(2), bold);
//            gTot.setAlignment(Paragraph.ALIGN_RIGHT);
//            doc.add(gTot);
//
//            doc.add(new Paragraph("----------------------------------------", normal));
//
//            Paragraph thanks = new Paragraph("Thank you! Visit again.", normal);
//            thanks.setAlignment(Paragraph.ALIGN_CENTER);
//            doc.add(thanks);
//
//        } catch (Exception e) {
//            throw new AdempiereException("Error generating 80mm PDF", e);
//        } finally {
//            if (doc.isOpen()) doc.close();
//        }
//    }
//    private static void addHeader(PdfPTable t, String text) {
//        PdfPCell c = new PdfPCell(new Paragraph(text,
//                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10)));
//        c.setPadding(5);
//        t.addCell(c);
//    }
//
//    private static void addCell(PdfPTable t, String text, Font f) {
//        PdfPCell c = new PdfPCell(new Paragraph(text, f));
//        c.setPadding(5);
//        t.addCell(c);
//    }
}
