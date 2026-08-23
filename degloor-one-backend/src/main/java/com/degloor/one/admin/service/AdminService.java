package com.degloor.one.admin.service;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.response.PageResponse;
import com.degloor.one.delivery.entity.DeliveryPartner;
import com.degloor.one.delivery.repository.DeliveryPartnerRepository;
import com.degloor.one.order.repository.ShopOrderRepository;
import com.degloor.one.product.entity.Product;
import com.degloor.one.product.repository.ProductRepository;
import com.degloor.one.review.entity.Complaint;
import com.degloor.one.review.repository.ComplaintRepository;
import com.degloor.one.user.dto.UserDtos.ProfileResponse;
import com.degloor.one.user.repository.UserRepository;
import java.util.Map;
import java.util.UUID;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminService {
    private final UserRepository users;
    private final BusinessRepository businesses;
    private final ProductRepository products;
    private final ShopOrderRepository orders;
    private final DeliveryPartnerRepository partners;
    private final ComplaintRepository complaints;

    public AdminService(
            UserRepository users,
            BusinessRepository businesses,
            ProductRepository products,
            ShopOrderRepository orders,
            DeliveryPartnerRepository partners,
            ComplaintRepository complaints
    ) {
        this.users = users;
        this.businesses = businesses;
        this.products = products;
        this.orders = orders;
        this.partners = partners;
        this.complaints = complaints;
    }

    public PageResponse<ProfileResponse> users(int page, int size) {
        return PageResponse.from(users.findAll(PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50)))
                .map(ProfileResponse::from));
    }

    public PageResponse<Business> businesses(int page, int size) {
        return PageResponse.from(businesses.findAll(PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50))));
    }

    public PageResponse<Product> products(int page, int size) {
        return PageResponse.from(products.findAll(PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50))));
    }

    public PageResponse<Map<String, Object>> orders(int page, int size) {
        return PageResponse.from(orders.findAll(PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50)))
                .map(o -> Map.<String, Object>of(
                        "id", o.getId().toString(),
                        "userId", o.getUserId().toString(),
                        "businessId", o.getBusinessId().toString(),
                        "totalAmount", o.getTotalAmount(),
                        "status", o.getStatus(),
                        "paymentStatus", o.getPaymentStatus(),
                        "createdAt", o.getCreatedAt()
                )));
    }

    public PageResponse<DeliveryPartner> partners(int page, int size) {
        return PageResponse.from(partners.findAll(PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50))));
    }

    public PageResponse<Complaint> complaints(int page, int size) {
        return PageResponse.from(complaints.findAllByOrderByCreatedAtDesc(PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50))));
    }

    @Transactional
    public Business verifyBusiness(UUID id, boolean verified) {
        Business b = businesses.findById(id)
                .orElseThrow(() -> BusinessException.notFound("BUSINESS_NOT_FOUND", "Business not found"));
        b.setVerified(verified);
        return businesses.save(b);
    }

    @Transactional
    public DeliveryPartner verifyPartner(UUID id, boolean verified) {
        DeliveryPartner p = partners.findById(id)
                .orElseThrow(() -> BusinessException.notFound("PARTNER_NOT_FOUND", "Delivery partner not found"));
        p.setVerified(verified);
        return partners.save(p);
    }

    @Transactional
    public Complaint resolveComplaint(UUID id, String status) {
        Complaint c = complaints.findById(id)
                .orElseThrow(() -> BusinessException.notFound("COMPLAINT_NOT_FOUND", "Complaint not found"));
        String next = status == null ? "resolved" : status.toLowerCase();
        if (!next.equals("pending") && !next.equals("in_progress") && !next.equals("resolved")) {
            throw BusinessException.badRequest("INVALID_STATUS", "Unknown complaint status");
        }
        c.setStatus(next);
        return complaints.save(c);
    }

    public Map<String, Object> reports() {
        return Map.of(
                "users", users.count(),
                "businesses", businesses.count(),
                "products", products.count(),
                "orders", orders.count(),
                "partners", partners.count(),
                "openComplaints", complaints.countByStatusNot("resolved")
        );
    }
}
