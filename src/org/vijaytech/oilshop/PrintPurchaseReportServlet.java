package org.vijaytech.oilshop;

import java.awt.Color;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.*;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.compiere.model.Query;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner;

import com.google.gson.Gson;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import com.lowagie.text.pdf.draw.LineSeparator;

public class PrintPurchaseReportServlet extends HttpServlet {

	private static final int PAGE_SIZE = 200;
	private static final long serialVersionUID = 1L;

	private static Timestamp toTs(String ymd) {
		return Timestamp.valueOf(LocalDate.parse(ymd).atStartOfDay());
	}

	private static Timestamp toTsEnd(String ymd) {
		return Timestamp.valueOf(LocalDate.parse(ymd).plusDays(1).atStartOfDay().minusNanos(1_000_000));
	}

	// Utility for Money (Fixed 2 decimals)
	private static String safe(BigDecimal bd) {
		return bd == null ? "0.00" : bd.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString();
	}

	// ✅ UTILITY FOR QUANTITY (Strict Format)
	// Logic:
	// 1. If 1.000 (Whole number) -> Show "1"
	// 2. If 0.500, 1.200, 0.100 (Has decimals) -> Force Scale 3 (e.g. "0.500")
	private static String formatQty(BigDecimal bd) {
		if (bd == null)
			return "0";

		// Check if value is an integer (e.g., 1.0, 2.0)
		if (bd.remainder(BigDecimal.ONE).compareTo(BigDecimal.ZERO) == 0) {
			// It is a whole number (e.g. 1.000), strip decimals
			return bd.setScale(0, BigDecimal.ROUND_HALF_UP).toPlainString();
		}

		// It has decimals (e.g. 0.5, 1.2, 0.900).
		// We force 3 decimal places to match user examples (0.500, 1.200)
		return bd.setScale(3, BigDecimal.ROUND_HALF_UP).toPlainString();
	}

	// ==================================================
	// ================ DO GET (PAGE + PDF) =============
	// ==================================================
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {

		String docNo = req.getParameter("docNo");
		if (docNo != null && !docNo.isEmpty()) {
			String format = req.getParameter("format");
			generateInvoiceOutput(req, resp, docNo, format);
			return;
		}

		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("ctx") == null) {
			resp.sendRedirect(req.getContextPath() + "/userlogin.jsp?error=session_expired");
			return;
		}

		Properties ctx = (Properties) session.getAttribute("ctx");
		Env.setCtx(ctx);

		if (Env.getAD_Client_ID(ctx) == 0)
			Env.setContext(ctx, "#AD_Client_ID", 1000000);
		if (Env.getAD_Org_ID(ctx) == 0)
			Env.setContext(ctx, "#AD_Org_ID", 1000000);
		if (Env.getAD_User_ID(ctx) == 0)
			Env.setContext(ctx, "#AD_User_ID", 100);
		if (Env.getContextAsInt(ctx, "#AD_Role_ID") == 0)
			Env.setContext(ctx, "#AD_Role_ID", 102);

