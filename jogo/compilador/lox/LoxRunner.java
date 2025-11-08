package lox;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;

public class LoxRunner {
    private static final Interpreter interpreter = new Interpreter();
    
    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("Usage: LoxRunner <code>");
            System.exit(1);
        }
        
        String source = args[0];
        // Restore source from base64 (for special characters and newlines)
        try {
            source = new String(java.util.Base64.getDecoder().decode(source), StandardCharsets.UTF_8);
        } catch (IllegalArgumentException e) {
            // Not base64, use as is
        }
        
        // Capture stdout
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PrintStream originalOut = System.out;
        PrintStream originalErr = System.err;
        PrintStream captureOut = new PrintStream(baos, true, StandardCharsets.UTF_8);
        
        System.setOut(captureOut);
        System.setErr(captureOut);
        
        boolean success = false;
        String output = "";
        String error = "";
        
        try {
            // Reset error flags
            Lox.hadError = false;
            Lox.hadRuntimeError = false;
            
            Lox.run(source);
            
            // Get captured output
            String captured = baos.toString(StandardCharsets.UTF_8);
            
            if (!Lox.hadError && !Lox.hadRuntimeError) {
                success = true;
                output = captured.trim();
            } else {
                error = captured.trim();
                // Remove error prefixes if present
                if (error.startsWith("[line")) {
                    // Keep the error message
                }
            }
        } catch (Exception e) {
            error = e.getMessage();
            if (error == null) {
                error = "Runtime exception occurred";
            }
        } finally {
            System.setOut(originalOut);
            System.setErr(originalErr);
        }
        
        // Output JSON result
        if (success) {
            System.out.println("{\"success\":true,\"output\":\"" + escapeJson(output) + "\"}");
        } else {
            System.out.println("{\"success\":false,\"error\":\"" + escapeJson(error) + "\"}");
        }
    }
    
    private static String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t")
                  .replace("\b", "\\b")
                  .replace("\f", "\\f");
    }
}

