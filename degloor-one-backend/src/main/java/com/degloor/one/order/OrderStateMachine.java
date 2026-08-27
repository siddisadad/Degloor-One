package com.degloor.one.order;

import com.degloor.one.common.exception.BusinessException;
import java.util.Map;
import java.util.Set;

public final class OrderStateMachine {
    static final Map<String, Set<String>> OWNER_DIRECT = Map.of(
            OrderStatus.PENDING, Set.of(OrderStatus.ACCEPTED, OrderStatus.CANCELLED),
            OrderStatus.ACCEPTED, Set.of(OrderStatus.READY, OrderStatus.CANCELLED),
            OrderStatus.READY, Set.of(OrderStatus.CANCELLED)
    );

    private OrderStateMachine() {}

    public static boolean canOwnerTransition(String from, String to) {
        Set<String> allowed = OWNER_DIRECT.get(OrderStatus.normalize(from));
        return allowed != null && allowed.contains(OrderStatus.normalize(to));
    }

    public static boolean canCustomerCancel(String status) {
        return OrderStatus.PENDING.equals(OrderStatus.normalize(status));
    }

    public static boolean canOwnerCancel(String status, boolean riderAssigned) {
        if (riderAssigned) {
            return false;
        }
        return switch (OrderStatus.normalize(status)) {
            case OrderStatus.PENDING, OrderStatus.ACCEPTED, OrderStatus.READY -> true;
            default -> false;
        };
    }

    public static boolean canConfirmDelivery(String status) {
        return switch (OrderStatus.normalize(status)) {
            case OrderStatus.READY, OrderStatus.SHIPPING, OrderStatus.OUT_FOR_DELIVERY -> true;
            default -> false;
        };
    }

    public static void assertOwnerTransition(String from, String to) {
        if (!canOwnerTransition(from, to)) {
            throw BusinessException.conflict("INVALID_ORDER_TRANSITION",
                    "Cannot change order from " + from + " to " + to);
        }
    }

    public static void assertCustomerCancel(String status) {
        if (!canCustomerCancel(status)) {
            throw BusinessException.conflict("INVALID_ORDER_TRANSITION",
                    "This order can no longer be cancelled");
        }
    }

    public static void assertOwnerCancel(String status, boolean riderAssigned) {
        if (!canOwnerCancel(status, riderAssigned)) {
            throw BusinessException.conflict("INVALID_ORDER_TRANSITION",
                    riderAssigned
                            ? "Cannot cancel after a rider is assigned"
                            : "This order can no longer be cancelled");
        }
    }

    public static void assertConfirmable(String status) {
        if (!canConfirmDelivery(status)) {
            throw BusinessException.conflict("INVALID_ORDER_TRANSITION", "Order is not ready for delivery confirmation");
        }
    }
}
