package com.degloor.one.business.util;

import com.degloor.one.business.dto.BusinessDtos.HoursResponse;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/** Same Sunday=0 weekday rule as Flutter [ShopHours.isOpenNow]. */
public final class OpenHours {
    private OpenHours() {}

    public static boolean currentlyOpen(boolean shopOpen, List<HoursResponse> hours, LocalDateTime at) {
        if (!shopOpen) {
            return false;
        }
        if (hours == null || hours.isEmpty()) {
            return true;
        }
        int dayOfWeek = at.getDayOfWeek().getValue() % 7;
        int currentMinutes = at.getHour() * 60 + at.getMinute();
        for (HoursResponse row : hours) {
            if (row.dayOfWeek() != dayOfWeek) {
                continue;
            }
            if (row.closed()) {
                return false;
            }
            LocalTime open = row.openTime();
            LocalTime close = row.closeTime();
            if (open == null || close == null) {
                return false;
            }
            int openMinutes = open.getHour() * 60 + open.getMinute();
            int closeMinutes = close.getHour() * 60 + close.getMinute();
            if (closeMinutes > openMinutes) {
                return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
            }
            return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
        }
        return false;
    }
}
