package org.vijaytech.textile.utils;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.compiere.util.DB;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

public class SingleInvoicePDF extends HttpServlet {

	private String safe(BigDecimal bd) {
        return (bd == null) ? " " : bd.toPlainString();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String doc = req.getParameter("docNo");
        if (doc == null || doc.trim().isEmpty()) {
            resp.getWriter().write("DocumentNo is missing");
            return;
        }
        doc = java.net.URLDecoder.decode(doc, "UTF-8");

        // -----------------------------
        // Main SQL (without GST columns)
        // -----------------------------
        String sql = "SELECT i.DateInvoiced, i.DocumentNo, bp.Name AS BPartner, "
                + "p.Name AS Product, il.QtyInvoiced, il.PriceActual, il.LineNetAmt "
                + "FROM C_Invoice i "
                + "JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID "
                + "LEFT JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID "
                + "LEFT JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID "
                + "WHERE i.DocumentNo=?";


        Document pdf = new Document(PageSize.A4.rotate(), 20, 20, 30, 30);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        try {
            PdfWriter.getInstance(pdf, baos);
            pdf.open();

            // --------------------------
            // HEADER SECTION
          //  --------------------------
            Paragraph header = new Paragraph("Happy Lady",
                    new Font(Font.HELVETICA, 20, Font.BOLD));
            header.setAlignment(Element.ALIGN_CENTER);
            pdf.add(header);

            Paragraph title = new Paragraph("Invoice Report",
                    new Font(Font.HELVETICA, 14, Font.BOLD));
            title.setAlignment(Element.ALIGN_CENTER);
            pdf.add(title);

            pdf.add(new Paragraph("Document No: " + doc));
            pdf.add(new Paragraph("Generated On: " + new java.util.Date()));
            pdf.add(new Paragraph(" "));

            // --------------------------
            // TABLE (ITEM DETAILS)
            // --------------------------
            PdfPTable table = new PdfPTable(new float[]{
                    2, 2, 3, 3, 2, 2, 2,
                    1.5f, 1.5f, 1.5f, 1.5f,
                    1.5f, 1.5f
            });
            table.setWidthPercentage(100);

            String[] cols = {
                    "Date", "Doc No", "BPartner", "Product",
                    "Qty", "Price", "Amount",
                    "CGST%", "CGST Amt",
                    "SGST%", "SGST Amt",
                    "IGST%", "IGST Amt"
            };
            for (String c : cols) table.addCell(headerCell(c));

            BigDecimal taxable = BigDecimal.ZERO;
            BigDecimal totalCGST = BigDecimal.ZERO;
            BigDecimal totalSGST = BigDecimal.ZERO;
            BigDecimal totalIGST = BigDecimal.ZERO;
            BigDecimal totalQty = BigDecimal.ZERO;
            BigDecimal totalAmt = BigDecimal.ZERO;

            Connection conn = DB.getConnectionRW();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, doc);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                String product = rs.getString("Product");
                BigDecimal qty = rs.getBigDecimal("QtyInvoiced");
                BigDecimal price = rs.getBigDecimal("PriceActual");
                BigDecimal amt = rs.getBigDecimal("LineNetAmt");

                totalQty = totalQty.add(qty);
                totalAmt = totalAmt.add(amt);
                taxable = taxable.add(amt);

                // -----------------------------
                // SAFELY FETCH GST VALUES
                // -----------------------------
                BigDecimal cgst = BigDecimal.ZERO, cgstAmt = BigDecimal.ZERO;
                BigDecimal sgst = BigDecimal.ZERO, sgstAmt = BigDecimal.ZERO;
                BigDecimal igst = BigDecimal.ZERO, igstAmt = BigDecimal.ZERO;

                try {
                    String gstSql = "SELECT CGST, CGST_Amt, SGST, SGST_Amt, IGST, IGST_Amt "
                            + "FROM C_InvoiceLine WHERE Product = ? LIMIT 1";
                    PreparedStatement gstPS = conn.prepareStatement(gstSql);
                    gstPS.setString(1, product);
                    ResultSet gstRS = gstPS.executeQuery();

                    if (gstRS.next()) {
                        cgst = gstRS.getBigDecimal("CGST");
                        cgstAmt = gstRS.getBigDecimal("CGST_Amt");
                        sgst = gstRS.getBigDecimal("SGST");
                        sgstAmt = gstRS.getBigDecimal("SGST_Amt");
                        igst = gstRS.getBigDecimal("IGST");
                        igstAmt = gstRS.getBigDecimal("IGST_Amt");
                    }
                } catch (Exception ignore) {
                    // No GST columns → keep blank
                }

                totalCGST = totalCGST.add(cgstAmt);
                totalSGST = totalSGST.add(sgstAmt);
                totalIGST = totalIGST.add(igstAmt);

                // --------------------------
                // ADD TABLE ROW
                // --------------------------
                table.addCell(rs.getTimestamp("DateInvoiced").toString());
                table.addCell(rs.getString("DocumentNo"));
                table.addCell(rs.getString("BPartner"));
                table.addCell(product);
                table.addCell(rightCell(qty));
                table.addCell(rightCell(price));
                table.addCell(rightCell(amt));

                table.addCell(safe(cgst));
                table.addCell(safe(cgstAmt));
                table.addCell(safe(sgst));
                table.addCell(safe(sgstAmt));
                table.addCell(safe(igst));
                table.addCell(safe(igstAmt));
            }

