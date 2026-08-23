package com.degloor.one.common.security;

import com.degloor.one.user.entity.UserAccount;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Service
public class JwtService {
    private final JwtProperties properties;
    private final SecretKey key;

    public JwtService(JwtProperties properties) {
        this.properties = properties;
        this.key = Keys.hmacShaKeyFor(pad(properties.getSecret()).getBytes(StandardCharsets.UTF_8));
    }

    public String createAccessToken(UserAccount user) {
        Instant now = Instant.now();
        Instant exp = now.plusSeconds(properties.getAccessMinutes() * 60);
        return Jwts.builder()
                .subject(user.getId().toString())
                .claim("role", user.getRole())
                .claim("email", user.getEmail())
                .issuedAt(Date.from(now))
                .expiration(Date.from(exp))
                .signWith(key)
                .compact();
    }

    public Claims parse(String token) {
        return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
    }

    public UUID userId(String token) {
        return UUID.fromString(parse(token).getSubject());
    }

    private static String pad(String secret) {
        if (secret == null) {
            return "x".repeat(32);
        }
        return secret.length() >= 32 ? secret : secret + "x".repeat(32 - secret.length());
    }
}
