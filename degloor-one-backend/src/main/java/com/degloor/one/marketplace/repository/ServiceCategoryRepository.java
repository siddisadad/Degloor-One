package com.degloor.one.marketplace.repository;

import com.degloor.one.marketplace.entity.ServiceCategory;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ServiceCategoryRepository extends JpaRepository<ServiceCategory, UUID> {
    List<ServiceCategory> findAllByOrderByNameAsc();
}
