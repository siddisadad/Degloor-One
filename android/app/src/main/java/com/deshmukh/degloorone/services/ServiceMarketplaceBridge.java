package com.deshmukh.degloorone.services;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Native Java implementation for Service Marketplace logic.
 * Demonstrates using Java programming for the services layer as requested.
 */
public class ServiceMarketplaceBridge implements MethodChannel.MethodCallHandler {
    
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "getNativeCategories":
                result.success(getCategories());
                break;
            case "getNativeProviders":
                String categoryId = call.argument("categoryId");
                result.success(getProviders(categoryId));
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private List<Map<String, Object>> getCategories() {
        List<Map<String, Object>> categories = new ArrayList<>();
        
        categories.add(createCategory("scat-electric", "Electrician (Native)", "electrical_services"));
        categories.add(createCategory("scat-plumb", "Plumber (Native)", "plumbing"));
        categories.add(createCategory("scat-carp", "Carpenter (Native)", "construction"));
        categories.add(createCategory("scat-clean", "Cleaner (Native)", "cleaning_services"));
        
        return categories;
    }

    private Map<String, Object> createCategory(String id, String name, String icon) {
        Map<String, Object> cat = new HashMap<>();
        cat.put("id", id);
        cat.put("name", name);
        cat.put("icon_name", icon);
        return cat;
    }

    private List<Map<String, Object>> getProviders(String categoryId) {
        List<Map<String, Object>> allProviders = new ArrayList<>();
        
        // Mock data logic in Java
        allProviders.add(createProvider(
            "sp-native-1", "user-electrician", "scat-electric",
            "Ravi Electrician", "Electrician", "Native Java Electrician", 450.0, 10));
        allProviders.add(createProvider(
            "sp-native-2", "user-plumber", "scat-plumb",
            "Amit Plumber", "Plumber", "Native Java Plumber", 350.0, 5));

        if (categoryId == null || categoryId.isEmpty()) {
            return allProviders;
        }

        List<Map<String, Object>> filtered = new ArrayList<>();
        for (Map<String, Object> p : allProviders) {
            if (categoryId.equals(p.get("category_id"))) {
                filtered.add(p);
            }
        }
        return filtered;
    }

    private Map<String, Object> createProvider(
        String id,
        String userId,
        String categoryId,
        String displayName,
        String categoryName,
        String bio,
        double rate,
        int years
    ) {
        Map<String, Object> p = new HashMap<>();
        p.put("id", id);
        p.put("user_id", userId);
        p.put("category_id", categoryId);
        p.put("bio", bio);
        p.put("hourly_rate", rate);
        p.put("experience_years", years);
        p.put("is_verified", true);

        Map<String, Object> user = new HashMap<>();
        user.put("full_name", displayName);
        p.put("users", user);

        Map<String, Object> cat = new HashMap<>();
        cat.put("name", categoryName);
        p.put("service_categories", cat);

        return p;
    }
}