		try {
			List<Map<String, Object>> supplierList = new ArrayList<>();
			List<TF_MBPartner> partners = new Query(ctx, TF_MBPartner.Table_Name, "IsActive='Y' AND isEmployee='N'",
					null).setClient_ID().list();

			for (TF_MBPartner bp : partners) {
				Map<String, Object> m = new HashMap<>();
				m.put("id", bp.get_ID());
				m.put("name", bp.getName());
				supplierList.add(m);
			}

			req.setAttribute("supplierList", supplierList);

			req.setAttribute("orgName", "THIRU SENTHILATHIPATHI OIL STORE");
			req.setAttribute("orgGST", "33AFFPR4639J1Z6");
			req.setAttribute("orgAddress",
					"No.42,Krishna Moorthi Bavanam,Madakulam Main Road,Palangantham,Madurai – 625003");

			RequestDispatcher rd = req.getRequestDispatcher("/pages/purchaseReport.jsp");
			rd.forward(req, resp);

		} catch (Exception e) {
			e.printStackTrace();
			throw new ServletException("Error loading Purchase Report", e);
		}
	}

	// ==================================================
	// ================ DO POST (JSON DATA) =============
	// ==================================================
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

		StringBuilder sb = new StringBuilder();
		try (BufferedReader br = request.getReader()) {
			String line;
			while ((line = br.readLine()) != null)
				sb.append(line);
		}

		JSONObject json = new JSONObject(sb.toString());

		String from = json.optString("from");
		String to = json.optString("to");
		String type = json.optString("type");
		String org = json.optString("org");
		String bp = json.optString("bp");
		String summary = json.optString("summary", "N");
		int page = json.optInt("page", 1);

		boolean isSOTrx = type.equalsIgnoreCase("sales");

		JSONArray result = new JSONArray();

		StringBuilder sql = new StringBuilder();

		if (summary.equals("Y")) {
			sql.append("SELECT i.DateInvoiced, bp.Name AS BPartner, ").append("p.Name AS Product, u.Name AS UOM, ")
					.append("SUM(il.QtyInvoiced) AS Qty, ").append("AVG(il.PriceActual) AS Price, ")
					.append("SUM(il.LineNetAmt) AS Amount ").append("FROM C_Invoice i ")
					.append("JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID ")
					.append("LEFT JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID ")
					.append("LEFT JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID ")
					.append("LEFT JOIN C_UOM u ON il.C_UOM_ID = u.C_UOM_ID ")
					.append("WHERE i.IsSOTrx=? AND i.DocStatus IN ('CO','CL') ")
					.append("AND i.DateInvoiced BETWEEN ? AND ? ");

			if (org != null && !org.isEmpty())
				sql.append("AND i.AD_Org_ID=").append(org);
			if (bp != null && !bp.isEmpty())
				sql.append("AND i.C_BPartner_ID=").append(bp);

			sql.append(" GROUP BY i.DateInvoiced, bp.Name, p.Name ").append(" ORDER BY i.DateInvoiced");

		} else {
			sql.append("SELECT i.DateInvoiced, i.DocumentNo, ").append("bp.Name AS BPartner, ")
					.append("p.Name AS Product, ").append("u.Name AS UOM, ").append("il.QtyInvoiced AS Qty, ")
					.append("il.PriceActual AS Price, ").append("il.LineNetAmt AS Amount, ")
					.append("COALESCE(o.Cash, 0) AS CashAmt, ").append("COALESCE(o.UPI, 0) AS UpiAmt ")
					.append("FROM C_Invoice i ").append("JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID ")
					.append("LEFT JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID ")
					.append("LEFT JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID ")
					.append("LEFT JOIN C_UOM u ON il.C_UOM_ID = u.C_UOM_ID ")
					.append("LEFT JOIN C_Order o ON i.C_Order_ID = o.C_Order_ID ").append("WHERE i.IsSOTrx=? ")
					.append("AND i.DocStatus IN ('CO','CL') ").append("AND i.DateInvoiced BETWEEN ? AND ? ");

			if (org != null && !org.isEmpty())
				sql.append("AND i.AD_Org_ID=").append(org);

			if (bp != null && !bp.isEmpty())
				sql.append("AND i.C_BPartner_ID=").append(bp);

			sql.append(" ORDER BY i.DateInvoiced ").append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
		}

		try (Connection conn = DB.getConnectionRW(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

			int idx = 1;

			ps.setString(idx++, isSOTrx ? "Y" : "N");
			ps.setTimestamp(idx++, toTs(from));
			ps.setTimestamp(idx++, toTsEnd(to));

			if (summary.equals("N")) {
				int offset = (page - 1) * PAGE_SIZE;
				ps.setInt(idx++, offset);
				ps.setInt(idx++, PAGE_SIZE);
			}

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				JSONObject row = new JSONObject();

				row.put("Date", rs.getTimestamp("DateInvoiced").toString());
				if (summary.equals("N"))
					row.put("DocumentNo", rs.getString("DocumentNo"));
				row.put("BPartner", rs.getString("BPartner"));
				row.put("Product", rs.getString("Product"));
				row.put("UOM", rs.getString("UOM"));

				// ✅ Uses the forced 3-decimal formatQty logic
				row.put("Qty", formatQty(rs.getBigDecimal("Qty")));

				row.put("Price", safe(rs.getBigDecimal("Price")));
				row.put("Amount", safe(rs.getBigDecimal("Amount")));
				row.put("upi", safe(rs.getBigDecimal("UpiAmt")));
				row.put("cash", safe(rs.getBigDecimal("CashAmt")));

				result.put(row);
			}

		} catch (Exception ex) {
			ex.printStackTrace();
			JSONObject err = new JSONObject();
			err.put("error", ex.getMessage());
			response.getWriter().write(err.toString());
			return;
		}

		response.setContentType("application/json");
		response.getWriter().write(result.toString());
	}

	private void generateInvoiceOutput(HttpServletRequest req, HttpServletResponse resp, String docNo, String format)
			throws IOException {

		List<Map<String, String>> lines = new ArrayList<>();
		List<Map<String, String>> taxes = new ArrayList<>();

		String bPartner = "";
		String phone = "";
		String docDate = "";
		String grandTotal = "0.00";
		String upi = "0.00";
		String cash = "0.00";

		int invoiceId = 0;

		BigDecimal taxableTotal = BigDecimal.ZERO;
		BigDecimal gstTotal = BigDecimal.ZERO;

		String sql = "SELECT i.C_Invoice_ID, i.DateInvoiced, i.GrandTotal, " + " bp.Name,bp.phone, "
				+ " il.LineNetAmt, il.PriceActual, il.QtyInvoiced, "
				+ " p.Name AS ProductName, COALESCE(p.HSNCode,'') AS HSNCode " + "FROM C_Invoice i "
				+ "JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID "
				+ "JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID "
				+ "LEFT JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID " + "WHERE i.DocumentNo=?";

		try (Connection conn = DB.getConnectionRW(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setString(1, docNo);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {

				if (invoiceId == 0) {
					invoiceId = rs.getInt("C_Invoice_ID");

					bPartner = rs.getString("Name");
					phone = rs.getString("phone");

					Timestamp ts = rs.getTimestamp("DateInvoiced");
					docDate = new SimpleDateFormat("dd-MM-yyyy HH:mm").format(ts);

					grandTotal = safe(rs.getBigDecimal("GrandTotal"));
				}

				Map<String, String> line = new HashMap<>();
				line.put("Product", rs.getString("ProductName"));
				line.put("HSN", rs.getString("HSNCode"));
				// ✅ Uses the forced 3-decimal formatQty logic
				line.put("Qty", formatQty(rs.getBigDecimal("QtyInvoiced")));
				line.put("Price", safe(rs.getBigDecimal("PriceActual")));
				line.put("Total", safe(rs.getBigDecimal("LineNetAmt")));

				lines.add(line);
			}

		} catch (Exception e) {
			e.printStackTrace();
			resp.sendError(500, "Error loading Invoice Lines");
			return;
		}

		String taxSql = "SELECT t.Name AS TaxName, it.TaxAmt, it.TaxBaseAmt " + "FROM C_InvoiceTax it "
				+ "JOIN C_Tax t ON it.C_Tax_ID = t.C_Tax_ID " + "WHERE it.C_Invoice_ID=?";

		try (Connection conn = DB.getConnectionRW(); PreparedStatement ps = conn.prepareStatement(taxSql)) {

			ps.setInt(1, invoiceId);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {

				String name = rs.getString("TaxName");

				BigDecimal taxAmt = rs.getBigDecimal("TaxAmt");
				BigDecimal baseAmt = rs.getBigDecimal("TaxBaseAmt");

				gstTotal = gstTotal.add(taxAmt);

				if (baseAmt.compareTo(taxableTotal) > 0) {
					taxableTotal = baseAmt;
				}

				BigDecimal rate = BigDecimal.ZERO;
				if (baseAmt.compareTo(BigDecimal.ZERO) > 0) {
					rate = taxAmt.multiply(new BigDecimal("100")).divide(baseAmt, 2, BigDecimal.ROUND_HALF_UP);
				}

				if (name.contains("CGST"))
					name = "CGST";
				else if (name.contains("SGST"))
					name = "SGST";
				else if (name.contains("IGST"))
					name = "IGST";

				Map<String, String> tax = new HashMap<>();
				tax.put("Name", name + " @" + rate + "%");
				tax.put("Amt", safe(taxAmt));

				taxes.add(tax);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		BigDecimal calcGrand = taxableTotal.add(gstTotal);

		if (calcGrand.subtract(new BigDecimal(grandTotal)).abs().doubleValue() > 1) {
			calcGrand = new BigDecimal(grandTotal);
		}

		if ("thermal".equalsIgnoreCase(format)) {

			generateThermalHtml(resp, docNo, bPartner, docDate, grandTotal, taxableTotal, lines, taxes, phone);

		} else {

			generateA4Pdf(resp, docNo, bPartner, docDate, grandTotal, taxableTotal, lines, taxes, phone);
		}
	}

	private void generateThermalHtml(HttpServletResponse resp, String docNo, String bp, String date, String total,
			BigDecimal subTotal, List<Map<String, String>> lines, List<Map<String, String>> taxes, String phone)
			throws IOException {

		resp.setContentType("text/html");
		PrintWriter out = resp.getWriter();

		out.println("<!DOCTYPE html>");
		out.println("<html><head><meta charset='UTF-8'>");
		out.println("<title>Receipt</title>");
		out.println("<style>");
		out.println("@media print {");
		out.println("@page { margin: 0; size: 80mm auto; }");
		out.println("body { -webkit-print-color-adjust: exact; print-color-adjust: exact; margin: 0; }");
		out.println("}");
		out.println(
				"body { font-family: 'Courier New', Courier, monospace; font-size: 12px; color: #000; width: 76mm; margin: 2mm auto; line-height: 1.2; }");
		out.println(
				".header { text-align: center; border-bottom: 2px solid #000; padding-bottom: 5px; margin-bottom: 8px; }");
		out.println(
				".store-name { font-size: 16px; font-weight: bold; text-transform: uppercase; margin: 0; line-height: 1.2; }");
		out.println(".sub-header { font-size: 10px; font-weight: bold; margin-top: 2px; }");
		out.println(
				".invoice-meta { text-align: left; margin-bottom: 8px; font-size: 12px; border-bottom: 1px dashed #000; padding-bottom: 5px; }");
		out.println(".meta-row { display: flex; justify-content: space-between; margin: 1px 0; }");
		out.println(
				".table-head { display: flex; border-bottom: 1px solid #000; padding-bottom: 2px; font-weight: bold; font-size: 11px; }");
		out.println(".table-row { display: flex; padding: 2px 0; border-bottom: 1px dotted #ccc; }");

		// Alignment CSS
		out.println(
				".col-item { flex: 3; padding-right: 5px; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }");
		out.println(".col-hsn { flex: 1; text-align: center; font-size: 10px; white-space: nowrap; }");
		out.println(".col-qty { flex: 0.8; text-align: right; white-space: nowrap; }");
		out.println(".col-amt { flex: 1.2; text-align: right; white-space: nowrap; }");
		out.println(".col-rate { flex: 1; text-align: right; font-size: 10px; white-space: nowrap; }");

		out.println(".totals-section { margin-top: 5px; border-top: 1px solid #000; padding-top: 2px; }");
		out.println(".total-row { display: flex; justify-content: space-between; margin: 1px 0; }");
		out.println(
				".grand-total { display: flex; justify-content: space-between; font-weight: bold; font-size: 14px; border-top: 1px solid #000; border-bottom: 1px solid #000; padding: 4px 0; margin-top: 3px; }");
		out.println(
				".footer { text-align: center; margin-top: 10px; font-weight: bold; font-size: 11px; border-top: 1px dashed #000; padding-top: 5px; }");
		out.println("</style></head><body>");

		// HEADER
		out.println("<div class='header'>");
		out.println("<div class='store-name'>THIRU SENTHILATHIPATHI OIL STORE</div>");
		out.println(
				"<div style='font-size:10px;'>No.42,Krishna Moorthi Bavanam,Madakulam Main Road,Palangantham,Madurai – 625003</div>");
		out.println("<div style='font-size:10px; font-weight:bold;'>GST: 33AFFPR4639J1Z6</div>");
		out.println("</div>");

		// META
		out.println("<div class='invoice-meta'>");
		out.println("<div style='font-weight:bold; margin-bottom:3px;'>TAX INVOICE</div>");
		out.println(
				"<div class='meta-row'><span>INV #: " + docNo + "</span><span>" + date.split(" ")[0] + "</span></div>");
		out.println("<div class='meta-row'><span>CUST: "
				+ (bp != null ? bp.substring(0, Math.min(bp.length(), 20)) : "Walk-in") + "</span></div>");
		out.println("<div class='meta-row'><span>TIME: " + date.split(" ")[1] + "</span></div>");
		out.println("</div>");

		// TABLE HEADER
		out.println("<div class='table-head'>");
		out.println("<div class='col-item'>ITEM</div>");
		out.println("<div class='col-hsn'>HSN</div>");
		out.println("<div class='col-rate'>RATE</div>");
		out.println("<div class='col-qty'>QTY</div>");
		out.println("<div class='col-amt'>AMT</div>");
		out.println("</div>");

		// LINES
		for (Map<String, String> line : lines) {
			out.println("<div class='table-row'>");
			out.println("<div class='col-item' title='" + line.get("Product") + "'>"
					+ line.get("Product").substring(0, Math.min(line.get("Product").length(), 18)) + "</div>");
			out.println("<div class='col-hsn'>" + line.get("HSN") + "</div>");
			out.println("<div class='col-rate'>" + line.get("Price") + "</div>");
			// ✅ Uses formatQty (Forces 0.500)
			out.println("<div class='col-qty'>" + formatQty(new BigDecimal(line.get("Qty"))) + "</div>");
			out.println("<div class='col-amt'>" + line.get("Total") + "</div>");
			out.println("</div>");
		}

		out.println("<div class='totals-section'>");
		// Taxable Amount
		out.println("<div class='total-row'><span>Taxable Amount:</span><span>" + safe(subTotal) + "</span></div>");

		// GST Breakup
		for (Map<String, String> tax : taxes) {
			out.println("<div class='total-row'><span>" + tax.get("Name") + ":</span><span>" + tax.get("Amt")
					+ "</span></div>");
		}

		// Grand Total
		out.println("<div class='grand-total'>");
		out.println("<span style='font-size:12px'>TOTAL</span><span>" + total + "</span>");
		out.println("</div>");

		// GST Inclusive Note
		out.println("<div class='total-row' style='font-size:10px;'>");
		out.println("<span>(All Prices Inclusive of GST)</span><span></span>");
		out.println("</div>");
		out.println("</div>");

		// FOOTER (QR Code Removed as per instruction)
		out.println("<div class='footer'>");

		// ✅ QR CODE REMOVED

		out.println("THANK YOU VISIT AGAIN<br>");
		out.println("<span style='font-weight:normal; font-size:9px;'>Computer Generated Invoice</span>");
		out.println("</div>");

		out.println("<script>window.onload = function(){ window.print(); }</script>");
		out.println("</body></html>");
	}

	private void generateA4Pdf(HttpServletResponse resp, String docNo, String bp, String date, String total,
			BigDecimal subTotal, List<Map<String, String>> lines, List<Map<String, String>> taxes, String phone) throws IOException {

		Document document = new Document(PageSize.A4, 20, 20, 30, 30);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();

		try {
			PdfWriter.getInstance(document, baos);
			document.open();

// Colors
			Color corporateBlue = new Color(0, 51, 102);
			Color lightGrey = new Color(245, 245, 245);
// Use a distinct grey for borders to ensure they are visible
			Color borderColor = new Color(180, 180, 180);

// Fonts
			Font fontTitle = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 24, Color.WHITE);
			Font fontSubTitle = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, Color.WHITE);
			Font fontHeader = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, corporateBlue);
			Font fontTableHead = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.WHITE);
			Font fontNormal = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.BLACK);
			Font fontBold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.BLACK);

