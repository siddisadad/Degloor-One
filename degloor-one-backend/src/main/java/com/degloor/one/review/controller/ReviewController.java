package com.degloor.one.review.controller;

import com.degloor.one.common.response.ApiResponse;
import com.degloor.one.common.security.CurrentUser;
import com.degloor.one.product.service.ProductService;
import com.degloor.one.review.dto.ReviewDtos.ComplaintResponse;
import com.degloor.one.review.dto.ReviewDtos.CreateComplaintRequest;
import com.degloor.one.review.dto.ReviewDtos.CreateReviewRequest;
import com.degloor.one.review.dto.ReviewDtos.ReviewResponse;
import com.degloor.one.review.service.ReviewService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Reviews")
public class ReviewController {
    private final ReviewService reviews;
    private final ProductService products;

    public ReviewController(ReviewService reviews, ProductService products) {
        this.reviews = reviews;
        this.products = products;
    }

    @GetMapping("/businesses/{id}/reviews")
    public ApiResponse<List<ReviewResponse>> businessReviews(@PathVariable UUID id) {
        return ApiResponse.ok(reviews.forBusiness(id));
    }

    @GetMapping("/reviews/{id}")
    public ApiResponse<List<ReviewResponse>> reviewsAlias(@PathVariable UUID id) {
        return ApiResponse.ok(reviews.forBusiness(id));
    }

    @GetMapping("/products/{id}/reviews")
    public ApiResponse<List<ReviewResponse>> productReviews(@PathVariable UUID id) {
        return ApiResponse.ok(reviews.forBusiness(UUID.fromString(products.get(id).businessId())));
    }

    @PostMapping("/reviews")
    public ApiResponse<ReviewResponse> create(@Valid @RequestBody CreateReviewRequest req) {
        return ApiResponse.ok(reviews.create(CurrentUser.require(), req), "Created");
    }

    @PostMapping("/complaints")
    public ApiResponse<ComplaintResponse> complain(@Valid @RequestBody CreateComplaintRequest req) {
        return ApiResponse.ok(reviews.complain(CurrentUser.require(), req), "Created");
    }

    @GetMapping("/complaints/mine")
    public ApiResponse<List<ComplaintResponse>> myComplaints() {
        return ApiResponse.ok(reviews.myComplaints(CurrentUser.require()));
    }
}
