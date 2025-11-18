package org.vijaytech.textile.utils;

import java.io.File;
import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.compiere.util.DB;

import com.lowagie.text.Document;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

public class GenerateTextileBillPDF {

	 public static String generate(int orderId, Properties ctx) throws Exception {

	        // --- PDF STORAGE LOCATION ---
	        String base = System.getProperty("user.dir") + "/pdf-bills/";
	        File dir = new File(base);
	        if (!dir.exists()) dir.mkdirs();

	        String file = base + "textile_bill_" + orderId + ".pdf";

	        // ===================================================================
	        // 1) FETCH ORDER HEADER
	        // ===================================================================
	        String sqlHeader = 
	            "SELECT o.documentno, bp.name, bp.taxid, " +
	            "l.address1 || ', ' || l.city || '-' || l.postal AS address, " +
	            "o.dateordered " +
	            "FROM c_order o " +
	            "JOIN c_bpartner bp ON bp.c_bpartner_id = o.c_bpartner_id " +
	            "LEFT JOIN c_location l ON l.c_location_id = bp.c_location_id " +
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
	            date = rs.getString("dateordered");
	        }
	        rs.close();
	        ps.close();

	        // ===================================================================
	        // 2) FETCH ORDER LINES
	        // ===================================================================
	        String sqlLines = 
	            "SELECT p.name AS item, p.hsncode, ol.qtyordered, ol.priceactual, " +
	            "(ol.qtyordered * ol.priceactual) AS amount, " +
	            "u.x12de355 AS uom " +
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

	            total = total.add(rs2.getBigDecimal("amount"));
	            lines.add(m);
	        }
	        rs2.close();
	        ps2.close();

	        // ===================================================================
	        // 3) GENERATE PDF (OpenPDF)
	        // ===================================================================
	        Document doc = new Document();
	        PdfWriter.getInstance(doc, new FileOutputStream(file));
	        doc.open();

	        Font header = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14);
	        Font bold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
	        Font normal = FontFactory.getFont(FontFactory.HELVETICA, 10);

	        // TITLE
	        doc.add(new Paragraph("TEXTILE BILL", header));
	        doc.add(new Paragraph(" "));

	        // CUSTOMER INFO
	        doc.add(new Paragraph("Bill No : " + docNo, bold));
	        doc.add(new Paragraph("Date : " + date, normal));
	        doc.add(new Paragraph("Customer : " + customer, bold));
	        doc.add(new Paragraph("Address : " + address, normal));
	        doc.add(new Paragraph("GSTIN : " + gst, normal));
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
	            addCell(table, l.get("item").toString(), normal);
	            addCell(table, l.get("hsn").toString(), normal);
	            addCell(table, l.get("qty").toString(), normal);
	            addCell(table, l.get("rate").toString(), normal);
	            addCell(table, l.get("amount").toString(), normal);
	        }

	        doc.add(table);

	        doc.add(new Paragraph(" "));
	        doc.add(new Paragraph("Total Amount : ₹ " + total.toPlainString(), header));

	        doc.close();

	        return file;
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