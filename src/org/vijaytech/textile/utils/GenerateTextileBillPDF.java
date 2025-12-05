package org.vijaytech.textile.utils;

import java.io.File;
import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.awt.Color; // ✅ Use java.awt.Color

import org.compiere.util.DB;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

public class GenerateTextileBillPDF {

	// Color theme based on your logo
	private static final Color COLOR_PRIMARY = new Color(251, 176, 52); // Yellow-Orange
	private static final Color COLOR_ACCENT = new Color(194, 24, 91); // Pink Magenta
	private static final Color COLOR_LIGHT = new Color(255, 235, 215);

	// ✅ Removed invalid generic <COLOR_ACCENT>
	public static String generate(File pdfFile, int orderId, String phone, Properties ctx) throws Exception {

		if (pdfFile.getParentFile() != null && !pdfFile.getParentFile().exists()) {
			pdfFile.getParentFile().mkdirs();
		}

		// FETCH BILL HEADER
		String sql = "SELECT o.documentno, o.dateordered, " + "bp.name, bp.phone, "
				+ "COALESCE(l.address1,'') AS cust_addr, " + "org.name AS org_name, "
				+ "oi.taxid AS gst, oi.phone AS org_phone, " + "COALESCE(loc.address1,'') AS org_addr "
				+ "FROM c_order o " + "JOIN c_bpartner bp ON bp.c_bpartner_id = o.c_bpartner_id "
				+ "LEFT JOIN c_bpartner_location bpl ON (bpl.c_bpartner_id = bp.c_bpartner_id AND bpl.isbillto = 'Y') "
				+ "LEFT JOIN c_location l ON l.c_location_id = bpl.c_location_id "
				+ "JOIN ad_org org ON org.ad_org_id = o.ad_org_id "
				+ "JOIN ad_orginfo oi ON oi.ad_org_id = org.ad_org_id "
				+ "LEFT JOIN c_location loc ON loc.c_location_id = oi.c_location_id " + "WHERE o.c_order_id = ?";

		PreparedStatement ps = DB.prepareStatement(sql, null);
		ps.setInt(1, orderId);
		ResultSet rs = ps.executeQuery();

		String billNo = "", billDate = "", custName = "", custPhone = "", custAddr = "";
		String orgName = "", orgGST = "", orgPhone = "", orgAddr = "";

		if (rs.next()) {
			billNo = rs.getString("documentno");
			Timestamp ts = rs.getTimestamp("dateordered");
			billDate = ts != null ? ts.toString() : "";
			custName = rs.getString("name");
			custPhone = rs.getString("phone");
			custAddr = rs.getString("cust_addr");
			orgName = rs.getString("org_name");
			orgGST = rs.getString("gst");
			orgPhone = rs.getString("org_phone");
			orgAddr = rs.getString("org_addr");
		}
		rs.close();
		ps.close();

		// FETCH ITEMS
		String sql2 = "SELECT p.name, p.value, p.hsncode, " + "ol.qtyordered, ol.priceactual " + "FROM c_orderline ol "
				+ "JOIN m_product p ON p.m_product_id = ol.m_product_id " + "WHERE ol.c_order_id = ?";

		PreparedStatement ps2 = DB.prepareStatement(sql2, null);
		ps2.setInt(1, orderId);
		ResultSet rs2 = ps2.executeQuery();

		class Item {
			String name, code, hsn;
			BigDecimal qty, rate, amt, gst;
		}
		List<Item> items = new ArrayList<>();
		BigDecimal total = BigDecimal.ZERO;
		BigDecimal gstTotal = BigDecimal.ZERO;

		while (rs2.next()) {
			Item it = new Item();
			it.name = rs2.getString(1);
			it.code = rs2.getString(2);
			it.hsn = rs2.getString(3);
			it.qty = rs2.getBigDecimal(4);
			it.rate = rs2.getBigDecimal(5);

			if (it.qty == null)
				it.qty = BigDecimal.ZERO;
			if (it.rate == null)
				it.rate = BigDecimal.ZERO;

			it.amt = it.qty.multiply(it.rate);
			it.gst = it.amt.multiply(new BigDecimal("0.05")); // 5% GST textile

			total = total.add(it.amt);
			gstTotal = gstTotal.add(it.gst);

			items.add(it);
		}
		rs2.close();
		ps2.close();

		// PDF START
		Document doc = new Document(PageSize.A4, 30, 30, 30, 30);
		PdfWriter.getInstance(doc, new FileOutputStream(pdfFile));
		doc.open();

		Font bigTitle = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, COLOR_ACCENT);
		Font bold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
		Font normal = FontFactory.getFont(FontFactory.HELVETICA, 10);

