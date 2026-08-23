package com.degloor.one.review.service;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.order.service.OrderService;
import com.degloor.one.review.dto.ReviewDtos.ComplaintResponse;
import com.degloor.one.review.dto.ReviewDtos.CreateComplaintRequest;
import com.degloor.one.review.dto.ReviewDtos.CreateReviewRequest;
import com.degloor.one.review.dto.ReviewDtos.ReviewResponse;
import com.degloor.one.review.entity.Complaint;
import com.degloor.one.review.entity.Review;
import com.degloor.one.review.repository.ComplaintRepository;
import com.degloor.one.review.repository.ReviewRepository;
import com.degloor.one.user.entity.UserAccount;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReviewService {
    private final ReviewRepository reviews;
    private final ComplaintRepository complaints;
    private final BusinessRepository businesses;
    private final OrderService orders;

    public ReviewService(
            ReviewRepository reviews,
            ComplaintRepository complaints,
            BusinessRepository businesses,
            OrderService orders
    ) {
        this.reviews = reviews;
        this.complaints = complaints;
        this.businesses = businesses;
        this.orders = orders;
    }

    public List<ReviewResponse> forBusiness(UUID businessId) {
        businesses.findById(businessId)
                .orElseThrow(() -> BusinessException.notFound("BUSINESS_NOT_FOUND", "Business not found"));
        return reviews.findByBusinessIdOrderByCreatedAtDesc(businessId).stream().map(ReviewResponse::from).toList();
    }

    @Transactional
    public ReviewResponse create(UserAccount user, CreateReviewRequest req) {
        Business shop = businesses.findById(req.businessId())
                .orElseThrow(() -> BusinessException.notFound("BUSINESS_NOT_FOUND", "Business not found"));
        if (reviews.existsByUserIdAndBusinessId(user.getId(), shop.getId())) {
            throw BusinessException.conflict("REVIEW_EXISTS", "You have already reviewed this shop");
        }
        if (!orders.hasDeliveredOrder(user.getId(), shop.getId())) {
            throw BusinessException.forbidden("REVIEW_NOT_ELIGIBLE", "You can review a shop after a delivered order");
        }
        Review review = new Review();
        review.setUserId(user.getId());
        review.setBusinessId(shop.getId());
        review.setOrderId(req.orderId());
        review.setRating(req.rating());
        review.setComment(req.comment());
        reviews.save(review);
        refreshRating(shop);
        return ReviewResponse.from(review);
    }

    @Transactional
    public ComplaintResponse complain(UserAccount user, CreateComplaintRequest req) {
        Complaint c = new Complaint();
        c.setUserId(user.getId());
        c.setOrderId(req.orderId());
        c.setBusinessId(req.businessId());
        c.setSubject(req.subject().trim());
        c.setDescription(req.description().trim());
        c.setStatus("pending");
        return ComplaintResponse.from(complaints.save(c));
    }

    public List<ComplaintResponse> myComplaints(UserAccount user) {
        return complaints.findByUserIdOrderByCreatedAtDesc(user.getId()).stream().map(ComplaintResponse::from).toList();
    }

    private void refreshRating(Business shop) {
        List<Review> rows = reviews.findByBusinessIdOrderByCreatedAtDesc(shop.getId());
        double avg = rows.stream().mapToInt(Review::getRating).average().orElse(0);
        shop.setRating(Math.round(avg * 10.0) / 10.0);
        businesses.save(shop);
    }
}
