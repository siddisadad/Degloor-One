package com.degloor.one.notification.service;

import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.response.PageResponse;
import com.degloor.one.notification.dto.NotificationDtos.NotificationResponse;
import com.degloor.one.notification.entity.Notification;
import com.degloor.one.notification.repository.NotificationRepository;
import com.degloor.one.user.entity.UserAccount;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NotificationService {
    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);
    private final NotificationRepository notifications;

    public NotificationService(NotificationRepository notifications) {
        this.notifications = notifications;
    }

    public PageResponse<NotificationResponse> list(UserAccount user, int page, int size) {
        var result = notifications.findByUserIdOrderByCreatedAtDesc(
                user.getId(), PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50)));
        return PageResponse.from(result.map(NotificationResponse::from));
    }

    public long unread(UserAccount user) {
        return notifications.countByUserIdAndReadFalse(user.getId());
    }

    @Transactional
    public void markRead(UserAccount user, UUID id) {
        Notification n = notifications.findById(id)
                .orElseThrow(() -> BusinessException.notFound("NOTIFICATION_NOT_FOUND", "Notification not found"));
        if (!n.getUserId().equals(user.getId())) {
            throw BusinessException.forbidden("FORBIDDEN", "Not your notification");
        }
        n.setRead(true);
        notifications.save(n);
    }

    @Transactional
    public void markAllRead(UserAccount user) {
        for (Notification n : notifications.findByUserIdAndReadFalse(user.getId())) {
            n.setRead(true);
            notifications.save(n);
        }
    }

    public void notifyQuietly(UUID userId, String title, String message, String type) {
        try {
            Notification n = new Notification();
            n.setUserId(userId);
            n.setTitle(title);
            n.setMessage(message);
            n.setType(type);
            notifications.save(n);
        } catch (Exception e) {
            log.warn("businessEvent=NOTIFY_FAILED userId={}", userId);
        }
    }
}
