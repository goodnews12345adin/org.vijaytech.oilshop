package org.vijaytech.oilshop.utils;

import java.io.File;
import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.awt.Color;
import java.net.URL;

import org.compiere.util.DB;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

public class GenerateTextileBillPDF {

    // ===== SHOP DETAILS =====
    private static final String SHOP_NAME    = "Happy Lady Fashion";
    private static final String SHOP_ADDRESS = "Old Subramanian Clinic (Opposite), Main Road, Kadayanallur \u2013 627751";
    private static final String SHOP_PHONE   = "9597908804";
    private static final String SHOP_EMAIL   = "yourmail@example.com"; // change to real email
    private static final String SHOP_ADDRESS1 = "Palanganatham";
    private static final String SHOP_NAME1    = "SKV";
    // ===== COLOR THEME =====
    private static final Color COLOR_PRIMARY   = new Color(251, 176, 52);   // Yellow-Orange
    private static final Color COLOR_ACCENT    = new Color(194, 24, 91);    // Pink Magenta
    private static final Color COLOR_BORDER    = COLOR_ACCENT;              // All borders pink
    private static final Color COLOR_PANEL_BG  = new Color(253, 249, 255);  // Light panel bg
    private static final Color COLOR_ROW_SHADE = new Color(244, 240, 250);  // Alt row shade

    private static final String DEFAULT_LOGO_CLASSPATH = "pages/hlfmdyy.jpg";

    public static String generate(File pdfFile, int orderId, String phone, Properties ctx) throws Exception {

        if (pdfFile.getParentFile() != null && !pdfFile.getParentFile().exists()) {
            pdfFile.getParentFile().mkdirs();
        }

        // ================== FETCH BILL HEADER ==================
        String sql = "SELECT o.documentno, o.dateordered, "
                + "bp.name, bp.phone, COALESCE(l.address1,'') AS cust_addr, "
                + "org.name AS org_name "
                + "FROM c_order o "
                + "JOIN c_bpartner bp ON bp.c_bpartner_id = o.c_bpartner_id "
                + "LEFT JOIN c_bpartner_location bpl ON (bpl.c_bpartner_id = bp.c_bpartner_id AND bpl.isbillto = 'Y') "
                + "LEFT JOIN c_location l ON l.c_location_id = bpl.c_location_id "
                + "JOIN ad_org org ON org.ad_org_id = o.ad_org_id "
                + "WHERE o.c_order_id = ?";

        PreparedStatement ps = DB.prepareStatement(sql, null);
        ps.setInt(1, orderId);
        ResultSet rs = ps.executeQuery();

        String billNo = "", billDate = "", custName = "", custPhone = "", custAddr = "";
        String orgName = SHOP_NAME;

        if (rs.next()) {
            billNo = rs.getString("documentno");
            Timestamp ts = rs.getTimestamp("dateordered");
            if (ts != null) {
                billDate = new SimpleDateFormat("dd-MM-yyyy hh:mm a").format(ts);
            }
            custName  = rs.getString("name");
            custPhone = rs.getString("phone");
            custAddr  = rs.getString("cust_addr");
            String dbOrgName = rs.getString("org_name");
            if (dbOrgName != null && !dbOrgName.trim().isEmpty()) {
                orgName = dbOrgName;
            }
        }
        rs.close();
        ps.close();

        // ================== FETCH ITEMS ==================
        String sql2 = "SELECT p.name, p.value, p.hsncode, "
                + "ol.qtyordered, ol.priceactual "
                + "FROM c_orderline ol "
                + "JOIN m_product p ON p.m_product_id = ol.m_product_id "
                + "WHERE ol.c_order_id = ?";

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
            it.hsn  = rs2.getString(3);
            it.qty  = rs2.getBigDecimal(4);
            it.rate = rs2.getBigDecimal(5);

            if (it.qty == null)  it.qty  = BigDecimal.ZERO;
            if (it.rate == null) it.rate = BigDecimal.ZERO;

            it.amt = it.qty.multiply(it.rate);
            it.gst = it.amt.multiply(new BigDecimal("0.05"));

            total = total.add(it.amt);
            gstTotal = gstTotal.add(it.gst);

            items.add(it);
        }
        rs2.close();
        ps2.close();

