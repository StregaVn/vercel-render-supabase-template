package com.template.app.security;

import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;

@Component
public class AuditLogger {

    public void logAuthenticationSuccess(String username, String email) {
        String ipAddress = getClientIpAddress();
        // TODO: Implement actual audit logging
        // Log format: timestamp, event_type, username, email, ip_address, result
        System.out.printf("AUTH_SUCCESS: user=%s, email=%s, ip=%s%n", username, email, ipAddress);
    }

    public void logAuthenticationFailure(String username, String reason) {
        String ipAddress = getClientIpAddress();
        // TODO: Implement actual audit logging
        System.out.printf("AUTH_FAILURE: user=%s, reason=%s, ip=%s%n", username, reason, ipAddress);
    }

    public void logAuthorizationCheck(String username, String resource, String action, boolean allowed) {
        String ipAddress = getClientIpAddress();
        // TODO: Implement actual audit logging
        System.out.printf("AUTHZ_CHECK: user=%s, resource=%s, action=%s, allowed=%s, ip=%s%n", 
            username, resource, action, allowed, ipAddress);
    }

    public void logTokenRefresh(String username) {
        // TODO: Implement actual audit logging
        System.out.printf("TOKEN_REFRESH: user=%s%n", username);
    }

    private String getClientIpAddress() {
        try {
            ServletRequestAttributes attributes = 
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                String xForwardedFor = request.getHeader("X-Forwarded-For");
                if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
                    return xForwardedFor.split(",")[0].trim();
                }
                return request.getRemoteAddr();
            }
        } catch (Exception e) {
            // Ignore
        }
        return "unknown";
    }
}

