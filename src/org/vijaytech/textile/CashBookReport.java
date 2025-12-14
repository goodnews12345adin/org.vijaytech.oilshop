package org.vijaytech.textile;

import java.awt.Color;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MBPartner;
import org.compiere.model.MBankAccount;
import org.compiere.model.MElementValue;
import org.compiere.model.MOrg;
import org.compiere.model.Query;
import org.compiere.util.DB;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

public class CashBookReport extends HttpServlet{

	 private static final long serialVersionUID = 1L;

	    private SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");

	    protected void doGet(HttpServletRequest request, HttpServletResponse response)
	            throws ServletException, IOException {

	        try {
	        	 HttpSession session = request.getSession(false);

	        	    if (session == null) {
	        	        response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
	        	        return;
	        	    }

	        	    Properties ctx = (Properties) session.getAttribute("ctx");

	        	    if (ctx == null) {
	        	        response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=context_missing");
	        	        return;
	        	    }
	         // =============================
	         // 1. ORGANIZATION LIST
	         // =============================
	         List<MOrg> orgListRaw = new Query(ctx, MOrg.Table_Name,
	                         "IsActive='Y'", null)
	                         .setClient_ID()
	                         .setOrderBy("Name")
	                         .list();

	         List<Map<String,Object>> orgList = new ArrayList<>();
	         for (MOrg o : orgListRaw) {
	             Map<String,Object> m = new HashMap<>();
	             m.put("id", o.getAD_Org_ID());
	             m.put("name", o.getName());
	             orgList.add(m);
	         }
				/* request.setAttribute("orgList", orgList); */


	         // =============================
	         // 2. BANK / CASH ACCOUNT LIST
	         // =============================
	         List<MBankAccount> bankRaw = new Query(ctx, MBankAccount.Table_Name,
	                         "IsActive='Y'", null)
	                         .setClient_ID()
	                         .setOrderBy("Name")
	                         .list();

	         List<Map<String,Object>> bankList = new ArrayList<>();
	         for (MBankAccount b : bankRaw) {
	             Map<String,Object> m = new HashMap<>();
	             m.put("id", b.getC_BankAccount_ID());
	             m.put("name", b.getName());
	             bankList.add(m);
	         }
	         request.setAttribute("bankList", bankList);


	         // =============================
	         // 3. BUSINESS PARTNER LIST
	         // =============================
	         List<MBPartner> bpRaw = new Query(ctx, MBPartner.Table_Name,
	                         "IsActive='Y'", null)
	                         .setClient_ID()
	                         .setOrderBy("Name")
	                         .list();

	         List<Map<String,Object>> bpList = new ArrayList<>();
	         for (MBPartner p : bpRaw) {
	             Map<String,Object> m = new HashMap<>();
	             m.put("id", p.getC_BPartner_ID());
	             m.put("name", p.getName());
	             bpList.add(m);
	         }
	         request.setAttribute("bpList", bpList);


	         // =============================
	         // 4. EXPENSE ACCOUNT LIST
	         // =============================
	         List<MElementValue> expRaw =
	                 new Query(ctx, MElementValue.Table_Name,
	                         "AccountType='E' AND IsSummary='N' AND IsActive='Y'", null)
	                         .setClient_ID()
	                         .setOrderBy("Value")
	                         .list();

	         List<Map<String,Object>> expenseList = new ArrayList<>();
	         for (MElementValue e : expRaw) {
	             Map<String,Object> m = new HashMap<>();
	             m.put("id", e.getC_ElementValue_ID());
	             m.put("name", e.getValue() + " - " + e.getName());
	             expenseList.add(m);
	         }
	         request.setAttribute("expenseList", expenseList);


	            request.getRequestDispatcher("pages/CashBookReport.jsp").forward(request, response);

	        } catch (Exception ex) {
	            throw new ServletException("Error loading Expense Entry page", ex);
	        }
	    }



	    @Override
	    protected void doPost(HttpServletRequest request, HttpServletResponse response)
	            throws ServletException, IOException {

	        String action = request.getParameter("action");

	        String bankId = request.getParameter("bank_id");
	        String bpId   = request.getParameter("bp_id");
	        String from   = request.getParameter("from_date");
	        String to     = request.getParameter("to_date");

	        List<Map<String,Object>> results = loadCashBook( bankId, bpId, from, to);

	        try {

	            // ===============================
	            // AJAX SEARCH → JSON RESPONSE
	            // ===============================
	            if ("search".equalsIgnoreCase(action)) {

	                response.setContentType("application/json");
	                response.setCharacterEncoding("UTF-8");

	                StringBuilder json = new StringBuilder();
	                json.append("[");

	                for (int i = 0; i < results.size(); i++) {
	                    Map<String,Object> r = results.get(i);

	                    json.append("{")
	                        .append("\"datetrx\":\"").append(r.get("datetrx")).append("\",")
	                        .append("\"documentno\":\"").append(r.get("documentno")).append("\",")
	                        .append("\"bpname\":\"").append(r.get("bpname")).append("\",")
	                        .append("\"accounthead\":\"").append(r.get("accounthead")).append("\",")
	                        .append("\"description\":\"").append(r.get("description")).append("\",")
	                        .append("\"receipt\":").append(r.get("receipt")).append(",")
	                        .append("\"payment\":").append(r.get("payment")).append(",")
	                        .append("\"balance\":").append(r.get("balance"))
	                        .append("}");

	                    if (i < results.size() - 1) json.append(",");
	                }

	                json.append("]");
	                response.getWriter().print(json.toString());
	                return;
	            }

	            // ===============================
	            // PDF DOWNLOAD
	            // ===============================
	            if ("pdf".equalsIgnoreCase(action)) {

	                response.setContentType("application/pdf");
	                response.setHeader(
	                    "Content-Disposition",
	                    "inline; filename=CashBookReport.pdf"
	                );

	                OutputStream out = response.getOutputStream();
	                createPDF(results, out);
	                out.flush();
	                return;
	            }

	        } catch (Exception e) {
	            throw new ServletException(e);
	        }
	    }

	  


