package org.vijaytech.oilshop.utils;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.compiere.util.DB;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

public class SingleInvoicePDF extends HttpServlet {

    private String fmt(BigDecimal v) {
        return v == null ? "0.00" : v.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private PdfPCell cell(String t, Font f, int align) {
        PdfPCell c = new PdfPCell(new Phrase(t, f));
        c.setBorder(Rectangle.NO_BORDER);
        c.setHorizontalAlignment(align);
        c.setPadding(2);
        return c;
    }

    private PdfPCell cell(BigDecimal v, Font f) {
        return cell(fmt(v), f, Element.ALIGN_RIGHT);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String docNo = req.getParameter("docNo");
        if (docNo == null || docNo.trim().isEmpty()) {
            resp.getWriter().write("DocumentNo missing");
            return;
        }

        /* 80mm thermal page */
        Document pdf = new Document(new Rectangle(226, 1200), 8, 8, 8, 8);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        Font f8  = new Font(Font.HELVETICA, 8);
        Font f8b = new Font(Font.HELVETICA, 8, Font.BOLD);
        Font f9b = new Font(Font.HELVETICA, 9, Font.BOLD);

        String typeSql = "SELECT IsSOTrx FROM C_Invoice WHERE DocumentNo=?";
        String dataSql =
        	    "SELECT bp.Name bpname, p.Name product, p.HSNCode hsn, " +
        	    "il.QtyInvoiced qty, il.PriceActual rate, " +
        	    "(il.QtyInvoiced * il.PriceActual) AS gross, " +
        	    "((il.QtyInvoiced * il.PriceActual) - il.LineNetAmt) AS discamt, " +
        	    "il.LineNetAmt AS taxable " +
        	    "FROM C_Invoice i " +
        	    "JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID " +
        	    "JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID " +
        	    "JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID " +
        	    "WHERE i.DocumentNo=?";


        try (Connection con = DB.getConnectionRW()) {

            PdfWriter.getInstance(pdf, baos);
            pdf.open();

            /* Sales / Purchase */
            String trxType = "SALES";
            PreparedStatement ps = con.prepareStatement(typeSql);
            ps.setString(1, docNo);
            ResultSet rs = ps.executeQuery();
            if (rs.next() && "N".equals(rs.getString(1)))
                trxType = "PURCHASE";

            pdf.add(new Paragraph(trxType + " INVOICE", f9b));
            pdf.add(new Paragraph("Invoice : " + docNo, f8));
            pdf.add(new Paragraph("--------------------------------"));

            /* Data */
            ps = con.prepareStatement(dataSql);
            ps.setString(1, docNo);
            rs = ps.executeQuery();

            PdfPTable itemTable = new PdfPTable(new float[]{3f, 1f, 1.2f});
            itemTable.setWidthPercentage(100);

            itemTable.addCell(cell("Item", f8b, Element.ALIGN_LEFT));
            itemTable.addCell(cell("Qty", f8b, Element.ALIGN_RIGHT));
            itemTable.addCell(cell("Amt", f8b, Element.ALIGN_RIGHT));

            BigDecimal subTotal = BigDecimal.ZERO;
            BigDecimal totalDisc = BigDecimal.ZERO;
            BigDecimal gstRate = new BigDecimal("5");

            /* HSN Summary Map */
            Map<String, BigDecimal[]> hsnMap = new LinkedHashMap<>();

            while (rs.next()) {

                BigDecimal taxable = rs.getBigDecimal("taxable");
                BigDecimal disc = rs.getBigDecimal("discamt");
                BigDecimal cgst = taxable.multiply(gstRate).divide(new BigDecimal("200"));
                BigDecimal sgst = taxable.multiply(gstRate).divide(new BigDecimal("200"));

                subTotal = subTotal.add(taxable);
                totalDisc = totalDisc.add(disc);

                itemTable.addCell(cell(rs.getString("product"), f8, Element.ALIGN_LEFT));
                itemTable.addCell(cell(rs.getBigDecimal("qty"), f8));
                itemTable.addCell(cell(taxable, f8));

                String hsn = rs.getString("hsn");
                hsnMap.putIfAbsent(hsn,
                        new BigDecimal[]{BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO});
                BigDecimal[] arr = hsnMap.get(hsn);
                arr[0] = arr[0].add(taxable);
                arr[1] = arr[1].add(cgst);
                arr[2] = arr[2].add(sgst);
            }

            pdf.add(itemTable);
            pdf.add(new Paragraph("--------------------------------"));

            BigDecimal cgstTot = BigDecimal.ZERO;
            BigDecimal sgstTot = BigDecimal.ZERO;
            for (BigDecimal[] v : hsnMap.values()) {
                cgstTot = cgstTot.add(v[1]);
                sgstTot = sgstTot.add(v[2]);
            }

            BigDecimal grossTotal = subTotal.add(cgstTot).add(sgstTot);
            BigDecimal rounded = grossTotal.setScale(0, RoundingMode.HALF_UP);
            BigDecimal roundOff = rounded.subtract(grossTotal);

            pdf.add(new Paragraph("Subtotal : " + fmt(subTotal), f8));
            pdf.add(new Paragraph("Discount : " + fmt(totalDisc), f8));
            pdf.add(new Paragraph("CGST 9%  : " + fmt(cgstTot), f8));
            pdf.add(new Paragraph("SGST 9%  : " + fmt(sgstTot), f8));
            pdf.add(new Paragraph("RoundOff : " + fmt(roundOff), f8));
            pdf.add(new Paragraph("PAYABLE  : " + fmt(rounded), f9b));

            /* HSN SUMMARY */
            pdf.add(new Paragraph("\nHSN SUMMARY", f8b));

            PdfPTable hsnTable = new PdfPTable(new float[]{2f, 2f, 2f, 2f});
            hsnTable.setWidthPercentage(100);

            hsnTable.addCell(cell("HSN", f8b, Element.ALIGN_LEFT));
            hsnTable.addCell(cell("Taxable", f8b, Element.ALIGN_RIGHT));
            hsnTable.addCell(cell("CGST", f8b, Element.ALIGN_RIGHT));
            hsnTable.addCell(cell("SGST", f8b, Element.ALIGN_RIGHT));

            for (Map.Entry<String, BigDecimal[]> e : hsnMap.entrySet()) {
                hsnTable.addCell(cell(e.getKey(), f8, Element.ALIGN_LEFT));
                hsnTable.addCell(cell(e.getValue()[0], f8));
                hsnTable.addCell(cell(e.getValue()[1], f8));
                hsnTable.addCell(cell(e.getValue()[2], f8));
            }

            pdf.add(hsnTable);
            pdf.add(new Paragraph("\nThank you!", f8));

            pdf.close();

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition",
                    "attachment; filename=" + docNo.replace("/", "_") + "_80mm.pdf");
            baos.writeTo(resp.getOutputStream());

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("PDF ERROR : " + e.getMessage());
        }
    }
}
