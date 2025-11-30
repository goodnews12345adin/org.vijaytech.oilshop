package org.vijaytech.textile;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.compiere.util.DB;
import org.json.JSONArray;
import org.json.JSONObject;

public class ProfitAndLossReport extends  HttpServlet{

	    // ----------------------------------------
	    // GET  (For Excel / PDF download later)
	    // ----------------------------------------
	    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
	            throws ServletException, IOException {

	        String action = req.getParameter("action");

	        if ("excel".equalsIgnoreCase(action)) {
	            resp.setContentType("text/plain");
	            resp.getWriter().write("Excel download will be implemented");
	            return;
	        }

	        if ("pdf".equalsIgnoreCase(action)) {
	            resp.setContentType("text/plain");
	            resp.getWriter().write("PDF download will be implemented");
	            return;
	        }

	        resp.setContentType("application/json");
	        resp.getWriter().write("{\"message\":\"GET OK\"}");
	        RequestDispatcher rd = req.getRequestDispatcher("/pages/profitandloss.jsp");
		    rd.forward(req, resp);
	    }


	    // ----------------------------------------
	    // POST  (Main logic → return JSON for JSP table)
	    // ----------------------------------------
	    @Override
	    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
	            throws ServletException, IOException {

	        resp.setContentType("application/json");
	        resp.setCharacterEncoding("UTF-8");

	        // ---------------------------
	        // Read incoming JSON
	        // ---------------------------
	        StringBuilder sb = new StringBuilder();
	        String line;

	        try (BufferedReader br = req.getReader()) {
	            while ((line = br.readLine()) != null)
	                sb.append(line);
	        }

	        JSONObject json = new JSONObject(sb.toString());

	        String from     = json.optString("from");
	        String to       = json.optString("to");
	        String org      = json.optString("org");
	        String product  = json.optString("product");
	        String category = json.optString("category");
	        
	        System.out.println("from date"+from);
	        System.out.println("to date"+to);
	        // ---------------------------
	        // Build SQL (Merged Sales + Purchase)
	        // ---------------------------
	        String sql =
	                "WITH sales AS ( " +
	                "    SELECT il.M_Product_ID, p.Value AS productcode, p.Name AS productname, " +
	                "           il.AD_Org_ID, i.DateAcct AS movementdate, " +
	                "           SUM(il.QtyInvoiced) AS salesqty, SUM(il.LineNetAmt) AS salesamt " +
	                "    FROM C_Invoice i " +
	                "    JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID " +
	                "    JOIN M_Product p ON p.M_Product_ID = il.M_Product_ID " +
	                "    WHERE i.IsSOTrx = 'Y' AND i.DocStatus IN ('CO','CL') " +
	                "    GROUP BY il.M_Product_ID, p.Value, p.Name, il.AD_Org_ID, i.DateAcct " +
	                "), " +
	                "purchase AS ( " +
	                "    SELECT il.M_Product_ID, p.Value AS productcode, p.Name AS productname, " +
	                "           il.AD_Org_ID, i.DateAcct AS movementdate, " +
	                "           SUM(il.QtyInvoiced) AS purqty, SUM(il.LineNetAmt) AS puramt " +
	                "    FROM C_Invoice i " +
	                "    JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID " +
	                "    JOIN M_Product p ON p.M_Product_ID = il.M_Product_ID " +
	                "    WHERE i.IsSOTrx = 'N' AND i.DocStatus IN ('CO','CL') " +
	                "    GROUP BY il.M_Product_ID, p.Value, p.Name, il.AD_Org_ID, i.DateAcct " +
	                ") " +
	                "SELECT " +
	                "  COALESCE(s.productcode, p.productcode) AS productcode, " +
	                "  COALESCE(s.productname, p.productname) AS productname, " +
	                "  COALESCE(s.salesqty, 0) AS salesqty, " +
	                "  COALESCE(s.salesamt, 0) AS salesamt, " +
	                "  COALESCE(p.purqty, 0) AS purqty, " +
	                "  COALESCE(p.puramt, 0) AS puramt " +
	                "FROM sales s " +
	                "FULL OUTER JOIN purchase p ON ( " +
	                "    s.M_Product_ID = p.M_Product_ID " +
	                "    AND s.AD_Org_ID = p.AD_Org_ID " +
	                "    AND s.movementdate = p.movementdate " +
	                ") " +
	                "WHERE (COALESCE(s.movementdate, p.movementdate)::DATE BETWEEN ?::DATE AND ?::DATE)";


	        List<Object> params = new ArrayList<>();
	        params.add(from);
	        params.add(to);

	        // Org filter
	        if (!org.isEmpty()) {
	            sql += " AND COALESCE(s.AD_Org_ID, p.AD_Org_ID) = ? ";
	            params.add(Integer.parseInt(org));
	        }

	        // Product filter
	        if (!product.isEmpty()) {
	            sql += " AND (COALESCE(s.productcode, p.productcode) ILIKE ? " +
	                   " OR COALESCE(s.productname, p.productname) ILIKE ?) ";
	            params.add("%" + product + "%");
	            params.add("%" + product + "%");
	        }

	        // Category filter
	        if (!category.isEmpty()) {
	            sql += " AND p.M_Product_Category_ID = ? ";
	            params.add(Integer.parseInt(category));
	        }

	        // ---------------------------
	        // Execute Query
	        // ---------------------------
	        List<List<Object>> rows = DB.getSQLArrayObjectsEx(
	                null,
	                sql,
	                params.toArray()
	        );

	        JSONArray arr = new JSONArray();

	        double totalSalesAmt = 0;
	        double totalPurchaseAmt = 0;
	        double totalProfit = 0;

	        // ---------------------------
	        // Parse rows + compute profit
	        // ---------------------------
	        for (List<Object> r : rows) {

	            double salesAmt = r.get(3) != null ? ((Number) r.get(3)).doubleValue() : 0.0;
	            double purchaseAmt = r.get(5) != null ? ((Number) r.get(5)).doubleValue() : 0.0;
	            double profit = salesAmt - purchaseAmt;

	            totalSalesAmt += salesAmt;
	            totalPurchaseAmt += purchaseAmt;
	            totalProfit += profit;

	            JSONObject o = new JSONObject();

	            o.put("productCode",     r.get(0));
	            o.put("productName",     r.get(1));
	            o.put("salesQty",        r.get(2));
	            o.put("salesAmount",     salesAmt);
	            o.put("purchaseQty",     r.get(4));
	            o.put("purchaseAmount",  purchaseAmt);
	            o.put("profit",          profit);

	            arr.put(o);
	        }

	        // Totals JSON
	        JSONObject totals = new JSONObject();
	        totals.put("totalSalesAmount", totalSalesAmt);
	        totals.put("totalPurchaseAmount", totalPurchaseAmt);
	        totals.put("totalProfit", totalProfit);

	        // Final response
	        JSONObject finalOutput = new JSONObject();
	        finalOutput.put("rows", arr);
	        finalOutput.put("totals", totals);

	        resp.getWriter().write(finalOutput.toString());
	    }
	    
//	    private void exportPDF(ReportResult result, HttpServletResponse resp) throws IOException {
//
//	        resp.setContentType("application/pdf");
//	        resp.setHeader("Content-Disposition", "attachment; filename=ProfitLossReport.pdf");
//
//	        Document document = new Document(PageSize.A4.rotate());
//	        PdfWriter.getInstance(document, resp.getOutputStream());
//	        document.open();
//
//	        document.add(new Paragraph("Purchase & Sales Profit & Loss Report"));
//	        document.add(new Paragraph(" ")); // Empty line
//
//	        PdfPTable table = new PdfPTable(7);
//	        table.setWidths(new float[]{2, 4, 2, 2, 2, 2, 2});
//
//	        table.addCell("Product Code");
//	        table.addCell("Product Name");
//	        table.addCell("Sales Qty");
//	        table.addCell("Sales Amount");
//	        table.addCell("Purchase Qty");
//	        table.addCell("Purchase Amount");
//	        table.addCell("Profit");
//
//	        for (ReportRow r : result.rows) {
//	            table.addCell(r.productCode);
//	            table.addCell(r.productName);
//	            table.addCell(r.salesQty.toString());
//	            table.addCell(r.salesAmount.toString());
//	            table.addCell(r.purchaseQty.toString());
//	            table.addCell(r.purchaseAmount.toString());
//	            table.addCell(r.profit.toString());
//	        }
//
//	        PdfPCell total = new PdfPCell(new Phrase("TOTAL"));
//	        total.setColspan(2);
//	        table.addCell(total);
//
//	        table.addCell(""); // Sales Qty blank
//	        table.addCell(result.totals.totalSalesAmount.toString());
//	        table.addCell(""); // Purchase Qty blank
//	        table.addCell(result.totals.totalPurchaseAmount.toString());
//	        table.addCell(result.totals.totalProfit.toString());
//
//	        document.add(table);
//	        document.close();
//	    }

//	    private void exportExcel(ReportResult result, HttpServletResponse resp) throws IOException {
//
//	        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
//	        resp.setHeader("Content-Disposition", "attachment; filename=ProfitLossReport.xlsx");
//
//	        XSSFWorkbook wb = new XSSFWorkbook();
//	        XSSFSheet sheet = wb.createSheet("P&L");
//
//	        int rowNo = 0;
//
//	        Row header = sheet.createRow(rowNo++);
//	        header.createCell(0).setCellValue("Product Code");
//	        header.createCell(1).setCellValue("Product Name");
//	        header.createCell(2).setCellValue("Sales Qty");
//	        header.createCell(3).setCellValue("Sales Amount");
//	        header.createCell(4).setCellValue("Purchase Qty");
//	        header.createCell(5).setCellValue("Purchase Amount");
//	        header.createCell(6).setCellValue("Profit");
//
//	        for (ReportRow r : result.rows) {
//	            Row row = sheet.createRow(rowNo++);
//	            row.createCell(0).setCellValue(r.productCode);
//	            row.createCell(1).setCellValue(r.productName);
//	            row.createCell(2).setCellValue(r.salesQty.doubleValue());
//	            row.createCell(3).setCellValue(r.salesAmount.doubleValue());
//	            row.createCell(4).setCellValue(r.purchaseQty.doubleValue());
//	            row.createCell(5).setCellValue(r.purchaseAmount.doubleValue());
//	            row.createCell(6).setCellValue(r.profit.doubleValue());
//	        }
//
//	        // Totals
//	        Row t = sheet.createRow(rowNo++);
//	        t.createCell(0).setCellValue("TOTAL");
//	        t.createCell(3).setCellValue(result.totals.totalSalesAmount.doubleValue());
//	        t.createCell(5).setCellValue(result.totals.totalPurchaseAmount.doubleValue());
//	        t.createCell(6).setCellValue(result.totals.totalProfit.doubleValue());
//
//	        wb.write(resp.getOutputStream());
//	        wb.close();
//	    }



}
