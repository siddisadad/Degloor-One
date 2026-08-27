package com.degloor.one.job.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "jobs")
public class JobPosting {
    @Id
    private UUID id;
    @Column(name = "business_id", nullable = false)
    private UUID businessId;
    @Column(name = "poster_id", nullable = false)
    private UUID posterId;
    @Column(nullable = false)
    private String title;
    @Column(nullable = false)
    private String description;
    private String category;
    @Column(name = "job_type", nullable = false)
    private String jobType;
    @Column(name = "salary_range")
    private String salaryRange;
    @Column(name = "location_text")
    private String locationText;
    @Column(name = "is_active", nullable = false)
    private boolean active = true;
    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() {
        if (id == null) id = UUID.randomUUID();
        if (createdAt == null) createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public UUID getBusinessId() { return businessId; }
    public void setBusinessId(UUID businessId) { this.businessId = businessId; }
    public UUID getPosterId() { return posterId; }
    public void setPosterId(UUID posterId) { this.posterId = posterId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getJobType() { return jobType; }
    public void setJobType(String jobType) { this.jobType = jobType; }
    public String getSalaryRange() { return salaryRange; }
    public void setSalaryRange(String salaryRange) { this.salaryRange = salaryRange; }
    public String getLocationText() { return locationText; }
    public void setLocationText(String locationText) { this.locationText = locationText; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Instant getCreatedAt() { return createdAt; }
}
