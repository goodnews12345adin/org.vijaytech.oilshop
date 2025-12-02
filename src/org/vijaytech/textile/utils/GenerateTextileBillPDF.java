package org.vijaytech.textile.utils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Properties;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.util.DB;
import org.json.JSONArray;

import com.lowagie.text.Document;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

public class GenerateTextileBillPDF {

	 public static String generate(File pdfFile, int orderId, Properties ctx) throws Exception {

	        // --- PDF STORAGE LOCATION ---
//	        String base = System.getProperty("user.dir") + "/pdf-bills/";
//	        File dir = new File(base);
//	        if (!dir.exists()) dir.mkdirs();

//	        String file = base + "" + orderId + ".pdf";

	            if (pdfFile.getParentFile() != null && !pdfFile.getParentFile().exists()) {
	            	pdfFile.getParentFile().mkdirs();
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
	                PdfWriter.getInstance(doc, new FileOutputStream(pdfFile));
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

	        return pdfFile.getAbsolutePath();
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