	    private List<Map<String,Object>> loadCashBook(
	             String bankId, String bpId, String from, String to) {


	        StringBuilder sql = new StringBuilder();
	        List<Object> params = new ArrayList<>();

	        sql.append("SELECT p.DateTrx, p.DocumentNo, bp.Name AS bpname, ")
	           .append("ev.Name AS accounthead, p.Description, ")
	           .append("CASE WHEN p.IsReceipt='Y' THEN p.PayAmt ELSE 0 END AS receipt, ")
	           .append("CASE WHEN p.IsReceipt='N' THEN p.PayAmt ELSE 0 END AS payment ")
	           .append("FROM C_Payment p ")
	           .append("LEFT JOIN C_BPartner bp ON bp.C_BPartner_ID = p.C_BPartner_ID ")
	           .append("LEFT JOIN C_ElementValue ev ON ev.C_ElementValue_ID = p.C_ElementValue_ID ")
	           .append("WHERE p.IsActive='Y' ")
	           .append("AND p.AD_Org_ID = '1000000' ");

	

	        if (bankId != null && !bankId.trim().isEmpty()) {
	            sql.append("AND p.C_BankAccount_ID = ? ");
	            params.add(Integer.parseInt(bankId));
	        }

	        if (bpId != null && !bpId.trim().isEmpty()) {
	            sql.append("AND p.C_BPartner_ID = ? ");
	            params.add(Integer.parseInt(bpId));
	        }

	        if (from != null && !from.isEmpty()) {
	            sql.append("AND p.DateTrx >= ? ");
	            params.add(Timestamp.valueOf(from + " 00:00:00"));
	        }

	        if (to != null && !to.isEmpty()) {
	            sql.append("AND p.DateTrx <= ? ");
	            params.add(Timestamp.valueOf(to + " 23:59:59"));
	        }

	        sql.append("ORDER BY p.DateTrx, p.C_Payment_ID");

	        List<List<Object>> raw =
	            DB.getSQLArrayObjectsEx(null, sql.toString(), params.toArray());

	        List<Map<String,Object>> rows = new ArrayList<>();

	        if (raw == null || raw.isEmpty()) {
	            return rows; // empty list is better than exception
	        }

	        java.math.BigDecimal balance = java.math.BigDecimal.ZERO;

	        for (List<Object> r : raw) {

	            Map<String,Object> m = new HashMap<>();

	            java.math.BigDecimal receipt =
	                r.get(5) == null ? java.math.BigDecimal.ZERO : (java.math.BigDecimal) r.get(5);

	            java.math.BigDecimal payment =
	                r.get(6) == null ? java.math.BigDecimal.ZERO : (java.math.BigDecimal) r.get(6);

	            balance = balance.add(receipt).subtract(payment);

	            m.put("datetrx",     r.get(0));
	            m.put("documentno",  r.get(1));
	            m.put("bpname",      r.get(2));
	            m.put("accounthead", r.get(3));
	            m.put("description", r.get(4));
	            m.put("receipt",     receipt);
	            m.put("payment",     payment);
	            m.put("balance",     balance);

	            rows.add(m);
	        }

	        return rows;
	    }
	    
