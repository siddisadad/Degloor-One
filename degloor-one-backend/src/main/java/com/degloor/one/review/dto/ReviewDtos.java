package com.degloor.one.review.dto;

import com.degloor.one.review.entity.Complaint;
import com.degloor.one.review.entity.Review;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;
import java.util.UUID;

public final class ReviewDtos {
    private ReviewDtos() {}

    public record CreateReviewRequest(
            @NotNull UUID businessId,
            UUID orderId,
            @Min(1) @Max(5) int rating,
            String comment
    ) {}

    public record ReviewResponse(String id, String userId, String businessId, String orderId, int rating, String comment, Instant createdAt) {
        public static ReviewResponse from(Review r) {
            return new ReviewResponse(
                    r.getId().toString(),
                    r.getUserId().toString(),
                    r.getBusinessId().toString(),
                    r.getOrderId() == null ? null : r.getOrderId().toString(),
                    r.getRating(),
                    r.getComment(),
                    r.getCreatedAt()
            );
        }
    }

    public record CreateComplaintRequest(
            UUID orderId,
            UUID businessId,
            @NotBlank String subject,
            @NotBlank String description
    ) {}

    public record ComplaintResponse(String id, String userId, String orderId, String businessId, String subject, String description, String status, Instant createdAt) {
        public static ComplaintResponse from(Complaint c) {
            return new ComplaintResponse(
                    c.getId().toString(),
                    c.getUserId().toString(),
                    c.getOrderId() == null ? null : c.getOrderId().toString(),
                    c.getBusinessId() == null ? null : c.getBusinessId().toString(),
                    c.getSubject(),
                    c.getDescription(),
                    c.getStatus(),
                    c.getCreatedAt()
            );
        }
    }
}
