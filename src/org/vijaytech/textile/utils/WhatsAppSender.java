package org.vijaytech.textile.utils;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class WhatsAppSender {

    // TODO: set these constants (place them in properties instead of hardcoding in production)
    private static final String PHONE_ID = "YOUR_PHONE_ID"; // e.g. 102233... (from meta)
    private static final String ACCESS_TOKEN = "YOUR_ACCESS_TOKEN"; // from Meta
    private static final String API_URL = "https://graph.facebook.com/v17.0/" + PHONE_ID + "/messages";

    /**
     * Sends a document (PDF) to the given phone number using WhatsApp Cloud API.
     * phone must be in international format without '+' e.g. 9198xxxxxxx
     */
    public static void sendDocument(String phone, String publicPdfUrl, String caption) throws Exception {
        if (phone == null || phone.trim().length() == 0) throw new IllegalArgumentException("Missing phone");
        if (publicPdfUrl == null || publicPdfUrl.trim().length() == 0) throw new IllegalArgumentException("Missing pdf url");

        String payload = "{"
                + "\"messaging_product\":\"whatsapp\","
                + "\"to\":\"" + phone + "\","
                + "\"type\":\"document\","
                + "\"document\":{"
                +    "\"link\":\"" + publicPdfUrl + "\","
                +    (caption != null ? ("\"caption\":\"" + escapeJson(caption) + "\"") : "")
                + "}"
                + "}";

        URL url = new URL(API_URL);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Authorization", "Bearer " + ACCESS_TOKEN);
        con.setRequestProperty("Content-Type", "application/json");
        con.setDoOutput(true);

        byte[] out = payload.getBytes(StandardCharsets.UTF_8);
        OutputStream os = con.getOutputStream();
        os.write(out);
        os.flush();
        os.close();

        int code = con.getResponseCode();
        if (code >= 200 && code < 300) {
            // success
            System.out.println("WhatsApp document sent to " + phone + " url=" + publicPdfUrl + " response=" + code);
        } else {
            java.io.InputStream err = con.getErrorStream();
            String errMsg = err != null ? new java.util.Scanner(err).useDelimiter("\\A").next() : "no error";
            throw new RuntimeException("WhatsApp API error code=" + code + " msg=" + errMsg);
        }
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"");
    }
}