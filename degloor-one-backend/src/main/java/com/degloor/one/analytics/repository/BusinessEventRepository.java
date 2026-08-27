package com.degloor.one.analytics.repository;

import com.degloor.one.analytics.entity.BusinessEvent;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BusinessEventRepository extends JpaRepository<BusinessEvent, UUID> {
    List<BusinessEvent> findByBusinessId(UUID businessId);
    long countByBusinessIdAndEventType(UUID businessId, String eventType);

    @Query("""
            select e.eventType as eventType, count(e) as total
            from BusinessEvent e
            where e.businessId = :businessId
            group by e.eventType
            """)
    List<EventTypeCount> countGroupedByEventType(@Param("businessId") UUID businessId);

    interface EventTypeCount {
        String getEventType();
        long getTotal();
    }
}
