package com.degloor.one.auth.service;

import com.degloor.one.auth.dto.AuthDtos;
import com.degloor.one.auth.entity.PasswordResetToken;
import com.degloor.one.auth.entity.RefreshToken;
import com.degloor.one.auth.repository.PasswordResetTokenRepository;
import com.degloor.one.auth.repository.RefreshTokenRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.security.JwtProperties;
import com.degloor.one.common.security.JwtService;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Arrays;
import java.util.Base64;
import java.util.HexFormat;

@Service
public class AuthService {
    private static final Logger log = LoggerFactory.getLogger(AuthService.class);
    private static final long RESET_TTL_HOURS = 2;

    private final UserRepository users;
    private final RefreshTokenRepository refreshTokens;
    private final PasswordResetTokenRepository passwordResetTokens;
    private final PasswordEncoder encoder;
    private final JwtService jwtService;
    private final JwtProperties jwtProperties;
    private final Environment environment;
    private final SecureRandom random = new SecureRandom();

    public AuthService(
            UserRepository users,
            RefreshTokenRepository refreshTokens,
            PasswordResetTokenRepository passwordResetTokens,
            PasswordEncoder encoder,
            JwtService jwtService,
            JwtProperties jwtProperties,
            Environment environment
    ) {
        this.users = users;
        this.refreshTokens = refreshTokens;
        this.passwordResetTokens = passwordResetTokens;
        this.encoder = encoder;
        this.jwtService = jwtService;
        this.jwtProperties = jwtProperties;
        this.environment = environment;
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
        if (stored.isRevoked() || stored.getExpiresAt().isBefore(Instant.now())) {
            throw BusinessException.unauthorized("INVALID_REFRESH", "Please sign in again");
        }
        stored.setRevoked(true);
        return issue(stored.getUser());
    }

    @Transactional
    public void logout(UserAccount user) {
        refreshTokens.deleteByUser(user);
    }

    /**
     * Always succeeds to avoid email enumeration. Non-production profiles return
     * the raw token so Flutter can complete the flow without an email provider.
     */
    @Transactional
    public AuthDtos.ForgotPasswordResponse forgotPassword(String email) {
        String normalized = email == null ? "" : email.trim().toLowerCase();
        UserAccount user = users.findByEmailIgnoreCase(normalized).orElse(null);
        if (user == null) {
            return new AuthDtos.ForgotPasswordResponse(null);
        }
        passwordResetTokens.deleteByUser(user);
        String raw = newToken();
        PasswordResetToken token = new PasswordResetToken();
        token.setUser(user);
        token.setTokenHash(hash(raw));
        token.setExpiresAt(Instant.now().plusSeconds(RESET_TTL_HOURS * 3600));
        passwordResetTokens.save(token);
        log.info("Password reset issued for {} (valid {}h). Deep link token logged for operators without SMTP.",
                user.getEmail(), RESET_TTL_HOURS);
        log.info("Password reset token for {}: {}", user.getEmail(), raw);
        if (exposeResetToken()) {
            return new AuthDtos.ForgotPasswordResponse(raw);
        }
        return new AuthDtos.ForgotPasswordResponse(null);
    }

    @Transactional
    public AuthDtos.TokenResponse resetPassword(AuthDtos.ResetPasswordRequest request) {
        PasswordResetToken stored = passwordResetTokens.findByTokenHash(hash(request.token()))
                .orElseThrow(() -> BusinessException.badRequest("INVALID_RESET_TOKEN", "This reset link is invalid or has expired"));
        if (stored.getUsedAt() != null || stored.getExpiresAt().isBefore(Instant.now())) {
            throw BusinessException.badRequest("INVALID_RESET_TOKEN", "This reset link is invalid or has expired");
        }
        UserAccount user = stored.getUser();
        user.setPasswordHash(encoder.encode(request.newPassword()));
        users.save(user);
        refreshTokens.deleteByUser(user);
        passwordResetTokens.deleteByUser(user);
        return issue(user);
    }

    @Transactional
    public AuthDtos.TokenResponse changePassword(UserAccount user, AuthDtos.ChangePasswordRequest request) {
        user.setPasswordHash(encoder.encode(request.newPassword()));
        users.save(user);
        refreshTokens.deleteByUser(user);
        passwordResetTokens.deleteByUser(user);
        return issue(user);
    }

    public AuthDtos.AuthUser toUser(UserAccount user) {
        return new AuthDtos.AuthUser(user.getId(), user.getEmail(), user.getFullName(), user.getPhoneNumber(), user.getRole());
    }

    private boolean exposeResetToken() {
        return Arrays.stream(environment.getActiveProfiles())
                .anyMatch(profile -> "dev".equalsIgnoreCase(profile) || "test".equalsIgnoreCase(profile));
    }

    private AuthDtos.TokenResponse issue(UserAccount user) {
        String refresh = newToken();
        RefreshToken token = new RefreshToken();
        token.setUser(user);
        token.setTokenHash(hash(refresh));
        token.setExpiresAt(Instant.now().plusSeconds(jwtProperties.getRefreshDays() * 24 * 3600));
        refreshTokens.save(token);
        return new AuthDtos.TokenResponse(jwtService.createAccessToken(user), refresh, toUser(user));
    }

    private String newToken() {
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
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
