package com.degloor.one.order.controller;

import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.response.PageResponse;
import com.degloor.one.common.security.CurrentUser;
import com.degloor.one.order.dto.OrderDtos.CancelRequest;
import com.degloor.one.order.dto.OrderDtos.CheckoutRequest;
import com.degloor.one.order.dto.OrderDtos.DeliveryOtpResponse;
import com.degloor.one.order.dto.OrderDtos.OrderResponse;
import com.degloor.one.order.dto.OrderDtos.StatusRequest;
import com.degloor.one.order.service.OrderService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/orders")
@Tag(name = "Orders")
@SecurityRequirement(name = "bearer-jwt")
public class OrderController {
    private final OrderService orders;

    public OrderController(OrderService orders) {
        this.orders = orders;
    }

    @PostMapping
    public ApiResponse<OrderResponse> checkout(@Valid @RequestBody CheckoutRequest req) {
        return ApiResponse.ok(orders.checkout(CurrentUser.require(), req), "Order placed");
    }

    @GetMapping
    public ApiResponse<PageResponse<OrderResponse>> mine(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.ok(orders.mine(CurrentUser.require(), page, size));
    }

    @GetMapping("/shop/{businessId}")
    public ApiResponse<PageResponse<OrderResponse>> shop(
            @PathVariable UUID businessId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.ok(orders.forShop(CurrentUser.require(), businessId, page, size));
    }

    @GetMapping("/{id}")
    public ApiResponse<OrderResponse> get(@PathVariable UUID id) {
        return ApiResponse.ok(orders.get(CurrentUser.require(), id));
    }

    @GetMapping("/{id}/delivery-otp")
    public ApiResponse<DeliveryOtpResponse> otp(@PathVariable UUID id) {
        return ApiResponse.ok(orders.deliveryOtp(CurrentUser.require(), id));
    }

    @PostMapping("/{id}/cancel")
    public ApiResponse<OrderResponse> cancel(@PathVariable UUID id, @RequestBody(required = false) CancelRequest req) {
        return ApiResponse.ok(orders.cancel(CurrentUser.require(), id, req == null ? null : req.reason()), "Cancelled");
    }

    @PostMapping("/{id}/status")
    public ApiResponse<OrderResponse> status(@PathVariable UUID id, @Valid @RequestBody StatusRequest req) {
        return ApiResponse.ok(orders.ownerStatus(CurrentUser.require(), id, req.status()), "Updated");
    }
}
