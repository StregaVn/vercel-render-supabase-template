package com.template.app.security;

import org.springframework.security.authentication.ReactiveAuthenticationManager;
import org.springframework.security.core.Authentication;
import reactor.core.publisher.Mono;

public class CookieTokenReactiveAuthenticationManager implements ReactiveAuthenticationManager {

    private final JwtTokenProvider jwtTokenProvider;

    public CookieTokenReactiveAuthenticationManager(JwtTokenProvider jwtTokenProvider) {
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Override
    public Mono<Authentication> authenticate(Authentication authentication) {
        if (authentication instanceof JwtAuthenticationToken jwtAuth) {
            String token = (String) jwtAuth.getCredentials();
            if (jwtTokenProvider.validateToken(token)) {
                return Mono.just(authentication);
            }
        }
        return Mono.empty();
    }
}

