package com.degloor.one.common.security;

import org.junit.jupiter.api.Test;
import org.springframework.core.env.Environment;
import org.springframework.mock.env.MockEnvironment;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

class JwtSecretValidatorTest {
    @Test
    void allowsDefaultSecretOnDev() {
        JwtProperties props = new JwtProperties();
        props.setSecret("change-me-in-production-use-a-64-char-secret-key-please");
        Environment env = new MockEnvironment().withProperty("spring.profiles.active", "dev");
        ((MockEnvironment) env).setActiveProfiles("dev");
        assertDoesNotThrow(() -> new JwtSecretValidator(props, env).validate());
    }

    @Test
    void rejectsDefaultSecretOnProd() {
        JwtProperties props = new JwtProperties();
        props.setSecret("change-me-in-production-use-a-64-char-secret-key-please");
        MockEnvironment env = new MockEnvironment();
        env.setActiveProfiles("prod");
        assertThrows(IllegalStateException.class, () -> new JwtSecretValidator(props, env).validate());
    }

    @Test
    void rejectsShortSecretOnStaging() {
        JwtProperties props = new JwtProperties();
        props.setSecret("too-short-secret");
        MockEnvironment env = new MockEnvironment();
        env.setActiveProfiles("staging");
        assertThrows(IllegalStateException.class, () -> new JwtSecretValidator(props, env).validate());
    }

    @Test
    void acceptsStrongSecretOnProd() {
        JwtProperties props = new JwtProperties();
        props.setSecret("production-grade-secret-with-enough-entropy-0123456789");
        MockEnvironment env = new MockEnvironment();
        env.setActiveProfiles("prod");
        assertDoesNotThrow(() -> new JwtSecretValidator(props, env).validate());
    }
}
