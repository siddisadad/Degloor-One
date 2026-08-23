package com.degloor.one.analytics.controller;

import com.degloor.one.analytics.service.AnalyticsService;
import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.Map;
import java.util.UUID;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Analytics")
public class AnalyticsController {
    private final AnalyticsService analytics;

    public AnalyticsController(AnalyticsService analytics) {
        this.analytics = analytics;
    }

    @PostMapping("/analytics/events")
    public ApiResponse<Void> track(@RequestBody Map<String, String> body, Authentication auth) {
        UUID businessId = UUID.fromString(body.get("businessId"));
        analytics.track(
                auth != null && auth.getPrincipal() instanceof com.degloor.one.user.entity.UserAccount user ? user : null,
                businessId,
                body.get("eventType"),
                body.get("metadata")
        );
        return ApiResponse.ok(null, "Recorded");
    }

    @GetMapping("/businesses/{id}/insights")
    public ApiResponse<Map<String, Object>> insights(@PathVariable UUID id) {
        return ApiResponse.ok(analytics.insights(CurrentUser.require(), id));
    }
}
