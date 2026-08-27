package com.degloor.one.marketplace.repository;

import com.degloor.one.marketplace.entity.ServiceRequest;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ServiceRequestRepository extends JpaRepository<ServiceRequest, UUID> {
    List<ServiceRequest> findByUserIdOrderByCreatedAtDesc(UUID userId);
    List<ServiceRequest> findByProviderIdOrderByCreatedAtDesc(UUID providerId);
}