// --- 1. MAIN HEADER (Blue Box) ---
			PdfPTable headerBox = new PdfPTable(1);
			headerBox.setWidthPercentage(100);

			PdfPCell headerCell = new PdfPCell();
			headerCell.setBackgroundColor(corporateBlue);
			headerCell.setBorder(Rectangle.NO_BORDER);
			headerCell.setPadding(15);

			Paragraph mainTitle = new Paragraph("TAX INVOICE", fontTitle);
			mainTitle.setAlignment(Element.ALIGN_CENTER);
			headerCell.addElement(mainTitle);

			Paragraph companyInfo = new Paragraph("THIRU SENTHILATHIPATHI OIL STORE", fontSubTitle);
			companyInfo.setAlignment(Element.ALIGN_CENTER);
			headerCell.addElement(companyInfo);

			Paragraph addressInfo = new Paragraph("No.42,Krishna Moorthi Bavanam,Madakulam Main Road,Palangantham,Madurai  625003 | GST: 33AFFPR4639J1Z6",
					FontFactory.getFont(FontFactory.HELVETICA, 10, Color.WHITE));
			addressInfo.setAlignment(Element.ALIGN_CENTER);
			headerCell.addElement(addressInfo);

			headerBox.addCell(headerCell);
			document.add(headerBox);
			document.add(Chunk.NEWLINE);

