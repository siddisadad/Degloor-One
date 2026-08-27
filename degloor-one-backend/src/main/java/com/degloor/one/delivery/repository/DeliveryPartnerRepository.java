package com.degloor.one.delivery.repository;

import com.degloor.one.delivery.entity.DeliveryPartner;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeliveryPartnerRepository extends JpaRepository<DeliveryPartner, UUID> {
    Optional<DeliveryPartner> findByUserId(UUID userId);
}
