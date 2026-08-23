package com.degloor.one.marketplace.controller;

import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
import com.degloor.one.marketplace.dto.MarketplaceDtos.CategoryResponse;
import com.degloor.one.marketplace.dto.MarketplaceDtos.CreateRequestDto;
import com.degloor.one.marketplace.dto.MarketplaceDtos.ProviderResponse;
import com.degloor.one.marketplace.dto.MarketplaceDtos.RegisterProviderRequest;
import com.degloor.one.marketplace.dto.MarketplaceDtos.RequestResponse;
import com.degloor.one.marketplace.service.MarketplaceService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/services")
@Tag(name = "Services")
public class MarketplaceController {
    private final MarketplaceService marketplace;

    public MarketplaceController(MarketplaceService marketplace) {
        this.marketplace = marketplace;
    }

    @GetMapping("/categories")
    public ApiResponse<List<CategoryResponse>> categories() {
        return ApiResponse.ok(marketplace.categories());
    }

    @GetMapping("/providers")
    public ApiResponse<List<ProviderResponse>> providers(@RequestParam(required = false) UUID categoryId) {
        return ApiResponse.ok(marketplace.providers(categoryId));
    }

    @GetMapping("/providers/{id}")
    public ApiResponse<ProviderResponse> provider(@PathVariable UUID id) {
        return ApiResponse.ok(marketplace.provider(id));
    }

    @PostMapping("/providers")
    public ApiResponse<ProviderResponse> register(@RequestBody RegisterProviderRequest req) {
        return ApiResponse.ok(marketplace.register(CurrentUser.require(), req), "Registered");
    }

    @PostMapping("/requests")
    public ApiResponse<RequestResponse> create(@Valid @RequestBody CreateRequestDto req) {
        return ApiResponse.ok(marketplace.create(CurrentUser.require(), req), "Created");
    }

    @GetMapping("/requests/mine")
    public ApiResponse<List<RequestResponse>> mine() {
        return ApiResponse.ok(marketplace.mine(CurrentUser.require()));
    }

    @GetMapping("/requests/inbox")
    public ApiResponse<List<RequestResponse>> inbox() {
        return ApiResponse.ok(marketplace.forProvider(CurrentUser.require()));
    }

    @PostMapping("/requests/{id}/status")
    public ApiResponse<RequestResponse> status(@PathVariable UUID id, @RequestBody Map<String, String> body) {
        return ApiResponse.ok(marketplace.transition(CurrentUser.require(), id, body.getOrDefault("status", "")), "Updated");
    }
}
