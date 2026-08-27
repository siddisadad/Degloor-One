package com.degloor.one.order.repository;

import com.degloor.one.order.entity.ShopOrder;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ShopOrderRepository extends JpaRepository<ShopOrder, UUID> {
    Page<ShopOrder> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);
    Page<ShopOrder> findByBusinessIdOrderByCreatedAtDesc(UUID businessId, Pageable pageable);
    Page<ShopOrder> findByStatusOrderByCreatedAtDesc(String status, Pageable pageable);
    List<ShopOrder> findByUserIdAndBusinessIdAndStatus(UUID userId, UUID businessId, String status);
    long countByBusinessIdAndStatus(UUID businessId, String status);

    @Query("""
            select o from ShopOrder o
            where o.status = :status
              and not exists (
                select 1 from DeliveryAssignment a where a.orderId = o.id
              )
            order by o.createdAt desc
            """)
    List<ShopOrder> findUnassignedByStatus(@Param("status") String status, Pageable pageable);
}
