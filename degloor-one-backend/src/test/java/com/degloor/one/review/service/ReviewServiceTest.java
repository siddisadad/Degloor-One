package com.degloor.one.review.service;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.order.service.OrderService;
import com.degloor.one.review.dto.ReviewDtos.CreateReviewRequest;
import com.degloor.one.review.repository.ComplaintRepository;
import com.degloor.one.review.repository.ReviewRepository;
import com.degloor.one.user.entity.UserAccount;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ReviewServiceTest {
    @Mock ReviewRepository reviews;
    @Mock ComplaintRepository complaints;
    @Mock BusinessRepository businesses;
    @Mock OrderService orders;
    ReviewService service;
    UserAccount user;
    Business shop;

    @BeforeEach
    void setUp() {
        service = new ReviewService(reviews, complaints, businesses, orders);
        user = new UserAccount();
        user.setId(UUID.randomUUID());
        shop = new Business();
        shop.setId(UUID.randomUUID());
    }

    @Test
    void blocksDuplicateReview() {
        when(businesses.findById(shop.getId())).thenReturn(Optional.of(shop));
        when(reviews.existsByUserIdAndBusinessId(user.getId(), shop.getId())).thenReturn(true);
        BusinessException ex = assertThrows(BusinessException.class, () ->
                service.create(user, new CreateReviewRequest(shop.getId(), null, 5, "Nice")));
        assertEquals("REVIEW_EXISTS", ex.getCode());
    }

    @Test
    void blocksReviewWithoutDeliveredOrder() {
        when(businesses.findById(shop.getId())).thenReturn(Optional.of(shop));
        when(reviews.existsByUserIdAndBusinessId(user.getId(), shop.getId())).thenReturn(false);
        when(orders.hasDeliveredOrder(user.getId(), shop.getId())).thenReturn(false);
        BusinessException ex = assertThrows(BusinessException.class, () ->
                service.create(user, new CreateReviewRequest(shop.getId(), null, 5, "Nice")));
        assertEquals("REVIEW_NOT_ELIGIBLE", ex.getCode());
    }
}
