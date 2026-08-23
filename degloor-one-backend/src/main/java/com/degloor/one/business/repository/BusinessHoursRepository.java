package com.degloor.one.business.repository;

import com.degloor.one.business.entity.BusinessHours;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BusinessHoursRepository extends JpaRepository<BusinessHours, UUID> {
    List<BusinessHours> findByBusinessIdOrderByDayOfWeekAsc(UUID businessId);
    Optional<BusinessHours> findByBusinessIdAndDayOfWeek(UUID businessId, int dayOfWeek);
    void deleteByBusinessId(UUID businessId);
}