	    private void createPDF(List<Map<String,Object>> rows, OutputStream out) throws Exception {

	        Document document = new Document(PageSize.A4.rotate(), 20, 20, 70, 45);
	        PdfWriter writer = PdfWriter.getInstance(document, out);
	        writer.setPageEvent(new PageNumberFooter());
	        document.open();

	        // ===============================
	        // Fonts
	        // ===============================
	        Font companyFont = new Font(Font.HELVETICA, 15, Font.BOLD);
	        Font titleFont   = new Font(Font.HELVETICA, 12, Font.BOLD);
	        Font headerFont  = new Font(Font.HELVETICA, 9, Font.BOLD);
	        Font bodyFont    = new Font(Font.HELVETICA, 9);
	        Font totalFont   = new Font(Font.HELVETICA, 9, Font.BOLD);

	        // ===============================
	        // LOGO (CENTERED)
	        // ===============================
	        try {
	            Image logo = Image.getInstance("/opt/idempiere/logo/company_logo.png");
	            logo.scaleToFit(70, 70);
	            logo.setAlignment(Image.ALIGN_CENTER);
	            document.add(logo);
	        } catch (Exception e) {
	            // logo optional
	        }

	        // ===============================
	        // CENTERED HEADER TEXT
	        // ===============================
	        Paragraph company = new Paragraph("HAPPY LADY FASHIONS", companyFont);
	        company.setAlignment(Element.ALIGN_CENTER);
	        document.add(company);

	        Paragraph address = new Paragraph(
	            "No.12, Main Road, Chennai – 600001",
	            bodyFont
	        );
	        address.setAlignment(Element.ALIGN_CENTER);
	        document.add(address);

	        Paragraph report = new Paragraph("CASH BOOK REPORT", titleFont);
	        report.setAlignment(Element.ALIGN_CENTER);
	        report.setSpacingBefore(6);
	        report.setSpacingAfter(10);
	        document.add(report);

	        // ===============================
	        // DATA TABLE
	        // ===============================
	        PdfPTable table = new PdfPTable(8);
	        table.setWidthPercentage(100);
	        table.setWidths(new float[]{10, 14, 18, 18, 24, 10, 10, 12});

	        addHeaderCell(table, "Date", headerFont);
	        addHeaderCell(table, "Document No", headerFont);
	        addHeaderCell(table, "BP Name", headerFont);
	        addHeaderCell(table, "Account Head", headerFont);
	        addHeaderCell(table, "Description", headerFont);
	        addHeaderCell(table, "Receipt", headerFont);
	        addHeaderCell(table, "Payment", headerFont);
	        addHeaderCell(table, "Balance", headerFont);

	        double totalReceipt = 0;
	        double totalPayment = 0;
	        double closingBalance = 0;

	        for (Map<String,Object> row : rows) {

	            table.addCell(textCell(row.get("datetrx"), bodyFont));
	            table.addCell(textCell(row.get("documentno"), bodyFont));
	            table.addCell(textCell(row.get("bpname"), bodyFont));
	            table.addCell(textCell(row.get("accounthead"), bodyFont));
	            table.addCell(textCell(row.get("description"), bodyFont));

	            double receipt = parse(row.get("receipt"));
	            double payment = parse(row.get("payment"));
	            closingBalance = parse(row.get("balance"));

	            totalReceipt += receipt;
	            totalPayment += payment;

	            table.addCell(amountCell(receipt, bodyFont));
	            table.addCell(amountCell(payment, bodyFont));
	            table.addCell(amountCell(closingBalance, bodyFont));
	        }

	        // ===============================
	        // TOTAL FOOTER ROW
	        // ===============================
	        PdfPCell totalLabel = new PdfPCell(new Phrase("TOTAL", totalFont));
	        totalLabel.setColspan(5);
	        totalLabel.setHorizontalAlignment(Element.ALIGN_RIGHT);
	        totalLabel.setBackgroundColor(new Color(230,230,230));
	        totalLabel.setPadding(6);
	        table.addCell(totalLabel);

	        table.addCell(amountCell(totalReceipt, totalFont));
	        table.addCell(amountCell(totalPayment, totalFont));
	        table.addCell(amountCell(closingBalance, totalFont));

	        document.add(table);
	        document.close();
	    }


	    class PageNumberFooter extends PdfPageEventHelper {

	        Font footerFont = new Font(Font.HELVETICA, 8);

	        @Override
	        public void onEndPage(PdfWriter writer, Document document) {

	            PdfPTable footer = new PdfPTable(1);
	            try {
	                footer.setTotalWidth(200);
	                footer.setLockedWidth(true);
	                footer.getDefaultCell().setBorder(Rectangle.NO_BORDER);
	                footer.getDefaultCell().setHorizontalAlignment(Element.ALIGN_CENTER);

	                footer.addCell(
	                    new Phrase("Page " + writer.getPageNumber(), footerFont)
	                );

	                footer.writeSelectedRows(
	                    0, -1,
	                    (document.right() + document.left()) / 2,
	                    document.bottom() - 12,
	                    writer.getDirectContent()
	                );
	            } catch (Exception e) {
	                // ignore
	            }
	        }
	    }


	    private void addHeaderCell(PdfPTable table, String text, Font font) {
	        PdfPCell cell = new PdfPCell(new Phrase(text, font));
	        cell.setBackgroundColor(new Color(220, 220, 220));
	        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	        cell.setPadding(5);
	        table.addCell(cell);
	    }

	    private PdfPCell textCell(Object value, Font font) {
	        PdfPCell cell = new PdfPCell(new Phrase(
	            value == null ? "" : value.toString(), font
	        ));
	        cell.setPadding(4);
	        return cell;
	    }

	    private PdfPCell amountCell(double value, Font font) {
	        PdfPCell cell = new PdfPCell(
	            new Phrase(String.format("%.2f", value), font)
	        );
	        cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
	        cell.setPadding(4);
	        return cell;
	    }

	    private double parse(Object o) {
	        if (o == null) return 0;
	        return Double.parseDouble(o.toString());
	    }
}
