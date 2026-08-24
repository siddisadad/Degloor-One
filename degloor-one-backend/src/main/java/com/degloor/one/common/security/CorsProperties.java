package com.degloor.one.common.security;

import java.util.Arrays;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "degloor.cors")
public class CorsProperties {
    private List<String> allowedOrigins = List.of("http://localhost:*", "http://127.0.0.1:*");

    public List<String> getAllowedOrigins() {
        return allowedOrigins;
    }

    public void setAllowedOrigins(List<String> allowedOrigins) {
        this.allowedOrigins = allowedOrigins;
    }

    public List<String> origins() {
        if (allowedOrigins == null || allowedOrigins.isEmpty()) {
            return List.of("http://localhost:*", "http://127.0.0.1:*");
        }
        return allowedOrigins.stream()
                .flatMap(value -> Arrays.stream(value.split(",")))
                .map(String::trim)
                .filter(value -> !value.isEmpty())
                .toList();
    }
}
