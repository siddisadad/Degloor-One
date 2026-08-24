package com.degloor.one.review.repository;

import com.degloor.one.review.entity.Review;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    List<Review> findByBusinessIdOrderByCreatedAtDesc(UUID businessId);
    long countByBusinessId(UUID businessId);
    boolean existsByUserIdAndBusinessId(UUID userId, UUID businessId);
    List<Review> findByUserIdAndBusinessId(UUID userId, UUID businessId);

    @Query("select r.businessId, count(r) from Review r where r.businessId in :ids group by r.businessId")
    List<Object[]> countGroupedByBusinessId(@Param("ids") Collection<UUID> ids);
}