		// ===== LOGO + TITLE =====
		try {
			Image logo = Image.getInstance("src/main/webapp/images/happylady_logo.png");
			logo.scaleAbsolute(140, 60);
			doc.add(logo);
		} catch (Exception e) {
			// Ignore logo errors
		}

		Paragraph title = new Paragraph("Happy Lady Fashion", bigTitle);
		title.setAlignment(Element.ALIGN_RIGHT);
		doc.add(title);

		Paragraph shop = new Paragraph(orgAddr + "\nGSTIN: " + orgGST + "\nPhone: " + orgPhone, normal);
		shop.setAlignment(Element.ALIGN_RIGHT);
		doc.add(shop);

		doc.add(new Paragraph("\n"));

		// ===== BILL INFO =====
		PdfPTable info = new PdfPTable(2);
		info.setWidthPercentage(100);

		info.addCell(cell("Bill No:", bold));
		info.addCell(cell(billNo, normal));

		info.addCell(cell("Bill Date:", bold));
		info.addCell(cell(billDate, normal));

		info.addCell(cell("Customer:", bold));
		info.addCell(cell(custName, normal));

		info.addCell(cell("Phone:", bold));
		info.addCell(cell(phone, normal));

		info.addCell(cell("Address:", bold));
		info.addCell(cell(custAddr, normal));

		doc.add(info);

		doc.add(new Paragraph("\n"));

		// ===== ITEM TABLE =====
		PdfPTable table = new PdfPTable(6);
		table.setWidthPercentage(100);
		table.setWidths(new float[] { 4, 1, 1, 1, 1, 1.2f });

		table.addCell(header("Item"));
		table.addCell(header("Qty"));
		table.addCell(header("Rate"));
		table.addCell(header("Amount"));
		table.addCell(header("HSN"));
		table.addCell(header("GST 5%"));

		for (Item it : items) {
			table.addCell(cell(it.name, normal));
			table.addCell(cell(it.qty.toPlainString(), normal));
			table.addCell(cell(it.rate.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString(), normal));
			table.addCell(cell(it.amt.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString(), normal));
			table.addCell(cell(it.hsn != null ? it.hsn : "", normal));
			table.addCell(cell(it.gst.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString(), normal));
		}

		doc.add(table);

		doc.add(new Paragraph("\n"));

		// ===== TOTAL =====
		BigDecimal grandTotal = total.add(gstTotal);

		Paragraph t = new Paragraph("Subtotal: ₹ " + total.setScale(2, BigDecimal.ROUND_HALF_UP), bold);
		t.setAlignment(Element.ALIGN_RIGHT);
		doc.add(t);

		Paragraph g = new Paragraph("GST (5%): ₹ " + gstTotal.setScale(2, BigDecimal.ROUND_HALF_UP), bold);
		g.setAlignment(Element.ALIGN_RIGHT);
		doc.add(g);

		Paragraph gt = new Paragraph("Grand Total: ₹ " + grandTotal.setScale(2, BigDecimal.ROUND_HALF_UP), bigTitle);
		gt.setAlignment(Element.ALIGN_RIGHT);
		doc.add(gt);

		doc.add(new Paragraph("\n"));

		// ===== TEXTILE FOOTER =====
		Paragraph terms = new Paragraph("No return/exchange without bill.\n" + "Color may vary slightly.\n"
				+ "Thank you for shopping at Happy Lady Fashion ❤️", normal);
		terms.setAlignment(Element.ALIGN_CENTER);
		doc.add(terms);

		doc.close();

		return pdfFile.getAbsolutePath();
	}

	private static PdfPCell header(String text) {
		// ✅ Use java.awt.Color.WHITE
		Font font = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.WHITE);
		PdfPCell c = new PdfPCell(new Phrase(text, font));
		c.setBackgroundColor(COLOR_ACCENT); // Color accent background
		c.setPadding(6);
		return c;
	}

	private static PdfPCell cell(String text, Font f) {
		PdfPCell c = new PdfPCell(new Phrase(text != null ? text : "", f));
		c.setPadding(6);
		return c;
	}
}
