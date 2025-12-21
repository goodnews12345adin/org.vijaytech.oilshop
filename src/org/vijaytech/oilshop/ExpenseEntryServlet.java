package org.vijaytech.oilshop;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;

import org.compiere.util.DB;
import org.compiere.util.Env;
import org.vijaytech.model.TF_MPayment;
import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MAttachment;
import org.compiere.model.MBPartner;
import org.compiere.model.MBankAccount;
import org.compiere.model.MElementValue;
import org.compiere.model.MOrg;
import org.compiere.model.Query;
import org.compiere.process.DocAction;

public class ExpenseEntryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /********************************************************************
     *  GET METHOD
     *  Loads the JSP page with any needed reference lists.
     ********************************************************************/
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("ctx") == null) {
            response.sendRedirect("userlogin.jsp?error=session_expired");
            return;
        }

        Properties ctx = (Properties) session.getAttribute("ctx");

        try {

            // 1. ORG LIST
            List<MOrg> orgModelList = new Query(ctx, MOrg.Table_Name,
                    "IsActive='Y'", null)
                    .setClient_ID()
                    .list();
            List<Map<String,Object>> orgList = mapOrg(orgModelList);

            // 2. BANK ACCOUNT LIST
            List<MBankAccount> bankModelList = new Query(ctx, MBankAccount.Table_Name,
                    "IsActive='Y'", null)
                    .setClient_ID()
                    .list();
            List<Map<String,Object>> bankAccountList = mapBank(bankModelList);

            // 3. BUSINESS PARTNER LIST
            List<MBPartner> bpModelList = new Query(ctx, MBPartner.Table_Name,
                    "IsActive='Y' AND isCustomer ='Y' AND isVendor ='Y'", null)
                    .setClient_ID()
                    .list();
            List<Map<String,Object>> partnerList = mapBPartner(bpModelList);

            // 4. EXPENSE ACCOUNT LIST (AccountType = 'E')
            List<MElementValue> accModelList = new Query(ctx, MElementValue.Table_Name,
                    "AccountType='E' AND IsSummary='N' AND IsActive='Y'", null)
                    .setClient_ID()
                    .list();
            List<Map<String,Object>> expenseAccountList = mapExpenseAccount(accModelList);

            // 5. Tender List Manual
            List<Map<String,Object>> tenderList = new ArrayList<>();
            tenderList.add(Map.of("value","Cash","name","Cash"));
            tenderList.add(Map.of("value","Bank","name","Bank Transfer"));
            tenderList.add(Map.of("value","UPI","name","UPI"));

            // Set attributes for JSP
            request.setAttribute("orgList", orgList);
            request.setAttribute("bankAccountList", bankAccountList);
            request.setAttribute("partnerList", partnerList);
            request.setAttribute("expenseAccountList", expenseAccountList);
            request.setAttribute("tenderList", tenderList);

            request.getRequestDispatcher("pages/ExpenseEntry.jsp").forward(request, response);

        } catch (Exception ex) {
            ex.printStackTrace();
            throw new ServletException("Error loading Expense Entry page", ex);
        }
    }
    
 // ==============================
//  MAPPING HELPERS
//  Convert PO model list → List<Map<String,Object>>
// ==============================

private List<Map<String,Object>> mapOrg(List<MOrg> list) {
    List<Map<String,Object>> data = new ArrayList<>();
    for (MOrg o : list) {
        Map<String,Object> m = new HashMap<>();
        m.put("id", o.getAD_Org_ID());
        m.put("name", o.getName());
        data.add(m);
    }
    return data;
}

private List<Map<String,Object>> mapBank(List<MBankAccount> list) {
    List<Map<String,Object>> data = new ArrayList<>();
    for (MBankAccount b : list) {
        Map<String,Object> m = new HashMap<>();
        m.put("id", b.getC_BankAccount_ID());
        m.put("name", b.getAccountNo() + " - " + b.getName());
        data.add(m);
    }
    return data;
}

private List<Map<String,Object>> mapBPartner(List<MBPartner> list) {
    List<Map<String,Object>> data = new ArrayList<>();
    for (MBPartner bp : list) {
        Map<String,Object> m = new HashMap<>();
        m.put("id", bp.getC_BPartner_ID());
        m.put("name", bp.getName());
        data.add(m);
    }
    return data;
}

