package com.degloor.one.delivery.service;

import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.security.Roles;
import com.degloor.one.common.util.Geo;
import com.degloor.one.delivery.dto.DeliveryDtos.AssignmentResponse;
import com.degloor.one.delivery.dto.DeliveryDtos.MyOrdersResponse;
import com.degloor.one.delivery.dto.DeliveryDtos.PartnerResponse;
import com.degloor.one.delivery.entity.DeliveryAssignment;
import com.degloor.one.delivery.entity.DeliveryPartner;
import com.degloor.one.delivery.repository.DeliveryAssignmentRepository;
import com.degloor.one.delivery.repository.DeliveryPartnerRepository;
import com.degloor.one.notification.service.NotificationService;
import com.degloor.one.order.OrderStateMachine;
import com.degloor.one.order.OrderStatus;
import com.degloor.one.order.dto.OrderDtos.OrderResponse;
import com.degloor.one.order.entity.ShopOrder;
import com.degloor.one.order.repository.OrderItemRepository;
import com.degloor.one.order.repository.OrderStatusHistoryRepository;
import com.degloor.one.order.repository.ShopOrderRepository;
import com.degloor.one.order.service.OrderService;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DeliveryService {
    private final DeliveryPartnerRepository partners;
    private final DeliveryAssignmentRepository assignments;
    private final ShopOrderRepository orders;
    private final OrderItemRepository orderItems;
    private final OrderStatusHistoryRepository history;
    private final OrderService orderService;
    private final OtpService otpService;
    private final NotificationService notifications;
    private final UserRepository users;
    private final BusinessRepository businesses;

    public DeliveryService(
            DeliveryPartnerRepository partners,
            DeliveryAssignmentRepository assignments,
            ShopOrderRepository orders,
            OrderItemRepository orderItems,
            OrderStatusHistoryRepository history,
            OrderService orderService,
            OtpService otpService,
            NotificationService notifications,
            UserRepository users,
            BusinessRepository businesses
    ) {
        this.partners = partners;
        this.assignments = assignments;
        this.orders = orders;
        this.orderItems = orderItems;
        this.history = history;
        this.orderService = orderService;
        this.otpService = otpService;
        this.notifications = notifications;
        this.users = users;
        this.businesses = businesses;
    }

    public PartnerResponse me(UserAccount user) {
        return PartnerResponse.from(requirePartner(user));
    }

    @Transactional
    public PartnerResponse register(UserAccount user, String vehicleType, String vehicleNumber) {
        return partners.findByUserId(user.getId()).map(PartnerResponse::from).orElseGet(() -> {
            DeliveryPartner p = new DeliveryPartner();
            p.setUserId(user.getId());
            p.setVehicleType(vehicleType);
            p.setVehicleNumber(vehicleNumber);
            p.setAvailable(false);
            p.setVerified(false);
            if (Roles.CUSTOMER.equals(user.getRole())) {
                user.setRole(Roles.DELIVERY_PARTNER);
                users.save(user);
            }
            return PartnerResponse.from(partners.save(p));
        });
    }

    @Transactional
    public PartnerResponse setAvailable(UserAccount user, boolean available) {
        DeliveryPartner partner = requirePartner(user);
        if (available && !partner.isVerified()) {
            throw BusinessException.forbidden("PARTNER_UNVERIFIED", "Your account is pending verification");
        }
        partner.setAvailable(available);
        return PartnerResponse.from(partners.save(partner));
    }

    @Transactional
    public PartnerResponse updateLocation(UserAccount user, double lat, double lng) {
        Geo.requireCoordinates(lat, lng);
        DeliveryPartner partner = requirePartner(user);
        partner.setCurrentLatitude(lat);
        partner.setCurrentLongitude(lng);
        return PartnerResponse.from(partners.save(partner));
    }

    public MyOrdersResponse myOrders(UserAccount user) {
        DeliveryPartner partner = requirePartner(user);
        List<OrderResponse> assigned = assignments.findByDeliveryPartnerIdAndStatusNot(partner.getId(), "delivered")
                .stream()
                .map(a -> toOrder(orders.findById(a.getOrderId()).orElseThrow()))
                .toList();
        List<OrderResponse> ready = orders.findByStatusOrderByCreatedAtDesc(OrderStatus.READY, PageRequest.of(0, 50))
                .stream()
                .filter(o -> !assignments.existsByOrderId(o.getId()))
                .map(this::toOrder)
                .toList();
        return new MyOrdersResponse(PartnerResponse.from(partner), assigned, ready);
    }

    @Transactional
    public AssignmentResponse accept(UserAccount user, UUID orderId) {
        DeliveryPartner partner = requireActivePartner(user);
        ShopOrder order = orderService.require(orderId);
        if (!OrderStatus.READY.equals(OrderStatus.normalize(order.getStatus()))) {
            throw BusinessException.conflict("INVALID_ORDER_TRANSITION", "Order is not ready for pickup");
        }
        if (assignments.existsByOrderId(orderId)) {
            throw BusinessException.conflict("ORDER_ASSIGNED", "This order already has a rider");
        }
        DeliveryAssignment assignment = new DeliveryAssignment();
        assignment.setOrderId(orderId);
        assignment.setDeliveryPartnerId(partner.getId());
        assignment.setStatus("assigned");
        assignments.save(assignment);
        orderService.applyStatus(order, OrderStatus.SHIPPING, "Rider assigned");
        notifications.notifyQuietly(order.getUserId(), "Rider assigned", "A delivery partner is on the way to the shop.", "delivery");
        return AssignmentResponse.from(assignment);
    }

    @Transactional
    public AssignmentResponse pickupAssignment(UserAccount user, UUID assignmentId) {
        DeliveryAssignment assignment = assignments.findById(assignmentId)
                .orElseThrow(() -> BusinessException.notFound("ASSIGNMENT_NOT_FOUND", "No delivery assignment for this order"));
        return pickup(user, assignment.getOrderId());
    }

    @Transactional
    public AssignmentResponse pickup(UserAccount user, UUID orderId) {
        DeliveryAssignment assignment = requireOwnAssignment(user, orderId);
        if (!"assigned".equals(assignment.getStatus())) {
            throw BusinessException.conflict("INVALID_ORDER_TRANSITION", "Order is not waiting for pickup");
        }
        ShopOrder order = orderService.require(orderId);
        if (!OrderStatus.SHIPPING.equals(OrderStatus.normalize(order.getStatus()))
                && !OrderStatus.READY.equals(OrderStatus.normalize(order.getStatus()))) {
            throw BusinessException.conflict("INVALID_ORDER_TRANSITION", "Order cannot be picked up in its current state");
        }
        assignment.setStatus("picked_up");
        assignments.save(assignment);
        orderService.applyStatus(order, OrderStatus.OUT_FOR_DELIVERY, "Picked up");
        notifications.notifyQuietly(order.getUserId(), "Out for delivery", "Your order is on the way.", "delivery");
        return AssignmentResponse.from(assignment);
    }

    @Transactional
    public OrderResponse verifyOtp(UserAccount user, UUID orderId, String otp) {
        ShopOrder order = orderService.require(orderId);
        OrderStateMachine.assertConfirmable(order.getStatus());
        boolean ownerCounter = businesses.findById(order.getBusinessId())
                .map(b -> b.getOwnerId().equals(user.getId()))
                .orElse(false);
        if (!ownerCounter) {
            DeliveryAssignment assignment = requireOwnAssignment(user, orderId);
            if (!"picked_up".equals(assignment.getStatus()) && !"assigned".equals(assignment.getStatus())) {
                throw BusinessException.forbidden("FORBIDDEN", "You are not assigned to this delivery");
            }
            assignment.setStatus("delivered");
            assignments.save(assignment);
        } else if (!OrderStatus.READY.equals(OrderStatus.normalize(order.getStatus()))) {
            throw BusinessException.conflict("INVALID_ORDER_TRANSITION", "Shop counter-delivery is only allowed when the order is ready");
        }
        otpService.verify(order, otp);
        order.setPaymentStatus(OrderStatus.PAID);
        orderService.applyStatus(order, OrderStatus.DELIVERED, "Delivered");
        notifications.notifyQuietly(order.getUserId(), "Delivered", "Your order has been delivered.", "delivery");
        return toOrder(order);
    }

    private DeliveryPartner requirePartner(UserAccount user) {
        if (Roles.isAdmin(user)) {
            return partners.findByUserId(user.getId())
                    .orElseThrow(() -> BusinessException.notFound("PARTNER_NOT_FOUND", "Delivery profile not found"));
        }
        Roles.requireDeliveryPartner(user);
        return partners.findByUserId(user.getId())
                .orElseThrow(() -> BusinessException.notFound("PARTNER_NOT_FOUND", "Delivery profile not found"));
    }

    private DeliveryPartner requireActivePartner(UserAccount user) {
        DeliveryPartner partner = requirePartner(user);
        if (!partner.isVerified() || !partner.isAvailable()) {
            throw BusinessException.forbidden("PARTNER_UNAVAILABLE", "You must be verified and available to accept orders");
        }
        return partner;
    }

    private DeliveryAssignment requireOwnAssignment(UserAccount user, UUID orderId) {
        DeliveryPartner partner = requirePartner(user);
        DeliveryAssignment assignment = assignments.findByOrderId(orderId)
                .orElseThrow(() -> BusinessException.notFound("ASSIGNMENT_NOT_FOUND", "No delivery assignment for this order"));
        if (!assignment.getDeliveryPartnerId().equals(partner.getId()) && !Roles.isAdmin(user)) {
            throw BusinessException.forbidden("FORBIDDEN", "This delivery is assigned to another partner");
        }
        return assignment;
    }

    private OrderResponse toOrder(ShopOrder order) {
        return OrderResponse.from(
                order,
                orderItems.findByOrderId(order.getId()),
                history.findByOrderIdOrderByCreatedAtAsc(order.getId())
        );
    }
}
