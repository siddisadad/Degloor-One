package com.degloor.one.job.repository;

import com.degloor.one.common.repository.Specs;
import com.degloor.one.job.entity.JobPosting;
import jakarta.persistence.criteria.Predicate;
import java.util.Locale;
import org.springframework.data.jpa.domain.Specification;

public final class JobSpecifications {
    private JobSpecifications() {}

    public static Specification<JobPosting> search(String q, String category) {
        return search(q, category, null);
    }

    public static Specification<JobPosting> search(String q, String category, String jobType) {
        return (root, query, cb) -> {
            Predicate pred = cb.isTrue(root.get("active"));
            if (category != null && !category.isBlank()) {
                pred = cb.and(pred, cb.equal(cb.lower(root.get("category")), category.toLowerCase(Locale.ROOT)));
            }
            if (jobType != null && !jobType.isBlank()) {
                pred = cb.and(pred, cb.equal(cb.lower(root.get("jobType")), jobType.toLowerCase(Locale.ROOT)));
            }
            if (q != null && !q.isBlank()) {
                pred = cb.and(pred, cb.or(
                        Specs.likeContains(cb, root.get("title"), q),
                        Specs.likeContains(cb, root.get("description"), q)
                ));
            }
            return pred;
        };
    }
}
