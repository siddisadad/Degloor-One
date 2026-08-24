package com.degloor.one.business.dto;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.entity.BusinessCategory;
import com.degloor.one.business.entity.BusinessHours;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public final class BusinessDtos {
    private BusinessDtos() {}

    public record CategoryResponse(String id, String name, String iconName, int displayOrder) {
        public static CategoryResponse from(BusinessCategory c) {
            return new CategoryResponse(c.getId().toString(), c.getName(), c.getIconName(), c.getDisplayOrder());
        }
    }

    public record HoursResponse(int dayOfWeek, LocalTime openTime, LocalTime closeTime, boolean closed) {
        public static HoursResponse from(BusinessHours h) {
            return new HoursResponse(h.getDayOfWeek(), h.getOpenTime(), h.getCloseTime(), h.isClosed());
        }
    }

    public record HoursRequest(int dayOfWeek, LocalTime openTime, LocalTime closeTime, boolean closed) {}

    public record BusinessResponse(
            String id,
            String ownerId,
            String name,
            String ownerName,
            String description,
            String categoryId,
            String cityId,
            String addressText,
            String whatsappNumber,
            String phoneNumber,
            Double latitude,
            Double longitude,
            double rating,
            boolean open,
            boolean verified,
            String imageUrl,
            Instant createdAt,
            Double distanceKm,
            List<HoursResponse> hours
    ) {
        public static BusinessResponse from(Business b, List<HoursResponse> hours, Double distanceKm) {
            return new BusinessResponse(
                    b.getId().toString(),
                    b.getOwnerId().toString(),
                    b.getName(),
                    b.getOwnerName(),
                    b.getDescription(),
                    b.getCategoryId() == null ? null : b.getCategoryId().toString(),
                    b.getCityId() == null ? null : b.getCityId().toString(),
                    b.getAddressText(),
                    b.getWhatsappNumber(),
                    b.getPhoneNumber(),
                    b.getLatitude(),
                    b.getLongitude(),
                    b.getRating(),
                    b.isOpen(),
                    b.isVerified(),
                    b.getImageUrl(),
                    b.getCreatedAt(),
                    distanceKm,
                    hours
            );
        }
    }

    public record UpsertBusinessRequest(
            @NotBlank @Size(max = 160) String name,
            String ownerName,
            String description,
            UUID categoryId,
            UUID cityId,
            String addressText,
            String whatsappNumber,
            String phoneNumber,
            Double latitude,
            Double longitude,
            Boolean open,
            String imageUrl,
            List<HoursRequest> hours
    ) {}
}
