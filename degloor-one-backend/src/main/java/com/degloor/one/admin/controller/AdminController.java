package com.degloor.one.admin.controller;

import com.degloor.one.admin.service.AdminService;
import com.degloor.one.business.entity.Business;
import com.degloor.one.business.entity.BusinessCategory;
import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.response.PageResponse;
import com.degloor.one.delivery.entity.DeliveryPartner;
import com.degloor.one.product.entity.Product;
import com.degloor.one.review.entity.Complaint;
import com.degloor.one.user.dto.UserDtos.ProfileResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.Map;
import java.util.UUID;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin")
@SecurityRequirement(name = "bearer-jwt")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
    private final AdminService admin;

    public AdminController(AdminService admin) {
        this.admin = admin;
    }

    @GetMapping("/users")
    public ApiResponse<PageResponse<ProfileResponse>> users(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.ok(admin.users(page, size));
    }

    @GetMapping("/businesses")
    public ApiResponse<PageResponse<Business>> businesses(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.ok(admin.businesses(page, size));
    }

    @GetMapping("/products")
    public ApiResponse<PageResponse<Product>> products(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.ok(admin.products(page, size));
    }

    @GetMapping("/orders")
    public ApiResponse<PageResponse<Map<String, Object>>> orders(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.ok(admin.orders(page, size));
    }

    @GetMapping("/delivery")
    public ApiResponse<PageResponse<DeliveryPartner>> delivery(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.ok(admin.partners(page, size));
    }

    @GetMapping("/complaints")
    public ApiResponse<PageResponse<Complaint>> complaints(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.ok(admin.complaints(page, size));
    }

    @GetMapping("/reports")
    public ApiResponse<Map<String, Object>> reports() {
        return ApiResponse.ok(admin.reports());
    }

    @GetMapping("/categories")
    public ApiResponse<List<BusinessCategory>> categories() {
        return ApiResponse.ok(admin.listCategories());
    }

    @PostMapping("/categories")
    public ApiResponse<BusinessCategory> createCategory(@RequestBody Map<String, String> body) {
        return ApiResponse.ok(admin.createCategory(body.getOrDefault("name", "")));
    }

    @PostMapping("/businesses/{id}/verify")
    public ApiResponse<Business> verifyBusiness(@PathVariable UUID id, @RequestBody Map<String, Boolean> body) {
        return ApiResponse.ok(admin.verifyBusiness(id, body.getOrDefault("verified", true)));
    }

    @PostMapping("/delivery/{id}/verify")
    public ApiResponse<DeliveryPartner> verifyPartner(@PathVariable UUID id, @RequestBody Map<String, Boolean> body) {
        return ApiResponse.ok(admin.verifyPartner(id, body.getOrDefault("verified", true)));
    }

    @PostMapping("/complaints/{id}/status")
    public ApiResponse<Complaint> resolve(@PathVariable UUID id, @RequestBody Map<String, String> body) {
        return ApiResponse.ok(admin.resolveComplaint(id, body.getOrDefault("status", "resolved")));
    }
}
