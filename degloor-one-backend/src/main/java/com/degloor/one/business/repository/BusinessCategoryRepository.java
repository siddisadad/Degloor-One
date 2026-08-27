package com.degloor.one.business.repository;

import com.degloor.one.business.entity.BusinessCategory;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BusinessCategoryRepository extends JpaRepository<BusinessCategory, UUID> {
    List<BusinessCategory> findAllByOrderByDisplayOrderAsc();
    java.util.Optional<BusinessCategory> findByNameIgnoreCase(String name);
}
