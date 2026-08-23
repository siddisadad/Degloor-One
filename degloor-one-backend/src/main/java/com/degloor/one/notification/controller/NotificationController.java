package com.degloor.one.notification.controller;

import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.response.PageResponse;
import com.degloor.one.common.security.CurrentUser;
import com.degloor.one.notification.dto.NotificationDtos.NotificationResponse;
import com.degloor.one.notification.service.NotificationService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.Map;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/notifications")
@Tag(name = "Notifications")
@SecurityRequirement(name = "bearer-jwt")
public class NotificationController {
    private final NotificationService notifications;

    public NotificationController(NotificationService notifications) {
        this.notifications = notifications;
    }

    @GetMapping
    public ApiResponse<PageResponse<NotificationResponse>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.ok(notifications.list(CurrentUser.require(), page, size));
    }

    @GetMapping("/unread-count")
    public ApiResponse<Map<String, Long>> unread() {
        return ApiResponse.ok(Map.of("count", notifications.unread(CurrentUser.require())));
    }

    @PostMapping("/{id}/read")
    public ApiResponse<Void> read(@PathVariable UUID id) {
        notifications.markRead(CurrentUser.require(), id);
        return ApiResponse.ok(null, "Read");
    }

    @PostMapping("/read-all")
    public ApiResponse<Void> readAll() {
        notifications.markAllRead(CurrentUser.require());
        return ApiResponse.ok(null, "Read");
    }
}
