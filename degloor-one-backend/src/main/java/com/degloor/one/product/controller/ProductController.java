package com.degloor.one.product.controller;

import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.response.PageResponse;
import com.degloor.one.common.security.CurrentUser;
import com.degloor.one.product.dto.ProductDtos.CategoryResponse;
import com.degloor.one.product.dto.ProductDtos.ProductResponse;
import com.degloor.one.product.dto.ProductDtos.UpsertProductRequest;
import com.degloor.one.product.service.ProductService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Products")
public class ProductController {
    private final ProductService products;

    public ProductController(ProductService products) {
        this.products = products;
    }

    @GetMapping("/products")
    public ApiResponse<PageResponse<ProductResponse>> search(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) UUID businessId,
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice,
            @RequestParam(required = false) Boolean available,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String sort
    ) {
        return ApiResponse.ok(products.search(q, businessId, categoryId, minPrice, maxPrice, available, page, size, sort));
    }

    @GetMapping("/products/{id}")
    public ApiResponse<ProductResponse> get(@PathVariable UUID id) {
        return ApiResponse.ok(products.get(id));
    }

    @GetMapping("/businesses/{businessId}/products")
    public ApiResponse<List<ProductResponse>> forBusiness(
            @PathVariable UUID businessId,
            @RequestParam(defaultValue = "true") boolean availableOnly
    ) {
        return ApiResponse.ok(products.forBusiness(businessId, availableOnly));
    }

    @GetMapping("/businesses/{businessId}/product-categories")
    public ApiResponse<List<CategoryResponse>> categories(@PathVariable UUID businessId) {
        return ApiResponse.ok(products.categoriesFor(businessId));
    }

    @PostMapping("/products")
    public ApiResponse<ProductResponse> create(@Valid @RequestBody UpsertProductRequest req) {
        return ApiResponse.ok(products.create(CurrentUser.require(), req), "Created");
    }

    @PutMapping("/products/{id}")
    public ApiResponse<ProductResponse> update(@PathVariable UUID id, @Valid @RequestBody UpsertProductRequest req) {
        return ApiResponse.ok(products.update(CurrentUser.require(), id, req), "Updated");
    }

    @DeleteMapping("/products/{id}")
    public ApiResponse<Void> delete(@PathVariable UUID id) {
        products.delete(CurrentUser.require(), id);
        return ApiResponse.ok(null, "Deleted");
    }

    @PostMapping("/businesses/{businessId}/product-categories")
    public ApiResponse<CategoryResponse> createCategory(
            @PathVariable UUID businessId,
            @RequestBody Map<String, String> body
    ) {
        String name = body.getOrDefault("name", "").trim();
        return ApiResponse.ok(products.createCategory(CurrentUser.require(), businessId, name), "Created");
    }
}
