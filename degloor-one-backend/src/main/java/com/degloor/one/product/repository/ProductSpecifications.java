package com.degloor.one.product.repository;

import com.degloor.one.common.repository.Specs;
import com.degloor.one.product.entity.Product;
import jakarta.persistence.criteria.Predicate;
import java.util.UUID;
import org.springframework.data.jpa.domain.Specification;

public final class ProductSpecifications {
    private ProductSpecifications() {}

    public static Specification<Product> search(
            String q,
            UUID businessId,
            UUID categoryId,
            Double minPrice,
            Double maxPrice,
            Boolean available
    ) {
        return (root, query, cb) -> {
            Predicate pred = cb.conjunction();
            if (q != null && !q.isBlank()) {
                pred = cb.and(pred, Specs.likeContains(cb, root.get("name"), q));
            }
            if (businessId != null) {
                pred = cb.and(pred, cb.equal(root.get("businessId"), businessId));
            }
            if (categoryId != null) {
                pred = cb.and(pred, cb.equal(root.get("categoryId"), categoryId));
            }
            if (minPrice != null) {
                pred = cb.and(pred, cb.ge(root.get("price"), minPrice));
            }
            if (maxPrice != null) {
                pred = cb.and(pred, cb.le(root.get("price"), maxPrice));
            }
            if (available != null) {
                pred = cb.and(pred, cb.equal(root.get("available"), available));
            }
            return pred;
        };
    }
}
