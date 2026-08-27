package com.degloor.one.delivery.service;

import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.delivery.entity.DeliveryAssignment;
import com.degloor.one.delivery.entity.DeliveryPartner;
import com.degloor.one.delivery.repository.DeliveryAssignmentRepository;
import com.degloor.one.delivery.repository.DeliveryPartnerRepository;
import com.degloor.one.notification.service.NotificationService;
import com.degloor.one.order.OrderStatus;
import com.degloor.one.order.entity.ShopOrder;
import com.degloor.one.order.repository.ShopOrderRepository;
import com.degloor.one.order.service.OrderService;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
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
class DeliveryServiceTest {
    @Mock DeliveryPartnerRepository partners;
    @Mock DeliveryAssignmentRepository assignments;
    @Mock ShopOrderRepository orders;
    @Mock OrderService orderService;
    @Mock OtpService otpService;
    @Mock NotificationService notifications;
    @Mock UserRepository users;
    @Mock BusinessRepository businesses;

    DeliveryService service;
    UserAccount rider;
    DeliveryPartner partner;
    ShopOrder order;

    @BeforeEach
    void setUp() {
        service = new DeliveryService(
                partners, assignments, orders, orderService, otpService, notifications, users, businesses);
        rider = new UserAccount();
        rider.setId(UUID.randomUUID());
        rider.setRole("delivery_partner");
        partner = new DeliveryPartner();
        partner.setId(UUID.randomUUID());
        partner.setUserId(rider.getId());
        partner.setVerified(true);
        partner.setAvailable(true);
        order = new ShopOrder();
        order.setId(UUID.randomUUID());
        order.setStatus(OrderStatus.READY);
    }

    @Test
    void otherPartnerCannotPickup() {
        DeliveryAssignment assignment = new DeliveryAssignment();
        assignment.setOrderId(order.getId());
        assignment.setDeliveryPartnerId(UUID.randomUUID());
        assignment.setStatus("assigned");
        when(partners.findByUserId(rider.getId())).thenReturn(Optional.of(partner));
        when(assignments.findByOrderId(order.getId())).thenReturn(Optional.of(assignment));
        BusinessException ex = assertThrows(BusinessException.class, () -> service.pickup(rider, order.getId()));
        assertEquals("FORBIDDEN", ex.getCode());
    }

    @Test
    void unverifiedPartnerCannotAccept() {
        partner.setVerified(false);
        when(partners.findByUserId(rider.getId())).thenReturn(Optional.of(partner));
        BusinessException ex = assertThrows(BusinessException.class, () -> service.accept(rider, order.getId()));
        assertEquals("PARTNER_UNAVAILABLE", ex.getCode());
    }
}
