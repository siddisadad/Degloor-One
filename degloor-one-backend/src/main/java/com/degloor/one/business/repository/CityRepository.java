package com.degloor.one.business.repository;

import com.degloor.one.business.entity.City;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CityRepository extends JpaRepository<City, UUID> {
    Optional<City> findByNameIgnoreCase(String name);
}
