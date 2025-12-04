package org.vijaytech.textile.utils;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.InputStream;
import java.util.List;
import java.util.Collections;

public class WhatsAppSender {

    // --- Configuration Constants ---
    // NOTE: Replace this placeholder with your actual, non-expired JWT token.
    private static final String JWT_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImluZm9Ac21hcnRncm93dGhhaS5jb20iLCJyb2xlIjoiQWRtaW4iLCJjdXN0b21lcklkIjoiU21hcnQgR3Jvd3RoIEFJIiwiaWF0IjoxNzQ4NDk1OTQ5LCJleHAiOjE3ODAwNTM1NDl9.uIOUD-OLnqUZK41BuNFretia_BQP-phTWZafHwEteBY";
    private static final String API_ENDPOINT = "https://newapp.smartgrowthai.com/send/campaign";

    // Defaults for your invoice use-case (you can change these as needed)
    private static final String DEFAULT_TEMPLATE_ID   = "2330129374101343";     // from your example
    private static final String DEFAULT_API_CODE      = "undefined837069";   // your api code
    private static final String DEFAULT_CAMPAIGN_NAME = "newdemo";   // any name you like
    private static final String DEFAULT_FILENAME      = "Invoice.pdf";       // name shown in WhatsApp

    /**
     * Convenience wrapper so existing code like
     *   WhatsAppSender.sendDocument(phone, pdfUrl, caption)
     * continues to work.
     *
     * It maps into SmartGrowth campaign JSON.
     */
    public static void sendDocument(String phone, String publicPdfUrl, String caption) throws Exception {
        if (phone == null || phone.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing phone");
        }
        if (publicPdfUrl == null || publicPdfUrl.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing pdf url");
        }
        
//        String phone = "9965445949"; // input

        phone = phone.replaceAll("[^0-9]", ""); // remove spaces, +, -, etc.

        // If phone starts with "91" → do NOT append
        if (phone.startsWith("91")) {
            // already correct
        }
        // If phone has 10 digits → add Indian prefix
        else if (phone.length() == 10) {
            phone = "91" + phone;
        }
        // Single recipient
        List<String> phoneNumbers = Collections.singletonList(phone);

        // Use caption as first body param (template body param #1)
//        List<String> bodyParams = (caption != null && !caption.trim().isEmpty())
//                ? Collections.singletonList(caption)
//                : Collections.emptyList();
        
        String appNumber = "APP12345";
        String joinDate = "12-Dec-2025";

        List<String> bodyParams = new java.util.ArrayList<>();
        bodyParams.add(appNumber);   // {{1}}
        bodyParams.add(joinDate);    // {{2}}


        // No header params by default (customize if your template requires)
        List<String> headerParams = Collections.emptyList();

        sendWithoutMedia(DEFAULT_TEMPLATE_ID, DEFAULT_API_CODE, DEFAULT_CAMPAIGN_NAME, phoneNumbers, bodyParams, headerParams);
        
//        sendCampaign(
//                DEFAULT_TEMPLATE_ID,
//                DEFAULT_API_CODE,
//                DEFAULT_CAMPAIGN_NAME,
//                DEFAULT_FILENAME,
//                phoneNumbers,
//                publicPdfUrl,
//                bodyParams,
//                headerParams
//        );
    }
    
