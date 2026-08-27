package com.degloor.one.job.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "job_applications")
public class JobApplication {
    @Id
    private UUID id;
    @Column(name = "job_id", nullable = false)
    private UUID jobId;
    @Column(name = "applicant_id", nullable = false)
    private UUID applicantId;
    @Column(name = "experience_summary")
    private String experienceSummary;
    @Column(nullable = false)
    private String status = "applied";
    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() {
        if (id == null) id = UUID.randomUUID();
        if (createdAt == null) createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public UUID getJobId() { return jobId; }
    public void setJobId(UUID jobId) { this.jobId = jobId; }
    public UUID getApplicantId() { return applicantId; }
    public void setApplicantId(UUID applicantId) { this.applicantId = applicantId; }
    public String getExperienceSummary() { return experienceSummary; }
    public void setExperienceSummary(String experienceSummary) { this.experienceSummary = experienceSummary; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
