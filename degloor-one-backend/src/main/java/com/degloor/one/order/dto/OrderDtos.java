package com.degloor.one.order.dto;

import com.degloor.one.order.entity.OrderItem;
import com.degloor.one.order.entity.OrderStatusHistory;
import com.degloor.one.order.entity.ShopOrder;
import com.degloor.one.product.entity.Product;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public final class OrderDtos {
    private OrderDtos() {}

    public record CheckoutRequest(@NotNull UUID addressId, String paymentMethod) {}

    public record StatusRequest(@NotBlank String status) {}

    public record CancelRequest(String reason) {}

    public record OrderItemResponse(
            String productId,
            int quantity,
            double priceAtPurchase,
            String name,
            String imageUrl
    ) {
        public static OrderItemResponse from(OrderItem i) {
            return from(i, null);
        }

        public static OrderItemResponse from(OrderItem i, Product product) {
            return new OrderItemResponse(
                    i.getProductId().toString(),
                    i.getQuantity(),
                    i.getPriceAtPurchase(),
                    product == null ? null : product.getName(),
                    product == null ? null : product.getImageUrl()
            );
        }
    }

    public record HistoryResponse(String status, String notes, Instant createdAt) {
        public static HistoryResponse from(OrderStatusHistory h) {
            return new HistoryResponse(h.getStatus(), h.getNotes(), h.getCreatedAt());
        }
    }

    public record OrderResponse(
            String id,
            String userId,
            String businessId,
            double subtotal,
            double deliveryFee,
            double totalAmount,
            String status,
            String paymentStatus,
            String paymentMethod,
            String deliveryAddressId,
            Instant createdAt,
            List<OrderItemResponse> items,
            List<HistoryResponse> history
    ) {
        public static OrderResponse from(ShopOrder o, List<OrderItem> items, List<OrderStatusHistory> history) {
            return from(o, items, history, Map.of());
        }

        public static OrderResponse from(
                ShopOrder o,
                List<OrderItem> items,
                List<OrderStatusHistory> history,
                Map<UUID, Product> catalog
        ) {
            Map<UUID, Product> products = catalog == null ? Map.of() : catalog;
            return new OrderResponse(
                    o.getId().toString(),
                    o.getUserId().toString(),
                    o.getBusinessId().toString(),
                    o.getSubtotal(),
                    o.getDeliveryFee(),
                    o.getTotalAmount(),
                    o.getStatus(),
                    o.getPaymentStatus(),
                    o.getPaymentMethod(),
                    o.getDeliveryAddressId() == null ? null : o.getDeliveryAddressId().toString(),
                    o.getCreatedAt(),
                    items.stream().map(i -> OrderItemResponse.from(i, products.get(i.getProductId()))).toList(),
                    history.stream().map(HistoryResponse::from).toList()
            );
        }
    }

    public record DeliveryOtpResponse(String orderId, String otp) {}
}
