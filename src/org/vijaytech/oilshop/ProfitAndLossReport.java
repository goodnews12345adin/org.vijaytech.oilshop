package org.vijaytech.oilshop;

import java.awt.Color;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.compiere.model.MProduct;
import org.compiere.model.MProductCategory;
import org.compiere.model.Query;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONArray;
import org.json.JSONObject;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

public class ProfitAndLossReport extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // -------------------------------------------------
    // ================ DO GET =============
    // -------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        
        // ---- SINGLE INVOICE PDF CHECK ----
        String docNo = req.getParameter("docNo");
        if (docNo != null && !docNo.isEmpty()) {
            try {
                generateSingleInvoicePDF(req, resp, docNo);
                return;
            } catch (Exception e) {
                e.printStackTrace();
                sendErrorJSON(resp, "PDF Generation Failed", e);
            }
        }

        // ---- SESSION CHECK ----
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("ctx") == null) {
            resp.sendRedirect("userlogin.jsp?error=session_expired");
            return;
        }

        Properties ctx = (Properties) session.getAttribute("ctx");
        Env.setCtx(ctx);

        // Set Context Defaults if missing
        if (Env.getAD_Client_ID(ctx) == 0) Env.setContext(ctx, "#AD_Client_ID", 1000000);
        if (Env.getAD_Org_ID(ctx) == 0) Env.setContext(ctx, "#AD_Org_ID", 1000000);
        if (Env.getAD_User_ID(ctx) == 0) Env.setContext(ctx, "#AD_User_ID", 100);
        if (Env.getContextAsInt(ctx, "#AD_Role_ID") == 0) Env.setContext(ctx, "#AD_Role_ID", 102);

        try {
            // Load Dropdown Data using STANDARD ADempiere Models
            List<Map<String, Object>> categoryList = new ArrayList<>();
            List<Map<String, Object>> productList = new ArrayList<>();

            // Using MProductCategory (Standard)
            List<MProductCategory> cats = new Query(ctx, MProductCategory.Table_Name, "IsActive='Y'", null)
                    .setClient_ID()
                    .list();

            for (MProductCategory c : cats) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", c.get_ID());
                m.put("name", c.getName());
                categoryList.add(m);
            }
            
            // Using MProduct (Standard)
            List<MProduct> prods = new Query(ctx, MProduct.Table_Name, "IsActive='Y'", null)
                    .setClient_ID()
                    .list();
            for (MProduct p : prods) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", p.get_ID());
                m.put("name", p.getName());
                productList.add(m);
            }

            req.setAttribute("categoryList", categoryList);
            req.setAttribute("productList", productList);

            RequestDispatcher rd = req.getRequestDispatcher("/pages/profitandloss.jsp");
            rd.forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading Report", e);
        }
    }	

    // -------------------------------------------------
    // ================ DO POST (JSON DATA) =============
    // -------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = request.getReader()) {
            String line; 
            while ((line = br.readLine()) != null) { 
                sb.append(line); 
            }
        }

        if(sb.length() == 0) {
            sendErrorJSON(response, "Invalid Request", new Exception("No JSON data received"));
            return;
        }

        JSONObject json = new JSONObject(sb.toString());

        String from = json.optString("from");
        String to = json.optString("to");
        String category = json.optString("category");
        String product = json.optString("product");

        // Validate Dates
        if(from == null || from.isEmpty() || to == null || to.isEmpty()) {
            sendErrorJSON(response, "Invalid Parameters", new Exception("Date range is required"));
            return;
        }

        try {
            // 1. Fetch Sales Data
            List<Map<String, Object>> salesList = fetchTransactionData(true, from, to, category, product);
            
            // 2. Fetch Purchase Data
            List<Map<String, Object>> purchaseList = fetchTransactionData(false, from, to, category, product);

            // 3. Merge Data
            Map<String, Map<String, Object>> mergedMap = new LinkedHashMap<>();
            
            BigDecimal grandSales = BigDecimal.ZERO;
            BigDecimal grandPurchase = BigDecimal.ZERO;
            BigDecimal grandProfit = BigDecimal.ZERO;
            BigDecimal grandQty = BigDecimal.ZERO;

            // Process Sales
            for (Map<String, Object> row : salesList) {
                String code = (String) row.get("Code");
                Map<String, Object> m = new HashMap<>();
                m.put("productCode", code);
                m.put("productName", row.get("Product"));
                m.put("salesQty", row.get("Qty"));
                m.put("salesAmount", row.get("Amount"));
                m.put("purchaseQty", BigDecimal.ZERO);
                m.put("purchaseAmount", BigDecimal.ZERO);
                m.put("balanceQty", row.get("Qty"));
                m.put("profit", row.get("Amount"));
                mergedMap.put(code, m);
            }

            // Process Purchases and Merge
            for (Map<String, Object> row : purchaseList) {
                String code = (String) row.get("Code");
                Map<String, Object> m = mergedMap.get(code);
                
                BigDecimal purchQty = (BigDecimal) row.get("Qty");
                BigDecimal purchAmt = (BigDecimal) row.get("Amount");
                String prodName = (String) row.get("Product");

                if (m == null) {
                    m = new HashMap<>();
                    m.put("productCode", code);
                    m.put("productName", prodName);
                    m.put("salesQty", BigDecimal.ZERO);
                    m.put("salesAmount", BigDecimal.ZERO);
                    m.put("purchaseQty", purchQty);
                    m.put("purchaseAmount", purchAmt);
                    m.put("balanceQty", purchQty);
                    m.put("profit", purchAmt.negate());
                    mergedMap.put(code, m);
                } else {
                    m.put("productName", prodName);
                    m.put("purchaseQty", purchQty);
                    m.put("purchaseAmount", purchAmt);
                    
                    BigDecimal sAmt = (BigDecimal) m.get("salesAmount");
                    BigDecimal pAmt = (BigDecimal) m.get("purchaseAmount");
                    BigDecimal sQty = (BigDecimal) m.get("salesQty");
                    BigDecimal pQty = (BigDecimal) m.get("purchaseQty");

                    BigDecimal profit = sAmt.subtract(pAmt);
                    BigDecimal balQty = pQty.subtract(sQty);

                    m.put("profit", profit);
                    m.put("balanceQty", balQty);
                }
            }

            // Build Final Response
            JSONArray resultRows = new JSONArray();
            for (Map<String, Object> entry : mergedMap.values()) {
                JSONObject j = new JSONObject(entry);
                
                BigDecimal sAmt = num((BigDecimal) entry.get("salesAmount"));
                BigDecimal pAmt = num((BigDecimal) entry.get("purchaseAmount"));
                BigDecimal profit = sAmt.subtract(pAmt);
                BigDecimal qty = (BigDecimal) entry.get("balanceQty");

                grandSales = grandSales.add(sAmt);
                grandPurchase = grandPurchase.add(pAmt);
                grandProfit = grandProfit.add(profit);
                grandQty = grandQty.add(qty);

                resultRows.put(j);
            }

            // Create Totals Object
            JSONObject totals = new JSONObject();
            totals.put("totalSalesAmount", grandSales);
            totals.put("totalPurchaseAmount", grandPurchase);
            totals.put("totalProfit", grandProfit);
            totals.put("balanceQty", grandQty);

            // Create Main Response
            JSONObject responseObj = new JSONObject();
            responseObj.put("rows", resultRows);
            responseObj.put("totals", totals);

            response.setContentType("application/json");
            response.getWriter().write(responseObj.toString());

        } catch (Exception ex) {
            ex.printStackTrace();
            sendErrorJSON(response, "Server Error", ex);
        }
    }

    // Helper to fetch Sales or Purchase
    private List<Map<String, Object>> fetchTransactionData(boolean isSOTrx, String from, String to, String category, String product) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();

        sql.append("SELECT p.Value AS Code, p.Name AS Product, SUM(il.QtyInvoiced) AS Qty, SUM(il.LineNetAmt) AS Amount ");
        sql.append("FROM C_Invoice i ");
        sql.append("JOIN C_InvoiceLine il ON i.C_Invoice_ID = il.C_Invoice_ID ");
        sql.append("LEFT JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID ");
        sql.append("WHERE i.IsSOTrx=? AND i.DocStatus IN ('CO','CL') ");
        sql.append("AND i.DateInvoiced BETWEEN ? AND ? ");

        List<Object> params = new ArrayList<>();
        params.add(isSOTrx ? "Y" : "N");
        params.add(toTs(from));
        params.add(toTsEnd(to));

        if (category != null && !category.isEmpty()) {
            sql.append("AND p.M_Product_Category_ID=? ");
            params.add(Integer.parseInt(category));
        }

        if (product != null && !product.isEmpty()) {
            sql.append("AND p.M_Product_ID=? ");
            params.add(Integer.parseInt(product));
        }

        sql.append("GROUP BY p.Value, p.Name ");
        sql.append("ORDER BY p.Name");

        try (Connection conn = DB.getConnectionRW();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int idx = 1;
            for(Object p : params) {
                if(p instanceof Timestamp) {
                    ps.setTimestamp(idx++, (Timestamp)p);
                } else {
                    ps.setObject(idx++, p);
                }
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("Code", rs.getString("Code"));
                row.put("Product", rs.getString("Product"));
                row.put("Qty", rs.getBigDecimal("Qty"));
                row.put("Amount", rs.getBigDecimal("Amount"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================================================
    // ============ SINGLE INVOICE PDF (iText/Lowagie) ========
    // ==================================================
    private void generateSingleInvoicePDF(HttpServletRequest req, HttpServletResponse resp, String docNo) throws Exception {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("ctx") == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Session Expired");
            return;
        }
        Properties ctx = (Properties) session.getAttribute("ctx");
        Env.setCtx(ctx);

        StringBuilder sqlHeader = new StringBuilder();
        StringBuilder sqlLines = new StringBuilder();

        sqlHeader.append("SELECT i.DocumentNo, i.DateInvoiced, i.GrandTotal, bp.Name AS BPartner, bp.Name2, bp.City, bp.Postal, ");
        sqlHeader.append("org.Name AS OrgName ");
        sqlHeader.append("FROM C_Invoice i ");
        sqlHeader.append("JOIN C_BPartner bp ON i.C_BPartner_ID = bp.C_BPartner_ID ");
        sqlHeader.append("JOIN AD_Org org ON i.AD_Org_ID = org.AD_Org_ID ");
        sqlHeader.append("WHERE i.DocumentNo = ?");

        sqlLines.append("SELECT p.Name, il.QtyInvoiced, il.PriceActual, il.LineNetAmt ");
        sqlLines.append("FROM C_InvoiceLine il ");
        sqlLines.append("LEFT JOIN M_Product p ON il.M_Product_ID = p.M_Product_ID ");
        sqlLines.append("WHERE il.C_Invoice_ID = (SELECT C_Invoice_ID FROM C_Invoice WHERE DocumentNo = ?)");

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4);
        
        PdfWriter writer = PdfWriter.getInstance(document, baos);
        document.open();

        Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
        Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 10);
        Font tableHeaderFont = FontFactory.getFont(FontFactory.HELVETICA, 9, Font.BOLD);

        // Organization Header
        PdfPTable headerTable = new PdfPTable(1);
        headerTable.setWidthPercentage(100);
        PdfPCell orgCell = new PdfPCell(new Phrase("Vijay Tech Orbit", headerFont));
        
        orgCell.setBorder(Rectangle.NO_BORDER);
        orgCell.setPadding(10);
        orgCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        headerTable.addCell(orgCell);
        document.add(headerTable);

        String invoiceOrg = "Not Found";
        BigDecimal grandTotal = BigDecimal.ZERO;
        String dateStr = "";
        String partnerName = "";

        try (Connection conn = DB.getConnectionRW()) {
            // Header Info
            try (PreparedStatement psH = conn.prepareStatement(sqlHeader.toString())) {
                psH.setString(1, docNo);
                try (ResultSet rs = psH.executeQuery()) {
                    if (rs.next()) {
                        invoiceOrg = rs.getString("OrgName");
                        grandTotal = rs.getBigDecimal("GrandTotal");
                        partnerName = rs.getString("BPartner");
                        Timestamp d = rs.getTimestamp("DateInvoiced");
                        dateStr = new SimpleDateFormat("dd-MMM-yyyy").format(d);
                    } else {
                        throw new ServletException("Document Not Found");
                    }
                }
            }

            Paragraph info = new Paragraph();
            info.add(new Phrase("Invoice No: ", headerFont));
            info.add(new Phrase(docNo + "\n", normalFont));
            info.add(new Phrase("Date: ", headerFont));
            info.add(new Phrase(dateStr + "\n", normalFont));
            info.add(new Phrase("Customer: ", headerFont));
            info.add(new Phrase(partnerName + "\n\n", normalFont));
            document.add(info);

            // Lines Table
            PdfPTable table = new PdfPTable(4);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{3f, 1f, 1f, 1f});
            
            table.addCell(createCell("Product", tableHeaderFont));
            table.addCell(createCell("Qty", tableHeaderFont));
            table.addCell(createCell("Price", tableHeaderFont));
            table.addCell(createCell("Total", tableHeaderFont));

            try (PreparedStatement psL = conn.prepareStatement(sqlLines.toString())) {
                psL.setString(1, docNo);
                try (ResultSet rs = psL.executeQuery()) {
                    while (rs.next()) {
                        table.addCell(createCell(rs.getString("Name"), normalFont));
                        table.addCell(createCell(rs.getBigDecimal("QtyInvoiced").toString(), normalFont));
                        table.addCell(createCell(rs.getBigDecimal("PriceActual").toString(), normalFont));
                        table.addCell(createCell(rs.getBigDecimal("LineNetAmt").toString(), normalFont));
                    }
                }
            }
            
            if ("Not Found".equals(invoiceOrg)) {
                throw new ServletException("Invoice Not Found");
            }

            document.add(table);

            // Total
            Paragraph totalPara = new Paragraph("Grand Total: " + grandTotal, headerFont);
            totalPara.setAlignment(Element.ALIGN_RIGHT);
            totalPara.setSpacingBefore(15);
            document.add(totalPara);

            document.close();

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "attachment; filename=Invoice_" + docNo + ".pdf");
            resp.setContentLength(baos.size());
            OutputStream os = resp.getOutputStream();
            baos.writeTo(os);
            os.flush();
            os.close();

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private PdfPCell createCell(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBorderColor(Color.LIGHT_GRAY);
        cell.setPadding(5);
        return cell;
    }

    private void sendErrorJSON(HttpServletResponse response, String title, Exception e) throws IOException {
        JSONObject err = new JSONObject();
        err.put("error", title);
        try {
            String msg = e.getMessage();
            if (msg == null) msg = "Internal Server Error";
            err.put("message", msg);
        } catch (Exception ex) {
            err.put("message", ex.getMessage());
        }
        response.setContentType("application/json");
        response.getWriter().write(err.toString());
    }

    private BigDecimal num(BigDecimal bd) {
        return bd == null ? BigDecimal.ZERO : bd;
    }

    private Timestamp toTs(String dateStr) {
        try {
            return Timestamp.valueOf(dateStr + " 00:00:00");
        } catch (Exception e) {
            return null;
        }
    }

    private Timestamp toTsEnd(String dateStr) {
        try {
            return Timestamp.valueOf(dateStr + " 23:59:59");
        } catch (Exception e) {
            return null;
        }
    }
}