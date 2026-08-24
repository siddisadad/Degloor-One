package com.degloor.one.cart.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.UUID;

public final class CartDtos {
    private CartDtos() {}

    public record AddItemRequest(
            @NotNull UUID productId,
            @Min(1) @Max(99) int quantity,
            boolean replaceOtherBusiness
    ) {}

    public record UpdateQtyRequest(@Min(0) @Max(99) int quantity) {}

    public record CartItemResponse(
            String id,
            String productId,
            String name,
            double unitPrice,
            int quantity,
            double lineTotal,
            boolean available,
            Integer stockQuantity,
            String imageUrl
    ) {}

    public record CartResponse(
            String id,
            String businessId,
            String businessName,
            List<CartItemResponse> items,
            double subtotal
    ) {
        public static CartResponse empty() {
            return new CartResponse(null, null, null, List.of(), 0);
        }
    }
}
