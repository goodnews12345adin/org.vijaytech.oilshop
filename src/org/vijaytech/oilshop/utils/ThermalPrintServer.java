package org.vijaytech.oilshop.utils;

import org.compiere.util.DB;
import org.vijaytech.oilshop.utils.TvsRawPdfPrinter.Item;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class ThermalPrintServer {

    public static void printGstBill(int orderId) {

        PreparedStatement ps = null;
        ResultSet rs = null;

        PreparedStatement psLine = null;
        ResultSet rsLine = null;

        PreparedStatement psTax = null;
        ResultSet rsTax = null;

        try {
            /* ================= HEADER ================= */

            String sqlHeader =
                    "SELECT o.DocumentNo, o.DateOrdered " +
                    "FROM C_Order o " +
                    "WHERE o.C_Order_ID = ?";

            ps = DB.prepareStatement(sqlHeader, null);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();

            String billNo = "";
            Timestamp billDate = null;

            if (rs.next()) {
                billNo = rs.getString("DocumentNo");
                billDate = rs.getTimestamp("DateOrdered");
            }

            DB.close(rs, ps);

            /* ================= ITEMS (Line Amount = Gross) ================= */

            String sqlLines =
                    "SELECT p.Name, p.HSNCode, " +
                    "       ol.QtyOrdered, " +
                    "       ol.PriceActual, " +
                    "       ol.LineNetAmt AS LineAmtInclTax " +
                    "FROM C_OrderLine ol " +
                    "JOIN M_Product p ON p.M_Product_ID = ol.M_Product_ID " +
                    "WHERE ol.C_Order_ID = ?";

            psLine = DB.prepareStatement(sqlLines, null);
            psLine.setInt(1, orderId);
            rsLine = psLine.executeQuery();

            List<Item> items = new ArrayList<>();

            double grossTotal = 0;

            while (rsLine.next()) {

                String pname = rsLine.getString("Name");
                String hsn   = rsLine.getString("HSNCode");
                if (hsn == null) hsn = "";

                double qty  = rsLine.getDouble("QtyOrdered");
                double rate = rsLine.getDouble("PriceActual");

                // ✅ Line Amount already includes GST
                double lineAmtInclTax = rsLine.getDouble("LineAmtInclTax");

                // ✅ Create item
                Item it = new Item(pname, hsn, qty, rate, false);

                // ✅ Override amount with iDempiere LineNetAmt
                it.amount = lineAmtInclTax;

                items.add(it);

                grossTotal += lineAmtInclTax;
            }

            DB.close(rsLine, psLine);

            /* ================= GST BREAKUP (Exact Order Tax Tab) ================= */

            String sqlTax =
                    "SELECT t.Name AS TaxName, " +
                    "       ot.TaxBaseAmt, " +
                    "       ot.TaxAmt " +
                    "FROM C_OrderTax ot " +
                    "JOIN C_Tax t ON t.C_Tax_ID = ot.C_Tax_ID " +
                    "WHERE ot.C_Order_ID = ?";

            psTax = DB.prepareStatement(sqlTax, null);
            psTax.setInt(1, orderId);
            rsTax = psTax.executeQuery();

            double baseTotal = 0;
            double cgstAmt = 0;
            double sgstAmt = 0;

            while (rsTax.next()) {

                String taxName = rsTax.getString("TaxName");

                double baseAmt = rsTax.getDouble("TaxBaseAmt");
                double taxAmt  = rsTax.getDouble("TaxAmt");

                baseTotal += baseAmt;

                if (taxName.contains("CGST")) {
                    cgstAmt += taxAmt;
                }
                if (taxName.contains("SGST")) {
                    sgstAmt += taxAmt;
                }
            }

            DB.close(rsTax, psTax);

            /* ================= PRINT ================= */

            SimpleDateFormat df = new SimpleDateFormat("dd-MM-yyyy HH:mm");

            TvsRawPdfPrinter.printBill(
                    "THIRU SENTHILATHIPATHI OIL STORE",
                    "33AFFPR4639J1Z6",
                    "22422574000176",
                    billNo,
                    df.format(billDate),
                    items,
                    baseTotal,
                    cgstAmt,
                    sgstAmt,
                    grossTotal
            );

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DB.close(rs, ps);
            DB.close(rsLine, psLine);
            DB.close(rsTax, psTax);
        }
    }
}
