package com.degloor.one.common.security;

import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.user.entity.UserAccount;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

public final class CurrentUser {
    private CurrentUser() {}

    public static UserAccount require() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof UserAccount user)) {
            throw BusinessException.unauthorized("UNAUTHORIZED", "Please sign in to continue");
        }
        return user;
    }

    public static UUID id() {
        return require().getId();
    }

    public static void requireRole(String role) {
        if (!role.equals(require().getRole())) {
            throw BusinessException.forbidden("FORBIDDEN", "You do not have permission for this action");
        }
    }
}
