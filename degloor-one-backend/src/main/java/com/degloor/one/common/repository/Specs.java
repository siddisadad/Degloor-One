package com.degloor.one.common.repository;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Predicate;
import java.util.Locale;

/** Shared JPA specification helpers. */
public final class Specs {
    private Specs() {}

    public static String contains(String raw) {
        String escaped = raw.toLowerCase(Locale.ROOT)
                .replace("\\", "\\\\")
                .replace("%", "\\%")
                .replace("_", "\\_");
        return "%" + escaped + "%";
    }

    public static Predicate likeContains(CriteriaBuilder cb, Expression<String> path, String raw) {
        return cb.like(cb.lower(path), contains(raw), '\\');
    }
}
