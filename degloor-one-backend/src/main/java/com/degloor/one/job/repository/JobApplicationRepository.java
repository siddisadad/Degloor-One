package com.degloor.one.job.repository;

import com.degloor.one.job.entity.JobApplication;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface JobApplicationRepository extends JpaRepository<JobApplication, UUID> {
    boolean existsByJobIdAndApplicantId(UUID jobId, UUID applicantId);
    Optional<JobApplication> findByJobIdAndApplicantId(UUID jobId, UUID applicantId);
    List<JobApplication> findByJobIdOrderByCreatedAtDesc(UUID jobId);
    List<JobApplication> findByApplicantIdOrderByCreatedAtDesc(UUID applicantId);
}
