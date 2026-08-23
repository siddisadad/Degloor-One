package com.degloor.one.business.controller;

import com.degloor.one.business.dto.BusinessDtos.BusinessResponse;
import com.degloor.one.business.dto.BusinessDtos.CategoryResponse;
import com.degloor.one.business.dto.BusinessDtos.UpsertBusinessRequest;
import com.degloor.one.business.service.BusinessService;
import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
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
@RequestMapping("/api/v1")
@Tag(name = "Businesses")
public class BusinessController {
    private final BusinessService businesses;

    public BusinessController(BusinessService businesses) {
        this.businesses = businesses;
    }

    @GetMapping("/categories")
    public ApiResponse<List<CategoryResponse>> categories() {
        return ApiResponse.ok(businesses.categories());
    }

    @GetMapping("/businesses")
    public ApiResponse<List<BusinessResponse>> search(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(required = false) Double radiusKm,
            @RequestParam(required = false) Boolean verified
    ) {
        return ApiResponse.ok(businesses.search(q, categoryId, lat, lng, radiusKm, verified));
    }

    @GetMapping("/businesses/mine")
    public ApiResponse<List<BusinessResponse>> mine() {
        return ApiResponse.ok(businesses.mine(CurrentUser.require()));
    }

    @GetMapping("/businesses/{id}")
    public ApiResponse<BusinessResponse> get(
            @PathVariable UUID id,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng
    ) {
        return ApiResponse.ok(businesses.get(id, lat, lng));
    }

    @PostMapping("/businesses")
    public ApiResponse<BusinessResponse> create(@Valid @RequestBody UpsertBusinessRequest req) {
        return ApiResponse.ok(businesses.create(CurrentUser.require(), req), "Created");
    }

    @PutMapping("/businesses/{id}")
    public ApiResponse<BusinessResponse> update(@PathVariable UUID id, @Valid @RequestBody UpsertBusinessRequest req) {
        return ApiResponse.ok(businesses.update(CurrentUser.require(), id, req), "Updated");
    }

    @DeleteMapping("/businesses/{id}")
    public ApiResponse<Void> delete(@PathVariable UUID id) {
        businesses.delete(CurrentUser.require(), id);
        return ApiResponse.ok(null, "Deleted");
    }
}
