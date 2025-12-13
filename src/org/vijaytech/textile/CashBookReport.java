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
	            Properties ctx = (Properties) session.getAttribute("ctx");

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
	         request.setAttribute("orgList", orgList);


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



	    protected void doPost(HttpServletRequest request, HttpServletResponse response)
	            throws ServletException, IOException {

	        // POST = generate PDF
	        try {

	            String orgId = request.getParameter("ad_org_id");
	            String bankId = request.getParameter("bank_id");
	            String bpId = request.getParameter("bp_id");
	            String from = request.getParameter("from_date");
	            String to = request.getParameter("to_date");

	            List<Map<String,Object>> results = loadCashBook(orgId, bankId, bpId, from, to);

	            response.setContentType("application/pdf");
	            response.setHeader("Content-Disposition", "attachment; filename=CashBookReport.pdf");

	            OutputStream out = response.getOutputStream();
	            createPDF(results, out);
	            out.flush();

	        } catch (Exception ex) {
	            throw new ServletException("Error generating PDF", ex);
	        }
	    }

	  


	    private List<Map<String,Object>> loadCashBook(
	            String orgId, String bankId, String bpId, String from, String to) {

	    	StringBuilder sql = new StringBuilder();
	    	sql.append("SELECT p.DateTrx, p.DocumentNo, bp.Name AS bpname, ")
	    	   .append("ev.Name AS accounthead, p.Description, ")
	    	   .append("CASE WHEN p.IsReceipt='Y' THEN p.PayAmt ELSE 0 END AS receipt, ")
	    	   .append("CASE WHEN p.IsReceipt='N' THEN p.PayAmt ELSE 0 END AS payment ")
	    	   .append("FROM C_Payment p ")
	    	   .append("LEFT JOIN C_BPartner bp ON bp.C_BPartner_ID = p.C_BPartner_ID ")
	    	   .append("LEFT JOIN C_ElementValue ev ON ev.C_ElementValue_ID = p.C_ElementValue_ID ")
	    	   .append("WHERE p.IsActive='Y' ")
	    	   .append("AND p.AD_Org_ID = ").append(orgId).append(" ");

	    	if (bankId != null && !bankId.isEmpty()) {
	    	    sql.append("AND p.C_BankAccount_ID = ").append(bankId).append(" ");
	    	}

	        if (bpId != null && !bpId.isEmpty()) {
	            sql.append("AND p.C_BPartner_ID = ").append(bpId).append(" ");
	        }

	        if (from != null && !from.isEmpty()) {
	            sql.append("AND p.DateTrx >= '").append(from).append(" 00:00:00' ");
	        }
	        if (to != null && !to.isEmpty()) {
	            sql.append("AND p.DateTrx <= '").append(to).append(" 23:59:59' ");
	        }

	        sql.append("ORDER BY p.DateTrx ASC");

	        // Execute SQL
	        List<List<Object>> raw = DB.getSQLArrayObjectsEx(null, sql.toString());

	        // Convert to map list
	        List<Map<String,Object>> rows = new ArrayList<>();

	        for (List<Object> r : raw) {
	            Map<String,Object> m = new HashMap<>();

	            m.put("datetrx",     r.get(0));
	            m.put("documentno",  r.get(1));
	            m.put("bpname",      r.get(2));
	            m.put("accounthead", r.get(3));
	            m.put("description", r.get(4));
	            m.put("receipt",     r.get(5));
	            m.put("payment",     r.get(6));

	            rows.add(m);
	        }

	        // Running balance
	        double balance = 0;
	        for (Map<String,Object> row : rows) {

	            double receipt = 0;
	            double payment = 0;

	            if (row.get("receipt") != null)
	                receipt = Double.parseDouble(row.get("receipt").toString());

	            if (row.get("payment") != null)
	                payment = Double.parseDouble(row.get("payment").toString());

	            balance += (receipt - payment);
	            row.put("balance", balance);
	        }

	        return rows;
	    }



	    // -------------------------------------------------------------
	    // PDF GENERATION
	    // -------------------------------------------------------------
	    private void createPDF(List<Map<String,Object>> rows, OutputStream out) throws Exception {

	        Document doc = new Document(PageSize.A4.rotate());
	        PdfWriter.getInstance(doc, out);
	        doc.open();

	        Font titleFont = new Font(Font.HELVETICA, 16, Font.BOLD);
	        Paragraph title = new Paragraph("Cash Book Report", titleFont);
	        title.setAlignment(Element.ALIGN_CENTER);
	        doc.add(title);
	        doc.add(new Paragraph("\n"));

	        PdfPTable table = new PdfPTable(7);
	        table.setWidthPercentage(100);

	        addHeader(table, "Date");
	        addHeader(table, "Document No");
	        addHeader(table, "BP Name");
	        addHeader(table, "Account Head");
	        addHeader(table, "Description");
	        addHeader(table, "Receipt");
	        addHeader(table, "Payment");

	        for (Map<String,Object> row : rows) {
	            table.addCell(String.valueOf(row.get("datetrx")));
	            table.addCell(String.valueOf(row.get("documentno")));
	            table.addCell(row.get("bpname") == null ? "" : row.get("bpname").toString());
	            table.addCell(row.get("accounthead") == null ? "" : row.get("accounthead").toString());
	            table.addCell(row.get("description") == null ? "" : row.get("description").toString());
	            table.addCell(row.get("receipt").toString());
	            table.addCell(row.get("payment").toString());
	        }

	        doc.add(table);
	        doc.close();
	    }

	    private void addHeader(PdfPTable table, String text) {
	        PdfPCell cell = new PdfPCell(new Phrase(text));
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	        table.addCell(cell);
	    }
}
