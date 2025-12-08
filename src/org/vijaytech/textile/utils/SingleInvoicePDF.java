package org.vijaytech.textile.utils;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.compiere.util.DB;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

public class SingleInvoicePDF extends HttpServlet {

    /* =========================================================
       Utilities
       ========================================================= */

    private String safe(BigDecimal bd) {
        return (bd == null) ? "" : bd.toPlainString();
    }

    private PdfPCell headerCell(String text) {
        Font f = new Font(Font.HELVETICA, 10, Font.BOLD, Color.WHITE);
        PdfPCell c = new PdfPCell(new Phrase(text, f));
        c.setHorizontalAlignment(Element.ALIGN_CENTER);
        c.setBackgroundColor(new Color(40, 55, 90));
        c.setPadding(6);
        return c;
    }

    private PdfPCell right(BigDecimal v) {
        PdfPCell c = new PdfPCell(new Phrase(safe(v)));
        c.setHorizontalAlignment(Element.ALIGN_RIGHT);
        c.setPadding(6);
        return c;
    }

    private void addSummaryRow(PdfPTable table, String label, BigDecimal value, Font font) {
        PdfPCell c1 = new PdfPCell(new Phrase(label, font));
        c1.setColspan(5);
        c1.setHorizontalAlignment(Element.ALIGN_RIGHT);
        c1.setBorder(Rectangle.NO_BORDER);
        c1.setPadding(5);

        PdfPCell c2 = new PdfPCell(new Phrase("₹ " + safe(value), font));
        c2.setHorizontalAlignment(Element.ALIGN_RIGHT);
        c2.setBorder(Rectangle.NO_BORDER);
        c2.setPadding(5);

        table.addCell(c1);
        table.addCell(c2);
    }

    /* =========================================================
       SMALL WATERMARK
       ========================================================= */

    class Watermark extends PdfPageEventHelper {
        Font wmFont = new Font(Font.HELVETICA, 38, Font.BOLD, new Color(235, 235, 235));

        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            PdfContentByte canvas = writer.getDirectContentUnder();

            Phrase watermark = new Phrase("HAPPY LADY FASHION", wmFont);

