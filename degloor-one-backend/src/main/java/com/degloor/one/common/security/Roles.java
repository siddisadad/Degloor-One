package com.degloor.one.common.security;

import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.user.entity.UserAccount;

public final class Roles {
    public static final String CUSTOMER = "customer";
    public static final String BUSINESS_OWNER = "business_owner";
    public static final String DELIVERY_PARTNER = "delivery_partner";
    public static final String ADMIN = "admin";
    public static final String SERVICE_PROVIDER = "service_provider";

    private Roles() {}

    public static boolean isAdmin(UserAccount user) {
        return ADMIN.equals(user.getRole());
    }

    public static boolean isBusinessOwner(UserAccount user) {
        return BUSINESS_OWNER.equals(user.getRole()) || isAdmin(user);
    }

    public static boolean isDeliveryPartner(UserAccount user) {
        return DELIVERY_PARTNER.equals(user.getRole()) || isAdmin(user);
    }

    public static void requireAdmin(UserAccount user) {
        if (!isAdmin(user)) {
            throw BusinessException.forbidden("FORBIDDEN", "Admin access required");
        }
    }

    public static void requireBusinessOwner(UserAccount user) {
        if (!isBusinessOwner(user)) {
            throw BusinessException.forbidden("FORBIDDEN", "Business owner access required");
        }
    }

    public static void requireDeliveryPartner(UserAccount user) {
        if (!isDeliveryPartner(user)) {
            throw BusinessException.forbidden("FORBIDDEN", "Delivery partner access required");
        }
    }
}
