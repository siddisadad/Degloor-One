package com.degloor.one.review.repository;

import com.degloor.one.review.entity.Complaint;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ComplaintRepository extends JpaRepository<Complaint, UUID> {
    List<Complaint> findByUserIdOrderByCreatedAtDesc(UUID userId);
    Page<Complaint> findAllByOrderByCreatedAtDesc(Pageable pageable);
    long countByStatusNot(String status);
}
