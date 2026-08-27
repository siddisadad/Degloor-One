package com.degloor.one.user.controller;

import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
import com.degloor.one.user.dto.UserDtos.AddressRequest;
import com.degloor.one.user.dto.UserDtos.AddressResponse;
import com.degloor.one.user.dto.UserDtos.DeliveryFeeResponse;
import com.degloor.one.user.dto.UserDtos.ProfileResponse;
import com.degloor.one.user.dto.UserDtos.UpdateProfileRequest;
import com.degloor.one.user.service.UserService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
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
@RequestMapping("/api/v1/users")
@Tag(name = "Users")
@SecurityRequirement(name = "bearer-jwt")
public class UserController {
    private final UserService users;

    public UserController(UserService users) {
        this.users = users;
    }

    @GetMapping("/me")
    public ApiResponse<ProfileResponse> me() {
        return ApiResponse.ok(users.me(CurrentUser.id()));
    }

    @PutMapping("/me")
    public ApiResponse<ProfileResponse> update(@Valid @RequestBody UpdateProfileRequest req) {
        return ApiResponse.ok(users.updateMe(CurrentUser.id(), req), "Updated");
    }

    @GetMapping("/me/addresses")
    public ApiResponse<List<AddressResponse>> addresses() {
        return ApiResponse.ok(users.myAddresses(CurrentUser.id()));
    }

    @PostMapping("/me/addresses")
    public ApiResponse<AddressResponse> add(@Valid @RequestBody AddressRequest req) {
        return ApiResponse.ok(users.addAddress(CurrentUser.id(), req), "Created");
    }

    @PutMapping("/me/addresses/{id}")
    public ApiResponse<AddressResponse> updateAddress(
            @PathVariable UUID id, @Valid @RequestBody AddressRequest req) {
        return ApiResponse.ok(users.updateAddress(CurrentUser.id(), id, req), "Updated");
    }

    @DeleteMapping("/me/addresses/{id}")
    public ApiResponse<Void> deleteAddress(@PathVariable UUID id) {
        users.deleteAddress(CurrentUser.id(), id);
        return ApiResponse.ok(null, "Deleted");
    }

    @GetMapping("/me/addresses/{id}/delivery-fee")
    public ApiResponse<DeliveryFeeResponse> deliveryFee(
            @PathVariable UUID id, @RequestParam UUID businessId) {
        return ApiResponse.ok(users.deliveryFee(CurrentUser.id(), id, businessId));
    }
}
