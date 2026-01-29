package org.vijaytech.oilshop;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Properties;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MOrder;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MOrder;

public class CancelSalesEntry extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        PrintWriter out = resp.getWriter();

        try {
            // 1. Check Session
            if (session == null || session.getAttribute("ctx") == null) {
                // In AJAX, return JSON error instead of redirect
                out.write("{\"status\":\"error\", \"message\":\"Session expired. Please login again.\"}");
                return;
            }

            Properties ctx = (Properties) session.getAttribute("ctx");
            if (ctx == null) ctx = Env.getCtx();

            // Ensure mandatory context
            if (Env.getAD_Client_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Client_ID", 1000000);
            if (Env.getAD_Org_ID(ctx) == 0)
                Env.setContext(ctx, "#AD_Org_ID", 1000000);

            // 2. Get Document No from Request
            String documentNo = req.getParameter("documentNo");
            if (documentNo == null || documentNo.trim().isEmpty()) {
                throw new AdempiereException("Document No is missing");
            }

            // 3. Find Order ID based on DocumentNo
            int orderId = DB.getSQLValue(null,
                "SELECT C_Order_ID FROM C_Order WHERE DocumentNo = ? AND AD_Client_ID = ?",
                documentNo, Env.getAD_Client_ID(ctx));

            if (orderId <= 0) {
                throw new AdempiereException("Order not found: " + documentNo);
            }

            // 4. Load Order using TF_MOrder
            TF_MOrder ord = new TF_MOrder(ctx, orderId, null);

            // 5. Check Status before cancelling
            // We usually cannot Void an order that is already Voided, Reversed, or Closed.
            if (MOrder.DOCSTATUS_Voided.equals(ord.getDocStatus()) ||
                MOrder.DOCSTATUS_Reversed.equals(ord.getDocStatus()) ||
                MOrder.DOCSTATUS_Closed.equals(ord.getDocStatus())) {
                throw new AdempiereException("Order is already closed or voided.");
            }
            
            // We also typically don't Void a Drafted order; we just delete it or ignore it. 
            // But for POS logic, usually it is "Completed".
            if (!MOrder.DOCSTATUS_Completed.equals(ord.getDocStatus()) && 
                !MOrder.DOCSTATUS_Drafted.equals(ord.getDocStatus())) {
                 throw new AdempiereException("Cannot cancel order in status: " + ord.getDocStatus());
            }

            // 6. Void Logic (Reversing/Voiding is safer than hard delete in ERP)
            // If the order is Completed, we Void it to reverse inventory movement.
            // If it is Drafted, we can try to delete it, but Void is a safer generic action.
            
            ord.setDocAction(MOrder.DOCACTION_Void);
            
            if (!ord.processIt(MOrder.DOCACTION_Void)) {
                 // If Void fails (e.g. if it has closed shipments/invoices that can't be voided), try Close
                 ord.setDocAction(MOrder.DOCACTION_Close);
                 if(!ord.processIt(MOrder.DOCACTION_Close)) {
                     throw new AdempiereException("Could not Void or Close order: " + ord.getProcessMsg());
                 }
            }
            ord.saveEx();

            System.out.println("Order Cancelled/Voided: " + documentNo);

            // 7. Return Success
            JSONObject result = new JSONObject();
            result.put("status", "success");
            result.put("message", "Order cancelled successfully.");
            out.write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown Error";
            out.write("{\"status\":\"error\", \"message\":\"" + errorMsg + "\"}");
        }
    }
}