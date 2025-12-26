package org.vijaytech.oilshop;

import java.awt.Color;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.compiere.model.MProductCategory;
import org.compiere.model.Query;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MProduct;
import org.syvasoft.tallyfrontcrusher.model.TF_MProductCategory;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

public class ProfitAndLossReport extends HttpServlet {

    /* =========================
       GET → Render JSP
       ========================= */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("ctx") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        Properties ctx = (Properties) session.getAttribute("ctx");
        Env.setCtx(ctx);

        List<TF_MProduct> products = new Query(
                ctx, TF_MProduct.Table_Name, "IsActive='Y'", null)
                .setClient_ID()
                .list();

        List<TF_MProductCategory> cats = new Query(
                ctx, TF_MProductCategory.Table_Name, "IsActive='Y'", null)
                .setClient_ID()
                .list();

        List<Map<String, Object>> categoryList = new ArrayList<>();
        List<Map<String, Object>> productList = new ArrayList<>();

        for (MProductCategory c : cats) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", c.getM_Product_Category_ID());
            m.put("name", c.getName());
            categoryList.add(m);
        }

        for (TF_MProduct p : products) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", p.getM_Product_ID());
            m.put("name", p.getName());
            m.put("categoryId", p.getM_Product_Category_ID());
            productList.add(m);
        }

        req.setAttribute("categoryList", categoryList);
        req.setAttribute("productList", productList);

        RequestDispatcher rd =
                req.getRequestDispatcher("/pages/profitandloss.jsp");
        rd.forward(req, resp);
    }

    /* =========================
       POST → Load Report
       ========================= */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Properties ctx = (Properties) session.getAttribute("ctx");
        Env.setCtx(ctx);
        
       


        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = req.getReader()) {
            String line;
            while ((line = br.readLine()) != null)
                sb.append(line);
        }

        JSONObject json = new JSONObject(sb.toString());

        String from = json.getString("from");
        String to   = json.getString("to");

        /* =========================
           OPENING STOCK (PRODUCT)
           ========================= */
        Map<Integer, Double> openingMap = new HashMap<>();

        String openingSql =
            "SELECT m.M_Product_ID, SUM(m.MovementQty) " +
            "FROM M_Transaction m " +
            "WHERE m.MovementDate < ?::DATE " +
            "AND m.AD_Client_ID = ? " +
            "GROUP BY m.M_Product_ID";

        List<List<Object>> openRows =
            DB.getSQLArrayObjectsEx(
                null,
                openingSql,
                new Object[]{ from, Env.getAD_Client_ID(ctx) }
            );

        for (List<Object> r : openRows) {
            openingMap.put(
                ((Number) r.get(0)).intValue(),
                ((Number) r.get(1)).doubleValue()
            );
        }

        /* =========================
           SALES & PURCHASE (INVOICE)
           ========================= */
        String sql =
            "WITH sales AS ( " +
            " SELECT il.M_Product_ID, " +
            "        p.Value AS code, p.Name AS name, " +
            "        SUM(il.QtyInvoiced) qty, SUM(il.LineNetAmt) amt " +
            " FROM C_Invoice i " +
            " JOIN C_InvoiceLine il ON i.C_Invoice_ID=il.C_Invoice_ID " +
            " JOIN M_Product p ON p.M_Product_ID=il.M_Product_ID " +
            " WHERE i.IsSOTrx='Y' AND i.DocStatus IN ('CO','CL') " +
            " AND i.DateAcct BETWEEN ?::DATE AND ?::DATE " +
            " GROUP BY il.M_Product_ID, p.Value, p.Name ), " +

            "purchase AS ( " +
            " SELECT il.M_Product_ID, " +
            "        p.Value AS code, p.Name AS name, " +
            "        SUM(il.QtyInvoiced) qty, SUM(il.LineNetAmt) amt " +
            " FROM C_Invoice i " +
            " JOIN C_InvoiceLine il ON i.C_Invoice_ID=il.C_Invoice_ID " +
            " JOIN M_Product p ON p.M_Product_ID=il.M_Product_ID " +
            " WHERE i.IsSOTrx='N' AND i.DocStatus IN ('CO','CL') " +
            " AND i.DateAcct BETWEEN ?::DATE AND ?::DATE " +
            " GROUP BY il.M_Product_ID, p.Value, p.Name ) " +

            "SELECT COALESCE(s.M_Product_ID,p.M_Product_ID) pid, " +
            "       COALESCE(s.code,p.code), " +
            "       COALESCE(s.name,p.name), " +
            "       COALESCE(s.qty,0), COALESCE(s.amt,0), " +
            "       COALESCE(p.qty,0), COALESCE(p.amt,0) " +
            "FROM sales s FULL JOIN purchase p " +
            "ON s.M_Product_ID=p.M_Product_ID";

        List<List<Object>> rows =
            DB.getSQLArrayObjectsEx(
                null,
                sql,
                new Object[]{ from, to, from, to }
            );

        JSONArray data = new JSONArray();
        double totalSales = 0, totalPurchase = 0;

        for (List<Object> r : rows) {

            int productId = ((Number) r.get(0)).intValue();
            double salesQty = ((Number) r.get(3)).doubleValue();
            double salesAmt = ((Number) r.get(4)).doubleValue();
            double purQty   = ((Number) r.get(5)).doubleValue();
            double purAmt   = ((Number) r.get(6)).doubleValue();

            double opening = openingMap.getOrDefault(productId, 0.0);
            double balance = opening + purQty - salesQty;

            JSONObject o = new JSONObject();
            o.put("productId", productId);
            o.put("productCode", r.get(1));
            o.put("productName", r.get(2));
            o.put("openingQty", opening);
            o.put("purchaseQty", purQty);
            o.put("salesQty", salesQty);
            o.put("balanceQty", balance);
            o.put("negativeBalance", balance < 0);
            o.put("purchaseAmount", purAmt);
            o.put("salesAmount", salesAmt);
            o.put("profit", salesAmt - purAmt);

            totalSales += salesAmt;
            totalPurchase += purAmt;

            data.put(o);
        }

        JSONObject out = new JSONObject();
        out.put("rows", data);

        JSONObject totals = new JSONObject();
        totals.put("totalSalesAmount", totalSales);
        totals.put("totalPurchaseAmount", totalPurchase);
        totals.put("totalProfit", totalSales - totalPurchase);
        out.put("totals", totals);
        
        String exportType = req.getParameter("export");
        if (exportType == null) exportType = "json";

        if ("excel".equalsIgnoreCase(exportType)) {
            exportExcel(resp, data);
            return;
        }

        if ("csv".equalsIgnoreCase(exportType)) {
            exportCSV(resp, data);
            return;
        }

        if ("pdf".equalsIgnoreCase(exportType)) {
            exportPDF(resp, data, totals);
            return;
        }

        resp.setContentType("application/json");
        resp.getWriter().write(out.toString());

    }



	    /* ================= CSV ================= */
	    private void exportCSV(HttpServletResponse resp, JSONArray arr) throws IOException {

	        resp.setContentType("text/csv");
	        resp.setHeader("Content-Disposition", "attachment; filename=stock_report.csv");

	        PrintWriter out = resp.getWriter();
	        out.println("Product,Opening,Purchase,Sales,Balance,Negative");

	        for (int i = 0; i < arr.length(); i++) {
	            JSONObject o = arr.getJSONObject(i);
	            out.println(
	                o.getString("productName") + "," +
	                o.getDouble("openingQty") + "," +
	                o.getDouble("purchaseQty") + "," +
	                o.getDouble("salesQty") + "," +
	                o.getDouble("balanceQty") + "," +
	                o.getBoolean("negativeBalance")
	            );
	        }
	        out.flush();
	    }

	    /* ================= EXCEL ================= */
	    private void exportExcel(HttpServletResponse resp, JSONArray arr) throws IOException {

	        XSSFWorkbook wb = new XSSFWorkbook();
	        XSSFSheet sh = wb.createSheet("P&L Report");

	        int rowNum = 0;

	        // Header
	        Row h = sh.createRow(rowNum++);
	        String[] heads = {
	            "Product Code",
	            "Product Name",
	            "Opening Qty",
	            "Purchase Qty",
	            "Sales Qty",
	            "Balance Qty",
	            "Purchase Amount",
	            "Sales Amount",
	            "Profit",
	            "Negative Balance"
	        };

	        for (int i = 0; i < heads.length; i++) {
	            h.createCell(i).setCellValue(heads[i]);
	        }

	        // Data rows
	        for (int i = 0; i < arr.length(); i++) {
	            JSONObject o = arr.getJSONObject(i);
	            Row r = sh.createRow(rowNum++);

	            r.createCell(0).setCellValue(o.optString("productCode"));
	            r.createCell(1).setCellValue(o.optString("productName"));
	            r.createCell(2).setCellValue(o.optDouble("openingQty"));
	            r.createCell(3).setCellValue(o.optDouble("purchaseQty"));
	            r.createCell(4).setCellValue(o.optDouble("salesQty"));
	            r.createCell(5).setCellValue(o.optDouble("balanceQty"));
	            r.createCell(6).setCellValue(o.optDouble("purchaseAmount"));
	            r.createCell(7).setCellValue(o.optDouble("salesAmount"));
	            r.createCell(8).setCellValue(o.optDouble("profit"));
	            r.createCell(9).setCellValue(o.optBoolean("negativeBalance") ? "YES" : "NO");
	        }

	        // Auto-size columns
	        for (int i = 0; i < heads.length; i++) {
	            sh.autoSizeColumn(i);
	        }

	        resp.setContentType(
	            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
	        resp.setHeader(
	            "Content-Disposition",
	            "attachment; filename=P&L_Report.xlsx");

	        wb.write(resp.getOutputStream());
	        wb.close();
	    }


	    
private void exportPDF(HttpServletResponse resp, JSONArray arr, JSONObject totals)
        throws IOException {

    resp.setContentType("application/pdf");
    resp.setHeader(
        "Content-Disposition",
        "attachment; filename=P&L_Report.pdf"
    );

    Document document = new Document(PageSize.A4.rotate(), 20, 20, 20, 20);
    PdfWriter.getInstance(document, resp.getOutputStream());
    document.open();

    /* ================= TITLE ================= */
    Font titleFont = new Font(Font.HELVETICA, 14, Font.BOLD);
    Paragraph title = new Paragraph(
        "Purchase & Sales Profit and Loss Report",
        titleFont
    );
    title.setAlignment(Element.ALIGN_CENTER);
    document.add(title);
    document.add(new Paragraph(" "));

    /* ================= TABLE ================= */
    PdfPTable table = new PdfPTable(9);
    table.setWidthPercentage(100);
    table.setWidths(new float[]{
        2f, 4f, 2f, 2f, 2f, 2f, 2f, 2f, 2f
    });

    Font headerFont = new Font(Font.HELVETICA, 9, Font.BOLD);
    Font bodyFont   = new Font(Font.HELVETICA, 9);
    Font redFont    = new Font(Font.HELVETICA, 9, Font.BOLD, Color.RED);

    /* ---------- HEADER ---------- */
    String[] headers = {
        "Product Code", "Product Name",
        "Opening Qty", "Purchase Qty", "Sales Qty",
        "Balance Qty", "Purchase Amt", "Sales Amt", "Profit"
    };

    for (String h : headers) {
        PdfPCell c = new PdfPCell(new Phrase(h, headerFont));
        c.setHorizontalAlignment(Element.ALIGN_CENTER);
        c.setBackgroundColor(new Color(230,230,230));
        c.setPadding(5);
        table.addCell(c);
    }

    /* ---------- DATA ROWS ---------- */
    for (int i = 0; i < arr.length(); i++) {
        JSONObject o = arr.getJSONObject(i);

        boolean negative = o.optBoolean("negativeBalance");

        Font rowFont = negative ? redFont : bodyFont;

        table.addCell(new Phrase(o.optString("productCode"), rowFont));
        table.addCell(new Phrase(o.optString("productName"), rowFont));
        table.addCell(new Phrase(o.optString("openingQty"), rowFont));
        table.addCell(new Phrase(o.optString("purchaseQty"), rowFont));
        table.addCell(new Phrase(o.optString("salesQty"), rowFont));
        table.addCell(new Phrase(o.optString("balanceQty"), rowFont));
        table.addCell(new Phrase(o.optString("purchaseAmount"), rowFont));
        table.addCell(new Phrase(o.optString("salesAmount"), rowFont));
        table.addCell(new Phrase(o.optString("profit"), rowFont));
    }

    /* ---------- TOTAL ROW ---------- */
    PdfPCell totalCell = new PdfPCell(
        new Phrase("GRAND TOTAL", headerFont)
    );
    totalCell.setColspan(6);
    totalCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
    totalCell.setPadding(6);
    table.addCell(totalCell);

    table.addCell(new Phrase(
        totals.optString("totalPurchaseAmount"), headerFont));
    table.addCell(new Phrase(
        totals.optString("totalSalesAmount"), headerFont));
    table.addCell(new Phrase(
        totals.optString("totalProfit"), headerFont));

    document.add(table);
    document.close();
}

}


