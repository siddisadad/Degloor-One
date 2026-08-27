package com.degloor.one.job.dto;

import com.degloor.one.job.entity.JobApplication;
import com.degloor.one.job.entity.JobPosting;
import com.degloor.one.user.entity.UserAccount;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;
import java.util.UUID;

public final class JobDtos {
    private JobDtos() {}

    public record JobResponse(
            String id,
            String businessId,
            String posterId,
            String title,
            String description,
            String category,
            String jobType,
            String salaryRange,
            String locationText,
            boolean active,
            Instant createdAt
    ) {
        public static JobResponse from(JobPosting j) {
            return new JobResponse(
                    j.getId().toString(),
                    j.getBusinessId().toString(),
                    j.getPosterId().toString(),
                    j.getTitle(),
                    j.getDescription(),
                    j.getCategory(),
                    j.getJobType(),
                    j.getSalaryRange(),
                    j.getLocationText(),
                    j.isActive(),
                    j.getCreatedAt()
            );
        }
    }

    public record UpsertJobRequest(
            @NotNull UUID businessId,
            @NotBlank String title,
            @NotBlank String description,
            String category,
            @NotBlank String jobType,
            String salaryRange,
            String locationText
    ) {}

    public record ApplyRequest(@NotBlank String experienceSummary) {}

    public record ApplicationResponse(
            String id,
            String jobId,
            String applicantId,
            String experienceSummary,
            String status,
            String fullName,
            String phoneNumber,
            String avatarUrl
    ) {
        public static ApplicationResponse from(JobApplication a, UserAccount applicant) {
            return new ApplicationResponse(
                    a.getId().toString(),
                    a.getJobId().toString(),
                    a.getApplicantId().toString(),
                    a.getExperienceSummary(),
                    a.getStatus(),
                    applicant == null ? null : applicant.getFullName(),
                    applicant == null ? null : applicant.getPhoneNumber(),
                    applicant == null ? null : applicant.getAvatarUrl()
            );
        }
    }
}
