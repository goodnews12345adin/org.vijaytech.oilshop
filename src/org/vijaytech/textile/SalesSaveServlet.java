package org.vijaytech.textile;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MOrder;
import org.compiere.model.MProduct;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.MPriceListUOM;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrder;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrderLine;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;
import org.vijaytech.textile.utils.GenerateTextileBillPDF;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

public class SalesSaveServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        HttpSession session = req.getSession(false);

        // 🔒 Check login/session
        if (session == null || session.getAttribute("ctx") == null) {
            resp.sendRedirect(req.getContextPath() + "/userlogin.jsp?error=session_expired");
            return;
        }

        // 1️⃣ Read JSON from request body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }

        String json = sb.toString();
        System.out.println("Received JSON: " + json);

        JSONObject root = new JSONObject(json);
        JSONObject salesData = root.getJSONObject("salesData");

        Properties ctx = (Properties) session.getAttribute("ctx");
        if (ctx == null) ctx = Env.getCtx();

        // 🧩 Ensure mandatory context keys exist
        if (Env.getAD_Client_ID(ctx) == 0)
            Env.setContext(ctx, "#AD_Client_ID", 1000000); // your tenant
        if (Env.getAD_Org_ID(ctx) == 0)
            Env.setContext(ctx, "#AD_Org_ID", 1000000);
        if (Env.getAD_User_ID(ctx) == 0)
            Env.setContext(ctx, "#AD_User_ID", 100);       // your user
        if (Env.getContextAsInt(ctx, "#M_Warehouse_ID") == 0)
            Env.setContext(ctx, "#M_Warehouse_ID", 1000113);

        // ---- Customer ----
        JSONObject customer = salesData.getJSONObject("customer");
        String name = customer.optString("name", "Walk-in");
        String address = customer.optString("address", "");
        String phone = customer.optString("phone", "");
        
        BigDecimal discount = new BigDecimal( salesData.optString("discount"));
        String subtotal = salesData.optString("subtotal", "");
        String total = salesData.optString("total", "");

        System.out.println("Customer Details:");
        System.out.println("Name: " + name);
        System.out.println("Address: " + address);
        System.out.println("Phone: " + phone);

        // ---- Items ----
        JSONArray items = salesData.getJSONArray("items");
        System.out.println("\nItems:");

        // ✅ Create Order Header (using existing BP for now)
        TF_MBPartner bp = new TF_MBPartner(ctx, 1005586, null); // existing partner

        TF_MOrder ordH = new TF_MOrder(ctx, 0, null);
        ordH.setAD_Org_ID(1000000);
        ordH.setBPartner(bp);
        ordH.setC_DocType_ID(1000041);
        ordH.setC_DocTypeTarget_ID(1000041);
        ordH.setM_Warehouse_ID(1000113);
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
                    ", prodId: " + prodId+
                    ",discount "+discount);

            TF_MOrderLine ordLine = new TF_MOrderLine(ctx, 0, null);

            // prodId = M_Product_ID (coming from the UI)
//            MPriceListUOM priceList = new MPriceListUOM(ctx, prodId, null);
            TF_MProduct prod = new TF_MProduct(ctx,prodId, null);
