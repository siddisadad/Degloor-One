package com.degloor.one.review.repository;

import com.degloor.one.review.entity.Review;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    List<Review> findByBusinessIdOrderByCreatedAtDesc(UUID businessId);
    boolean existsByUserIdAndBusinessId(UUID userId, UUID businessId);
    List<Review> findByUserIdAndBusinessId(UUID userId, UUID businessId);
}