            ColumnText.showTextAligned(
                canvas,
                Element.ALIGN_CENTER,
                watermark,
                document.getPageSize().getWidth() / 2,
                document.getPageSize().getHeight() / 2,
                40
            );
        }
    }

    /* =========================================================
       MAIN SERVLET
       ========================================================= */

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String doc = req.getParameter("docNo");
        if (doc == null || doc.trim().isEmpty()) {
            resp.getWriter().write("DocumentNo missing");
            return;
        }
        doc = java.net.URLDecoder.decode(doc, "UTF-8");

        /* ---------------- SQL ----------------*/

        String typeSql = "SELECT IsSOTrx FROM C_Invoice WHERE DocumentNo=?";

        String sql =
            "SELECT i.DateInvoiced, i.DocumentNo, bp.Name AS PartnerName, " +
            "p.Name AS Product, p.HSNCode, " +
            "il.QtyInvoiced, il.PriceActual, il.LineNetAmt " +
            "FROM C_Invoice i " +
            "JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID " +
            "LEFT JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID " +
            "LEFT JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID " +
            "WHERE i.DocumentNo=?";

        Document pdf = new Document(PageSize.A4, 30, 30, 30, 30);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        try {

            PdfWriter writer = PdfWriter.getInstance(pdf, baos);
            writer.setPageEvent(new Watermark());
            pdf.open();

            Connection conn = DB.getConnectionRW();

            /* ----------------------------------------------------
               Detect Sales / Purchase
               ---------------------------------------------------- */
            PreparedStatement ps = conn.prepareStatement(typeSql);
            ps.setString(1, doc);
            ResultSet rs = ps.executeQuery();

            String invoiceType = "SALES";
            if (rs.next()) {
                invoiceType = rs.getString("IsSOTrx").equals("Y") ? "SALES" : "PURCHASE";
            }

            /* ----------------------------------------------------
               Header
               ---------------------------------------------------- */
            Font fTitle = new Font(Font.HELVETICA, 20, Font.BOLD);
            Font fSub   = new Font(Font.HELVETICA, 14, Font.BOLD);
            Font fBold  = new Font(Font.HELVETICA, 10, Font.BOLD);
            Font fText  = new Font(Font.HELVETICA, 10);

            Paragraph comp = new Paragraph("HAPPY LADY FASHION", fTitle);
            comp.setAlignment(Element.ALIGN_CENTER);
            pdf.add(comp);

            Paragraph inv = new Paragraph(
                invoiceType.equals("SALES") ? "SALES INVOICE" : "PURCHASE INVOICE",
                fSub
            );
            inv.setAlignment(Element.ALIGN_CENTER);
            pdf.add(inv);

            pdf.add(new Paragraph("Invoice No : " + doc, fText));
            pdf.add(new Paragraph("Date       : " + new java.util.Date(), fText));
            pdf.add(new Paragraph(" "));

            /* ----------------------------------------------------
               Load all rows first (forward-only safe)
               ---------------------------------------------------- */
            ps = conn.prepareStatement(sql);
            ps.setString(1, doc);
            rs = ps.executeQuery();

            java.util.List<Object[]> items = new java.util.ArrayList<>();
            String partner = "";

            boolean firstRow = true;

            while (rs.next()) {

                if (firstRow) {
                    partner = rs.getString("PartnerName");
                    firstRow = false;
                }

                items.add(new Object[]{
                    rs.getString("Product"),
                    rs.getString("HSNCode"),
                    rs.getBigDecimal("QtyInvoiced"),
                    rs.getBigDecimal("PriceActual"),
                    rs.getBigDecimal("LineNetAmt")
                });
            }

            /* ----------------------------------------------------
               Customer / Vendor box
               ---------------------------------------------------- */
            pdf.add(new Paragraph(
                invoiceType.equals("SALES") ? "Bill To:" : "Vendor:",
                fBold
            ));
            pdf.add(new Paragraph(partner, fText));
            pdf.add(new Paragraph(" "));

            /* ----------------------------------------------------
               TALLY STYLE: Single complete table
               ---------------------------------------------------- */

            PdfPTable table = new PdfPTable(new float[]{0.8f, 4f, 1.2f, 1.2f, 1.4f, 1.8f});
            table.setWidthPercentage(100);

            table.addCell(headerCell("S.No"));
            table.addCell(headerCell("Product"));
            table.addCell(headerCell("HSN"));
            table.addCell(headerCell("Qty"));
            table.addCell(headerCell("Rate"));
            table.addCell(headerCell("Amount"));

            int serial = 1;
            BigDecimal subtotal = BigDecimal.ZERO;

            for (Object[] row : items) {

                String product = (String) row[0];
                String hsn     = (String) row[1];
                BigDecimal qty = (BigDecimal) row[2];
                BigDecimal rate= (BigDecimal) row[3];
                BigDecimal amt = (BigDecimal) row[4];

                subtotal = subtotal.add(amt);

                PdfPCell sno = new PdfPCell(new Phrase("" + serial++));
                sno.setHorizontalAlignment(Element.ALIGN_CENTER);
                sno.setPadding(6);

                table.addCell(sno);
                table.addCell(product);
                table.addCell(hsn == null ? "" : hsn);
                table.addCell(right(qty));
                table.addCell(right(rate));
                table.addCell(right(amt));
            }

            /* ---------- Separator row ---------- */
            PdfPCell sep = new PdfPCell(new Phrase(" "));
            sep.setColspan(6);
            sep.setBorder(Rectangle.TOP);
            sep.setPadding(4);
            table.addCell(sep);

            /* ---------- SUMMARY SECTION (TALLY STYLE) ---------- */

            Font totalFont = new Font(Font.HELVETICA, 10, Font.BOLD);
            Font grandFont = new Font(Font.HELVETICA, 12, Font.BOLD);

            BigDecimal discount = BigDecimal.ZERO;
            BigDecimal taxableValue = subtotal.subtract(discount);

            // GST Calculations
            BigDecimal cgstAmt = taxableValue.multiply(new BigDecimal("0.09"));
            BigDecimal sgstAmt = taxableValue.multiply(new BigDecimal("0.09"));
            BigDecimal igstAmt = taxableValue.multiply(BigDecimal.ZERO);
            BigDecimal totalGST = cgstAmt.add(sgstAmt).add(igstAmt);

            addSummaryRow(table, "Subtotal", subtotal, totalFont);
            addSummaryRow(table, "Discount", discount, totalFont);
//            addSummaryRow(table, "Taxable Value", taxableValue, totalFont);
//            addSummaryRow(table, "CGST 9%", cgstAmt, totalFont);
//            addSummaryRow(table, "SGST 9%", sgstAmt, totalFont);
//            addSummaryRow(table, "IGST 18%", igstAmt, totalFont);
//            addSummaryRow(table, "Total GST", totalGST, totalFont);

            // GRAND TOTAL (Double border)
            PdfPCell gt1 = new PdfPCell(new Phrase("GRAND TOTAL", grandFont));
            gt1.setColspan(5);
            gt1.setHorizontalAlignment(Element.ALIGN_RIGHT);
            gt1.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
            gt1.setPadding(8);

            BigDecimal grandTotal = taxableValue.add(totalGST);
            PdfPCell gt2 = new PdfPCell(new Phrase("₹ " + safe(grandTotal), grandFont));
            gt2.setHorizontalAlignment(Element.ALIGN_RIGHT);
            gt2.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
            gt2.setPadding(8);

            table.addCell(gt1);
            table.addCell(gt2);

            pdf.add(table);

            /* ----------------------------------------------------
               Signature Section
               ---------------------------------------------------- */

            pdf.add(new Paragraph("\n"));
            PdfPTable sign = new PdfPTable(2);
            sign.setWidthPercentage(100);

            PdfPCell s1 = new PdfPCell(new Phrase("Customer Signature", fText));
            PdfPCell s2 = new PdfPCell(new Phrase("Authorized Signature", fText));

            s1.setBorder(Rectangle.NO_BORDER);
            s2.setBorder(Rectangle.NO_BORDER);

            sign.addCell(s1);
            sign.addCell(s2);

            pdf.add(sign);

            /* ----------------------------------------------------
               Write Output
               ---------------------------------------------------- */

            pdf.close();

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition",
                "attachment; filename=" +
                doc.replace("/", "_") +
                (invoiceType.equals("SALES") ? "_Sales.pdf" : "_Purchase.pdf"));

            baos.writeTo(resp.getOutputStream());

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("PDF ERROR: " + e.getMessage());
        }
    }
}
