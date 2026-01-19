package org.vijaytech.oilshop.utils;

import javax.imageio.ImageIO;
import javax.print.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
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
            String billNo,
            String billDate,
            List<Item> items,
            double gstRate   // e.g. 5 or 12 or 18
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
        sb.append("--------------------------------\n");

        sb.append(ALIGN_CENTER);
        sb.append("Bill No : ").append(billNo).append("\n");
        sb.append("Date    : ").append(billDate).append("\n");
        sb.append("--------------------------------\n");

        /* ===== HEADER ===== */
        sb.append(
            padRight("ITEM", 12) +
            padLeft("HSN", 4) +
            padLeft("QTY", 4) +
            padLeft("RATE", 6) +
            padLeft("AMT", 6) + "\n"
        );
        sb.append("--------------------------------\n");

        double subTotal = 0;

        for (Item i : items) {
            sb.append(formatItem(i));
            subTotal += i.amount;
        }

        sb.append("--------------------------------\n");

        /* ===== GST CALCULATION ===== */
        double gstAmount = subTotal * gstRate / 100;
        double cgst = gstAmount / 2;
        double sgst = gstAmount / 2;
        double grandTotal = subTotal + gstAmount;

        sb.append(formatLine("SUB TOTAL", subTotal));
        sb.append(formatLine("CGST " + (gstRate / 2) + "%", cgst));
        sb.append(formatLine("SGST " + (gstRate / 2) + "%", sgst));
        sb.append("--------------------------------\n");

        /* ===== BIG FONT TOTAL ===== */
        sb.append(ALIGN_CENTER).append(BOLD_ON).append(BIG_FONT);
        sb.append("TOTAL AMT ").append((int) grandTotal).append("\n");
        sb.append(NORMAL_FONT).append(BOLD_OFF);

        sb.append("\nTHANK YOU  VISIT AGAIN\n\n\n");
        

        /* FEED PAPER BEFORE CUT */
        sb.append("\n\n\n");   // 4 line feeds (adjust if needed)

        /* FULL CUT */
        sb.append("\u001D\u0056\u0000");  // GS V 0 = full cut


        byte[] data = sb.toString().getBytes(StandardCharsets.UTF_8);

        Doc doc = new SimpleDoc(
                data,
                DocFlavor.BYTE_ARRAY.AUTOSENSE,
                null
        );
        printer.createPrintJob().print(doc, null);
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
        public double discount;
        public boolean highlight;

        public Item(String name, String hsn, double qty, double rate, boolean highlight,double discount) {
            this.name = name;
            this.hsn = hsn;
            this.qty = qty;
            this.rate = rate;
            this.amount = qty * rate;
            this.highlight = highlight;
            this.discount = discount;
        }
    }
}