// --- 2. BILL TO / INVOICE DETAILS ---
			PdfPTable infoTable = new PdfPTable(2);
			infoTable.setWidthPercentage(100);
			infoTable.setWidths(new float[] { 1.5f, 1f });

// Left: Bill To
			PdfPCell billToCell = new PdfPCell();
			billToCell.setBorder(Rectangle.BOX);
			billToCell.setBorderColor(borderColor);
			billToCell.setPadding(10);

			Paragraph billToTitle = new Paragraph("Bill To:", fontHeader);
			billToTitle.setSpacingBefore(0);
			billToTitle.setSpacingAfter(5);
			billToCell.addElement(billToTitle);

			billToCell.addElement(new Phrase(bp, fontNormal));
//			billToCell.addElement(new Phrase("Bangalore, Karnataka", fontNormal));
			billToCell.addElement(Chunk.NEWLINE);
			billToCell.addElement(new Phrase("Date: " + date.split(" ")[0], fontBold));

			infoTable.addCell(billToCell);

// Right: Invoice Info
			PdfPCell invInfoCell = new PdfPCell();
			invInfoCell.setBorder(Rectangle.BOX);
			invInfoCell.setBorderColor(borderColor);
			invInfoCell.setBackgroundColor(lightGrey);
			invInfoCell.setPadding(10);