            pdf.add(table);

            // --------------------------
            // GST SUMMARY
            // --------------------------
            pdf.add(new Paragraph("\nGST Summary",
                    new Font(Font.HELVETICA, 14, Font.BOLD)));

            PdfPTable gst = new PdfPTable(new float[]{3, 2, 3, 3});
            gst.setWidthPercentage(70);

            gst.addCell(headerCell("Type"));
            gst.addCell(headerCell("Rate%"));
            gst.addCell(headerCell("Taxable"));
            gst.addCell(headerCell("Amount"));

            gst.addCell("CGST");
            gst.addCell(calcRate(totalCGST, taxable));
            gst.addCell(safe(taxable));
            gst.addCell(safe(totalCGST));

            gst.addCell("SGST");
            gst.addCell(calcRate(totalSGST, taxable));
            gst.addCell(safe(taxable));
            gst.addCell(safe(totalSGST));

            gst.addCell("IGST");
            gst.addCell(calcRate(totalIGST, taxable));
            gst.addCell(safe(taxable));
            gst.addCell(safe(totalIGST));

            pdf.add(gst);

            // FOOTER
            pdf.add(new Paragraph("\nThis is a system-generated invoice PDF.",
                    new Font(Font.COURIER, 8)));

            pdf.close();

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition",
                    "attachment; filename=" + doc.replace("/", "_") + "_Invoice.pdf");

            baos.writeTo(resp.getOutputStream());

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("Error generating PDF: " + e.getMessage());
        }
    }

    private PdfPCell headerCell(String t) {
        PdfPCell c = new PdfPCell(new Paragraph(t,
                new Font(Font.HELVETICA, 10, Font.BOLD)));
        c.setHorizontalAlignment(Element.ALIGN_CENTER);
        c.setBackgroundColor(new Color(230, 230, 230));
        c.setPadding(4);
        return c;
    }

    private PdfPCell rightCell(BigDecimal v) {
        PdfPCell c = new PdfPCell(new Paragraph(safe(v)));
        c.setHorizontalAlignment(Element.ALIGN_RIGHT);
        c.setPadding(4);
        return c;
    }

    private String calcRate(BigDecimal tax, BigDecimal taxable) {
        try {
            if (tax == null || tax.compareTo(BigDecimal.ZERO) == 0) return " ";
            if (taxable == null || taxable.compareTo(BigDecimal.ZERO) == 0) return " ";
            return tax.multiply(BigDecimal.valueOf(100))
                    .divide(taxable, 2, BigDecimal.ROUND_HALF_UP)
                    .toPlainString();
        } catch (Exception e) {
            return " ";
        }
    }
}
