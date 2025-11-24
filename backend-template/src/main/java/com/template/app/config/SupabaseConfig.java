package com.template.app.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import lombok.Getter;

/**
 * Configuration for Supabase integration.
 * 
 * Supabase provides:
 * - PostgreSQL database (via connection pooler)
 * - JWT authentication with JWKS endpoint
 * - Optional: Storage, Realtime, Edge Functions
 * 
 * To get these values:
 * 1. Go to your Supabase project dashboard
 * 2. Settings > API
 * 3. Copy Project URL (SUPABASE_URL)
 * 4. Copy anon/public key (SUPABASE_ANON_KEY)
 * 5. Copy service_role key (SUPABASE_SERVICE_KEY) - keep secret!
 * 6. Settings > Database > Connection string (for DB_URL)
 */
@Configuration
@Getter
public class SupabaseConfig {

    @Value("${supabase.url:}")
    private String url;

    @Value("${supabase.anon-key:}")
    private String anonKey;

    @Value("${supabase.service-key:}")
    private String serviceKey;

    /**
     * Get Supabase JWKS endpoint URL for JWT validation.
     * Format: https://{project-ref}.supabase.co/auth/v1/.well-known/jwks.json
     */
    public String getJwksUri() {
        if (url == null || url.isEmpty()) {
            return null;
        }
        // Extract project ref from URL if full URL provided
        // Or construct from project ref if only ref provided
        String baseUrl = url.endsWith("/") ? url.substring(0, url.length() - 1) : url;
        if (!baseUrl.contains("supabase.co")) {
            // Assume it's a project ref
            return String.format("https://%s.supabase.co/auth/v1/.well-known/jwks.json", baseUrl);
        }
        return baseUrl + "/auth/v1/.well-known/jwks.json";
    }
}

