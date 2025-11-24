package com.template.app.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
public class SecurityUtils {

    public Optional<String> getCurrentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Jwt jwt) {
            return Optional.ofNullable(jwt.getClaimAsString("sub"));
        }
        return Optional.empty();
    }

    public Optional<String> getCurrentUserEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Jwt jwt) {
            return Optional.ofNullable(jwt.getClaimAsString("email"));
        }
        return Optional.empty();
    }

    public List<String> getCurrentUserRoles() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Jwt jwt) {
            List<String> roles = jwt.getClaimAsStringList("roles");
            return roles != null ? roles : List.of();
        }
        return List.of();
    }

    public List<String> getCurrentUserPermissions() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Jwt jwt) {
            List<String> permissions = jwt.getClaimAsStringList("permissions");
            return permissions != null ? permissions : List.of();
        }
        return List.of();
    }

    public boolean hasRole(String role) {
        return getCurrentUserRoles().contains(role.toUpperCase());
    }

    public boolean hasPermission(String permission) {
        return getCurrentUserPermissions().contains(permission);
    }

    public boolean hasAnyRole(String... roles) {
        List<String> userRoles = getCurrentUserRoles();
        return java.util.Arrays.stream(roles)
            .anyMatch(role -> userRoles.contains(role.toUpperCase()));
    }

    public boolean hasAnyPermission(String... permissions) {
        List<String> userPermissions = getCurrentUserPermissions();
        return java.util.Arrays.stream(permissions)
            .anyMatch(userPermissions::contains);
    }

    public Optional<Jwt> getCurrentJwt() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Jwt jwt) {
            return Optional.of(jwt);
        }
        return Optional.empty();
    }
}

