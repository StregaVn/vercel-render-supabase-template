package com.template.app.security;

public class DataMaskingUtil {
    
    public static String maskPan(String pan) {
        if (pan == null || pan.length() < 4) {
            return pan;
        }
        return "****" + pan.substring(pan.length() - 4);
    }
    
    public static String maskSsn(String ssn) {
        if (ssn == null || ssn.length() < 4) {
            return ssn;
        }
        return "***-**-" + ssn.substring(ssn.length() - 4);
    }
    
    public static String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }
        int atIndex = email.indexOf("@");
        String localPart = email.substring(0, atIndex);
        String domain = email.substring(atIndex);
        if (localPart.length() <= 2) {
            return "**" + domain;
        }
        return localPart.substring(0, 2) + "***" + domain;
    }
}

