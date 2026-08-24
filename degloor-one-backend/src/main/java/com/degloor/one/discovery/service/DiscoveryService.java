package com.degloor.one.discovery.service;

import com.degloor.one.analytics.repository.BusinessEventRepository;
import com.degloor.one.analytics.repository.BusinessEventRepository.EventTypeCount;
import com.degloor.one.business.dto.BusinessDtos.BusinessQuery;
import com.degloor.one.business.dto.BusinessDtos.BusinessResponse;
import com.degloor.one.business.service.BusinessService;
import com.degloor.one.discovery.dto.DiscoveryDtos.MasterSearchResponse;
import com.degloor.one.discovery.dto.DiscoveryDtos.ShopInsightsResponse;
import com.degloor.one.job.dto.JobDtos.JobResponse;
import com.degloor.one.job.service.JobService;
import com.degloor.one.marketplace.dto.MarketplaceDtos.ProviderResponse;
import com.degloor.one.marketplace.service.MarketplaceService;
import com.degloor.one.product.dto.ProductDtos.ProductResponse;
import com.degloor.one.product.service.ProductService;
import com.degloor.one.review.repository.ReviewRepository;
import com.degloor.one.user.entity.UserAccount;
import org.springframework.stereotype.Service;

import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class DiscoveryService {
    private static final DateTimeFormatter DATE_KEY = DateTimeFormatter.ofPattern("MM/dd")
            .withZone(ZoneId.of("Asia/Kolkata"));

    private final BusinessService businesses;
    private final ProductService products;
    private final MarketplaceService marketplace;
    private final JobService jobs;
    private final ReviewRepository reviews;
    private final BusinessEventRepository events;

    public DiscoveryService(
            BusinessService businesses,
            ProductService products,
            MarketplaceService marketplace,
            JobService jobs,
            ReviewRepository reviews,
            BusinessEventRepository events
    ) {
        this.businesses = businesses;
        this.products = products;
        this.marketplace = marketplace;
        this.jobs = jobs;
        this.reviews = reviews;
        this.events = events;
    }

    public MasterSearchResponse masterSearch(
            String q,
            Double lat,
            Double lng,
            Double radiusKm,
            String scope
    ) {
        boolean all = scope == null || "all".equalsIgnoreCase(scope);
        boolean wantShops = all || "shops".equalsIgnoreCase(scope);
        boolean wantProducts = all || "products".equalsIgnoreCase(scope);
        boolean wantServices = all || "services".equalsIgnoreCase(scope);
        boolean wantJobs = all || "jobs".equalsIgnoreCase(scope);

        List<BusinessResponse> shopList = wantShops
                ? businesses.search(new BusinessQuery(
                        q, null, null, lat, lng, radiusKm, null, null, null, true, null, null, 0, 50
                )).items()
                : List.of();

        List<ProductResponse> productList = wantProducts ?
                products.search(q, null, null, null, null, true, 0, 50, "name").items() : List.of();

        List<ProviderResponse> serviceList = wantServices ?
                marketplace.providers(null) : List.of();

        List<JobResponse> jobList = wantJobs ?
                jobs.search(q, null) : List.of();

        return new MasterSearchResponse(shopList, productList, serviceList, jobList);
    }

    public ShopInsightsResponse insightsFor(UserAccount user, UUID businessId) {
        businesses.requireOwned(user, businessId);
        int reviewCount = (int) reviews.countByBusinessId(businessId);

        Map<String, Long> counts = new HashMap<>();
        Map<String, Integer> daily = new TreeMap<>();
        
        events.findByBusinessId(businessId).forEach(event -> {
            String type = event.getEventType();
            counts.put(type, counts.getOrDefault(type, 0L) + 1);
            
            String date = DATE_KEY.format(event.getCreatedAt());
            daily.put(date, daily.getOrDefault(date, 0) + 1);
        });

        return new ShopInsightsResponse(
                reviewCount,
                counts.getOrDefault("PROFILE_VIEW", 0L).intValue(),
                counts.getOrDefault("CALL_CLICK", 0L).intValue(),
                counts.getOrDefault("WHATSAPP_CLICK", 0L).intValue(),
                counts.getOrDefault("DIRECTIONS_CLICK", 0L).intValue(),
                daily
        );
    }
}
