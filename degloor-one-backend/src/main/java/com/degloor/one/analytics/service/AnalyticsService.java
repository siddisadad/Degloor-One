package com.degloor.one.analytics.service;

import com.degloor.one.analytics.entity.BusinessEvent;
import com.degloor.one.analytics.repository.BusinessEventRepository;
import com.degloor.one.analytics.repository.BusinessEventRepository.EventTypeCount;
import com.degloor.one.business.service.BusinessService;
import com.degloor.one.user.entity.UserAccount;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class AnalyticsService {
    private final BusinessEventRepository events;
    private final BusinessService businesses;

    public AnalyticsService(BusinessEventRepository events, BusinessService businesses) {
        this.events = events;
        this.businesses = businesses;
    }

    public void track(UserAccount user, UUID businessId, String eventType, String metadata) {
        businesses.require(businessId);
        BusinessEvent event = new BusinessEvent();
        event.setBusinessId(businessId);
        event.setUserId(user == null ? null : user.getId());
        event.setEventType(eventType == null ? "UNKNOWN" : eventType);
        event.setMetadata(metadata);
        events.save(event);
    }

    public Map<String, Object> insights(UserAccount user, UUID businessId) {
        businesses.requireOwned(user, businessId);
        Map<String, Long> counts = new HashMap<>();
        for (EventTypeCount row : events.countGroupedByEventType(businessId)) {
            counts.put(row.getEventType(), row.getTotal());
        }
        long profileViews = counts.getOrDefault("PROFILE_VIEW", 0L);
        long productViews = counts.getOrDefault("PRODUCT_VIEW", 0L);
        long calls = counts.getOrDefault("CALL_CLICK", 0L);
        long whatsapp = counts.getOrDefault("WHATSAPP_CLICK", 0L);
        long reviews = counts.getOrDefault("REVIEW_SUBMITTED", 0L);
        return Map.of(
                "businessId", businessId.toString(),
                "events", profileViews + productViews + calls + whatsapp + reviews,
                "profileViews", profileViews,
                "productViews", productViews,
                "calls", calls,
                "whatsapp", whatsapp,
                "reviews", reviews
        );
    }
}
