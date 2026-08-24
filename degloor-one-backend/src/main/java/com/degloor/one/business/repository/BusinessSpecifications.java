package com.degloor.one.business.repository;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.entity.BusinessCategory;
import com.degloor.one.business.entity.City;
import com.degloor.one.common.repository.Specs;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
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
            if (verifiedOnly != null) {
                pred = cb.and(pred, verifiedOnly
                        ? cb.isTrue(root.get("verified"))
                        : cb.isFalse(root.get("verified")));
            }
            if (q != null && !q.isBlank()) {
                Subquery<UUID> categoryIds = query.subquery(UUID.class);
                Root<BusinessCategory> category = categoryIds.from(BusinessCategory.class);
                categoryIds.select(category.get("id"))
                        .where(Specs.likeContains(cb, category.get("name"), q));
                pred = cb.and(pred, cb.or(
                        Specs.likeContains(cb, root.get("name"), q),
                        Specs.likeContains(cb, root.get("description"), q),
                        Specs.likeContains(cb, root.get("subCategory"), q),
                        Specs.likeContains(cb, root.get("addressText"), q),
                        root.get("categoryId").in(categoryIds)
                ));
            }
            return pred;
        };
    }

    public static Specification<Business> inCity(String city) {
        if (city == null || city.isBlank()) {
            return (root, query, cb) -> cb.conjunction();
        }
        String name = city.trim();
        return (root, query, cb) -> {
            Subquery<UUID> cityIds = query.subquery(UUID.class);
            Root<City> cityRoot = cityIds.from(City.class);
            cityIds.select(cityRoot.get("id"))
                    .where(cb.equal(cb.lower(cityRoot.get("name")), name.toLowerCase()));
            return root.get("cityId").in(cityIds);
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
