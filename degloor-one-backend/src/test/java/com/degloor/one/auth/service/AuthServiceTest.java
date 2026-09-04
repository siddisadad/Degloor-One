package com.degloor.one.auth.service;

import com.degloor.one.auth.entity.RefreshToken;
import com.degloor.one.auth.repository.RefreshTokenRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.security.JwtProperties;
import com.degloor.one.common.security.JwtService;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.HexFormat;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {
    @Mock UserRepository users;
    @Mock RefreshTokenRepository refreshTokens;
    @Mock PasswordEncoder encoder;
    @Mock JwtService jwtService;
    JwtProperties jwtProperties;
    AuthService service;
    UserAccount user;

    @BeforeEach
    void setUp() {
        jwtProperties = new JwtProperties();
        jwtProperties.setRefreshDays(14);
        service = new AuthService(users, refreshTokens, encoder, jwtService, jwtProperties);
        user = new UserAccount();
        user.setId(UUID.randomUUID());
        user.setEmail("owner@example.com");
        user.setRole("customer");
    }

    @Test
    void revokedRefreshTokenKillsTheSessionFamily() {
        String raw = "stolen-rotated-refresh";
        RefreshToken stored = new RefreshToken();
        stored.setUser(user);
        stored.setTokenHash(sha256(raw));
        stored.setRevoked(true);
        stored.setExpiresAt(Instant.now().plusSeconds(3600));
        when(refreshTokens.findByTokenHash(sha256(raw))).thenReturn(Optional.of(stored));

        BusinessException ex = assertThrows(BusinessException.class, () -> service.refresh(raw));

        assertEquals("INVALID_REFRESH", ex.getCode());
        verify(refreshTokens).deleteByUser(user);
        verify(refreshTokens, never()).save(org.mockito.ArgumentMatchers.any());
    }

    @Test
    void expiredRefreshTokenDoesNotKillOtherSessions() {
        String raw = "expired-refresh";
        RefreshToken stored = new RefreshToken();
        stored.setUser(user);
        stored.setTokenHash(sha256(raw));
        stored.setRevoked(false);
        stored.setExpiresAt(Instant.now().minusSeconds(60));
        when(refreshTokens.findByTokenHash(sha256(raw))).thenReturn(Optional.of(stored));

        BusinessException ex = assertThrows(BusinessException.class, () -> service.refresh(raw));

        assertEquals("INVALID_REFRESH", ex.getCode());
        verify(refreshTokens, never()).deleteByUser(user);
        verify(refreshTokens, never()).save(org.mockito.ArgumentMatchers.any());
    }

    private static String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
}
