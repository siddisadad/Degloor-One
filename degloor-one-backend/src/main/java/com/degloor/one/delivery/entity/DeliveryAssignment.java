package com.degloor.one.delivery.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "delivery_assignments")
public class DeliveryAssignment {
    @Id
    private UUID id;
    @Column(name = "order_id", nullable = false, unique = true)
    private UUID orderId;
    @Column(name = "delivery_partner_id", nullable = false)
    private UUID deliveryPartnerId;
    @Column(nullable = false)
    private String status = "assigned";
    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() {
        if (id == null) id = UUID.randomUUID();
        if (createdAt == null) createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public UUID getOrderId() { return orderId; }
    public void setOrderId(UUID orderId) { this.orderId = orderId; }
    public UUID getDeliveryPartnerId() { return deliveryPartnerId; }
    public void setDeliveryPartnerId(UUID deliveryPartnerId) { this.deliveryPartnerId = deliveryPartnerId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
