package org.vijaytech.oilshop;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.compiere.model.Query;
import org.compiere.util.Env;
import org.compiere.util.Trx;
import org.json.JSONArray;
import org.json.JSONObject;
import org.syvasoft.tallyfrontcrusher.model.TF_MBPartner; 

public class BPManageServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("ctx") == null) {
            if ("list".equalsIgnoreCase(request.getParameter("action"))) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"error\":\"session_expired\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/userlogin.jsp?error=session_expired");
            return;
        }

        Properties ctx = (Properties) session.getAttribute("ctx");
        Env.setCtx(ctx);

        // Ensure Context Keys
        if (Env.getAD_Client_ID(ctx) == 0) Env.setContext(ctx, "#AD_Client_ID", 1000000);
        if (Env.getAD_Org_ID(ctx) == 0)    Env.setContext(ctx, "#AD_Org_ID", 1000000);
        if (Env.getAD_User_ID(ctx) == 0)   Env.setContext(ctx, "#AD_User_ID", 100);
        if (Env.getContextAsInt(ctx, "#AD_Role_ID") == 0) Env.setContext(ctx, "#AD_Role_ID", 102);

        String action = request.getParameter("action");

        if ("list".equalsIgnoreCase(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                List<TF_MBPartner> bpList = new Query(ctx, TF_MBPartner.Table_Name, "IsActive='Y'", null)
                        .setClient_ID()
                        .setOrderBy("Created DESC")
                        .list();

                JSONArray arr = new JSONArray();
                for (TF_MBPartner bp : bpList) {
                    JSONObject obj = new JSONObject();
                    obj.put("id", bp.get_ID());
                    obj.put("name", bp.getName());
                    obj.put("value", bp.getValue());
                    obj.put("isCustomer", bp.isCustomer());
                    obj.put("isVendor", bp.isVendor());
                    
                    // ✅ Added new fields to JSON response
                    obj.put("location", bp.getDesignation());
                    obj.put("taxId", bp.getTaxID());
                    obj.put("phone", bp.getPhone());
                    
                    arr.put(obj);
                }
                response.getWriter().write(arr.toString());
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(500);
                response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            }
            return; 
        }

        RequestDispatcher rd = request.getRequestDispatcher("/pages/bp_manager.jsp");
        rd.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Properties ctx = (session != null) ? (Properties) session.getAttribute("ctx") : null;

        if (ctx == null) {
            response.setStatus(401);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }
        
        // Set Context for current thread
        Env.setCtx(ctx);
        
        // Ensure Context IDs (Safety Net)
        if (Env.getAD_Client_ID(ctx) == 0) Env.setContext(ctx, "#AD_Client_ID", 1000000);
        if (Env.getAD_Org_ID(ctx) == 0)    Env.setContext(ctx, "#AD_Org_ID", 1000000);

        Trx trx = null;
        String trxName = Trx.createTrxName("BPSave");

        try {
            StringBuilder sb = new StringBuilder();
            String line;
            try (BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) { sb.append(line); }
            }

            JSONObject root = new JSONObject(sb.toString());
            String name = root.optString("name").trim();
            String value = root.optString("value").trim();
            
            // ✅ Extract new fields
            String location = root.optString("location").trim();
            String taxId = root.optString("taxId").trim();
            String phone = root.optString("phone").trim();
            
            boolean isCustomer = root.optBoolean("isCustomer");
            boolean isVendor = root.optBoolean("isVendor");

            if (name.isEmpty()) {
                response.setStatus(400);
                response.getWriter().write("{\"error\":\"Name is mandatory.\"}");
                return;
            }

            // ✅ ✅ VALIDATION BLOCK START ✅ ✅
            
            // 1. Validate Phone Number
            // Logic: Optional '+', followed by 10-15 digits, spaces, or hyphens allowed.
            if (!phone.isEmpty()) {
                if (!phone.matches("^[+]?[0-9\\-\\s]{10,15}$")) {
                    response.setStatus(400);
                    response.getWriter().write("{\"error\":\"Invalid Phone Number. Please enter a valid number (10-15 digits).\"}");
                    return;
                }
            }

            // 2. Validate Tax ID
            // Logic: Alphanumeric characters and hyphens allowed. Length 5-30.
            // This accommodates GSTIN (15 chars) and other generic formats.
            if (!taxId.isEmpty()) {
                if (!taxId.matches("^[0-9A-Za-z\\-]{5,30}$")) {
                    response.setStatus(400);
                    response.getWriter().write("{\"error\":\"Invalid Tax ID. Must be 5-30 alphanumeric characters.\"}");
                    return;
                }
            }
            
            // ✅ ✅ VALIDATION BLOCK END ✅ ✅

            trx = Trx.get(trxName, true);

            TF_MBPartner bp = new TF_MBPartner(ctx, 0, trxName);
            
            // --- FIX FOR NULLPOINTER EXCEPTION ---
            // The Model's beforeSave() logic expects these fields.
            bp.setCity("Head Office");         
            bp.setC_Country_ID(208);          
            bp.setContactName(name);          
            bp.setAD_Org_ID(Env.getAD_Org_ID(ctx));
            // -----------------------------------

            bp.setName(name);
            if(!value.isEmpty()) bp.setValue(value);
            
            bp.setIsCustomer(isCustomer); 
            bp.setIsVendor(isVendor);
            bp.setIsActive(true);
            
            // ✅ Set new fields
            if (!location.isEmpty()) bp.setDesignation(location);
            if (!taxId.isEmpty()) bp.setTaxID(taxId);
            if (!phone.isEmpty()) bp.setPhone(phone);
            
            // Set BP Group
            int bpGroupID = new Query(ctx, "C_BP_Group", "IsDefault='Y'", trxName)
                    .setClient_ID()
                    .firstId();
            if (bpGroupID <= 0) {
                bpGroupID = new Query(ctx, "C_BP_Group", "", trxName)
                        .setClient_ID()
                        .firstId();
            }
            
            if (bpGroupID > 0) {
                bp.setC_BP_Group_ID(bpGroupID);
            } else {
                throw new Exception("No Business Partner Group found in System.");
            }
            
            bp.setSO_CreditLimit(BigDecimal.ZERO); 
            
            bp.saveEx(trxName);

            trx.commit(true);
            response.getWriter().write("{\"status\":\"success\",\"message\":\"Partner Created Successfully\"}");
            
        } catch (Exception e) {
            if (trx != null) trx.rollback();
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            if (trx != null) trx.close();
        }
    }
}