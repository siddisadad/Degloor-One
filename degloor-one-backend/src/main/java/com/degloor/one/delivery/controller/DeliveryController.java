package com.degloor.one.delivery.controller;

import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
import com.degloor.one.delivery.dto.DeliveryDtos.AssignmentResponse;
import com.degloor.one.delivery.dto.DeliveryDtos.AvailabilityRequest;
import com.degloor.one.delivery.dto.DeliveryDtos.LocationRequest;
import com.degloor.one.delivery.dto.DeliveryDtos.MyOrdersResponse;
import com.degloor.one.delivery.dto.DeliveryDtos.OtpVerifyRequest;
import com.degloor.one.delivery.dto.DeliveryDtos.PartnerResponse;
import com.degloor.one.delivery.dto.DeliveryDtos.RegisterRequest;
import com.degloor.one.delivery.service.DeliveryService;
import com.degloor.one.order.dto.OrderDtos.OrderResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/delivery")
@Tag(name = "Delivery")
@SecurityRequirement(name = "bearer-jwt")
public class DeliveryController {
    private final DeliveryService delivery;

    public DeliveryController(DeliveryService delivery) {
        this.delivery = delivery;
    }

    @GetMapping("/me")
    public ApiResponse<PartnerResponse> me() {
        return ApiResponse.ok(delivery.me(CurrentUser.require()));
    }

    @PostMapping("/register")
    public ApiResponse<PartnerResponse> register(@RequestBody(required = false) RegisterRequest req) {
        RegisterRequest body = req == null ? new RegisterRequest(null, null) : req;
        return ApiResponse.ok(delivery.register(CurrentUser.require(), body.vehicleType(), body.vehicleNumber()), "Registered");
    }

    @PostMapping("/availability")
    public ApiResponse<PartnerResponse> availability(@RequestBody AvailabilityRequest req) {
        return ApiResponse.ok(delivery.setAvailable(CurrentUser.require(), req.available()));
    }

    @GetMapping("/my-orders")
    public ApiResponse<MyOrdersResponse> myOrders() {
        return ApiResponse.ok(delivery.myOrders(CurrentUser.require()));
    }

    @PostMapping("/orders/{id}/accept")
    public ApiResponse<AssignmentResponse> accept(@PathVariable UUID id) {
        return ApiResponse.ok(delivery.accept(CurrentUser.require(), id), "Accepted");
    }

    @PostMapping("/orders/{id}/pickup")
    public ApiResponse<AssignmentResponse> pickup(@PathVariable UUID id) {
        return ApiResponse.ok(delivery.pickup(CurrentUser.require(), id), "Picked up");
    }

    @PostMapping("/assignments/{id}/pickup")
    public ApiResponse<AssignmentResponse> pickupAssignment(@PathVariable UUID id) {
        return ApiResponse.ok(delivery.pickupAssignment(CurrentUser.require(), id), "Picked up");
    }

    @PostMapping("/orders/{id}/deliver")
    public ApiResponse<OrderResponse> deliver(@PathVariable UUID id, @Valid @RequestBody OtpVerifyRequest req) {
        return ApiResponse.ok(delivery.verifyOtp(CurrentUser.require(), id, req.otp()), "Delivered");
    }

    @PostMapping("/orders/{id}/otp/verify")
    public ApiResponse<OrderResponse> verifyOtp(@PathVariable UUID id, @Valid @RequestBody OtpVerifyRequest req) {
        return ApiResponse.ok(delivery.verifyOtp(CurrentUser.require(), id, req.otp()), "Delivered");
    }

    @PostMapping("/location")
    public ApiResponse<PartnerResponse> location(@RequestBody LocationRequest req) {
        return ApiResponse.ok(delivery.updateLocation(CurrentUser.require(), req.latitude(), req.longitude()));
    }
}
