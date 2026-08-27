package com.deshmukh.degloorone.services;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Native Java implementation for Discovery logic.
 */
public class DiscoveryBridge implements MethodChannel.MethodCallHandler {
    
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "getNativeDiscoveryCategories":
                result.success(getCategories());
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private List<Map<String, Object>> getCategories() {
        List<Map<String, Object>> categories = new ArrayList<>();
        
        categories.add(createCategory("cat-grocery", "Grocery (Native)", "shopping_basket_rounded", 1));
        categories.add(createCategory("cat-food", "Food (Native)", "restaurant_rounded", 2));
        
        return categories;
    }

    private Map<String, Object> createCategory(String id, String name, String icon, int order) {
        Map<String, Object> cat = new HashMap<>();
        cat.put("id", id);
        cat.put("name", name);
        cat.put("icon_name", icon);
        cat.put("display_order", order);
        return cat;
    }
}