// Align the cell content to the right
			invInfoCell.setHorizontalAlignment(Element.ALIGN_RIGHT);

			Paragraph pNo = new Paragraph("Invoice No: " + docNo, fontHeader);
			pNo.setAlignment(Element.ALIGN_RIGHT);
			invInfoCell.addElement(pNo);
			invInfoCell.addElement(Chunk.NEWLINE);

// Ensure the Total lines up on the right
			Paragraph pTotalLabel = new Paragraph("Invoice Total: ", fontBold);
			pTotalLabel.setAlignment(Element.ALIGN_RIGHT);
			invInfoCell.addElement(pTotalLabel);

			Paragraph pTotalVal = new Paragraph(total, fontHeader);
			pTotalVal.setAlignment(Element.ALIGN_RIGHT);
			invInfoCell.addElement(pTotalVal);

			infoTable.addCell(invInfoCell);
			document.add(infoTable);
			document.add(Chunk.NEWLINE);

// --- 3. LINE ITEMS ---
			PdfPTable itemsTable = new PdfPTable(6);
			itemsTable.setWidthPercentage(100);
			itemsTable.setWidths(new float[] { 3f, 1.2f, 1f, 1.2f, 1.2f, 1.5f });

// Header Row - Use borders to separate from content
			itemsTable.setHeaderRows(1);
			itemsTable.addCell(
					createPdfCell("Item Description", Element.ALIGN_LEFT, fontTableHead, corporateBlue, borderColor));
			itemsTable.addCell(createPdfCell("HSN", Element.ALIGN_CENTER, fontTableHead, corporateBlue, borderColor));
			itemsTable.addCell(createPdfCell("Qty", Element.ALIGN_CENTER, fontTableHead, corporateBlue, borderColor));
			itemsTable.addCell(createPdfCell("Rate", Element.ALIGN_RIGHT, fontTableHead, corporateBlue, borderColor));
			itemsTable.addCell(createPdfCell("Tax", Element.ALIGN_RIGHT, fontTableHead, corporateBlue, borderColor));
			itemsTable.addCell(createPdfCell("Amount", Element.ALIGN_RIGHT, fontTableHead, corporateBlue, borderColor));

