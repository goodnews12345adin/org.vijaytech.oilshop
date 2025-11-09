package org.vijaytech.textile;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.compiere.print.ReportEngine;
import org.compiere.model.MQuery;
import org.compiere.model.PrintInfo;
import org.compiere.print.MPrintFormat;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.compiere.util.Language;

public class PrintPurchaseReportServlet extends HttpServlet {
	
	   private static final int PAGE_SIZE = 200; // Rows per page in detail mode

	    @Override
	    protected void doGet(HttpServletRequest request, HttpServletResponse response)
	            throws ServletException, IOException {

	        /** --- 1. Read web params --- */
	    	 HttpSession session = request.getSession(false);

		        // 🔒 Check login/session
		        if (session == null || session.getAttribute("ctx") == null) {
		            response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
		            return;
		        }

		            Properties ctx = (Properties) session.getAttribute("ctx");

	        if (ctx == null) ctx = Env.getCtx();
	        System.out.println("data income ");
	        String type = val(request.getParameter("type"));     // sales | purchase
	        String from = val(request.getParameter("from"));     // yyyy-MM-dd
	        String to   = val(request.getParameter("to"));       // yyyy-MM-dd
	        String org  = val(request.getParameter("org"));      // optional AD_Org_ID
	        String bp   = val(request.getParameter("bp"));       // optional C_BPartner_ID
	        boolean summary = "Y".equalsIgnoreCase(val(request.getParameter("summary")));
	        int page = parseInt(val(request.getParameter("page")), 1);
	        if (page < 1) page = 1;

	        if (!"sales".equalsIgnoreCase(type) && !"purchase".equalsIgnoreCase(type)) {
	            type = "sales"; // default
	        }

	        /** --- 2. Build SQL --- */
	        boolean isSOTrx = "sales".equalsIgnoreCase(type);
	        StringBuilder sql = new StringBuilder();

	        if (summary) {
	            sql.append("SELECT i.DateInvoiced, bp.Name AS BPartner, p.Name AS Product, ")
	               .append("SUM(il.QtyInvoiced) AS Qty, AVG(il.PriceActual) AS Price, SUM(il.LineNetAmt) AS Amount ")
	               .append("FROM C_Invoice i ")
	               .append("JOIN C_InvoiceLine il ON (i.C_Invoice_ID=il.C_Invoice_ID) ")
	               .append("LEFT JOIN C_BPartner bp ON (i.C_BPartner_ID=bp.C_BPartner_ID) ")
	               .append("LEFT JOIN M_Product p ON (il.M_Product_ID=p.M_Product_ID) ")
	               .append("WHERE i.IsSOTrx=? AND i.DocStatus IN ('CO','CL') ")
	               .append("AND i.DateInvoiced BETWEEN ? AND ? ");
	            if (org != null) sql.append("AND i.AD_Org_ID=? ");
	            if (bp != null)  sql.append("AND i.C_BPartner_ID=? ");
	            sql.append("GROUP BY i.DateInvoiced, bp.Name, p.Name ")
	               .append("ORDER BY i.DateInvoiced, bp.Name, p.Name ");
	        } else {
	            sql.append("SELECT i.DateInvoiced, i.DocumentNo, bp.Name AS BPartner, p.Name AS Product, ")
	               .append("il.QtyInvoiced AS Qty, il.PriceActual AS Price, il.LineNetAmt AS Amount ")
	               .append("FROM C_Invoice i ")
	               .append("JOIN C_InvoiceLine il ON (i.C_Invoice_ID=il.C_Invoice_ID) ")
	               .append("LEFT JOIN C_BPartner bp ON (i.C_BPartner_ID=bp.C_BPartner_ID) ")
	               .append("LEFT JOIN M_Product p ON (il.M_Product_ID=p.M_Product_ID) ")
	               .append("WHERE i.IsSOTrx=? AND i.DocStatus IN ('CO','CL') ")
	               .append("AND i.DateInvoiced BETWEEN ? AND ? ");
	            if (org != null) sql.append("AND i.AD_Org_ID=? ");
	            if (bp != null)  sql.append("AND i.C_BPartner_ID=? ");
	            sql.append("ORDER BY i.DateInvoiced, i.DocumentNo, p.Name ")
	               .append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
	        }

	        /** --- 3. Execute SQL & Stream HTML --- */
	        try (Connection conn = DB.getConnectionRW();
	             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

	            int idx = 1;
	            ps.setString(idx++, isSOTrx ? "Y" : "N");
	            ps.setTimestamp(idx++, toTs(from));
	            ps.setTimestamp(idx++, toTsInclusiveEnd(to));
	            if (org != null) ps.setInt(idx++, Integer.parseInt(org));
	            if (bp != null)  ps.setInt(idx++, Integer.parseInt(bp));
	            if (!summary) {
	                int offset = (page - 1) * PAGE_SIZE;
	                ps.setInt(idx++, offset);
	                ps.setInt(idx++, PAGE_SIZE);
	            }

	            try (ResultSet rs = ps.executeQuery()) {
	                response.setContentType("text/html; charset=UTF-8");
	                try (ServletOutputStream out = response.getOutputStream()) {

	                    out.println("<html><head><meta charset='UTF-8'>");
	                    out.println("<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css' rel='stylesheet'>");
	                    out.println("<title>" + esc(type) + " Report</title></head><body class='p-3'>");

	                    out.println("<div class='container-fluid'>");
	                    out.println("<h4 class='mb-3 text-capitalize'>" + esc(type) + " Report</h4>");

	                    out.println("<div class='table-responsive'><table class='table table-sm table-striped table-bordered'>");

	                    if (summary) {
	                        out.println("<thead class='table-light'><tr>" +
	                                th("Date") + th("Business Partner") + th("Product") +
	                                th("Qty") + th("Price") + th("Amount") + "</tr></thead><tbody>");
	                        while (rs.next()) {
	                            out.println("<tr>" +
	                                    td(fmtDate(rs.getTimestamp("DateInvoiced"))) +
	                                    td(esc(rs.getString("BPartner"))) +
	                                    td(esc(rs.getString("Product"))) +
	                                    td(rs.getBigDecimal("Qty")) +
	                                    td(rs.getBigDecimal("Price")) +
	                                    td(rs.getBigDecimal("Amount")) +
	                                    "</tr>");
	                        }
	                    } else {
	                        out.println("<thead class='table-light'><tr>" +
	                                th("Date") + th("Doc No") + th("Business Partner") +
	                                th("Product") + th("Qty") + th("Price") + th("Amount") + "</tr></thead><tbody>");
	                        while (rs.next()) {
	                            out.println("<tr>" +
	                                    td(fmtDate(rs.getTimestamp("DateInvoiced"))) +
	                                    td(esc(rs.getString("DocumentNo"))) +
	                                    td(esc(rs.getString("BPartner"))) +
	                                    td(esc(rs.getString("Product"))) +
	                                    td(rs.getBigDecimal("Qty")) +
	                                    td(rs.getBigDecimal("Price")) +
	                                    td(rs.getBigDecimal("Amount")) +
	                                    "</tr>");
	                        }
	                    }
	                    out.println("</tbody></table></div>");

	                    if (!summary) {
	                        int prev = Math.max(1, page - 1);
	                        int next = page + 1;
	                        out.println("<a class='btn btn-sm btn-secondary me-2' href='?type=" + type + "&from=" + from + "&to=" + to + "&page=" + prev + "'>Prev</a>");
	                        out.println("<a class='btn btn-sm btn-secondary' href='?type=" + type + "&from=" + from + "&to=" + to + "&page=" + next + "'>Next</a>");
	                    }

	                    out.println("</div></body></html>");
	                }
	            }
	        } catch (Exception e) {
	            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
	            response.setContentType("text/plain; charset=UTF-8");
	            response.getWriter().println("Error: " + e.getMessage());
	        }
	    }

	    /** --- Helpers --- */

	    private static String val(String s) { return (s == null || s.trim().isEmpty()) ? null : s.trim(); }
	    private static int parseInt(String s, int d) { try { return Integer.parseInt(s); } catch (Exception e){ return d; } }
	    private static Timestamp toTs(String ymd) { return Timestamp.valueOf(LocalDate.parse(ymd).atStartOfDay()); }
	    private static Timestamp toTsInclusiveEnd(String ymd) {
	        return Timestamp.valueOf(LocalDate.parse(ymd).plusDays(1).atStartOfDay().minusNanos(1_000_000));
	    }
	    private static String esc(Object o) { return o == null ? "" :
	            o.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
	            .replace("\"","&quot;").replace("'","&#39;"); }
	    private static String th(String s){ return "<th>" + esc(s) + "</th>"; }
	    private static String td(Object o){ return "<td>" + esc(o) + "</td>"; }
	    private static String fmtDate(Timestamp ts){ return ts == null ? "" : ts.toLocalDateTime().toLocalDate().toString(); }
	}
	