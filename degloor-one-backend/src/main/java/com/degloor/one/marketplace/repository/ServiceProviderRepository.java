package com.degloor.one.marketplace.repository;

import com.degloor.one.marketplace.entity.ServiceProvider;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ServiceProviderRepository extends JpaRepository<ServiceProvider, UUID> {
    Optional<ServiceProvider> findByUserId(UUID userId);
    List<ServiceProvider> findAllByOrderByIdAsc();
    List<ServiceProvider> findByCategoryIdOrderByIdAsc(UUID categoryId);
}
