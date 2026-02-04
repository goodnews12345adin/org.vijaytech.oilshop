package org.vijaytech.oilshop.utils;

	import java.awt.image.BufferedImage;
import java.io.FileOutputStream;
import java.util.List;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfWriter;

	public class PrintServletOilShop {

	    public static void generateThermalPDF(
	            String shopName,
	            String gstNo,
	            String fssai,
	            String billNo,
	            String billDate,
	            List<TvsRawPdfPrinter.Item> items,
	            double baseTotal,
	            double cgstAmt,
	            double sgstAmt,
	            double grossTotal
	    ) throws Exception {

	        // ✅ 80mm Thermal Paper Width
	        Rectangle pageSize = new Rectangle(226, 600); // 80mm width approx
	        Document doc = new Document(pageSize, 10, 10, 10, 10);

	        String fileName = "Thermal_Bill_" + billNo + ".pdf";
	        PdfWriter writer = PdfWriter.getInstance(doc, new FileOutputStream(fileName));

	        doc.open();

	        // ✅ Monospace Font (Thermal Look)
	        BaseFont bf = BaseFont.createFont(BaseFont.COURIER, BaseFont.CP1252, false);
	        Font font = new Font(bf, 9);
	        Font bold = new Font(bf, 10, Font.BOLD);

	        // ✅ Header Center
	        Paragraph head = new Paragraph(shopName, bold);
	        head.setAlignment(Element.ALIGN_CENTER);
	        doc.add(head);

	        doc.add(centerLine("GSTIN: " + gstNo, font));
	        doc.add(centerLine("FSSAI: " + fssai, font));

	        doc.add(line());

	        doc.add(leftLine("Bill No : " + billNo, font));
	        doc.add(leftLine("Date    : " + billDate, font));

	        doc.add(line());

	        // ✅ Table Header
	        doc.add(new Paragraph(
	                pad("ITEM", 10) +
	                pad("HSN", 5) +
	                pad("GST", 4) +
	                pad("QTY", 4) +
	                pad("AMT", 7),
	                bold));

	        doc.add(line());

	        // ✅ Items
	        for (TvsRawPdfPrinter.Item i : items) {

	            // Wrap Name
	            List<String> wrapped = wrapText(i.name, 10);

	            // First Line
	            doc.add(new Paragraph(
	                    pad(wrapped.get(0), 10) +
	                    pad(i.hsn, 5) +
	                    pad("", 4) +
	                    pad(String.valueOf((int) i.qty), 4) +
	                    pad(String.format("%.2f", i.amount), 7),
	                    font));

	            // Extra wrapped lines
	            for (int x = 1; x < wrapped.size(); x++) {
	                doc.add(new Paragraph(
	                        pad(wrapped.get(x), 10),
	                        font));
	            }
	        }

	        doc.add(line());

	        // ✅ Totals Block
	        doc.add(new Paragraph(formatTotal("TAX BASE", baseTotal), bold));
	        doc.add(new Paragraph(formatTotal("CGST", cgstAmt), bold));
	        doc.add(new Paragraph(formatTotal("SGST", sgstAmt), bold));

	        doc.add(line());

	        doc.add(new Paragraph(formatTotal("TOTAL", grossTotal), bold));

	        doc.add(new Paragraph("\nTHANK YOU VISIT AGAIN\n", font));

	        // ✅ QR CODE
//	        Image qr = generateQRCodeImage("Bill:" + billNo + "|Total:" + grossTotal);
//	        qr.setAlignment(Image.ALIGN_CENTER);
//	        qr.scaleToFit(90, 90);
//
//	        doc.add(qr);

	        doc.close();

	        System.out.println("✅ Thermal PDF Generated: " + fileName);
	    }

	    // ---------------- HELPERS ----------------

	    private static Paragraph centerLine(String txt, Font f) {
	        Paragraph p = new Paragraph(txt, f);
	        p.setAlignment(Element.ALIGN_CENTER);
	        return p;
	    }

	    private static Paragraph leftLine(String txt, Font f) {
	        Paragraph p = new Paragraph(txt, f);
	        p.setAlignment(Element.ALIGN_LEFT);
	        return p;
	    }

	    private static Paragraph line() {
	        return new Paragraph("--------------------------------", new Font(Font.HELVETICA, 9));
	    }

	    private static String pad(String text, int len) {
	        if (text == null) text = "";
	        return String.format("%-" + len + "s", text);
	    }

	    private static String formatTotal(String label, double value) {
	        return String.format("%-15s %10.2f", label, value);
	    }

	    private static List<String> wrapText(String text, int width) {
	        java.util.ArrayList<String> lines = new java.util.ArrayList<>();

	        if (text == null) {
	            lines.add("");
	            return lines;
	        }

	        while (text.length() > width) {
	            lines.add(text.substring(0, width));
	            text = text.substring(width);
	        }
	        lines.add(text);

	        return lines;
	    }

	    // ✅ QR Code Generator
//	    private static Image generateQRCodeImage(String content) throws Exception {
//
//	        // ✅ iText Native QR Generator (No ZXing Needed)
//	        BarcodeQRCode qrCode = new BarcodeQRCode(content, 150, 150, null);
//
//	        Image qrImage = qrCode.getImage();
//
//	        // ✅ Scale for Thermal Receipt
//	        qrImage.scaleToFit(90, 90);
//	        qrImage.setAlignment(Image.ALIGN_CENTER);
//
//	        return qrImage;
//	    }

	    private static byte[] writerImage(BufferedImage image) throws Exception {
	        java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
	        javax.imageio.ImageIO.write(image, "png", baos);
	        return baos.toByteArray();
	    }
	}
