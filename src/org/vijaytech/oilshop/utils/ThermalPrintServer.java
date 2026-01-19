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
        PreparedStatement ps2 = null;
        ResultSet rs = null;
        ResultSet rs2 = null;

        try {
            /* ================= HEADER ================= */
            String sql =
                    "SELECT o.documentno, o.dateordered " +
                    "FROM c_order o " +
                    "WHERE o.c_order_id = ?";

            ps = DB.prepareStatement(sql, null);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();

            String billNo = "";
            Timestamp billDate = null;

            if (rs.next()) {
                billNo = rs.getString("documentno");
                billDate = rs.getTimestamp("dateordered");
            }

            DB.close(rs, ps);

            /* ================= ITEMS ================= */
            String sql2 =
                    "SELECT p.name, p.hsncode, ol.qtyordered, ol.priceactual, p.GSTRate, ol.discount " +
                    "FROM c_orderline ol " +
                    "LEFT JOIN m_product p ON p.m_product_id = ol.m_product_id " +
                    "WHERE ol.c_order_id = ?";

            ps2 = DB.prepareStatement(sql2, null);
            ps2.setInt(1, orderId);
            rs2 = ps2.executeQuery();

            List<Item> items = new ArrayList<>();
            double gstRate = 0;   // single slab
            double subTotal = 0;
            double discount = 0;
            while (rs2.next()) {
                String pname = rs2.getString("name");
                String hsn   = rs2.getString("hsncode");
                if (hsn == null) hsn = "";

                double qty  = rs2.getDouble("qtyordered");
                double rate = rs2.getDouble("priceactual");

                // take GST rate only once (single slab assumption)
                if (gstRate == 0) {
                    gstRate = rs2.getDouble("GSTRate");
                }
                if (discount == 0) {
                	discount = rs2.getDouble("discount");
                }

                Item it = new Item(pname, hsn, qty, rate, false,discount);
                items.add(it);

                subTotal += it.amount;
            }

            DB.close(rs2, ps2);

            /* ================= PRINT ================= */
            SimpleDateFormat df = new SimpleDateFormat("dd-MM-yyyy HH:mm");

            TvsRawPdfPrinter.printBill(
                    "SKV OIL STORE",
                    "33ABCDE1234F1Z5",   // GSTIN
                    billNo,
                    df.format(billDate),
                    items,
                    gstRate
            );

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DB.close(rs, ps);
            DB.close(rs2, ps2);
        }
    }
}