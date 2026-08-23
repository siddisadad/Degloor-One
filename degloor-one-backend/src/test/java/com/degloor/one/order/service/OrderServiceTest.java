package com.degloor.one.order.service;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.delivery.repository.DeliveryAssignmentRepository;
import com.degloor.one.order.OrderStatus;
import com.degloor.one.order.entity.ShopOrder;
import com.degloor.one.order.repository.OrderItemRepository;
import com.degloor.one.order.repository.OrderStatusHistoryRepository;
import com.degloor.one.order.repository.ShopOrderRepository;
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
class OrderServiceTest {
    @Mock ShopOrderRepository orders;
    @Mock OrderItemRepository orderItems;
    @Mock OrderStatusHistoryRepository history;
    @Mock com.degloor.one.product.repository.ProductRepository products;
    @Mock BusinessRepository businesses;
    @Mock com.degloor.one.cart.service.CartService carts;
    @Mock com.degloor.one.user.service.UserService users;
    @Mock com.degloor.one.delivery.service.OtpService otp;
    @Mock com.degloor.one.notification.service.NotificationService notifications;
    @Mock DeliveryAssignmentRepository assignments;

    OrderService service;
    UserAccount customer;
    UserAccount stranger;
    ShopOrder order;

    @BeforeEach
    void setUp() {
        service = new OrderService(
                orders, orderItems, history, products, businesses, carts, users, otp, notifications, assignments);
        customer = new UserAccount();
        customer.setId(UUID.randomUUID());
        customer.setRole("customer");
        stranger = new UserAccount();
        stranger.setId(UUID.randomUUID());
        stranger.setRole("customer");
        order = new ShopOrder();
        order.setId(UUID.randomUUID());
        order.setUserId(customer.getId());
        order.setBusinessId(UUID.randomUUID());
        order.setStatus(OrderStatus.PENDING);
    }

    @Test
    void strangerCannotViewOrder() {
        when(orders.findById(order.getId())).thenReturn(Optional.of(order));
        when(businesses.findById(order.getBusinessId())).thenReturn(Optional.empty());
        BusinessException ex = assertThrows(BusinessException.class, () -> service.requireVisible(stranger, order.getId()));
        assertEquals("FORBIDDEN", ex.getCode());
    }

    @Test
    void ownerCannotSkipToDelivered() {
        UserAccount owner = new UserAccount();
        owner.setId(UUID.randomUUID());
        owner.setRole("business_owner");
        Business shop = new Business();
        shop.setId(order.getBusinessId());
        shop.setOwnerId(owner.getId());
        when(orders.findById(order.getId())).thenReturn(Optional.of(order));
        when(businesses.findById(order.getBusinessId())).thenReturn(Optional.of(shop));
        BusinessException ex = assertThrows(BusinessException.class,
                () -> service.ownerStatus(owner, order.getId(), "delivered"));
        assertEquals("INVALID_ORDER_TRANSITION", ex.getCode());
    }
}
