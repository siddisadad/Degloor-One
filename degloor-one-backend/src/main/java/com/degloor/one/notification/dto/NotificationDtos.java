package com.degloor.one.notification.dto;

import com.degloor.one.notification.entity.Notification;
import java.time.Instant;

public final class NotificationDtos {
    private NotificationDtos() {}

    public record NotificationResponse(
            String id,
            String title,
            String message,
            String type,
            boolean read,
            Instant createdAt
    ) {
        public static NotificationResponse from(Notification n) {
            return new NotificationResponse(
                    n.getId().toString(),
                    n.getTitle(),
                    n.getMessage(),
                    n.getType(),
                    n.isRead(),
                    n.getCreatedAt()
            );
        }
    }
}
