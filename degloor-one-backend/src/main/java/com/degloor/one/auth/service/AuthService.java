package com.degloor.one.auth.service;

import com.degloor.one.auth.dto.AuthDtos;
import com.degloor.one.auth.entity.RefreshToken;
import com.degloor.one.auth.repository.RefreshTokenRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.security.JwtProperties;
import com.degloor.one.common.security.JwtService;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;

@Service
public class AuthService {
    private final UserRepository users;
    private final RefreshTokenRepository refreshTokens;
    private final PasswordEncoder encoder;
    private final JwtService jwtService;
    private final JwtProperties jwtProperties;
    private final SecureRandom random = new SecureRandom();

    public AuthService(
            UserRepository users,
            RefreshTokenRepository refreshTokens,
            PasswordEncoder encoder,
            JwtService jwtService,
            JwtProperties jwtProperties
    ) {
        this.users = users;
        this.refreshTokens = refreshTokens;
        this.encoder = encoder;
        this.jwtService = jwtService;
        this.jwtProperties = jwtProperties;
    }

    @Transactional
    public AuthDtos.TokenResponse register(AuthDtos.RegisterRequest request) {
        if (users.existsByEmailIgnoreCase(request.email())) {
            throw BusinessException.conflict("EMAIL_IN_USE", "That email is already registered");
        }
        UserAccount user = new UserAccount();
        user.setEmail(request.email().trim().toLowerCase());
        user.setPasswordHash(encoder.encode(request.password()));
        user.setFullName(request.fullName());
        user.setPhoneNumber(request.phoneNumber());
        user.setRole("customer");
        users.save(user);
        return issue(user);
    }

    @Transactional
    public AuthDtos.TokenResponse login(AuthDtos.LoginRequest request) {
        UserAccount user = users.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> BusinessException.unauthorized("INVALID_CREDENTIALS", "Email or password is incorrect"));
        if (!encoder.matches(request.password(), user.getPasswordHash())) {
            throw BusinessException.unauthorized("INVALID_CREDENTIALS", "Email or password is incorrect");
        }
        return issue(user);
    }

    @Transactional
    public AuthDtos.TokenResponse refresh(String refreshToken) {
        RefreshToken stored = refreshTokens.findByTokenHash(hash(refreshToken))
                .orElseThrow(() -> BusinessException.unauthorized("INVALID_REFRESH", "Please sign in again"));
        if (stored.isRevoked()) {
            // Reuse of a rotated refresh token is treated as theft: revoke the
            // whole session family so an attacker's newer token dies too.
            refreshTokens.deleteByUser(stored.getUser());
            throw BusinessException.unauthorized("INVALID_REFRESH", "Please sign in again");
        }
        if (stored.getExpiresAt().isBefore(Instant.now())) {
            throw BusinessException.unauthorized("INVALID_REFRESH", "Please sign in again");
        }
        stored.setRevoked(true);
        return issue(stored.getUser());
    }

    @Transactional
    public void logout(UserAccount user) {
        refreshTokens.deleteByUser(user);
    }

    public AuthDtos.AuthUser toUser(UserAccount user) {
        return new AuthDtos.AuthUser(user.getId(), user.getEmail(), user.getFullName(), user.getPhoneNumber(), user.getRole());
    }

    private AuthDtos.TokenResponse issue(UserAccount user) {
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        String refresh = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        RefreshToken token = new RefreshToken();
        token.setUser(user);
        token.setTokenHash(hash(refresh));
        token.setExpiresAt(Instant.now().plusSeconds(jwtProperties.getRefreshDays() * 24 * 3600));
        refreshTokens.save(token);
        return new AuthDtos.TokenResponse(jwtService.createAccessToken(user), refresh, toUser(user));
    }

    private static String hash(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException("Unable to hash token");
        }
    }
}
