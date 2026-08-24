package com.degloor.one.marketplace.dto;

import com.degloor.one.marketplace.entity.ServiceCategory;
import com.degloor.one.marketplace.entity.ServiceProvider;
import com.degloor.one.marketplace.entity.ServiceRequest;
import com.degloor.one.user.entity.UserAccount;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;
import java.util.UUID;

public final class MarketplaceDtos {
    private MarketplaceDtos() {}

    public record CategoryResponse(String id, String name, String iconName) {
        public static CategoryResponse from(ServiceCategory c) {
            return new CategoryResponse(c.getId().toString(), c.getName(), c.getIconName());
        }
    }

    public record ProviderResponse(
            String id,
            String userId,
            String categoryId,
            String bio,
            Double hourlyRate,
            Integer experienceYears,
            boolean verified,
            String fullName,
            String phoneNumber,
            String avatarUrl
    ) {
        public static ProviderResponse from(ServiceProvider p, UserAccount user) {
            return new ProviderResponse(
                    p.getId().toString(),
                    p.getUserId().toString(),
                    p.getCategoryId() == null ? null : p.getCategoryId().toString(),
                    p.getBio(),
                    p.getHourlyRate(),
                    p.getExperienceYears(),
                    p.isVerified(),
                    user == null ? null : user.getFullName(),
                    user == null ? null : user.getPhoneNumber(),
                    user == null ? null : user.getAvatarUrl()
            );
        }
    }

    public record RegisterProviderRequest(UUID categoryId, String bio, Double hourlyRate, Integer experienceYears) {}

    public record CreateRequestDto(@NotNull UUID providerId, @NotBlank String description, Instant scheduledAt) {}

    public record RequestResponse(
            String id,
            String userId,
            String providerId,
            String description,
            String status,
            Instant scheduledAt,
            Instant createdAt
    ) {
        public static RequestResponse from(ServiceRequest r) {
            return new RequestResponse(
                    r.getId().toString(),
                    r.getUserId().toString(),
                    r.getProviderId().toString(),
                    r.getDescription(),
                    r.getStatus(),
                    r.getScheduledAt(),
                    r.getCreatedAt()
            );
        }
    }
}
