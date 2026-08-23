package com.degloor.one.job.controller;

import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
import com.degloor.one.job.dto.JobDtos.ApplicationResponse;
import com.degloor.one.job.dto.JobDtos.ApplyRequest;
import com.degloor.one.job.dto.JobDtos.JobResponse;
import com.degloor.one.job.dto.JobDtos.UpsertJobRequest;
import com.degloor.one.job.service.JobService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/jobs")
@Tag(name = "Jobs")
public class JobController {
    private final JobService jobs;

    public JobController(JobService jobs) {
        this.jobs = jobs;
    }

    @GetMapping
    public ApiResponse<List<JobResponse>> search(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String category
    ) {
        return ApiResponse.ok(jobs.search(q, category));
    }

    @GetMapping("/{id}")
    public ApiResponse<JobResponse> get(@PathVariable UUID id) {
        return ApiResponse.ok(jobs.get(id));
    }

    @PostMapping
    public ApiResponse<JobResponse> create(@Valid @RequestBody UpsertJobRequest req) {
        return ApiResponse.ok(jobs.create(CurrentUser.require(), req), "Created");
    }

    @PutMapping("/{id}")
    public ApiResponse<JobResponse> update(@PathVariable UUID id, @Valid @RequestBody UpsertJobRequest req) {
        return ApiResponse.ok(jobs.update(CurrentUser.require(), id, req), "Updated");
    }

    @PostMapping("/{id}/close")
    public ApiResponse<JobResponse> close(@PathVariable UUID id) {
        return ApiResponse.ok(jobs.close(CurrentUser.require(), id), "Closed");
    }

    @PostMapping("/{id}/apply")
    public ApiResponse<ApplicationResponse> apply(@PathVariable UUID id, @Valid @RequestBody ApplyRequest req) {
        return ApiResponse.ok(jobs.apply(CurrentUser.require(), id, req), "Applied");
    }

    @DeleteMapping("/{id}/apply")
    public ApiResponse<Void> withdraw(@PathVariable UUID id) {
        jobs.withdraw(CurrentUser.require(), id);
        return ApiResponse.ok(null, "Withdrawn");
    }

    @GetMapping("/{id}/applications")
    public ApiResponse<List<ApplicationResponse>> applications(@PathVariable UUID id) {
        return ApiResponse.ok(jobs.applicationsFor(CurrentUser.require(), id));
    }
}
