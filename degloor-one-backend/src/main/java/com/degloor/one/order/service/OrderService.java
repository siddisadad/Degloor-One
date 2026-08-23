package com.degloor.one.order.service;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.cart.entity.Cart;
import com.degloor.one.cart.entity.CartItem;
import com.degloor.one.cart.service.CartService;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.response.PageResponse;
import com.degloor.one.common.security.Roles;
import com.degloor.one.common.util.Geo;
import com.degloor.one.delivery.repository.DeliveryAssignmentRepository;
import com.degloor.one.delivery.service.OtpService;
import com.degloor.one.notification.service.NotificationService;
import com.degloor.one.order.OrderStateMachine;
import com.degloor.one.order.OrderStatus;
import com.degloor.one.order.dto.OrderDtos.CheckoutRequest;
import com.degloor.one.order.dto.OrderDtos.DeliveryOtpResponse;
import com.degloor.one.order.dto.OrderDtos.OrderResponse;
import com.degloor.one.order.entity.OrderItem;
import com.degloor.one.order.entity.OrderStatusHistory;
import com.degloor.one.order.entity.ShopOrder;
import com.degloor.one.order.repository.OrderItemRepository;
import com.degloor.one.order.repository.OrderStatusHistoryRepository;
import com.degloor.one.order.repository.ShopOrderRepository;
import com.degloor.one.product.entity.Product;
import com.degloor.one.product.repository.ProductRepository;
import com.degloor.one.user.entity.Address;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.service.UserService;
import java.util.List;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {
    private static final Logger log = LoggerFactory.getLogger(OrderService.class);

    private final ShopOrderRepository orders;
    private final OrderItemRepository orderItems;
    private final OrderStatusHistoryRepository history;
    private final ProductRepository products;
    private final BusinessRepository businesses;
    private final CartService carts;
    private final UserService users;
    private final OtpService otpService;
    private final NotificationService notifications;
    private final DeliveryAssignmentRepository assignments;

    public OrderService(
            ShopOrderRepository orders,
            OrderItemRepository orderItems,
            OrderStatusHistoryRepository history,
            ProductRepository products,
            BusinessRepository businesses,
            CartService carts,
            UserService users,
            OtpService otpService,
            NotificationService notifications,
            DeliveryAssignmentRepository assignments
    ) {
        this.orders = orders;
        this.orderItems = orderItems;
        this.history = history;
        this.products = products;
        this.businesses = businesses;
        this.carts = carts;
        this.users = users;
        this.otpService = otpService;
        this.notifications = notifications;
        this.assignments = assignments;
    }

    @Transactional
    public OrderResponse checkout(UserAccount user, CheckoutRequest req) {
        Cart cart = carts.requireCart(user.getId());
        List<CartItem> items = carts.itemsOf(cart.getId());
        if (items.isEmpty()) {
            throw BusinessException.badRequest("CART_EMPTY", "Cart is empty");
        }
        Address address = users.requireOwnedAddress(user.getId(), req.addressId());
        Business shop = businesses.findById(cart.getBusinessId())
                .orElseThrow(() -> BusinessException.notFound("BUSINESS_NOT_FOUND", "Business not found"));
        if (!shop.isVerified()) {
            throw BusinessException.badRequest("BUSINESS_NOT_VERIFIED", "This shop is not accepting orders yet");
        }
        if (shop.getLatitude() == null || shop.getLongitude() == null) {
            throw BusinessException.badRequest("INVALID_LOCATION", "Shop location is missing");
        }

        double subtotal = 0;
        for (CartItem item : items) {
            Product product = products.findById(item.getProductId())
                    .orElseThrow(() -> BusinessException.notFound("PRODUCT_NOT_FOUND", "Product not found"));
            if (!product.getBusinessId().equals(shop.getId())) {
                throw BusinessException.badRequest("CART_PRODUCT", "Cart contains items from another shop");
            }
            if (!product.isAvailable()) {
                throw BusinessException.badRequest("PRODUCT_UNAVAILABLE", product.getName() + " is no longer available");
            }
            if (product.isTrackInventory() && item.getQuantity() > product.getStockQuantity()) {
                throw BusinessException.conflict("CART_OUT_OF_STOCK", "Not enough stock for " + product.getName());
            }
            subtotal += product.getPrice() * item.getQuantity();
        }

        double km = Geo.haversineKm(shop.getLatitude(), shop.getLongitude(), address.getLatitude(), address.getLongitude());
        double fee = Geo.deliveryFee(km);
        double total = subtotal + fee;

        ShopOrder order = new ShopOrder();
        order.setUserId(user.getId());
        order.setBusinessId(shop.getId());
        order.setSubtotal(subtotal);
        order.setDeliveryFee(fee);
        order.setTotalAmount(total);
        order.setStatus(OrderStatus.PENDING);
        order.setPaymentStatus(OrderStatus.UNPAID);
        order.setPaymentMethod(req.paymentMethod() == null || req.paymentMethod().isBlank() ? "COD" : req.paymentMethod());
        order.setDeliveryAddressId(address.getId());
        orders.save(order);
        otpService.generateAndStore(order);

        for (CartItem item : items) {
            Product product = products.findById(item.getProductId()).orElseThrow();
            OrderItem line = new OrderItem();
            line.setOrderId(order.getId());
            line.setProductId(product.getId());
            line.setQuantity(item.getQuantity());
            line.setPriceAtPurchase(product.getPrice());
            orderItems.save(line);
            if (product.isTrackInventory()) {
                product.setStockQuantity(product.getStockQuantity() - item.getQuantity());
                products.save(product);
            }
        }

        recordHistory(order.getId(), OrderStatus.PENDING, "Order placed");
        carts.clearCart(user.getId());
        notifications.notifyQuietly(user.getId(), "Order placed", "Your order is waiting for the shop to accept it.", "order");
        notifications.notifyQuietly(shop.getOwnerId(), "New order", "A customer placed an order at " + shop.getName() + ".", "order");
        log.info("businessEvent=ORDER_PLACED orderId={} userId={} total={}", order.getId(), user.getId(), total);
        return toResponse(order);
    }

    public PageResponse<OrderResponse> mine(UserAccount user, int page, int size) {
        var result = orders.findByUserIdOrderByCreatedAtDesc(user.getId(), PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50)));
        return PageResponse.from(result.map(this::toResponse));
    }

    public PageResponse<OrderResponse> forShop(UserAccount user, UUID businessId, int page, int size) {
        businesses.findById(businessId)
                .filter(b -> Roles.isAdmin(user) || b.getOwnerId().equals(user.getId()))
                .orElseThrow(() -> BusinessException.forbidden("FORBIDDEN", "Not your business"));
        var result = orders.findByBusinessIdOrderByCreatedAtDesc(businessId, PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50)));
        return PageResponse.from(result.map(this::toResponse));
    }

    public OrderResponse get(UserAccount user, UUID id) {
        return toResponse(requireVisible(user, id));
    }

    public DeliveryOtpResponse deliveryOtp(UserAccount user, UUID id) {
        ShopOrder order = requireVisible(user, id);
        if (!order.getUserId().equals(user.getId()) && !Roles.isAdmin(user)) {
            throw BusinessException.forbidden("FORBIDDEN", "Only the customer can view the delivery code");
        }
        return new DeliveryOtpResponse(order.getId().toString(), otpService.revealForCustomer(order));
    }

    @Transactional
    public OrderResponse cancel(UserAccount user, UUID id, String reason) {
        ShopOrder order = requireVisible(user, id);
        boolean owner = isShopOwner(user, order);
        boolean assigned = assignments.existsByOrderId(order.getId());
        if (owner) {
            OrderStateMachine.assertOwnerCancel(order.getStatus(), assigned);
        } else if (order.getUserId().equals(user.getId())) {
            OrderStateMachine.assertCustomerCancel(order.getStatus());
        } else {
            throw BusinessException.forbidden("FORBIDDEN", "You cannot cancel this order");
        }
        applyStatus(order, OrderStatus.CANCELLED, reason == null ? "Cancelled" : reason);
        restoreStock(order);
        notifications.notifyQuietly(order.getUserId(), "Order cancelled", "Your order was cancelled.", "order");
        return toResponse(order);
    }

    @Transactional
    public OrderResponse ownerStatus(UserAccount user, UUID id, String nextStatus) {
        ShopOrder order = requireVisible(user, id);
        if (!isShopOwner(user, order)) {
            throw BusinessException.forbidden("FORBIDDEN", "Not your shop order");
        }
        String next = OrderStatus.normalize(nextStatus);
        if (OrderStatus.CANCELLED.equals(next)) {
            return cancel(user, id, "Cancelled by shop");
        }
        OrderStateMachine.assertOwnerTransition(order.getStatus(), next);
        applyStatus(order, next, "Updated by shop");
        notifications.notifyQuietly(order.getUserId(), "Order update", "Your order is now " + next + ".", "order");
        return toResponse(order);
    }

    public ShopOrder requireVisible(UserAccount user, UUID id) {
        ShopOrder order = orders.findById(id)
                .orElseThrow(() -> BusinessException.notFound("ORDER_NOT_FOUND", "Order not found"));
        if (Roles.isAdmin(user) || order.getUserId().equals(user.getId()) || isShopOwner(user, order)) {
            return order;
        }
        throw BusinessException.forbidden("FORBIDDEN", "You cannot view this order");
    }

    public ShopOrder require(UUID id) {
        return orders.findById(id)
                .orElseThrow(() -> BusinessException.notFound("ORDER_NOT_FOUND", "Order not found"));
    }

    public boolean hasDeliveredOrder(UUID userId, UUID businessId) {
        return !orders.findByUserIdAndBusinessIdAndStatus(userId, businessId, OrderStatus.DELIVERED).isEmpty();
    }

    public void applyStatus(ShopOrder order, String status, String notes) {
        order.setStatus(status);
        orders.save(order);
        recordHistory(order.getId(), status, notes);
        log.info("businessEvent=ORDER_STATUS orderId={} status={}", order.getId(), status);
    }

    private void restoreStock(ShopOrder order) {
        for (OrderItem item : orderItems.findByOrderId(order.getId())) {
            products.findById(item.getProductId()).ifPresent(product -> {
                if (product.isTrackInventory()) {
                    product.setStockQuantity(product.getStockQuantity() + item.getQuantity());
                    products.save(product);
                }
            });
        }
    }

    private boolean isShopOwner(UserAccount user, ShopOrder order) {
        if (Roles.isAdmin(user)) {
            return true;
        }
        return businesses.findById(order.getBusinessId())
                .map(b -> b.getOwnerId().equals(user.getId()))
                .orElse(false);
    }

    private void recordHistory(UUID orderId, String status, String notes) {
        OrderStatusHistory row = new OrderStatusHistory();
        row.setOrderId(orderId);
        row.setStatus(status);
        row.setNotes(notes);
        history.save(row);
    }

    private OrderResponse toResponse(ShopOrder order) {
        return OrderResponse.from(
                order,
                orderItems.findByOrderId(order.getId()),
                history.findByOrderIdOrderByCreatedAtAsc(order.getId())
        );
    }
}