// Data Rows
			for (Map<String, String> line : lines) {
				PdfPCell cDesc = new PdfPCell(new Phrase(line.get("Product"), fontNormal));
				cDesc.setBorderColor(borderColor);
				cDesc.setPadding(4);
				itemsTable.addCell(cDesc);

				PdfPCell cHSN = new PdfPCell(new Phrase(line.get("HSN"), fontNormal));
				cHSN.setHorizontalAlignment(Element.ALIGN_CENTER);
				cHSN.setBorderColor(borderColor);
				cHSN.setPadding(4);
				itemsTable.addCell(cHSN);

				PdfPCell cQty = new PdfPCell(new Phrase(line.get("Qty"), fontNormal));
				cQty.setHorizontalAlignment(Element.ALIGN_CENTER);
				cQty.setBorderColor(borderColor);
				cQty.setPadding(4);
				itemsTable.addCell(cQty);

				PdfPCell cRate = new PdfPCell(new Phrase(line.get("Price"), fontNormal));
				cRate.setHorizontalAlignment(Element.ALIGN_RIGHT);
				cRate.setBorderColor(borderColor);
				cRate.setPadding(4);
				itemsTable.addCell(cRate);

				PdfPCell cTax = new PdfPCell(new Phrase("Taxable", fontNormal));
				cTax.setHorizontalAlignment(Element.ALIGN_RIGHT);
				cTax.setBorderColor(borderColor);
				cTax.setPadding(4);
				itemsTable.addCell(cTax);

				PdfPCell cTotal = new PdfPCell(new Phrase(line.get("Total"), fontNormal));
				cTotal.setHorizontalAlignment(Element.ALIGN_RIGHT);
				cTotal.setBorderColor(borderColor);
				cTotal.setPadding(4);
				itemsTable.addCell(cTotal);
			}
			document.add(itemsTable);
			document.add(Chunk.NEWLINE);

