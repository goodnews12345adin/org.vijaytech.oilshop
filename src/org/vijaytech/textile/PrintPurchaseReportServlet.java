package org.vijaytech.textile;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDate;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.compiere.util.DB;
import org.json.JSONArray;
import org.json.JSONObject;

import com.lowagie.text.Document;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

public class PrintPurchaseReportServlet extends HttpServlet {

	    private static final int PAGE_SIZE = 200;

	    private static Timestamp toTs(String ymd) {
	        return Timestamp.valueOf(LocalDate.parse(ymd).atStartOfDay());
	    }

	    private static Timestamp toTsEnd(String ymd) {
	        return Timestamp.valueOf(LocalDate.parse(ymd)
	                .plusDays(1).atStartOfDay().minusNanos(1_000_000));
	    }

	    private static String n(BigDecimal bd) {
	        return bd == null ? "" : bd.toPlainString();
	    }

	    // ===========================
	    //       ROW PDF GET
	    // ===========================
	    @Override
	    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
	            throws IOException {

	        String rowpdf = req.getParameter("rowpdf");
	        String docno = req.getParameter("docno");

	        if ("Y".equalsIgnoreCase(rowpdf) && docno != null) {
	            exportSinglePDF(docno, resp);
	            return;
	        }

	        resp.getWriter().write("Invalid Request");
	    }


