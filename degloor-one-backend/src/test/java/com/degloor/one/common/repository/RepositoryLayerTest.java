package com.degloor.one.common.repository;

import com.degloor.one.analytics.entity.BusinessEvent;
import com.degloor.one.analytics.repository.BusinessEventRepository;
import com.degloor.one.business.entity.Business;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.business.repository.BusinessSpecifications;
import com.degloor.one.delivery.entity.DeliveryAssignment;
import com.degloor.one.delivery.repository.DeliveryAssignmentRepository;
import com.degloor.one.job.entity.JobPosting;
import com.degloor.one.job.repository.JobPostingRepository;
import com.degloor.one.job.repository.JobSpecifications;
import com.degloor.one.order.OrderStatus;
import com.degloor.one.order.entity.ShopOrder;
import com.degloor.one.order.repository.ShopOrderRepository;
import com.degloor.one.review.entity.Complaint;
import com.degloor.one.review.repository.ComplaintRepository;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@DataJpaTest
@ActiveProfiles("test")
class RepositoryLayerTest {
    @Autowired BusinessRepository businesses;
    @Autowired ShopOrderRepository orders;
    @Autowired DeliveryAssignmentRepository assignments;
    @Autowired ComplaintRepository complaints;
    @Autowired BusinessEventRepository events;
    @Autowired JobPostingRepository jobs;

    @Test
    void businessSearchFiltersInTheDatabase() {
        UUID grocery = UUID.randomUUID();
        Business patil = shop("Patil Kirana", "Daily groceries", grocery, true);
        shop("Hotel Annapurna", "Veg thali", UUID.randomUUID(), true);
        shop("Unverified Tea", "College Road tea", grocery, false);

        List<Business> kirana = businesses.findAll(BusinessSpecifications.search("kirana", null, true));
        assertEquals(1, kirana.size());
        assertEquals(patil.getId(), kirana.getFirst().getId());

        List<Business> groceryOnly = businesses.findAll(BusinessSpecifications.search(null, grocery, true));
        assertEquals(1, groceryOnly.size());
        assertEquals(patil.getId(), groceryOnly.getFirst().getId());
    }

    @Test
    void unassignedReadyOrdersSkipAssignedRows() {
        ShopOrder ready = order(OrderStatus.READY);
        ShopOrder taken = order(OrderStatus.READY);
        order(OrderStatus.PENDING);
        DeliveryAssignment assignment = new DeliveryAssignment();
        assignment.setOrderId(taken.getId());
        assignment.setDeliveryPartnerId(UUID.randomUUID());
        assignments.save(assignment);

        List<ShopOrder> open = orders.findUnassignedByStatus(OrderStatus.READY, PageRequest.of(0, 20));
        assertEquals(1, open.size());
        assertEquals(ready.getId(), open.getFirst().getId());
    }

    @Test
    void complaintAndEventCountsStayInSql() {
        UUID userId = UUID.randomUUID();
        complaints.save(complaint(userId, "pending"));
        complaints.save(complaint(userId, "in_progress"));
        complaints.save(complaint(userId, "resolved"));
        assertEquals(2, complaints.countByStatusNot("resolved"));

        UUID businessId = UUID.randomUUID();
        events.save(event(businessId, "PROFILE_VIEW"));
        events.save(event(businessId, "PROFILE_VIEW"));
        events.save(event(businessId, "CALL_CLICK"));
        var grouped = events.countGroupedByEventType(businessId);
        assertEquals(2, grouped.size());
        assertEquals(2, grouped.stream()
                .filter(row -> "PROFILE_VIEW".equals(row.getEventType()))
                .findFirst()
                .orElseThrow()
                .getTotal());
    }

    @Test
    void jobSearchIgnoresClosedPostings() {
        UUID businessId = UUID.randomUUID();
        JobPosting open = job(businessId, "Shop helper", "Counter work", "retail", true);
        job(businessId, "Closed helper", "Old posting", "retail", false);
        job(businessId, "Cook", "Kitchen", "food", true);

        List<JobPosting> retail = jobs.findAll(
                JobSpecifications.search("helper", "retail"),
                Sort.by(Sort.Direction.DESC, "createdAt"));
        assertEquals(1, retail.size());
        assertEquals(open.getId(), retail.getFirst().getId());
        assertTrue(retail.getFirst().isActive());
        assertFalse(jobs.findAll(JobSpecifications.search("cook", "retail")).stream()
                .anyMatch(row -> row.getTitle().equals("Cook")));
    }

    private Business shop(String name, String description, UUID categoryId, boolean verified) {
        Business shop = new Business();
        shop.setOwnerId(UUID.randomUUID());
        shop.setName(name);
        shop.setDescription(description);
        shop.setCategoryId(categoryId);
        shop.setVerified(verified);
        shop.setOpen(true);
        shop.setLatitude(18.5522);
        shop.setLongitude(77.5844);
        return businesses.save(shop);
    }

    private ShopOrder order(String status) {
        ShopOrder order = new ShopOrder();
        order.setUserId(UUID.randomUUID());
        order.setBusinessId(UUID.randomUUID());
        order.setSubtotal(100);
        order.setDeliveryFee(20);
        order.setTotalAmount(120);
        order.setStatus(status);
        order.setPaymentStatus(OrderStatus.UNPAID);
        return orders.save(order);
    }

    private Complaint complaint(UUID userId, String status) {
        Complaint row = new Complaint();
        row.setUserId(userId);
        row.setSubject("Missing item");
        row.setDescription("Rice bag was short.");
        row.setStatus(status);
        return row;
    }

    private BusinessEvent event(UUID businessId, String type) {
        BusinessEvent event = new BusinessEvent();
        event.setBusinessId(businessId);
        event.setEventType(type);
        return event;
    }

    private JobPosting job(UUID businessId, String title, String description, String category, boolean active) {
        JobPosting job = new JobPosting();
        job.setBusinessId(businessId);
        job.setPosterId(UUID.randomUUID());
        job.setTitle(title);
        job.setDescription(description);
        job.setCategory(category);
        job.setJobType("full_time");
        job.setActive(active);
        return jobs.save(job);
    }
}
