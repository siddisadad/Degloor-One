package com.degloor.one.order;

public final class OrderStatus {
    public static final String PENDING = "pending";
    public static final String ACCEPTED = "accepted";
    public static final String READY = "ready";
    public static final String SHIPPING = "shipping";
    public static final String OUT_FOR_DELIVERY = "out_for_delivery";
    public static final String DELIVERED = "delivered";
    public static final String CANCELLED = "cancelled";

    public static final String UNPAID = "unpaid";
    public static final String PAID = "paid";

    private OrderStatus() {}

    public static String normalize(String status) {
        if (status == null) {
            return PENDING;
        }
        return switch (status.toLowerCase().trim()) {
            case "placed", "created" -> PENDING;
            case "out for delivery" -> OUT_FOR_DELIVERY;
            default -> status.toLowerCase().trim();
        };
    }
}
