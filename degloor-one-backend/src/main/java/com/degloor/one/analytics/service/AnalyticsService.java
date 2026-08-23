package com.degloor.one.analytics.service;

import com.degloor.one.analytics.entity.BusinessEvent;
import com.degloor.one.analytics.repository.BusinessEventRepository;
import com.degloor.one.business.service.BusinessService;
import com.degloor.one.user.entity.UserAccount;
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
        return Map.of(
                "businessId", businessId.toString(),
                "events", events.countByBusinessIdAndEventType(businessId, "PROFILE_VIEW")
                        + events.countByBusinessIdAndEventType(businessId, "PRODUCT_VIEW")
                        + events.countByBusinessIdAndEventType(businessId, "CALL_CLICK")
                        + events.countByBusinessIdAndEventType(businessId, "WHATSAPP_CLICK")
                        + events.countByBusinessIdAndEventType(businessId, "REVIEW_SUBMITTED"),
                "profileViews", events.countByBusinessIdAndEventType(businessId, "PROFILE_VIEW"),
                "productViews", events.countByBusinessIdAndEventType(businessId, "PRODUCT_VIEW"),
                "calls", events.countByBusinessIdAndEventType(businessId, "CALL_CLICK"),
                "whatsapp", events.countByBusinessIdAndEventType(businessId, "WHATSAPP_CLICK"),
                "reviews", events.countByBusinessIdAndEventType(businessId, "REVIEW_SUBMITTED")
        );
    }
}
