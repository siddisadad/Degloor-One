package com.degloor.one.business.dto;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.entity.BusinessCategory;
import com.degloor.one.business.entity.BusinessHours;
import com.degloor.one.business.util.OpenHours;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.time.LocalDateTime;
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

    public record BusinessQuery(
            String q,
            UUID categoryId,
            String city,
            Double lat,
            Double lng,
            Double radiusKm,
            Double latitude,
            Double longitude,
            Double radius,
            Boolean verified,
            Boolean openNow,
            Double minRating,
            Integer page,
            Integer size
    ) {
        public static final int DEFAULT_SIZE = 20;
        public static final double DEFAULT_RADIUS_KM = 5;

        public BusinessQuery resolved() {
            return new BusinessQuery(
                    q,
                    categoryId,
                    city,
                    first(lat, latitude),
                    first(lng, longitude),
                    first(radiusKm, radius),
                    null,
                    null,
                    null,
                    verified,
                    openNow,
                    minRating,
                    page,
                    size
            );
        }

        public BusinessQuery withCategory(UUID id) {
            return new BusinessQuery(
                    q, id, city, lat, lng, radiusKm, latitude, longitude, radius,
                    verified, openNow, minRating, page, size);
        }

        public BusinessQuery nearbyOrThrow() {
            BusinessQuery resolved = resolved();
            if (resolved.lat() == null || resolved.lng() == null) {
                throw com.degloor.one.common.exception.BusinessException.badRequest(
                        "INVALID_LOCATION", "Nearby search needs latitude and longitude");
            }
            return new BusinessQuery(
                    resolved.q(),
                    resolved.categoryId(),
                    resolved.city(),
                    resolved.lat(),
                    resolved.lng(),
                    resolved.radiusKm() == null ? DEFAULT_RADIUS_KM : resolved.radiusKm(),
                    null,
                    null,
                    null,
                    resolved.verified(),
                    resolved.openNow(),
                    resolved.minRating(),
                    resolved.page(),
                    resolved.size()
            );
        }

        private static Double first(Double primary, Double alias) {
            return primary != null ? primary : alias;
        }
    }

    public record BusinessResponse(
            String id,
            String ownerId,
            String name,
            String ownerName,
            String description,
            String categoryId,
            String category,
            String subCategory,
            String cityId,
            String city,
            String addressText,
            String whatsappNumber,
            String phoneNumber,
            Double latitude,
            Double longitude,
            Double discoveryRadius,
            double rating,
            long reviewCount,
            boolean open,
            boolean currentlyOpen,
            boolean verified,
            String verificationStatus,
            String imageUrl,
            List<String> photos,
            String source,
            Instant createdAt,
            Instant updatedAt,
            Double distanceKm,
            List<HoursResponse> hours
    ) {
        public static BusinessResponse from(
                Business b,
                List<HoursResponse> hours,
                Double distanceKm,
                String categoryName,
                String cityName,
                long reviewCount
        ) {
            List<HoursResponse> openHours = hours == null ? List.of() : hours;
            List<String> photos = b.getPhotos() == null ? List.of() : List.copyOf(b.getPhotos());
            if (photos.isEmpty() && b.getImageUrl() != null && !b.getImageUrl().isBlank()) {
                photos = List.of(b.getImageUrl());
            }
            String cover = b.getImageUrl() == null || b.getImageUrl().isBlank()
                    ? (photos.isEmpty() ? null : photos.get(0))
                    : b.getImageUrl();
            boolean currentlyOpen = OpenHours.currentlyOpen(b.isOpen(), openHours, LocalDateTime.now());
            return new BusinessResponse(
                    b.getId().toString(),
                    b.getOwnerId().toString(),
                    b.getName(),
                    b.getOwnerName(),
                    b.getDescription(),
                    b.getCategoryId() == null ? null : b.getCategoryId().toString(),
                    categoryName,
                    b.getSubCategory(),
                    b.getCityId() == null ? null : b.getCityId().toString(),
                    cityName,
                    b.getAddressText(),
                    b.getWhatsappNumber(),
                    b.getPhoneNumber(),
                    b.getLatitude(),
                    b.getLongitude(),
                    b.getDiscoveryRadius(),
                    b.getRating(),
                    reviewCount,
                    b.isOpen(),
                    currentlyOpen,
                    b.isVerified(),
                    b.isVerified() ? "VERIFIED" : "PENDING_VERIFICATION",
                    cover,
                    photos,
                    b.getSource() == null || b.getSource().isBlank() ? "owner" : b.getSource(),
                    b.getCreatedAt(),
                    b.getUpdatedAt(),
                    distanceKm,
                    openHours
            );
        }

        @JsonProperty("businessId")
        public String businessId() {
            return id;
        }

        @JsonProperty("businessName")
        public String businessName() {
            return name;
        }

        @JsonProperty("address")
        public String address() {
            return addressText;
        }

        @JsonProperty("phone")
        public String phone() {
            return phoneNumber;
        }

        @JsonProperty("lastUpdated")
        public Instant lastUpdated() {
            return updatedAt;
        }
    }

    public record UpsertBusinessRequest(
            @NotBlank @Size(max = 160) String name,
            String ownerName,
            String description,
            UUID categoryId,
            String subCategory,
            UUID cityId,
            String addressText,
            String whatsappNumber,
            String phoneNumber,
            Double latitude,
            Double longitude,
            Double discoveryRadius,
            Boolean open,
            String imageUrl,
            List<String> photos,
            List<HoursRequest> hours
    ) {}
}
