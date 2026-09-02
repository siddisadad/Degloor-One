package com.degloor.one.auth.controller;

import com.degloor.one.auth.dto.AuthDtos;
import com.degloor.one.auth.service.AuthService;
import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ApiResponse<AuthDtos.TokenResponse> register(@Valid @RequestBody AuthDtos.RegisterRequest request) {
        return ApiResponse.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ApiResponse<AuthDtos.TokenResponse> login(@Valid @RequestBody AuthDtos.LoginRequest request) {
        return ApiResponse.ok(authService.login(request));
    }

    @PostMapping("/refresh")
    public ApiResponse<AuthDtos.TokenResponse> refresh(@Valid @RequestBody AuthDtos.RefreshRequest request) {
        return ApiResponse.ok(authService.refresh(request.refreshToken()));
    }

    @PostMapping("/forgot-password")
    public ApiResponse<AuthDtos.ForgotPasswordResponse> forgotPassword(
            @Valid @RequestBody AuthDtos.ForgotPasswordRequest request
    ) {
        return ApiResponse.ok(
                authService.forgotPassword(request.email()),
                "If an account exists for that email, a reset link will be sent"
        );
    }

    @PostMapping("/reset-password")
    public ApiResponse<AuthDtos.TokenResponse> resetPassword(
            @Valid @RequestBody AuthDtos.ResetPasswordRequest request
    ) {
        return ApiResponse.ok(authService.resetPassword(request), "Password updated");
    }

    @PostMapping("/change-password")
    public ApiResponse<AuthDtos.TokenResponse> changePassword(
            @Valid @RequestBody AuthDtos.ChangePasswordRequest request
    ) {
        return ApiResponse.ok(
                authService.changePassword(CurrentUser.require(), request),
                "Password updated"
        );
    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout() {
        authService.logout(CurrentUser.require());
        return ApiResponse.ok(null, "Signed out");
    }

    @GetMapping("/me")
    public ApiResponse<AuthDtos.AuthUser> me() {
        return ApiResponse.ok(authService.toUser(CurrentUser.require()));
    }
}
