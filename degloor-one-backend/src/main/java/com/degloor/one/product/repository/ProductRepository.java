package com.degloor.one.product.repository;

import com.degloor.one.product.entity.Product;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface ProductRepository extends JpaRepository<Product, UUID>, JpaSpecificationExecutor<Product> {
    List<Product> findByBusinessIdAndAvailableTrueOrderByNameAsc(UUID businessId);
    List<Product> findByBusinessIdOrderByNameAsc(UUID businessId);
}
