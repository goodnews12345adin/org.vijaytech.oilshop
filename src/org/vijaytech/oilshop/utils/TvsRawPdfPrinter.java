package org.vijaytech.oilshop.utils;

import javax.print.*;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class TvsRawPdfPrinter {
    /* ============ ESC/POS COMMANDS ============ */
    private static final String ESC_INIT     = "\u001B\u0040";
    private static final String ALIGN_LEFT   = "\u001B\u0061\u0000";
    private static final String ALIGN_CENTER = "\u001B\u0061\u0001";
    private static final String BOLD_ON      = "\u001B\u0045\u0001";
    private static final String BOLD_OFF     = "\u001B\u0045\u0000";
    private static final String BIG_FONT     = "\u001D\u0021\u0011"; // double width+height
    private static final String NORMAL_FONT  = "\u001D\u0021\u0000";
    private static final String CUT          = "\u001D\u0056\u0001";

    /* ============ MAIN PRINT METHOD ============ */
    public static void printBill(
            String shopName,
            String gstNo,
            String fssai,
            String billNo,
            String billDate,
            List<Item> items,
            double baseTotal,
            double cgstAmt,
            double sgstAmt,
            double grossTotal
    ) throws Exception {

        PrintService printer = PrintServiceLookup.lookupDefaultPrintService();
        if (printer == null)
            throw new RuntimeException("No default printer found");

        StringBuilder sb = new StringBuilder();

        sb.append(ESC_INIT);
        sb.append(ALIGN_CENTER).append(BOLD_ON);
        sb.append(shopName).append("\n");
        sb.append(BOLD_OFF);

        sb.append("GSTIN: ").append(gstNo).append("\n");
        sb.append("FSSAI: ").append(fssai).append("\n");
        sb.append("--------------------------------\n");

        sb.append("Bill No : ").append(billNo).append("\n");
        sb.append("Date    : ").append(billDate).append("\n");
        sb.append("--------------------------------\n");

        sb.append(
                padRight("ITEM", 10) +
                padLeft("HSN", 5) +
                padLeft("GST%", 5) +
                padLeft("QTY", 4) +
                padLeft("AMT", 8) + "\n"
        );

        sb.append("--------------------------------\n");

        for (Item i : items) {
            sb.append(padRight(i.name, 12))
              .append(padLeft((int) i.qty + "", 4))
              .append(padLeft(String.format("%.2f", i.amount), 10))
              .append("\n");
        }

        sb.append("--------------------------------\n");

        // ✅ Exact iDempiere Totals
        sb.append(formatLine("TAX BASE AMT", baseTotal));
        sb.append(formatLine("CGST", cgstAmt));
        sb.append(formatLine("SGST", sgstAmt));

        sb.append("--------------------------------\n");

        sb.append(ALIGN_CENTER).append(BOLD_ON).append(BIG_FONT);
        sb.append("TOTAL AMT ").append(String.format("%.2f", grossTotal)).append("\n");
        sb.append(NORMAL_FONT).append(BOLD_OFF);

        sb.append("\nTHANK YOU\n\n");

        // Print
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        baos.write(sb.toString().getBytes());

        baos.write("\n\n\n".getBytes());
        baos.write(new byte[]{0x1D, 0x56, 0x00}); // Cut

        Doc doc = new SimpleDoc(
                baos.toByteArray(),
                DocFlavor.BYTE_ARRAY.AUTOSENSE,
                null
        );

        printer.createPrintJob().print(doc, null);
    }


    /* ============ QR CODE GENERATION (ESC/POS) ============ */
    private static byte[] getQRCodeBytes(String content) throws Exception {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        
        // 1. Set QR Model (Model 2)
        baos.write(new byte[]{0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00});
        
        // 2. Set QR Size (Size 6-8 is usually good for 3-inch printers)
        baos.write(new byte[]{0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x06});
        
        // 3. Set Error Correction Level (L)
        baos.write(new byte[]{0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x30});
        
        // 4. Store Data in Symbol Storage Area
        byte[] contentBytes = content.getBytes(StandardCharsets.UTF_8);
        int len = contentBytes.length + 3;
        byte pL = (byte) (len % 256);
        byte pH = (byte) (len / 256);
        baos.write(new byte[]{0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30});
        baos.write(contentBytes);
        
        // 5. Print the QR Code
        baos.write(new byte[]{0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30});
        
        return baos.toByteArray();
    }

    /* ============ ITEM FORMAT WITH WRAP ============ */
    private static String formatItem(Item i) {
        StringBuilder out = new StringBuilder();
        List<String> lines = wrapText(i.name, 12);

        if (i.highlight) {
            out.append(BOLD_ON).append("\u001D\u0021\u0001"); // double height
        }

        out.append(padRight(lines.get(0), 12))
           .append(padLeft(i.hsn, 4))
           .append(padLeft((int) i.qty + "", 4))
           .append(padLeft((int) i.rate + "", 6))
           .append(padLeft((int) i.amount + "", 6))
           .append("\n");

        for (int x = 1; x < lines.size(); x++) {
            out.append(padRight(lines.get(x), 12))
               .append(padLeft("", 4))
               .append(padLeft("", 4))
               .append(padLeft("", 6))
               .append(padLeft("", 6))
               .append("\n");
        }

        if (i.highlight) {
            out.append(NORMAL_FONT).append(BOLD_OFF);
        }
        return out.toString();
    }

    /* ============ HELPERS ============ */
    private static String formatLine(String label, double val) {
        return padRight(label, 18) + padLeft(String.format("%.2f", val), 14) + "\n";
    }

    private static List<String> wrapText(String text, int width) {
        List<String> lines = new ArrayList<>();
        String[] words = text.split(" ");
        StringBuilder line = new StringBuilder();

        for (String w : words) {
            if (line.length() + w.length() + 1 > width) {
                lines.add(line.toString());
                line = new StringBuilder(w);
            } else {
                if (line.length() > 0) line.append(" ");
                line.append(w);
            }
        }
        if (line.length() > 0) lines.add(line.toString());
        return lines;
    }

    private static String padRight(String s, int n) {
        return String.format("%-" + n + "s", s);
    }

    private static String padLeft(String s, int n) {
        return String.format("%" + n + "s", s);
    }

    /* ============ ITEM DTO ============ */
    public static class Item {
        public String name;
        public String hsn;
        public double qty;
        public double rate;
        public double amount;
        public boolean highlight;

        public Item(String name, String hsn, double qty, double rate, boolean highlight) {
            this.name = name;
            this.hsn = hsn;
            this.qty = qty;
            this.rate = rate;
            this.highlight = highlight;

            this.amount = 0; // ✅ Set externally from LineNetAmt
        }
    }

}