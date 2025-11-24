package com.template.app.security;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.web.server.authentication.ServerAuthenticationConverter;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

public class CookieTokenAuthenticationConverter implements ServerAuthenticationConverter {

    private final JwtTokenProvider jwtTokenProvider;
    private static final String TOKEN_COOKIE_NAME = "token";

    public CookieTokenAuthenticationConverter(JwtTokenProvider jwtTokenProvider) {
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Override
    public Mono<Authentication> convert(ServerWebExchange exchange) {
        return Mono.fromCallable(() -> {
            // Extract token from cookie
            String token = extractTokenFromCookie(exchange);
            if (token == null || token.isEmpty()) {
                return null;
            }

            // Validate token
            if (!jwtTokenProvider.validateToken(token)) {
                return null;
            }

            // Extract user info from token
            String email = jwtTokenProvider.getEmailFromToken(token);
            String userType = jwtTokenProvider.getUserTypeFromToken(token) != null
                ? jwtTokenProvider.getUserTypeFromToken(token).name()
                : null;

            if (email == null) {
                return null;
            }

            // Create authorities based on user type
            // Include both ROLE_ prefixed (for hasRole()) and plain (for hasAuthority())
            List<SimpleGrantedAuthority> authorities = Stream.of("ROLE_USER")
                    .map(SimpleGrantedAuthority::new)
                    .collect(Collectors.toList());

            if ("ADMIN".equals(userType)) {
                authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
                authorities.add(new SimpleGrantedAuthority("ADMIN"));
            } else if ("CUSTOMER".equals(userType)) {
                authorities.add(new SimpleGrantedAuthority("ROLE_CUSTOMER"));
                authorities.add(new SimpleGrantedAuthority("CUSTOMER"));
            }

            // Create JWT authentication token
            return new JwtAuthenticationToken(token, email, authorities);
        });
    }

    private String extractTokenFromCookie(ServerWebExchange exchange) {
        var cookies = exchange.getRequest().getCookies().get(TOKEN_COOKIE_NAME);
        if (cookies != null && !cookies.isEmpty()) {
            return cookies.get(0).getValue();
        }
        return null;
    }
}

