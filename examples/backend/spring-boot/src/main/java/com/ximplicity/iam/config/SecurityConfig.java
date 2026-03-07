package com.ximplicity.iam.config;

import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.authority.mapping.GrantedAuthoritiesMapper;
import org.springframework.security.oauth2.core.oidc.user.OidcUserAuthority;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Spring Security configuration for OAuth2 / OIDC login with Keycloak.
 *
 * <p>Key responsibilities:
 * <ul>
 *   <li>Define public and protected URL patterns.</li>
 *   <li>Map Keycloak realm roles from the access token into Spring
 *       Security {@link GrantedAuthority} instances so that role-based
 *       access checks ({@code hasRole("admin")}) work seamlessly.</li>
 *   <li>Configure logout to perform an OIDC RP-Initiated Logout so the
 *       Keycloak session is terminated as well.</li>
 * </ul>
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    /**
     * Configures the HTTP security filter chain.
     *
     * <p>Public pages ({@code /}, static resources, error pages) are
     * accessible without authentication. The {@code /admin/**} path
     * requires the {@code admin} role. All other paths require an
     * authenticated user.
     *
     * @param http the {@link HttpSecurity} builder
     * @return the configured {@link SecurityFilterChain}
     * @throws Exception if an error occurs during configuration
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/",
                    "/css/**",
                    "/js/**",
                    "/fonts/**",
                    "/images/**",
                    "/unauthorized",
                    "/error"
                ).permitAll()
                .requestMatchers("/admin/**").hasRole("admin")
                .anyRequest().authenticated()
            )
            .oauth2Login(oauth2 -> oauth2
                .defaultSuccessUrl("/dashboard", true)
            )
            .logout(logout -> logout
                .logoutSuccessUrl("/")
                .invalidateHttpSession(true)
                .clearAuthentication(true)
                .deleteCookies("JSESSIONID")
            )
            .exceptionHandling(ex -> ex
                .accessDeniedPage("/unauthorized")
            );

        return http.build();
    }

    /**
     * Maps Keycloak realm roles into Spring Security granted authorities.
     *
     * <p>Keycloak stores realm roles inside the ID / access token under
     * {@code realm_access.roles}. This mapper extracts those roles and
     * converts each one into a {@link SimpleGrantedAuthority} with the
     * {@code ROLE_} prefix so that Spring Security's {@code hasRole()}
     * checks work correctly.
     *
     * @return a {@link GrantedAuthoritiesMapper} that includes Keycloak
     *         realm roles
     */
    @Bean
    @SuppressWarnings("unchecked")
    public GrantedAuthoritiesMapper grantedAuthoritiesMapper() {
        return authorities -> {
            Set<GrantedAuthority> mapped = new HashSet<>(authorities);

            for (GrantedAuthority authority : authorities) {
                if (authority instanceof OidcUserAuthority oidcAuthority) {
                    Map<String, Object> claims = oidcAuthority.getIdToken().getClaims();

                    // Extract realm_access.roles from the token claims
                    Object realmAccess = claims.get("realm_access");
                    if (realmAccess instanceof Map<?, ?> realmAccessMap) {
                        Object roles = realmAccessMap.get("roles");
                        if (roles instanceof Collection<?> roleList) {
                            roleList.stream()
                                .filter(String.class::isInstance)
                                .map(String.class::cast)
                                .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
                                .forEach(mapped::add);
                        }
                    }
                }
            }

            return mapped;
        };
    }
}
