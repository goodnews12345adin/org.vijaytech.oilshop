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

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

@WebServlet("/SalesSaveServlet")
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
                    ", prodId: " + prodId);

            TF_MOrderLine ordLine = new TF_MOrderLine(ctx, 0, null);

            // prodId = M_Product_ID (coming from the UI)
            MProduct prod = new MProduct(ctx, prodId, null);

            ordLine.setC_Order_ID(ordH.get_ID());
            ordLine.setM_Product_ID(prod.get_ID());
            ordLine.setC_UOM_ID(prod.getC_UOM_ID());
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

        String filename = "invoice_" + ordH.get_ID() + ".pdf";

        String invoicesFolder = req.getServletContext().getRealPath("/invoices");
        if (invoicesFolder == null) {
            // fallback if running from packed WAR with no realPath
            invoicesFolder = System.getProperty("user.dir") + File.separator + "invoices";
        }
        Files.createDirectories(Paths.get(invoicesFolder));

        File pdfFile = new File(invoicesFolder, filename);

        try {
            generateInvoicePDF(pdfFile, ordH.get_ID());
        } catch (IOException | SQLException e) {
            e.printStackTrace();
            throw new ServletException("Error generating invoice PDF", e);
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
    private void generateInvoicePDF(File outFile, int orderId) throws IOException, SQLException {

        if (outFile.getParentFile() != null && !outFile.getParentFile().exists()) {
            outFile.getParentFile().mkdirs();
        }

        // ===================================================================
        // 1) FETCH ORDER HEADER
        // ===================================================================
        String sqlHeader =
                "SELECT o.documentno, bp.name, bp.taxid, " +
                "       coalesce(l.address1,'') || " +
                "       CASE WHEN l.city IS NOT NULL THEN ', ' || l.city ELSE '' END || " +
                "       CASE WHEN l.postal IS NOT NULL THEN '-' || l.postal ELSE '' END AS address, " +
                "       o.dateordered " +
                "FROM c_order o " +
                "JOIN c_bpartner bp ON bp.c_bpartner_id = o.c_bpartner_id " +
                "LEFT JOIN c_bpartner_location bpl ON (bpl.c_bpartner_id = bp.c_bpartner_id AND bpl.isbillto = 'Y') " +
                "LEFT JOIN c_location l ON l.c_location_id = bpl.c_location_id " +
                "WHERE o.c_order_id = ?";

        PreparedStatement ps = DB.prepareStatement(sqlHeader, null);
        ps.setInt(1, orderId);
        ResultSet rs = ps.executeQuery();

        String customer = "", gst = "", address = "", docNo = "", date = "";
        if (rs.next()) {
            docNo = rs.getString("documentno");
            customer = rs.getString("name");
            gst = rs.getString("taxid");
            address = rs.getString("address");
            date = String.valueOf(rs.getTimestamp("dateordered"));
        }
        rs.close();
        ps.close();

        // ===================================================================
        // 2) FETCH ORDER LINES
        // ===================================================================
        String sqlLines =
                "SELECT p.name AS item, p.hsncode, ol.qtyordered, ol.priceactual, " +
                "       (ol.qtyordered * ol.priceactual) AS amount, " +
                "       u.x12de355 AS uom " +
                "FROM c_orderline ol " +
                "JOIN m_product p ON p.m_product_id = ol.m_product_id " +
                "JOIN c_uom u ON u.c_uom_id = ol.c_uom_id " +
                "WHERE ol.c_order_id = ?";

        PreparedStatement ps2 = DB.prepareStatement(sqlLines, null);
        ps2.setInt(1, orderId);
        ResultSet rs2 = ps2.executeQuery();

        List<Map<String, Object>> lines = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;

        while (rs2.next()) {
            Map<String, Object> m = new HashMap<>();
            m.put("item", rs2.getString("item"));
            m.put("hsn", rs2.getString("hsncode"));
            m.put("qty", rs2.getBigDecimal("qtyordered"));
            m.put("rate", rs2.getBigDecimal("priceactual"));
            m.put("amount", rs2.getBigDecimal("amount"));
            m.put("uom", rs2.getString("uom"));

            if (rs2.getBigDecimal("amount") != null) {
                total = total.add(rs2.getBigDecimal("amount"));
            }
            lines.add(m);
        }
        rs2.close();
        ps2.close();

        // ===================================================================
        // 3) GENERATE PDF (OpenPDF)
        // ===================================================================
        Document doc = new Document();
        try {
            PdfWriter.getInstance(doc, new FileOutputStream(outFile));
            doc.open();

            Font header = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14);
            Font bold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
            Font normal = FontFactory.getFont(FontFactory.HELVETICA, 10);

            // TITLE
            doc.add(new Paragraph("TEXTILE BILL", header));
            doc.add(new Paragraph(" "));

            // CUSTOMER INFO
            doc.add(new Paragraph("Bill No : " + Objects.toString(docNo, ""), bold));
            doc.add(new Paragraph("Date : " + Objects.toString(date, ""), normal));
            doc.add(new Paragraph("Customer : " + Objects.toString(customer, ""), bold));
            doc.add(new Paragraph("Address : " + Objects.toString(address, ""), normal));
            doc.add(new Paragraph("GSTIN : " + Objects.toString(gst, ""), normal));
            doc.add(new Paragraph(" "));

            // TABLE
            PdfPTable table = new PdfPTable(5);
            table.setWidths(new float[]{4, 2, 1, 1.5f, 2});
            table.setWidthPercentage(100);

            addHeader(table, "Item");
            addHeader(table, "HSN");
            addHeader(table, "Qty");
            addHeader(table, "Rate");
            addHeader(table, "Amount");

            for (Map<String, Object> l : lines) {
                addCell(table, Objects.toString(l.get("item"), ""), normal);
                addCell(table, Objects.toString(l.get("hsn"), ""), normal);

                BigDecimal q = (BigDecimal) l.get("qty");
                BigDecimal r = (BigDecimal) l.get("rate");
                BigDecimal a = (BigDecimal) l.get("amount");

                addCell(table, q != null ? q.toPlainString() : "", normal);
                addCell(table, r != null ? r.toPlainString() : "", normal);
                addCell(table, a != null ? a.toPlainString() : "", normal);
            }

            doc.add(table);

            doc.add(new Paragraph(" "));
            doc.add(new Paragraph("Total Amount : ₹ " + total.toPlainString(), header));

        } catch (DocumentException e) {
            throw new IOException("Error generating PDF", e);
        } finally {
            if (doc.isOpen()) {
                doc.close();
            }
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