        // ================== PDF START ==================
        Document doc = new Document(PageSize.A4, 32, 32, 20, 26);
        PdfWriter writer = PdfWriter.getInstance(doc, new FileOutputStream(pdfFile));
        doc.open();

        // Outer border
        PdfContentByte cb = writer.getDirectContent();
        cb.saveState();
        cb.setColorStroke(COLOR_BORDER);
        cb.setLineWidth(2.0f);
        float x = doc.left();
        float y = doc.bottom();
        float w = doc.right() - doc.left();
        float h = doc.top() - doc.bottom();
        cb.rectangle(x, y, w, h);
        cb.stroke();
        cb.restoreState();

        // Meta
        doc.addTitle("Tax Invoice - " + billNo);
        doc.addAuthor(orgName);

        // Fonts
        Font invoiceTitleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, COLOR_ACCENT);
        Font sectionTitleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, COLOR_PRIMARY);
        Font bold             = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
        Font normal           = FontFactory.getFont(FontFactory.HELVETICA, 11);
        Font smallGray        = FontFactory.getFont(FontFactory.HELVETICA, 10, new Color(120, 120, 120));
        Font totalFont        = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, Color.WHITE);
        Font wordsFont        = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);

        // ================== HEADER (LOGO + SHOP DETAILS) ==================
        PdfPTable headerTable = new PdfPTable(1);
        headerTable.setWidthPercentage(100f);
        headerTable.setHorizontalAlignment(Element.ALIGN_CENTER);

        PdfPCell logoCell = new PdfPCell();
        logoCell.setBorder(Rectangle.NO_BORDER);
        logoCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        logoCell.setPaddingTop(6f);
        logoCell.setPaddingBottom(4f);

        Image logo = loadDefaultLogo();
        if (logo != null) {
            logo.scaleToFit(320, 140);
            logo.setAlignment(Image.ALIGN_CENTER);
            logoCell.addElement(logo);
        } else {
            Paragraph fallback = new Paragraph(SHOP_NAME, invoiceTitleFont);
            fallback.setAlignment(Element.ALIGN_CENTER);
            logoCell.addElement(fallback);
        }

        Font shopFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, Color.BLACK);

        Paragraph addrLine1 = new Paragraph(SHOP_ADDRESS, shopFont);
        addrLine1.setAlignment(Element.ALIGN_CENTER);
        addrLine1.setSpacingBefore(10f);
        addrLine1.setSpacingAfter(3f);
        logoCell.addElement(addrLine1);

        Paragraph contactLine = new Paragraph(
                "Phone: " + SHOP_PHONE + "   |   Mail: " + SHOP_EMAIL,
                shopFont
        );
        contactLine.setAlignment(Element.ALIGN_CENTER);
        contactLine.setSpacingBefore(0f);
        contactLine.setSpacingAfter(6f);
        logoCell.addElement(contactLine);

        headerTable.addCell(logoCell);
        doc.add(headerTable);

        // Accent line under header
        PdfPTable rule = new PdfPTable(1);
        rule.setWidthPercentage(100f);
        PdfPCell ruleCell = new PdfPCell(new Phrase(" "));
        ruleCell.setBorderWidthTop(1.5f);
        ruleCell.setBorderWidthBottom(0);
        ruleCell.setBorderWidthLeft(0);
        ruleCell.setBorderWidthRight(0);
        ruleCell.setBorderColorTop(COLOR_PRIMARY);
        ruleCell.setPaddingBottom(1f);
        rule.addCell(ruleCell);
        doc.add(rule);

        doc.add(new Paragraph(" "));

        // TAX INVOICE title
        Paragraph invoiceTitle = new Paragraph("TAX INVOICE", invoiceTitleFont);
        invoiceTitle.setAlignment(Element.ALIGN_CENTER);
        invoiceTitle.setSpacingAfter(6f);
        doc.add(invoiceTitle);

        // ================== BILL & CUSTOMER INFO PANELS ==================
        PdfPTable infoOuter = new PdfPTable(2);
        infoOuter.setWidthPercentage(100f);
        infoOuter.setWidths(new float[]{3f, 3f});
        infoOuter.setHorizontalAlignment(Element.ALIGN_CENTER);
        infoOuter.setSpacingBefore(4f);

        PdfPCell billInfoCell = new PdfPCell();
        billInfoCell.setPadding(8f);
        billInfoCell.setBorderColor(COLOR_BORDER);
        billInfoCell.setBorderWidth(1.0f);
        billInfoCell.setBackgroundColor(COLOR_PANEL_BG);
        billInfoCell.setVerticalAlignment(Element.ALIGN_TOP);

        Paragraph billHeading = new Paragraph("Bill Details", sectionTitleFont);
        billHeading.setSpacingAfter(4f);
        billInfoCell.addElement(billHeading);
        billInfoCell.addElement(infoLine("Bill No", billNo, normal));
        billInfoCell.addElement(infoLine("Bill Date", billDate, normal));

        PdfPCell custInfoCell = new PdfPCell();
        custInfoCell.setPadding(8f);
        custInfoCell.setBorderColor(COLOR_BORDER);
        custInfoCell.setBorderWidth(1.0f);
        custInfoCell.setBackgroundColor(COLOR_PANEL_BG);
        custInfoCell.setVerticalAlignment(Element.ALIGN_TOP);

        Paragraph custHeading = new Paragraph("Customer Details", sectionTitleFont);
        custHeading.setSpacingAfter(4f);
        custInfoCell.addElement(custHeading);
        custInfoCell.addElement(infoLine("Name", custName, normal));
        custInfoCell.addElement(infoLine("Phone",
                (phone != null && !phone.isEmpty()) ? phone : custPhone, normal));
        custInfoCell.addElement(infoLine("Address", custAddr, normal));

        infoOuter.addCell(billInfoCell);
        infoOuter.addCell(custInfoCell);
        doc.add(infoOuter);

        // ================== ITEM TABLE ==================
        PdfPTable table = new PdfPTable(6);
        table.setWidthPercentage(100f);
        table.setWidths(new float[]{4.0f, 1.0f, 1.2f, 1.4f, 1.0f, 1.4f});
        table.setHorizontalAlignment(Element.ALIGN_CENTER);
        table.setSpacingBefore(8f);

        table.addCell(header("Item"));
        table.addCell(header("Qty"));
        table.addCell(header("Rate"));
        table.addCell(header("Amount"));
        table.addCell(header("HSN"));
        table.addCell(header("GST 5%"));

        boolean shade = false;
        for (Item it : items) {
            table.addCell(bodyCell(it.name, normal, Element.ALIGN_LEFT, shade));
            table.addCell(bodyCell(it.qty.toPlainString(), normal, Element.ALIGN_RIGHT, shade));
            table.addCell(bodyCell(formatAmount(it.rate), normal, Element.ALIGN_RIGHT, shade));
            table.addCell(bodyCell(formatAmount(it.amt), normal, Element.ALIGN_RIGHT, shade));
            table.addCell(bodyCell(it.hsn != null ? it.hsn : "", normal, Element.ALIGN_CENTER, shade));
            table.addCell(bodyCell(formatAmount(it.gst), normal, Element.ALIGN_RIGHT, shade));
            shade = !shade;
        }

        doc.add(table);

        // ================== TOTALS + AMOUNT IN WORDS ==================
        BigDecimal grandTotal = total.add(gstTotal);
        String amountInWords = convertToIndianCurrency(grandTotal);

        PdfPTable bottom = new PdfPTable(3);
        bottom.setWidthPercentage(100f);
        bottom.setWidths(new float[]{3.8f, 1.4f, 1.2f});
        bottom.setHorizontalAlignment(Element.ALIGN_CENTER);
        bottom.setSpacingBefore(10f);

        PdfPCell wordsCell = new PdfPCell(
                new Phrase("Amount in Words: " + amountInWords, wordsFont)
        );
        wordsCell.setPadding(8f);
        wordsCell.setHorizontalAlignment(Element.ALIGN_LEFT);
        wordsCell.setVerticalAlignment(Element.ALIGN_TOP);
        wordsCell.setBorderColor(COLOR_BORDER);
        wordsCell.setBorderWidth(1.0f);
        wordsCell.setRowspan(3);
        bottom.addCell(wordsCell);

        PdfPCell labelSubtotal = totalLabelCell("Subtotal", bold);
        PdfPCell valueSubtotal = totalValueCell("₹ " + formatAmount(total), bold, false);
        bottom.addCell(labelSubtotal);
        bottom.addCell(valueSubtotal);

        PdfPCell labelGst = totalLabelCell("GST (5%)", bold);
        PdfPCell valueGst = totalValueCell("₹ " + formatAmount(gstTotal), bold, false);
        bottom.addCell(labelGst);
        bottom.addCell(valueGst);

        PdfPCell labelGrand = totalLabelCell("Grand Total", bold);
        labelGrand.setBackgroundColor(COLOR_ACCENT);
        labelGrand.setPhrase(new Phrase("Grand Total", totalFont));
        PdfPCell valueGrand = totalValueCell("₹ " + formatAmount(grandTotal), totalFont, true);

        bottom.addCell(labelGrand);
        bottom.addCell(valueGrand);

        doc.add(bottom);

        // ================== FOOTER: HINT + TERMS (INDENTED) + THANKS ==================

        float leftIndent = 10f; // approx 10px

        Paragraph hint = new Paragraph(
                "Please retain this invoice for future reference.",
                smallGray
        );
        hint.setAlignment(Element.ALIGN_LEFT);
        hint.setIndentationLeft(leftIndent);
        hint.setSpacingBefore(10f);
        hint.setSpacingAfter(4f);
        doc.add(hint);

        Font tcHeadingFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.BLACK);
        Font tcFont        = FontFactory.getFont(FontFactory.HELVETICA, 9, Color.BLACK);

        Paragraph tcHeading = new Paragraph("Terms & Conditions", tcHeadingFont);
        tcHeading.setAlignment(Element.ALIGN_LEFT);
        tcHeading.setIndentationLeft(leftIndent);
        tcHeading.setSpacingBefore(0f);
        tcHeading.setSpacingAfter(4f);
        doc.add(tcHeading);

        Paragraph tcLines = new Paragraph(
                "\u2022 Original bill is mandatory for any exchange.\n" +
                "\u2022 Goods once sold will not be taken back; only size exchange is allowed as per shop policy.\n" +
                "\u2022 No cash refund will be provided under any circumstances.\n" +
                "\u2022 Colour and appearance of products may slightly vary from display.",
                tcFont
        );
        tcLines.setAlignment(Element.ALIGN_LEFT);
        tcLines.setIndentationLeft(leftIndent);
        tcLines.setLeading(12f);
        tcLines.setSpacingAfter(10f);
        doc.add(tcLines);

        Paragraph thanks = new Paragraph(
                "Thank you for shopping at " + SHOP_NAME,
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, Color.BLACK)
        );
        thanks.setAlignment(Element.ALIGN_CENTER);
        thanks.setSpacingBefore(4f);
        thanks.setSpacingAfter(4f);
        doc.add(thanks);

        doc.close();
        return pdfFile.getAbsolutePath();
    }
    /// 80MM
    public static String generate80mm(File pdfFile, int orderId, Properties ctx) throws Exception {

        if (pdfFile.getParentFile() != null && !pdfFile.getParentFile().exists()) {
            pdfFile.getParentFile().mkdirs();
        }

        // ================= HEADER QUERY =================
        String sql = "SELECT o.documentno, o.dateordered, "
                   + "bp.name, bp.phone, COALESCE(l.address1,'') AS cust_addr "
                   + "FROM c_order o "
                   + "JOIN c_bpartner bp ON bp.c_bpartner_id = o.c_bpartner_id "
                   + "LEFT JOIN c_bpartner_location bpl ON (bpl.c_bpartner_id = bp.c_bpartner_id AND bpl.isbillto='Y') "
                   + "LEFT JOIN c_location l ON l.c_location_id = bpl.c_location_id "
                   + "WHERE o.c_order_id = ?";

        PreparedStatement ps = DB.prepareStatement(sql, null);
        ps.setInt(1, orderId);
        ResultSet rs = ps.executeQuery();

        String billNo="", custName="", phone="", address="";
        Timestamp billDate=null;

        if (rs.next()) {
            billNo   = rs.getString("documentno");
            billDate = rs.getTimestamp("dateordered");
            custName = rs.getString("name");
            phone    = rs.getString("phone");
            address  = rs.getString("cust_addr");
        }
        rs.close();
        ps.close();

        // ================= ITEMS QUERY =================
        String sql2 = "SELECT p.name, p.hsncode, ol.qtyordered, ol.priceactual "
                    + "FROM c_orderline ol "
                    + "JOIN m_product p ON p.m_product_id = ol.m_product_id "
                    + "WHERE ol.c_order_id = ?";

        PreparedStatement ps2 = DB.prepareStatement(sql2, null);
        ps2.setInt(1, orderId);
        ResultSet rs2 = ps2.executeQuery();

        class Item {
            String name, hsn;
            BigDecimal qty, rate, amt;
        }

        List<Item> items = new ArrayList<>();
        BigDecimal subTotal = BigDecimal.ZERO;

        while (rs2.next()) {
            Item it = new Item();
            it.name = rs2.getString(1);
            it.hsn  = rs2.getString(2);
            it.qty  = rs2.getBigDecimal(3);
            it.rate = rs2.getBigDecimal(4);

            if (it.qty == null)  it.qty = BigDecimal.ZERO;
            if (it.rate == null) it.rate = BigDecimal.ZERO;

            it.amt = it.qty.multiply(it.rate);
            subTotal = subTotal.add(it.amt);
            items.add(it);
        }
        rs2.close();
        ps2.close();

        BigDecimal cgst = subTotal.multiply(new BigDecimal("0.025")).setScale(2, RoundingMode.HALF_UP);
        BigDecimal sgst = cgst;
        BigDecimal grandTotal = subTotal.add(cgst).add(sgst);

        // ================= PDF START =================
        Rectangle pageSize = new Rectangle(226.77f, 1250f); // 80mm
        Document doc = new Document(pageSize, 6, 6, 6, 6);
        PdfWriter writer = PdfWriter.getInstance(doc, new FileOutputStream(pdfFile));
        doc.open();

        Font normal = new Font(Font.COURIER, 9);
        Font bold   = new Font(Font.COURIER, 9, Font.BOLD);
        Font title  = new Font(Font.COURIER, 10, Font.BOLD);

        SimpleDateFormat df = new SimpleDateFormat("dd/MM/yy HH:mm");

        // ================= HEADER =================
        Paragraph p = new Paragraph("SKV OILS", title);
        p.setAlignment(Element.ALIGN_CENTER);
        doc.add(p);
        doc.add(new Paragraph("--------------------------------", normal));

        doc.add(new Paragraph("| BILL NO : " + billNo, normal));
        doc.add(new Paragraph("| DATE    : " + (billDate != null ? df.format(billDate) : ""), normal));
        doc.add(new Paragraph("--------------------------------", normal));

        doc.add(new Paragraph("| Customer: " + custName, normal));
        doc.add(new Paragraph("| Phone   : " + phone, normal));
        doc.add(new Paragraph("--------------------------------", normal));

        // ================= ITEMS =================
        doc.add(new Paragraph("| SI ITEM     HSN   QTY RATE   AMT |", bold));
        doc.add(new Paragraph("------------------------------------", normal));

        int si = 1;
        for (Item it : items) {
            String row = String.format(
                "| %-2d %-8s %-5s %3s %5.2f %6.2f |",
                si++,
                it.name.length() > 8 ? it.name.substring(0,8) : it.name,
                it.hsn != null ? it.hsn : "",
                it.qty.stripTrailingZeros().toPlainString(),
                it.rate,
                it.amt
            );
            doc.add(new Paragraph(row, normal));
        }

        doc.add(new Paragraph("--------------------------------", normal));
        doc.add(new Paragraph(String.format("| SUB TOTAL : %14.2f |", subTotal), normal));
        doc.add(new Paragraph(String.format("| CGST @2.5%%: %13.2f |", cgst), normal));
        doc.add(new Paragraph(String.format("| SGST @2.5%%: %13.2f |", sgst), normal));
        doc.add(new Paragraph("--------------------------------", normal));

        Paragraph gt = new Paragraph(
            String.format("| TOTAL     : %14.2f |", grandTotal),
            bold
        );
        doc.add(gt);

        // ================= AMOUNT IN WORDS =================
        doc.add(new Paragraph("--------------------------------", normal));
        doc.add(new Paragraph("| Amount in Words", bold));
        doc.add(new Paragraph("| " + convertToIndianCurrency(grandTotal), normal));
        doc.add(new Paragraph("--------------------------------", normal));

        // ================= QR =================
        doc.add(new Paragraph("| Scan to Pay (PhonePe / GPay)", bold));

//        String upi =
//            "upi://pay?pa=skvoils@upi&pn=SKVOILS&am="
//            + grandTotal.toPlainString() + "&cu=INR";
//
//        BarcodeQRCode qr = new BarcodeQRCode(upi, 110, 110, null);
//        Image qrImg = qr.getImage();
//        qrImg.scaleToFit(110, 110);
//        qrImg.setAlignment(Image.ALIGN_CENTER);
//        doc.add(qrImg);

        doc.add(new Paragraph("--------------------------------", normal));
        Paragraph thanks = new Paragraph("Thank you! Visit again.", bold);
        thanks.setAlignment(Element.ALIGN_CENTER);
        doc.add(thanks);

        doc.close();
        return pdfFile.getAbsolutePath();
    }





    // ================== HELPER METHODS ==================

    private static PdfPCell header(String text) {
        Font font = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, Color.WHITE);
        PdfPCell c = new PdfPCell(new Phrase(text, font));
        c.setBackgroundColor(COLOR_ACCENT);
        c.setPadding(7f);
        c.setHorizontalAlignment(Element.ALIGN_CENTER);
        c.setVerticalAlignment(Element.ALIGN_MIDDLE);
        c.setBorderColor(COLOR_BORDER);
        c.setBorderWidth(1.0f);
        return c;
    }

    private static PdfPCell bodyCell(String text, Font f, int hAlign, boolean shaded) {
        PdfPCell c = new PdfPCell(new Phrase(text != null ? text : "", f));
        c.setPadding(6f);
        c.setHorizontalAlignment(hAlign);
        c.setVerticalAlignment(Element.ALIGN_MIDDLE);
        c.setBorderColor(COLOR_BORDER);
        c.setBorderWidth(0.9f);
        if (shaded) {
            c.setBackgroundColor(COLOR_ROW_SHADE);
        }
        return c;
    }

    private static PdfPCell totalLabelCell(String text, Font f) {
        PdfPCell c = new PdfPCell(new Phrase(text, f));
        c.setPadding(6f);
        c.setHorizontalAlignment(Element.ALIGN_RIGHT);
        c.setVerticalAlignment(Element.ALIGN_MIDDLE);
        c.setBorderColor(COLOR_BORDER);
        c.setBorderWidth(1.0f);
        return c;
    }

    private static PdfPCell totalValueCell(String text, Font f, boolean accentBackground) {
        PdfPCell c = new PdfPCell(new Phrase(text, f));
        c.setPadding(6f);
        c.setHorizontalAlignment(Element.ALIGN_RIGHT);
        c.setVerticalAlignment(Element.ALIGN_MIDDLE);
        c.setBorderColor(COLOR_BORDER);
        c.setBorderWidth(1.0f);
        if (accentBackground) {
            c.setBackgroundColor(COLOR_ACCENT);
        }
        return c;
    }

    private static Paragraph infoLine(String label, String value, Font valueFont) {
        Font labelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
        String val = (value != null && !value.trim().isEmpty()) ? value : "-";
        Paragraph p = new Paragraph(label + ": ", labelFont);
        p.add(new Phrase(val, valueFont));
        p.setSpacingAfter(3f);
        return p;
    }

    private static String formatAmount(BigDecimal amt) {
        if (amt == null) {
            return "0.00";
        }
        return amt.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private static Image loadDefaultLogo() {
        try {
            ClassLoader cl = Thread.currentThread().getContextClassLoader();
            URL url = cl.getResource(DEFAULT_LOGO_CLASSPATH);
            if (url != null) {
                return Image.getInstance(url);
            }

            File f1 = new File("src/main/webapp/pages/happy_lady_logo_transparent.png");
            if (f1.exists()) {
                return Image.getInstance(f1.getAbsolutePath());
            }

            File f2 = new File("pages/happy_lady_logo_transparent.png");
            if (f2.exists()) {
                return Image.getInstance(f2.getAbsolutePath());
            }

        } catch (Exception e) {
            // Ignore – will fall back to text
        }
        return null;
    }

    // ================== AMOUNT IN WORDS (INDIAN FORMAT) ==================
    private static String convertToIndianCurrency(BigDecimal amount) {
        if (amount == null) {
            amount = BigDecimal.ZERO;
        }

        amount = amount.setScale(2, RoundingMode.HALF_UP);

        long rupees = amount.longValue();
        int paise = amount
                .remainder(BigDecimal.ONE)
                .movePointRight(2)
                .abs()
                .intValue();

        String rupeesPart = numberToIndianWords(rupees);
        if (rupeesPart.isEmpty()) {
            rupeesPart = "Zero";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("Rupees ");
        sb.append(rupeesPart);

        if (paise > 0) {
            sb.append(" and ");
            sb.append(numberToIndianWords(paise));
            sb.append(" Paise");
        }

        sb.append(" Only");
        return sb.toString();
    }

    private static String numberToIndianWords(long number) {
        if (number == 0) {
            return "";
        }

        String[] units = {
                "", "One", "Two", "Three", "Four", "Five", "Six", "Seven",
                "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen",
                "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"
        };

        String[] tens = {
                "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty",
                "Seventy", "Eighty", "Ninety"
        };

        StringBuilder words = new StringBuilder();

        if (number >= 10000000) {
            long crore = number / 10000000;
            words.append(numberToIndianWords(crore)).append(" Crore ");
            number = number % 10000000;
        }

        if (number >= 100000) {
            long lakh = number / 100000;
            words.append(numberToIndianWords(lakh)).append(" Lakh ");
            number = number % 100000;
        }

        if (number >= 1000) {
            long thousand = number / 1000;
            words.append(numberToIndianWords(thousand)).append(" Thousand ");
            number = number % 1000;
        }

        if (number >= 100) {
            long hundred = number / 100;
            words.append(numberToIndianWords(hundred)).append(" Hundred ");
            number = number % 100;
        }

        if (number > 0) {
            if (number < 20) {
                words.append(units[(int) number]).append(" ");
            } else {
                words.append(tens[(int) (number / 10)]).append(" ");
                if ((number % 10) > 0) {
                    words.append(units[(int) (number % 10)]).append(" ");
                }
            }
        }

        return words.toString().trim();
    }
}
