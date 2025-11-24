package com.template.app.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * Password Hash Generator Utility
 * 
 * Generates BCrypt password hashes for use in database migrations and testing.
 * 
 * USAGE:
 * Run this class directly to generate a hash for a password:
 *   ./mvnw exec:java -Dexec.mainClass="com.template.app.util.PasswordHashGenerator"
 * 
 * Or run from your IDE as a Java application.
 * 
 * The generated hash can be used in:
 * - SQL migration scripts (e.g., V1__Initial_schema.sql)
 * - Test data setup
 * - Manual user creation
 * 
 * SECURITY NOTES:
 * - BCrypt automatically includes a salt
 * - Each call to encode() generates a different hash (due to random salt)
 * - BCrypt is intentionally slow to resist brute-force attacks
 * - Never store or log plain text passwords
 */
public class PasswordHashGenerator {
    
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // CHANGE THIS: Set your desired password
        String password = "admin123";
        
        // Generate BCrypt hash
        String hash = encoder.encode(password);
        
        System.out.println("========================================");
        System.out.println("PASSWORD HASH GENERATOR");
        System.out.println("========================================");
        System.out.println("Plain text: " + password);
        System.out.println("BCrypt hash: " + hash);
        System.out.println("========================================");
        System.out.println();
        System.out.println("Copy this hash into your SQL migration:");
        System.out.println("INSERT INTO users (email, password_hash, ...)");
        System.out.println("VALUES ('admin@example.com', '" + hash + "', ...);");
        System.out.println("========================================");
        
        // Verify the hash works
        boolean matches = encoder.matches(password, hash);
        System.out.println();
        System.out.println("Verification: " + (matches ? "✓ PASS" : "✗ FAIL"));
    }
}

