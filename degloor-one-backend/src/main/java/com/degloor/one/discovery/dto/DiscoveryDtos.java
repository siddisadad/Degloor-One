package com.degloor.one.discovery.dto;

import com.degloor.one.business.dto.BusinessDtos.BusinessResponse;
import com.degloor.one.job.dto.JobDtos.JobResponse;
import com.degloor.one.marketplace.dto.MarketplaceDtos.ProviderResponse;
import com.degloor.one.product.dto.ProductDtos.ProductResponse;
import java.util.List;
import java.util.Map;

public final class DiscoveryDtos {
    private DiscoveryDtos() {}

    public record MasterSearchResponse(
            List<BusinessResponse> shops,
            List<ProductResponse> products,
            List<ProviderResponse> services,
            List<JobResponse> jobs
    ) {}

    public record ShopInsightsResponse(
            int reviewCount,
            int profileViews,
            int callClicks,
            int whatsappClicks,
            int directionsClicks,
            Map<String, Integer> dailyCounts
    ) {
        public int inquiries() {
            return callClicks + whatsappClicks;
        }

        public double conversionRate() {
            return profileViews > 0 ? (double) inquiries() / profileViews * 100 : 0;
        }
    }
}