// --- 4. TOTALS SUMMARY ---
			PdfPTable summaryTable = new PdfPTable(2);
			summaryTable.setWidthPercentage(100);
			summaryTable.setWidths(new float[] { 2f, 1f });

// Left: Amount in Words
			PdfPCell wordsCell = new PdfPCell();
			wordsCell.setBorder(Rectangle.NO_BORDER);
			wordsCell.addElement(new Phrase("Amount in Words:", fontBold));
			wordsCell.addElement(new Phrase(
					NumberToWord.convertNumberToWord(Double.parseDouble(total)) + " Rupees Only", fontNormal));
			summaryTable.addCell(wordsCell);

// Right: Calculations
			PdfPCell calcCell = new PdfPCell();
			calcCell.setBorder(Rectangle.NO_BORDER);
			calcCell.setHorizontalAlignment(Element.ALIGN_RIGHT);

			Paragraph pSubTotal = new Paragraph("Sub Total: " + safe(subTotal), fontNormal);
			pSubTotal.setAlignment(Element.ALIGN_RIGHT);
			calcCell.addElement(pSubTotal);

			for (Map<String, String> tax : taxes) {
				Paragraph pTax = new Paragraph(tax.get("Name") + ": " + tax.get("Amt"), fontNormal);
				pTax.setAlignment(Element.ALIGN_RIGHT);
				calcCell.addElement(pTax);
			}

			Paragraph grandTotalP = new Paragraph("Grand Total: " + total + " INR", fontHeader);
			grandTotalP.setSpacingBefore(5);
			grandTotalP.setAlignment(Element.ALIGN_RIGHT);
			calcCell.addElement(grandTotalP);

			summaryTable.addCell(calcCell);
			document.add(summaryTable);

