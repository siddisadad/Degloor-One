package com.degloor.one.product.dto;

import com.degloor.one.product.entity.Product;
import com.degloor.one.product.entity.ProductCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import java.util.UUID;

public final class ProductDtos {
    private ProductDtos() {}

    public record CategoryResponse(String id, String businessId, String name) {
        public static CategoryResponse from(ProductCategory c) {
            return new CategoryResponse(c.getId().toString(), c.getBusinessId().toString(), c.getName());
        }
    }

    public record ProductResponse(
            String id,
            String businessId,
            String categoryId,
            String name,
            String description,
            double price,
            String imageUrl,
            boolean available,
            int stockQuantity,
            boolean trackInventory
    ) {
        public static ProductResponse from(Product p) {
            return new ProductResponse(
                    p.getId().toString(),
                    p.getBusinessId().toString(),
                    p.getCategoryId() == null ? null : p.getCategoryId().toString(),
                    p.getName(),
                    p.getDescription(),
                    p.getPrice(),
                    p.getImageUrl(),
                    p.isAvailable(),
                    p.getStockQuantity(),
                    p.isTrackInventory()
            );
        }
    }

    public record UpsertProductRequest(
            @NotNull UUID businessId,
            UUID categoryId,
            @NotBlank @Size(max = 160) String name,
            String description,
            @PositiveOrZero double price,
            String imageUrl,
            Boolean available,
            Integer stockQuantity,
            Boolean trackInventory
    ) {}
}