	    // ===========================
	    //     MAIN JSON POST
	    // ===========================
	    @Override
	    protected void doPost(HttpServletRequest request, HttpServletResponse response)
	            throws IOException {

	        StringBuilder sb = new StringBuilder();
	        try (BufferedReader br = request.getReader()) {
	            String line;
	            while ((line = br.readLine()) != null) sb.append(line);
	        }

	        JSONObject jsonIn = new JSONObject(sb.toString());

	        String from = jsonIn.optString("from");
	        String to = jsonIn.optString("to");
	        String type = jsonIn.optString("type");
	        String org = jsonIn.optString("org", null);
	        String bp = jsonIn.optString("bp", null);
	        String summary = jsonIn.optString("summary", "N");
	        int page = jsonIn.optInt("page", 1);
	        boolean isSOTrx = type.equalsIgnoreCase("sales");

	        JSONArray result = new JSONArray();

	        StringBuilder sql = new StringBuilder();

	        if (summary.equals("Y")) {
	            // -------------------------
	            // SUMMARY MODE
	            // -------------------------
	            sql.append("SELECT ")
	               .append(" i.DateInvoiced, ")
	               .append(" bp.Name AS BPartner, ")
	               .append(" p.Name AS Product, ")
	               .append(" SUM(il.QtyInvoiced) AS Qty, ")
	               .append(" AVG(il.PriceActual) AS Price, ")
	               .append(" SUM(il.LineNetAmt) AS Amount ")
	               .append("FROM C_Invoice i ")
	               .append("JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID ")

	               // Business Partner
	               .append("LEFT JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID ")

	               // Your table (TF_PriceListUOM)
	               .append("LEFT JOIN TF_PriceListUOM plu ON il.M_Product_ID = plu.M_Product_ID ")

	               // Product table for name
	               .append("LEFT JOIN M_Product p ON plu.M_Product_ID = p.M_Product_ID ")

	               .append("WHERE i.IsSOTrx=? ")
	               .append("AND i.DocStatus IN ('CO','CL') ")
	               .append("AND i.DateInvoiced BETWEEN ? AND ? ");

	            if (org != null && !org.isEmpty())
	                sql.append("AND i.AD_Org_ID=? ");

	            if (bp != null && !bp.isEmpty())
	                sql.append("AND i.C_BPartner_ID=? ");

	            sql.append("GROUP BY i.DateInvoiced, bp.Name, p.Name ")
	               .append("ORDER BY i.DateInvoiced");

	        } else {

	            // -------------------------
	            // DETAIL MODE
	            // -------------------------
	            sql.append("SELECT ")
	               .append(" i.DateInvoiced, ")
	               .append(" i.DocumentNo, ")
	               .append(" bp.Name AS BPartner, ")
	               .append(" p.Name AS Product, ")
	               .append(" il.QtyInvoiced AS Qty, ")
	               .append(" il.PriceActual AS Price, ")
	               .append(" il.LineNetAmt AS Amount ")
	               .append("FROM C_Invoice i ")
	               .append("JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID ")

	               // Business Partner
	               .append("LEFT JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID ")

	               // Your TF PriceList table
	               .append("LEFT JOIN TF_PriceListUOM plu ON il.M_Product_ID = plu.M_Product_ID ")

	               // Product name
	               .append("LEFT JOIN M_Product p ON plu.M_Product_ID = p.M_Product_ID ")

	               .append("WHERE i.IsSOTrx=? ")
	               .append("AND i.DocStatus IN ('CO','CL') ")
	               .append("AND i.DateInvoiced BETWEEN ? AND ? ");

	            if (org != null && !org.isEmpty())
	                sql.append("AND i.AD_Org_ID=? ");

	            if (bp != null && !bp.isEmpty())
	                sql.append("AND i.C_BPartner_ID=? ");

	            sql.append("ORDER BY i.DateInvoiced ")
	               .append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
	        }


	        try (Connection conn = DB.getConnectionRW();
	             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

	            int idx = 1;

	            ps.setString(idx++, isSOTrx ? "Y" : "N");
	            ps.setTimestamp(idx++, toTs(from));
	            ps.setTimestamp(idx++, toTsEnd(to));

	            if (org != null && !org.isEmpty()) ps.setInt(idx++, Integer.parseInt(org));
	            if (bp != null && !bp.isEmpty()) ps.setInt(idx++, Integer.parseInt(bp));

	            if (summary.equals("N")) {
	                int offset = (page - 1) * PAGE_SIZE;
	                ps.setInt(idx++, offset);
	                ps.setInt(idx++, PAGE_SIZE);
	            }

	            ResultSet rs = ps.executeQuery();
System.out.println("data size :  "+rs.getFetchSize()); 
	            while (rs.next()) {
	                JSONObject row = new JSONObject();

	                row.put("Date", rs.getTimestamp("DateInvoiced").toString());

	                if (summary.equals("N"))
	                    row.put("DocumentNo", rs.getString("DocumentNo"));

	                row.put("BPartner", rs.getString("BPartner"));
	                row.put("Product", rs.getString("Product"));
	                row.put("Qty", n(rs.getBigDecimal("Qty")));
	                row.put("Price", n(rs.getBigDecimal("Price")));
	                row.put("Amount", n(rs.getBigDecimal("Amount")));

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


	    // ===========================
	    //     SINGLE PDF EXPORT
	    // ===========================
	    private void exportSinglePDF(String docNo, HttpServletResponse response) throws IOException {

	        String sql = "SELECT i.DateInvoiced, i.DocumentNo, bp.Name AS BPartner, "
	                + "p.Name AS Product, il.QtyInvoiced, il.PriceActual, il.LineNetAmt "
	                + "FROM C_Invoice i "
	                + "JOIN C_InvoiceLine il ON i.C_Invoice_ID=il.C_Invoice_ID "
	                + "LEFT JOIN C_BPartner bp ON i.C_BPartner_ID=bp.C_BPartner_ID "
	                + "LEFT JOIN TF_PriceListUOM p ON il.M_Product_ID=p.M_Product_ID "
	                + "WHERE i.DocumentNo=?";

	        Document pdf = new Document(PageSize.A4);
	        ByteArrayOutputStream baos = new ByteArrayOutputStream();

	        try {
	            PdfWriter.getInstance(pdf, baos);
	            pdf.open();

	            pdf.add(new Paragraph("Invoice PDF - " + docNo));

	            PdfPTable table = new PdfPTable(7);
	            table.setWidthPercentage(100);

	            table.addCell("Date");
	            table.addCell("DocumentNo");
	            table.addCell("BPartner");
	            table.addCell("Product");
	            table.addCell("Qty");
	            table.addCell("Price");
	            table.addCell("Amount");

	            Connection conn = DB.getConnectionRW();
	            PreparedStatement ps = conn.prepareStatement(sql);
	            ps.setString(1, docNo);
	            ResultSet rs = ps.executeQuery();

	            while (rs.next()) {
	                table.addCell(rs.getTimestamp("DateInvoiced").toString());
	                table.addCell(rs.getString("DocumentNo"));
	                table.addCell(rs.getString("BPartner"));
	                table.addCell(rs.getString("Product"));
	                table.addCell(rs.getString("QtyInvoiced"));
	                table.addCell(rs.getString("PriceActual"));
	                table.addCell(rs.getString("LineNetAmt"));
	            }

	            pdf.add(table);
	            pdf.close();

	            response.setContentType("application/pdf");
	            response.setHeader("Content-Disposition",
	                    "attachment; filename=" + docNo + "_Report.pdf");

	            baos.writeTo(response.getOutputStream());

	        } catch (Exception e) {
	            e.printStackTrace();
	            response.getWriter().write("Error generating PDF");
	        }
	    }
	}
