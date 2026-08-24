package com.degloor.one.job.service;

import com.degloor.one.business.service.BusinessService;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.job.dto.JobDtos.ApplicationResponse;
import com.degloor.one.job.dto.JobDtos.ApplyRequest;
import com.degloor.one.job.dto.JobDtos.JobResponse;
import com.degloor.one.job.dto.JobDtos.UpsertJobRequest;
import com.degloor.one.job.entity.JobApplication;
import com.degloor.one.job.entity.JobPosting;
import com.degloor.one.job.repository.JobApplicationRepository;
import com.degloor.one.job.repository.JobPostingRepository;
import com.degloor.one.job.repository.JobSpecifications;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class JobService {
    private final JobPostingRepository jobs;
    private final JobApplicationRepository applications;
    private final BusinessService businesses;
    private final UserRepository users;

    public JobService(
            JobPostingRepository jobs,
            JobApplicationRepository applications,
            BusinessService businesses,
            UserRepository users
    ) {
        this.jobs = jobs;
        this.applications = applications;
        this.businesses = businesses;
        this.users = users;
    }

    public List<JobResponse> search(String q, String category) {
        return jobs.findAll(
                        JobSpecifications.search(q, category, null),
                        Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(JobResponse::from)
                .toList();
    }

    public JobResponse get(UUID id) {
        return JobResponse.from(require(id));
    }

    @Transactional
    public JobResponse create(UserAccount user, UpsertJobRequest req) {
        businesses.requireOwned(user, req.businessId());
        JobPosting job = new JobPosting();
        job.setPosterId(user.getId());
        apply(job, req);
        return JobResponse.from(jobs.save(job));
    }

    @Transactional
    public JobResponse update(UserAccount user, UUID id, UpsertJobRequest req) {
        JobPosting job = requireOwned(user, id);
        apply(job, req);
        return JobResponse.from(jobs.save(job));
    }

    @Transactional
    public JobResponse close(UserAccount user, UUID id) {
        JobPosting job = requireOwned(user, id);
        job.setActive(false);
        return JobResponse.from(jobs.save(job));
    }

    @Transactional
    public ApplicationResponse apply(UserAccount user, UUID jobId, ApplyRequest req) {
        JobPosting job = require(jobId);
        if (!job.isActive()) {
            throw BusinessException.conflict("JOB_CLOSED", "This job is no longer accepting applications");
        }
        if (applications.existsByJobIdAndApplicantId(jobId, user.getId())) {
            throw BusinessException.conflict("ALREADY_APPLIED", "You have already applied for this job");
        }
        if (req.experienceSummary() == null || req.experienceSummary().isBlank()) {
            throw BusinessException.badRequest("EXPERIENCE_REQUIRED", "Please share your experience");
        }
        JobApplication app = new JobApplication();
        app.setJobId(jobId);
        app.setApplicantId(user.getId());
        app.setExperienceSummary(req.experienceSummary().trim());
        app.setStatus("applied");
        return ApplicationResponse.from(applications.save(app), user);
    }

    @Transactional
    public void withdraw(UserAccount user, UUID jobId) {
        JobApplication app = applications.findByJobIdAndApplicantId(jobId, user.getId())
                .orElseThrow(() -> BusinessException.notFound("APPLICATION_NOT_FOUND", "Application not found"));
        applications.delete(app);
    }

    public List<ApplicationResponse> applicationsFor(UserAccount user, UUID jobId) {
        requireOwned(user, jobId);
        List<JobApplication> apps = applications.findByJobIdOrderByCreatedAtDesc(jobId);
        Map<UUID, UserAccount> applicants = users
                .findAllById(apps.stream().map(JobApplication::getApplicantId).toList())
                .stream()
                .collect(Collectors.toMap(UserAccount::getId, Function.identity()));
        return apps.stream()
                .map(app -> ApplicationResponse.from(app, applicants.get(app.getApplicantId())))
                .toList();
    }

    private JobPosting require(UUID id) {
        return jobs.findById(id).orElseThrow(() -> BusinessException.notFound("JOB_NOT_FOUND", "Job not found"));
    }

    private JobPosting requireOwned(UserAccount user, UUID id) {
        JobPosting job = require(id);
        businesses.requireOwned(user, job.getBusinessId());
        return job;
    }

    private void apply(JobPosting job, UpsertJobRequest req) {
        job.setBusinessId(req.businessId());
        job.setTitle(req.title().trim());
        job.setDescription(req.description().trim());
        job.setCategory(req.category());
        job.setJobType(req.jobType());
        job.setSalaryRange(req.salaryRange());
        job.setLocationText(req.locationText());
        job.setActive(true);
    }
}
