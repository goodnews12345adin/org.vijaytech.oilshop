package org.vijaytech.oilshop;

import java.io.IOException; 
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.compiere.model.MSysConfig;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.compiere.util.Util;

public class UserLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Helper method to set default context (fallback)
    private Properties setiDempiereContext(HttpServletRequest request) {
        HttpSession session = request.getSession(true);  // Create new session if missing
        Properties ctx = new Properties();               // Avoid sharing Env.getCtx()
        Env.setCtx(ctx);

        int clientID = MSysConfig.getIntValue("CLIENT_ID", 1000000);
        int userID   = 0;   // Hardcoded fallback
        int roleID   = 1000015;   // Hardcoded fallback
        int orgList    = 0;   // Hardcoded fallback

        Env.setContext(ctx, Env.AD_CLIENT_ID, clientID);
        Env.setContext(ctx, Env.AD_USER_ID, userID);
        Env.setContext(ctx, Env.AD_ROLE_ID, roleID);
//        Env.setContext(ctx, Env.AD_ORG_ID, orgList);

        return ctx;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Invalidate old session
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) oldSession.invalidate();
        System.out.println("Start");
        // Create new session and set timeout
        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(60 * 60 * 24); // 24 hours in seconds

        Properties ctx = setiDempiereContext(request);     
        
        Env.setCtx(ctx);
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // Validate user credentials
            String sql = "SELECT AD_User_ID FROM AD_User WHERE Name = ? AND Password = ? AND IsActive = 'Y'";
            pstmt = DB.prepareStatement(sql, null);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                int userID = rs.getInt("AD_User_ID");
                int clientID = MSysConfig.getIntValue("CLIENT_ID", 1000000);
                int roleID = MSysConfig.getIntValue("MOBWEB_ROLE_ID", 1000015, clientID);
                int orgID =0;
                // ✅ Load active organizations
                List<Organization> orgList = new ArrayList<>();
                String sqlOrg = "SELECT AD_Org_ID, Name FROM AD_Org WHERE AD_Client_ID = ? AND IsActive = 'Y'";
                PreparedStatement pstmt1 = DB.prepareStatement(sqlOrg, null);
                pstmt1.setInt(1, clientID);
                ResultSet rs1 = pstmt1.executeQuery();

                while (rs1.next()) {
                     orgID = 1000000;
//                    System.out.println("orgID"+orgID);
                    String orgName = rs1.getString("Name");
                    orgList.add(new Organization(orgID, orgName));
                }

                rs1.close();
                pstmt1.close();


                // Set context values
                Env.setContext(ctx, Env.AD_CLIENT_ID, clientID);
                Env.setContext(ctx, Env.AD_USER_ID, userID);
                Env.setContext(ctx, Env.AD_ROLE_ID, roleID);
//                Env.setContext(ctx, Env.AD_ORG_ID, orgList);

                // Save context to session
                session.setAttribute("ctx", ctx);
                session.setAttribute("AD_Client_ID", clientID);
                session.setAttribute("AD_User_ID", userID);
                session.setAttribute("AD_Role_ID", roleID);
                session.setAttribute("orgList", orgList);
                session.setAttribute("AD_Org_ID", orgID);
                System.out.println(orgID);

                response.sendRedirect("pages/dashboard.jsp");
            } else {
                setiDempiereContext(request);
                response.sendRedirect("pages/loginpage.jsp?error=1");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            setiDempiereContext(request);
            response.getWriter().println("Database Error: " + e.getMessage());
        } finally {
            DB.close(rs, pstmt);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        setiDempiereContext(request);
        response.sendRedirect("pages/loginpage.jsp");
    }
}