//            ordLine.setAD_Org_ID();
            ordLine.setC_Order_ID(ordH.get_ID());
            ordLine.setM_Product_ID(prod.get_ID());
            ordLine.setC_UOM_ID(prod.getC_UOM_ID());
            ordLine.setDiscount();
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

        // ===================== PDF GENERATION =====================

        String filename = "invoice_" + ordH.getDocumentNo() + ".pdf";

        String invoicesFolder = req.getServletContext().getRealPath("/invoices");
        if (invoicesFolder == null) {
            // fallback if running from packed WAR with no realPath
            invoicesFolder = System.getProperty("user.dir") + File.separator + "invoices";
        }
        Files.createDirectories(Paths.get(invoicesFolder));

        File pdfFile = new File(invoicesFolder, filename);

      
        	try {
				GenerateTextileBillPDF.generate(pdfFile, ordH.get_ID(), ctx);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        

        // 4️⃣ Return JSON with PDF URL (served by InvoicePDFServlet)
        String pdfUrl = req.getContextPath() + "/InvoicePDFServlet?file=" +
                URLEncoder.encode(filename, "UTF-8");

        resp.setContentType("application/json");
        resp.getWriter().write("{\"pdfUrl\":\"" + pdfUrl + "\"}");
    }

    // ---------------------------------------------------------------------
    // 🔵 PDF GENERATOR (OpenPDF)
    // ---------------------------------------------------------------------
    @SuppressWarnings("unused")
	private void generateInvoicePDF(File outFile, int orderId) throws IOException, SQLException {

        if (outFile.getParentFile() != null && !outFile.getParentFile().exists()) {
            outFile.getParentFile().mkdirs();
        }

        // --------------------------------------------------------------
        // FETCH HEADER
        // --------------------------------------------------------------
        String sqlHeader =
            "SELECT o.documentno, " +
            "       bp.name AS customer_name, " +
            "       bp.taxid AS customer_gstin, " +
            "       COALESCE(l.address1,'') || " +
            "       CASE WHEN l.address2 IS NOT NULL THEN ', ' || l.address2 ELSE '' END || " +
            "       CASE WHEN l.city IS NOT NULL THEN ', ' || l.city ELSE '' END || " +
            "       CASE WHEN l.postal IS NOT NULL THEN '-' || l.postal ELSE '' END AS customer_address, " +
            "       o.dateordered, " +

            "       org.name AS org_name, " +
            "       COALESCE(orgloc.address1,'') || " +
            "       CASE WHEN orgloc.address2 IS NOT NULL THEN ', ' || orgloc.address2 ELSE '' END || " +
            "       CASE WHEN orgloc.city IS NOT NULL THEN ', ' || orgloc.city ELSE '' END || " +
            "       CASE WHEN orgloc.postal IS NOT NULL THEN '-' || orgloc.postal ELSE '' END AS org_address, " +

            "       oi.taxid AS org_gstin, " +
            "       oi.phone AS org_phone, " +
            "       oi.email AS org_email " +

            "FROM c_order o " +
            "JOIN c_bpartner bp ON bp.c_bpartner_id = o.c_bpartner_id " +
            "LEFT JOIN c_bpartner_location bpl ON (bpl.c_bpartner_id = bp.c_bpartner_id AND bpl.isbillto = 'Y') " +
            "LEFT JOIN c_location l ON l.c_location_id = bpl.c_location_id " +
            "JOIN ad_org org ON org.ad_org_id = o.ad_org_id " +
            "JOIN ad_orginfo oi ON oi.ad_org_id = org.ad_org_id " +
            "LEFT JOIN c_location orgloc ON orgloc.c_location_id = oi.c_location_id " +
            "WHERE o.c_order_id = ?";

        PreparedStatement ps = DB.prepareStatement(sqlHeader, null);
        ps.setInt(1, orderId);
        ResultSet rs = ps.executeQuery();

        String docNo="", customer="", customerGST="", customerAddr="", date="";
        String orgName="", orgAddress="", orgGST="", orgPhone="", orgEmail="";

        if (rs.next()) {
            docNo = rs.getString("documentno");
            customer = rs.getString("customer_name");
            customerGST = rs.getString("customer_gstin");
            customerAddr = rs.getString("customer_address");
            date = String.valueOf(rs.getTimestamp("dateordered"));

            orgName = rs.getString("org_name");
            orgAddress = rs.getString("org_address");
            orgGST = rs.getString("org_gstin");
            orgPhone = rs.getString("org_phone");
            orgEmail = rs.getString("org_email");
        }
        rs.close();
        ps.close();

        // --------------------------------------------------------------
        // FETCH LINES (WITH DISCOUNT)
        // --------------------------------------------------------------
        String sqlLines =
            "SELECT p.name AS item, p.hsncode, ol.qtyordered, ol.priceactual, " +
            "       ol.discount, " +
            "       (ol.qtyordered * ol.priceactual) AS grossamount " +
            "FROM c_orderline ol " +
            "JOIN m_product p ON p.m_product_id = ol.m_product_id " +
            "WHERE ol.c_order_id = ?";

        PreparedStatement ps2 = DB.prepareStatement(sqlLines, null);
        ps2.setInt(1, orderId);
        ResultSet rs2 = ps2.executeQuery();

        class Line {
            String item;
            BigDecimal qty, rate, discount, gross, discAmt, netAmt;
        }
        List<Line> lines = new ArrayList<>();

        BigDecimal subTotal = BigDecimal.ZERO;
        BigDecimal totalDiscount = BigDecimal.ZERO;
        BigDecimal grandTotal = BigDecimal.ZERO;

        while (rs2.next()) {

            Line ln = new Line();
            ln.item = rs2.getString("item");
            ln.qty = rs2.getBigDecimal("qtyordered");
            ln.rate = rs2.getBigDecimal("priceactual");
            ln.discount = rs2.getBigDecimal("discount");
            ln.gross = ln.qty.multiply(ln.rate);

            // discount amount = gross * discount / 100
            ln.discAmt = ln.discount;//ln.gross.multiply(ln.discount).divide(new BigDecimal("100"));
            ln.netAmt = ln.gross.subtract(ln.discAmt);

            subTotal = subTotal.add(ln.gross);
            totalDiscount = totalDiscount.add(ln.discAmt);
            grandTotal = grandTotal.add(ln.netAmt);

            lines.add(ln);
        }
        rs2.close();
        ps2.close();

        // --------------------------------------------------------------
        // 80mm PDF START
        // --------------------------------------------------------------
        Rectangle receiptSize = new Rectangle(227, 1200);
        Document doc = new Document(receiptSize, 5, 5, 5, 5);

        try {
            PdfWriter.getInstance(doc, new FileOutputStream(outFile));
            doc.open();

            Font bold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8);
            Font normal = FontFactory.getFont(FontFactory.HELVETICA, 7);

            // HEADER
            Paragraph title = new Paragraph(orgName + "\n", bold);
            title.setAlignment(Paragraph.ALIGN_CENTER);
            doc.add(title);

            Paragraph addr = new Paragraph(orgAddress + "\n", normal);
            addr.setAlignment(Paragraph.ALIGN_CENTER);
            doc.add(addr);

            doc.add(new Paragraph("GSTIN: " + orgGST, normal));
            doc.add(new Paragraph("Phone: " + orgPhone, normal));
            doc.add(new Paragraph("----------------------------------------", normal));

            doc.add(new Paragraph("Bill No: " + docNo, normal));
            doc.add(new Paragraph("Date   : " + date, normal));
            doc.add(new Paragraph("Customer: " + customer, normal));
            doc.add(new Paragraph(customerAddr, normal));
            doc.add(new Paragraph("GSTIN: " + customerGST, normal));

            doc.add(new Paragraph("----------------------------------------", normal));

            // --------------------------------------------------------------
            //  ITEMS TABLE (5 COLUMNS NOW)
            // --------------------------------------------------------------
            PdfPTable table = new PdfPTable(5);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{3f, 1f, 1f, 1f, 1.5f});

            addHeader(table, "Item");
            addHeader(table, "Qty");
            addHeader(table, "Rate");
            addHeader(table, "Disc");
            addHeader(table, "Amt");

            for (Line ln : lines) {

                addCell(table, ln.item, normal);
                addCell(table, ln.qty.stripTrailingZeros().toPlainString(), normal);
                addCell(table, ln.rate.toPlainString(), normal);
                addCell(table, ln.discAmt.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString(), normal);
                addCell(table, ln.netAmt.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString(), normal);
            }

            doc.add(table);

            doc.add(new Paragraph("----------------------------------------", normal));

            // --------------------------------------------------------------
            //  SUMMARY TOTALS
            // --------------------------------------------------------------
            doc.add(new Paragraph("Sub Total     : ₹ " + subTotal.setScale(2), normal));
            doc.add(new Paragraph("Discount      : ₹ " + totalDiscount.setScale(2), normal));

            Paragraph gTot = new Paragraph("Grand Total   : ₹ " + grandTotal.setScale(2), bold);
            gTot.setAlignment(Paragraph.ALIGN_RIGHT);
            doc.add(gTot);

            doc.add(new Paragraph("----------------------------------------", normal));

            Paragraph thanks = new Paragraph("Thank you! Visit again.", normal);
            thanks.setAlignment(Paragraph.ALIGN_CENTER);
            doc.add(thanks);

        } catch (Exception e) {
            throw new AdempiereException("Error generating 80mm PDF", e);

        } finally {
            if (doc.isOpen()) doc.close();
        }
    }



    private static void addHeader(PdfPTable t, String text) {
        PdfPCell c = new PdfPCell(new Paragraph(text,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10)));
        c.setPadding(5);
        t.addCell(c);
    }

    private static void addCell(PdfPTable t, String text, Font f) {
        PdfPCell c = new PdfPCell(new Paragraph(text, f));
        c.setPadding(5);
        t.addCell(c);
    }
}
