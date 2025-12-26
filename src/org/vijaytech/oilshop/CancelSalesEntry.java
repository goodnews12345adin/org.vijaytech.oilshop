package org.vijaytech.oilshop;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.compiere.model.MOrder;
import org.compiere.process.DocAction;
import org.compiere.util.DB;
import org.json.JSONObject;

public class CancelSalesEntry extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ================================
    // LOAD SALES ENTRY LIST
    // ================================
    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Properties ctx = null;

        if (session != null) {
            ctx = (Properties) session.getAttribute("ctx");
        }

        if (ctx == null) {
            resp.sendRedirect("userlogin.jsp?error=session_expired");
            return;
        }

        List<String> salesList = new ArrayList<>();

        String sql =
            "SELECT DocumentNo " +
            "FROM C_Order " +
            "WHERE IsSOTrx='Y' " +
            "AND IsActive='Y' " +
            "AND DocStatus IN ('DR','IP','CO') " +
            "ORDER BY Created DESC";

        try (PreparedStatement ps =
                     DB.prepareStatement(sql, null);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                salesList.add(rs.getString("documentno"));
            }

        } catch (Exception e) {
            req.setAttribute("error", "Failed to load sales entries");
        }

        req.setAttribute("salesList", salesList);
        req.getRequestDispatcher("pages/cancelSalesEntry.jsp")
           .forward(req, resp);
    }

    // ================================
    // CANCEL SALES ENTRY
    // ================================
    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        JSONObject json = new JSONObject();

        HttpSession session = req.getSession(false);
        Properties ctx = (session != null) ? (Properties) session.getAttribute("ctx") : null;

        if (ctx == null) {
            json.put("status", "error");
            json.put("message", "Session expired");
            resp.getWriter().write(json.toString());
            return;
        }

        String documentNo = req.getParameter("documentNo");
        System.out.println("document no :" + documentNo);

        if (documentNo == null || documentNo.trim().isEmpty()) {
            json.put("status", "error");
            json.put("message", "Sales Order selection is required");
            resp.getWriter().write(json.toString());
            return;
        }

        int orderId = 0;

        String sql =
            "SELECT C_Order_ID FROM C_Order " +
            "WHERE DocumentNo=? AND IsSOTrx='Y' AND IsActive='Y'";

        try (PreparedStatement ps = DB.prepareStatement(sql, null)) {

            ps.setString(1, documentNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    orderId = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            json.put("status", "error");
            json.put("message", "Database error");
            resp.getWriter().write(json.toString());
            return;
        }

        if (orderId == 0) {
            json.put("status", "error");
            json.put("message", "Sales Order not found");
            resp.getWriter().write(json.toString());
            return;
        }

        try {
            MOrder order = new MOrder(ctx, orderId, null);

            if ("CO".equals(order.getDocStatus()) && order.isProcessed()) {
                order.setDocAction(DocAction.ACTION_Void);
                if (!order.processIt(DocAction.ACTION_Void)) {
                    throw new Exception(order.getProcessMsg());
                }
            } else {
                order.setDocStatus(DocAction.STATUS_Voided);
            }

            order.saveEx();

            json.put("status", "success");
            json.put("message", "Sales Order " + documentNo + " cancelled successfully");

        } catch (Exception e) {
            json.put("status", "error");
            json.put("message", "Cancel failed: " + e.getMessage());
        }

        resp.getWriter().write(json.toString());
    }

}
