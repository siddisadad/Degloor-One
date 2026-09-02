package com.degloor.one.product.repository;

import com.degloor.one.product.entity.Product;
import jakarta.persistence.LockModeType;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProductRepository extends JpaRepository<Product, UUID>, JpaSpecificationExecutor<Product> {
    List<Product> findByBusinessIdAndAvailableTrueOrderByNameAsc(UUID businessId);
    List<Product> findByBusinessIdOrderByNameAsc(UUID businessId);

    /** Row locks used by checkout / cancel stock adjustments to prevent oversell. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from Product p where p.id in :ids")
    List<Product> findAllByIdForUpdate(@Param("ids") Collection<UUID> ids);
}