    /**
     * Sends a campaign message using the Smart Growth AI API.
     * * @param templateId The ID of the WhatsApp template to use.
     * @param apiCode A unique code associated with your account for this API call.
     * @param campaignName A name to identify the campaign.
     * @param filename The name of the file if a document is attached (e.g., "Invoice.pdf").
     * @param phoneNumbers List of phone numbers (e.g., ["91xxxxxxxxxx", "91yyyyyyyyyy"]).
     * @param mediaUrl Public URL of the media/document to be sent (e.g., an image or PDF).
     * @param bodyParams List of parameters to fill into the template body.
     * @param headerParams List of parameters to fill into the template header.
     * @throws Exception if the connection fails or the API returns an error.
     */
    public static void sendCampaign(
        String templateId,
        String apiCode,
        String campaignName,
        String filename,
        List<String> phoneNumbers,
        String mediaUrl,
        List<String> bodyParams,
        List<String> headerParams
    ) throws Exception {

        // --- Build JSON Payload ---
        String payload = String.format(
            "{"
            + "\"templateId\": \"%s\","
            + "\"apiCode\": \"%s\","
            + "\"campaignName\": \"%s\","
            + "\"filename\": \"%s\","
            + "\"phoneNumbers\": %s,"
            + "\"mediaUrl\": \"%s\","
            + "\"bodyParams\": %s,"
            + "\"headerParams\": %s"
            + "}",
            templateId,
            apiCode,
            campaignName,
            filename,
            listToJsonArray(phoneNumbers),
            mediaUrl,
            listToJsonArray(bodyParams),
            listToJsonArray(headerParams)
        );

        // --- Execute HTTP Request ---
        URL url = new URL(API_ENDPOINT);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        
        con.setRequestMethod("POST");
        con.setRequestProperty("Authorization", "Bearer " + JWT_TOKEN);
        con.setRequestProperty("Content-Type", "application/json");
        con.setDoOutput(true);

        // Write the JSON payload to the request body
        try (OutputStream os = con.getOutputStream()) {
            byte[] out = payload.getBytes(StandardCharsets.UTF_8);
            os.write(out);
        }

        int code = con.getResponseCode();

        // --- Handle Response ---
        if (code >= 200 && code < 300) {
            // Success
            System.out.println("✅ Campaign request sent successfully. Response Code: " + code);
            printResponse(con.getInputStream());
        } else {
            // Error
            InputStream errorStream = con.getErrorStream() != null ? con.getErrorStream() : con.getInputStream();
            System.err.println("❌ Campaign API Error! Response Code: " + code);
            printResponse(errorStream);
            throw new RuntimeException("Smart Growth AI Campaign API failed with code " + code);
        }
    }

    /**
     * Helper method to convert a Java List<String> into a JSON array string ["a", "b"].
     */
    private static String listToJsonArray(List<String> list) {
        if (list == null || list.isEmpty()) {
            return "[]";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (int i = 0; i < list.size(); i++) {
            // Escape any quotes in the string and wrap in double quotes
            sb.append("\"").append(list.get(i).replace("\"", "\\\"")).append("\"");
            if (i < list.size() - 1) {
                sb.append(", ");
            }
        }
        sb.append("]");
        return sb.toString();
    }

    /**
     * Helper method to read and print the API response stream.
     */
    private static void printResponse(InputStream inputStream) throws Exception {
        if (inputStream == null) {
            System.out.println("No response body available.");
            return;
        }
        
        try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            String responseLine;
            StringBuilder response = new StringBuilder();
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            System.out.println("API Response Body: " + response.toString());
        }
    }
    
    public static void sendWithoutMedia(
            String templateId,
            String apiCode,
            String campaignName,
            List<String> phoneNumbers,
            List<String> bodyParams,
            List<String> headerParams
    ) throws Exception {

        sendCampaign(
                templateId,
                apiCode,
                campaignName,
                "",
                phoneNumbers,
                "",
                bodyParams,
                headerParams
        );
    }

    public static void sendWithMedia(
            String templateId,
            String apiCode,
            String campaignName,
            String filename,
            List<String> phoneNumbers,
            String mediaUrl,
            List<String> bodyParams,
            List<String> headerParams
    ) throws Exception {

        if (mediaUrl == null || mediaUrl.trim().isEmpty()) {
            throw new IllegalArgumentException("Media URL is required for sendWithMedia()");
        }

        sendCampaign(
                templateId,
                apiCode,
                campaignName,
                filename,
                phoneNumbers,
                mediaUrl,
                bodyParams,
                headerParams
        );
    }

    
    // --- Example Usage ---
    public static void main(String[] args) {
        try {
            // Example data based on your JSON structure
            List<String> phones = List.of("914567892345", "915678092314");
            List<String> body = List.of("Parameter1", "Parameter2");
            List<String> header = List.of("Parameter1");

            sendCampaign(
                "7667676877878",                   // templateId
                "ere323",                         // apiCode (example)
                "Customer Monthly Report",        // campaignName
                "Customer_Report.pdf",            // filename (for media)
                phones,                           // phoneNumbers
                "https://i.ibb.co/y6FcDJK/whatsapp-2022-0-sixteen-nine.jpg", // mediaUrl
                body,                             // bodyParams
                header                            // headerParams
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
