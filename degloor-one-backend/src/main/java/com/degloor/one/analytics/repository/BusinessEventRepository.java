package com.degloor.one.analytics.repository;

import com.degloor.one.analytics.entity.BusinessEvent;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BusinessEventRepository extends JpaRepository<BusinessEvent, UUID> {
    List<BusinessEvent> findByBusinessId(UUID businessId);
    long countByBusinessIdAndEventType(UUID businessId, String eventType);
}
