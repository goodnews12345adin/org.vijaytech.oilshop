package org.vijaytech.textile.utils;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class InvoicePDFServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String file = req.getParameter("file");
        String path = req.getServletContext().getRealPath("/invoices/" + file);

        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", "inline; filename=" + file);

        Files.copy(Paths.get(path), resp.getOutputStream());
    }
}
