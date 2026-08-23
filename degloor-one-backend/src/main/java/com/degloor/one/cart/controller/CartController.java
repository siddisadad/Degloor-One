package com.degloor.one.cart.controller;

import com.degloor.one.cart.dto.CartDtos.AddItemRequest;
import com.degloor.one.cart.dto.CartDtos.CartResponse;
import com.degloor.one.cart.dto.CartDtos.UpdateQtyRequest;
import com.degloor.one.cart.service.CartService;
import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/cart")
@Tag(name = "Cart")
@SecurityRequirement(name = "bearer-jwt")
public class CartController {
    private final CartService carts;

    public CartController(CartService carts) {
        this.carts = carts;
    }

    @GetMapping
    public ApiResponse<CartResponse> get() {
        return ApiResponse.ok(carts.get(CurrentUser.require()));
    }

    @PostMapping("/items")
    public ApiResponse<CartResponse> add(@Valid @RequestBody AddItemRequest req) {
        return ApiResponse.ok(carts.add(CurrentUser.require(), req), "Updated");
    }

    @PutMapping("/items/{productId}")
    public ApiResponse<CartResponse> update(@PathVariable UUID productId, @Valid @RequestBody UpdateQtyRequest req) {
        return ApiResponse.ok(carts.update(CurrentUser.require(), productId, req.quantity()), "Updated");
    }

    @DeleteMapping("/items/{productId}")
    public ApiResponse<CartResponse> remove(@PathVariable UUID productId) {
        return ApiResponse.ok(carts.update(CurrentUser.require(), productId, 0), "Updated");
    }

    @DeleteMapping
    public ApiResponse<Void> clear() {
        carts.clear(CurrentUser.require());
        return ApiResponse.ok(null, "Cleared");
    }
}
