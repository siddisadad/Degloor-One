package com.degloor.one.common.security;

import jakarta.annotation.PostConstruct;
import java.util.Arrays;
import java.util.Locale;
import java.util.Set;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/**
 * Refuses to boot staging/production with the default or undersized JWT secret.
 */
@Component
public class JwtSecretValidator {
    private static final Logger log = LoggerFactory.getLogger(JwtSecretValidator.class);
    private static final Set<String> SENSITIVE = Set.of("prod", "production", "staging", "stage");
    private static final String DEFAULT_SECRET =
            "change-me-in-production-use-a-64-char-secret-key-please";
    private static final int MIN_LENGTH = 32;

    private final JwtProperties jwtProperties;
    private final Environment environment;

    public JwtSecretValidator(JwtProperties jwtProperties, Environment environment) {
        this.jwtProperties = jwtProperties;
        this.environment = environment;
    }

    @PostConstruct
    void validate() {
        String secret = jwtProperties.getSecret();
        boolean sensitive = Arrays.stream(environment.getActiveProfiles())
                .map(profile -> profile.toLowerCase(Locale.ROOT))
                .anyMatch(SENSITIVE::contains);
        if (!sensitive) {
            if (secret == null || secret.isBlank() || DEFAULT_SECRET.equals(secret)) {
                log.warn("JWT secret is the built-in default. Set JWT_SECRET before any non-local deploy.");
            }
            return;
        }
        if (secret == null || secret.isBlank()) {
            throw new IllegalStateException(
                    "JWT_SECRET is required for profile " + Arrays.toString(environment.getActiveProfiles()));
        }
        if (DEFAULT_SECRET.equals(secret) || secret.toLowerCase(Locale.ROOT).contains("change-me")) {
            throw new IllegalStateException(
                    "JWT_SECRET must not use the default placeholder on staging/production");
        }
        if (secret.length() < MIN_LENGTH) {
            throw new IllegalStateException(
                    "JWT_SECRET must be at least " + MIN_LENGTH + " characters on staging/production");
        }
    }
}
