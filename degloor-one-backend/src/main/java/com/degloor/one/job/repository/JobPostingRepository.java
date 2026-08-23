package com.degloor.one.job.repository;

import com.degloor.one.job.entity.JobPosting;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface JobPostingRepository extends JpaRepository<JobPosting, UUID>, JpaSpecificationExecutor<JobPosting> {
    List<JobPosting> findByActiveTrueOrderByCreatedAtDesc();
    List<JobPosting> findByBusinessIdOrderByCreatedAtDesc(UUID businessId);
}