private List<Map<String,Object>> mapExpenseAccount(List<MElementValue> list) {
    List<Map<String,Object>> data = new ArrayList<>();
    for (MElementValue ev : list) {
        Map<String,Object> m = new HashMap<>();
        m.put("id", ev.getC_ElementValue_ID());
        m.put("name", ev.getValue() + " - " + ev.getName());
        data.add(m);
    }
    return data;
}


    /********************************************************************
     *  POST METHOD
     *  Saves the Header + Lines + Attachments
     ********************************************************************/
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("save".equalsIgnoreCase(action)) {
            saveExpense(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action.");
        }
    }

    /********************************************************************
     *  SAVE LOGIC
     ********************************************************************/
    private void saveExpense(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

    	  HttpSession session = req.getSession(false);
          if (session == null || session.getAttribute("ctx") == null) {
              resp.sendRedirect("userlogin.jsp?error=session_expired");
              return;
          }

          Properties ctx = (Properties) session.getAttribute("ctx");
          String trxName = null;
          int userId = Env.getAD_User_ID(ctx);
          if (Env.getAD_Client_ID(ctx) == 0)
              Env.setContext(ctx, "#AD_Client_ID", 1000000);
          if (Env.getAD_Org_ID(ctx) == 0)
              Env.setContext(ctx, "#AD_Org_ID", 1000000);
          if (Env.getAD_User_ID(ctx) == 0)
              Env.setContext(ctx, "#AD_User_ID", 100);
          if (Env.getContextAsInt(ctx, "#M_Warehouse_ID") == 0)
              Env.setContext(ctx, "#M_Warehouse_ID", 1000113);

          try {

              // --------------------------------------------------------------------
              // 1. Read Form Parameters
              // --------------------------------------------------------------------
              int AD_Org_ID = Env.getAD_Org_ID(ctx);

              String bpStr  = req.getParameter("c_bpartner_id");
              String accStr = req.getParameter("account_head_id");

              String bankStr = req.getParameter("bank_account_id");
              String docNo = req.getParameter("document_no");
              String dateStr = req.getParameter("transaction_date");
              String payAmtStr = req.getParameter("payment_amount");
              String tender = req.getParameter("tender_type");
              String desc = req.getParameter("description");

              // --------------------------------------------------------------------
              // 2. Normalize IDs: NEVER allow "" or null → convert to zero
              // --------------------------------------------------------------------
              int C_BPartner_ID = (bpStr == null || bpStr.trim().isEmpty()) ? 0 : Integer.parseInt(bpStr);
              int C_ElementValue_ID = (accStr == null || accStr.trim().isEmpty()) ? 0 : Integer.parseInt(accStr);
              int C_BankAccount_ID = Integer.parseInt(bankStr);

              // --------------------------------------------------------------------
              // 3. MUTUAL EXCLUSION RULE (business rule)
              // --------------------------------------------------------------------
              if (C_BPartner_ID > 0 && C_ElementValue_ID > 0) {
                  throw new ServletException("Select only ONE: Customer/Vendor OR Account Head.");
              }
              if (C_BPartner_ID == 0 && C_ElementValue_ID == 0) {
                  throw new ServletException("Customer/Vendor OR Account Head is mandatory.");
              }

              // Keep ONLY the selected one
              if (C_BPartner_ID > 0) {
                  C_ElementValue_ID = 0;    // ignore account head
              }
              if (C_ElementValue_ID > 0) {
                  C_BPartner_ID = 0;        // ignore partner
              }

              // --------------------------------------------------------------------
              // 4. Convert date and amount
              // --------------------------------------------------------------------
              Timestamp dateTrx = Timestamp.valueOf(dateStr.replace("T", " ") + ":00");
              BigDecimal payAmt = new BigDecimal(payAmtStr);

              // --------------------------------------------------------------------
              // 5. Prepare and save TF_MPayment
              // --------------------------------------------------------------------
              TF_MPayment pay = new TF_MPayment(ctx, 0, trxName);

              pay.setAD_Org_ID(AD_Org_ID);
              pay.setDateTrx(dateTrx);
              pay.setDateAcct(dateTrx);

              pay.setC_BankAccount_ID(C_BankAccount_ID);

              if (C_BPartner_ID > 0)
                  pay.setC_BPartner_ID(C_BPartner_ID);

              if (C_ElementValue_ID > 0)
                  pay.setC_ElementValue_ID(C_ElementValue_ID);
              pay.setC_Currency_ID(Env.getContextAsInt(ctx, "#C_Currency_ID"));
              if (pay.getC_Currency_ID() == 0)
                  pay.setC_Currency_ID(304);
              
              pay.setPayAmt(payAmt);
              pay.setTenderType("X");
              pay.setCashType(TF_MPayment.CASHTYPE_GeneralExpense);
              pay.setDescription(desc);

              if (docNo != null && !docNo.trim().isEmpty())
                  pay.setDocumentNo(docNo);

              // --------------------------------------------------------------------
              // 6. Draft → Save
              // --------------------------------------------------------------------
              pay.saveEx();

              // --------------------------------------------------------------------
              // 7. Complete the document
              // --------------------------------------------------------------------
              if (!pay.processIt(DocAction.ACTION_Complete)) {
                  throw new AdempiereException("Cannot complete document: " + pay.getProcessMsg());
              }

              pay.saveEx();

              // --------------------------------------------------------------------
              // 8. Redirect success
              // --------------------------------------------------------------------
              resp.sendRedirect("ExpenseEntryServlet?action=success&docno=" + pay.getDocumentNo());

          } catch (Exception ex) {
              ex.printStackTrace();
              req.setAttribute("error", ex.getMessage());
              req.getRequestDispatcher("/pages/ExpenseEntry.jsp").forward(req, resp);
          }
      }

    /********************************************************************
     *  Utility Functions
     ********************************************************************/
// -------------------------------------------------------------------------
// Helpers
// -------------------------------------------------------------------------

private int parseInt(String val) {
    try {
        return Integer.parseInt(val);
    } catch (Exception e) {
        return 0;
    }
}

private Timestamp parseDateTime(String dt) {
    try {
        // Input is: yyyy-MM-dd'T'HH:mm
        return Timestamp.valueOf(dt.replace("T", " ") + ":00");
    } catch (Exception e) {
        return new Timestamp(System.currentTimeMillis());
    }
}
}
