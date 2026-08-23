package com.degloor.one.delivery.repository;

import com.degloor.one.delivery.entity.DeliveryAssignment;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeliveryAssignmentRepository extends JpaRepository<DeliveryAssignment, UUID> {
    Optional<DeliveryAssignment> findByOrderId(UUID orderId);
    List<DeliveryAssignment> findByDeliveryPartnerIdAndStatusNot(UUID partnerId, String status);
    boolean existsByOrderId(UUID orderId);
    boolean existsByDeliveryPartnerIdAndStatusNot(UUID partnerId, String status);
}
