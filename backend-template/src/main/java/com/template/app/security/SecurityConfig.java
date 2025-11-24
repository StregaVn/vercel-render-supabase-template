package com.template.app.security;

import java.util.Arrays;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableReactiveMethodSecurity;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.SecurityWebFiltersOrder;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;
import org.springframework.security.web.server.authentication.AuthenticationWebFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsConfigurationSource;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;
import lombok.RequiredArgsConstructor;

@Configuration
@EnableWebFluxSecurity
@EnableReactiveMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenProvider jwtTokenProvider;

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        // Create authentication filter
        AuthenticationWebFilter authenticationFilter = new AuthenticationWebFilter(
            new CookieTokenReactiveAuthenticationManager(jwtTokenProvider));
        authenticationFilter.setServerAuthenticationConverter(
            new CookieTokenAuthenticationConverter(jwtTokenProvider));

        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .httpBasic(httpBasic -> httpBasic.disable())
            .formLogin(formLogin -> formLogin.disable())
            .addFilterAt(authenticationFilter, SecurityWebFiltersOrder.AUTHENTICATION)
            .authorizeExchange(exchanges -> exchanges
                .pathMatchers(org.springframework.http.HttpMethod.OPTIONS, "/**").permitAll()
                .pathMatchers("/actuator/health", "/actuator/info").permitAll()
                .pathMatchers("/api/auth/login", "/api/auth/logout").permitAll()
                .pathMatchers("/api/**").authenticated()
                .anyExchange().permitAll())
            .exceptionHandling(exceptionHandling -> exceptionHandling
                .authenticationEntryPoint((exchange, ex) -> {
                    exchange.getResponse().setStatusCode(org.springframework.http.HttpStatus.UNAUTHORIZED);
                    return exchange.getResponse().setComplete();
                }));

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Get allowed origins from environment variable
        // Default uses wildcard for localhost (any port) + dev domain
        // For production, set CORS_ALLOWED_ORIGINS to specific domains only
        // DEV: https://dev.fintech.hktech.io
        // TEST: https://test.fintech.hktech.io
        // PROD: https://fintech.hktech.io
        // PROD (Locum): https://locum.hktech.io
        // Vercel preview URLs: https://*.vercel.app
        String allowedOriginPatterns = System.getenv().getOrDefault("CORS_ALLOWED_ORIGINS",
            "http://localhost:*,https://dev.fintech.hktech.io,https://locum.hktech.io,https://*.vercel.app");

        // Use setAllowedOriginPatterns to support wildcards (e.g., http://localhost:*)
        configuration.setAllowedOriginPatterns(Arrays.asList(allowedOriginPatterns.split(",")));

        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type", "X-Requested-With"));
        configuration.setExposedHeaders(Arrays.asList("Authorization"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public org.springframework.security.oauth2.jwt.ReactiveJwtDecoder jwtDecoder(
            io.hktech.locumProduction.config.SupabaseConfig supabaseConfig) {
        // Use Supabase JWKS endpoint for JWT validation
        // Fallback to environment variable or default placeholder
        String jwkSetUri = System.getenv().getOrDefault("JWT_JWKS_URI",
            supabaseConfig.getJwksUri() != null 
                ? supabaseConfig.getJwksUri()
                : "https://your-project.supabase.co/auth/v1/.well-known/jwks.json");

        return org.springframework.security.oauth2.jwt.NimbusReactiveJwtDecoder
            .withJwkSetUri(jwkSetUri)
            .build();
    }
}
