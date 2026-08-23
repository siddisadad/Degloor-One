package com.degloor.one.business.repository;

import com.degloor.one.business.entity.Business;
import com.degloor.one.common.repository.Specs;
import jakarta.persistence.criteria.Predicate;
import java.util.UUID;
import org.springframework.data.jpa.domain.Specification;

public final class BusinessSpecifications {
    private BusinessSpecifications() {}

    public static Specification<Business> search(String q, UUID categoryId, Boolean verifiedOnly) {
        return (root, query, cb) -> {
            Predicate pred = cb.conjunction();
            if (categoryId != null) {
                pred = cb.and(pred, cb.equal(root.get("categoryId"), categoryId));
            }
            if (verifiedOnly != null && verifiedOnly) {
                pred = cb.and(pred, cb.isTrue(root.get("verified")));
            }
            if (q != null && !q.isBlank()) {
                pred = cb.and(pred, cb.or(
                        Specs.likeContains(cb, root.get("name"), q),
                        Specs.likeContains(cb, root.get("description"), q)
                ));
            }
            return pred;
        };
    }

    /** Coarse prefilter before exact Haversine in the service. */
    public static Specification<Business> withinBoundingBox(double lat, double lng, double radiusKm) {
        double dLat = radiusKm / 111.0;
        double cosLat = Math.max(0.2, Math.cos(Math.toRadians(lat)));
        double dLng = radiusKm / (111.0 * cosLat);
        return (root, query, cb) -> cb.and(
                cb.isNotNull(root.get("latitude")),
                cb.isNotNull(root.get("longitude")),
                cb.between(root.get("latitude"), lat - dLat, lat + dLat),
                cb.between(root.get("longitude"), lng - dLng, lng + dLng)
        );
    }
}
