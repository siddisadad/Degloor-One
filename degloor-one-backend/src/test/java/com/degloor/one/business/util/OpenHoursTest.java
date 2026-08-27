package com.degloor.one.business.util;

import com.degloor.one.business.dto.BusinessDtos.HoursResponse;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class OpenHoursTest {
    @Test
    void emptyHoursFollowsShopFlag() {
        assertTrue(OpenHours.currentlyOpen(true, List.of(), LocalDateTime.of(2026, 8, 24, 12, 0)));
        assertFalse(OpenHours.currentlyOpen(false, List.of(), LocalDateTime.of(2026, 8, 24, 12, 0)));
    }

    @Test
    void mondayWindowUsesSundayZeroWeekday() {
        HoursResponse monday = new HoursResponse(1, LocalTime.of(9, 0), LocalTime.of(18, 0), false);
        LocalDateTime mondayNoon = LocalDateTime.of(2026, 8, 24, 12, 0);
        assertTrue(OpenHours.currentlyOpen(true, List.of(monday), mondayNoon));
        assertFalse(OpenHours.currentlyOpen(true, List.of(monday), LocalDateTime.of(2026, 8, 24, 20, 0)));
        assertFalse(OpenHours.currentlyOpen(true, List.of(monday), LocalDateTime.of(2026, 8, 23, 12, 0)));
    }
}
