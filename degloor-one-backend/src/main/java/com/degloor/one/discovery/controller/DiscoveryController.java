package com.degloor.one.discovery.controller;

import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
import com.degloor.one.discovery.dto.DiscoveryDtos.MasterSearchResponse;
import com.degloor.one.discovery.dto.DiscoveryDtos.ShopInsightsResponse;
import com.degloor.one.discovery.service.DiscoveryService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/discovery")
@Tag(name = "Discovery")
public class DiscoveryController {
    private final DiscoveryService discovery;

    public DiscoveryController(DiscoveryService discovery) {
        this.discovery = discovery;
    }

    @GetMapping("/search")
    public ApiResponse<MasterSearchResponse> masterSearch(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(required = false) Double radiusKm,
            @RequestParam(required = false) String scope
    ) {
        return ApiResponse.ok(discovery.masterSearch(q, lat, lng, radiusKm, scope));
    }

    @GetMapping("/insights/{businessId}")
    public ApiResponse<ShopInsightsResponse> insights(@PathVariable UUID businessId) {
        return ApiResponse.ok(discovery.insightsFor(CurrentUser.require(), businessId));
    }
}
