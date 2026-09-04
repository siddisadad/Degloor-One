package com.degloor.one.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public final class AuthDtos {
    private AuthDtos() {}

    public record RegisterRequest(
            @Email @NotBlank String email,
            @NotBlank @Size(min = 8, max = 72) String password,
            String fullName,
            String phoneNumber
    ) {}

    public record LoginRequest(
            @Email @NotBlank String email,
            @NotBlank String password
    ) {}

    public record RefreshRequest(@NotBlank String refreshToken) {}

    public record ForgotPasswordRequest(@Email @NotBlank String email) {}

    public record ResetPasswordRequest(
            @NotBlank String token,
            @NotBlank @Size(min = 8, max = 72) String newPassword
    ) {}

    public record ChangePasswordRequest(
            @NotBlank @Size(min = 8, max = 72) String newPassword
    ) {}

    public record AuthUser(UUID id, String email, String fullName, String phoneNumber, String role) {}

    public record TokenResponse(String accessToken, String refreshToken, AuthUser user) {}

    /** resetToken is only populated on non-production profiles (no email provider yet). */
    public record ForgotPasswordResponse(String resetToken) {}
}
