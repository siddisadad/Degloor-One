package com.degloor.one.common.util;

public final class Geo {
    private Geo() {}

    public static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        double r = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 2 * r * Math.asin(Math.min(1, Math.sqrt(a)));
    }

    public static double deliveryFee(double km) {
        if (km <= 3) {
            return 20.0;
        }
        return 20.0 + Math.ceil(km - 3) * 10.0;
    }

    public static void requireCoordinates(Double lat, Double lng) {
        if (lat == null || lng == null || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
            throw com.degloor.one.common.exception.BusinessException.badRequest(
                    "INVALID_LOCATION", "Please pick a valid location");
        }
    }
}