// --- 5. SIGNATORY & TERMS ---
			PdfPTable footerTable = new PdfPTable(1);
			footerTable.setWidthPercentage(100);
			footerTable.setSpacingBefore(30);

			PdfPCell termsCell = new PdfPCell();
			termsCell.setBorder(Rectangle.TOP);
			termsCell.setBorderColor(corporateBlue);
			termsCell.setPaddingTop(10);
			termsCell.setPaddingBottom(10);

			termsCell.addElement(new Phrase("Terms & Conditions:", fontHeader));
			termsCell.addElement(Chunk.NEWLINE);
			termsCell.addElement(new Phrase("1. Goods once sold will not be taken back.", fontNormal));
			termsCell.addElement(new Phrase("2. Subject to Bangalore Jurisdiction.", fontNormal));
			termsCell.addElement(new Phrase("3. Payment due within 30 days.", fontNormal));

			footerTable.addCell(termsCell);
			document.add(footerTable);

			Paragraph signPara = new Paragraph("\n\n\nAuthorized Signatory", fontBold);
			signPara.setAlignment(Element.ALIGN_RIGHT);
			document.add(signPara);
			document.close();
			resp.setContentType("application/pdf");
			resp.setHeader("Content-Disposition", "attachment; filename=Invoice_" + docNo + ".pdf");
			resp.setContentLength(baos.size());
			baos.writeTo(resp.getOutputStream());
			resp.getOutputStream().flush();

		} catch (DocumentException e) {
			e.printStackTrace();
			throw new IOException("Error generating PDF: " + e.getMessage());
		}
	}

	private PdfPCell createPdfCell(String content, int alignment, Font font, Color bgColor, Color borderColor) {
		PdfPCell cell = new PdfPCell(new Phrase(content, font));
		cell.setHorizontalAlignment(alignment);
		cell.setBackgroundColor(bgColor);
		cell.setPadding(5);
// Set border color explicitly to ensure lines are visible
		cell.setBorderColor(borderColor);
		return cell;
	}

	static class NumberToWord {
		public static String convertNumberToWord(double number) {
// Simple placeholder implementation
			return String.valueOf(number);
		}
	}

}