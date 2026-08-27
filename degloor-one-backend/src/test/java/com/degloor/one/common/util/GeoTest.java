package com.degloor.one.common.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class GeoTest {
    @Test
    void feeIsTwentyWithinThreeKm() {
        assertEquals(20.0, Geo.deliveryFee(0));
        assertEquals(20.0, Geo.deliveryFee(3));
    }

    @Test
    void feeAddsTenPerExtraKm() {
        assertEquals(30.0, Geo.deliveryFee(3.1));
        assertEquals(40.0, Geo.deliveryFee(5));
    }

    @Test
    void degloorSelfDistanceIsZero() {
        assertTrue(Geo.haversineKm(18.5522, 77.5844, 18.5522, 77.5844) < 0.01);
    }
}
