package com.degloor.one.notification.repository;

import com.degloor.one.notification.entity.Notification;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    Page<Notification> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);
    long countByUserIdAndReadFalse(UUID userId);
    List<Notification> findByUserIdAndReadFalse(UUID userId);
}
