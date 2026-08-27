package com.degloor.one.order.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "orders")
public class ShopOrder {
    @Id
    private UUID id;
    @Column(name = "user_id", nullable = false)
    private UUID userId;
    @Column(name = "business_id", nullable = false)
    private UUID businessId;
    @Column(name = "total_amount", nullable = false)
    private double totalAmount;
    @Column(nullable = false)
    private double subtotal;
    @Column(name = "delivery_fee", nullable = false)
    private double deliveryFee;
    @Column(nullable = false)
    private String status = "pending";
    @Column(name = "payment_status", nullable = false)
    private String paymentStatus = "unpaid";
    @Column(name = "delivery_address_id")
    private UUID deliveryAddressId;
    @Column(name = "payment_method")
    private String paymentMethod;
    @Column(name = "delivery_otp_hash")
    private String deliveryOtpHash;
    @Column(name = "delivery_otp_cipher")
    private String deliveryOtpCipher;
    @Column(name = "otp_expires_at")
    private Instant otpExpiresAt;
    @Column(name = "otp_attempts", nullable = false)
    private int otpAttempts;
    @Column(name = "otp_used", nullable = false)
    private boolean otpUsed;
    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() {
        if (id == null) id = UUID.randomUUID();
        if (createdAt == null) createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    public UUID getBusinessId() { return businessId; }
    public void setBusinessId(UUID businessId) { this.businessId = businessId; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }
    public double getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(double deliveryFee) { this.deliveryFee = deliveryFee; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public UUID getDeliveryAddressId() { return deliveryAddressId; }
    public void setDeliveryAddressId(UUID deliveryAddressId) { this.deliveryAddressId = deliveryAddressId; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getDeliveryOtpHash() { return deliveryOtpHash; }
    public void setDeliveryOtpHash(String deliveryOtpHash) { this.deliveryOtpHash = deliveryOtpHash; }
    public String getDeliveryOtpCipher() { return deliveryOtpCipher; }
    public void setDeliveryOtpCipher(String deliveryOtpCipher) { this.deliveryOtpCipher = deliveryOtpCipher; }
    public Instant getOtpExpiresAt() { return otpExpiresAt; }
    public void setOtpExpiresAt(Instant otpExpiresAt) { this.otpExpiresAt = otpExpiresAt; }
    public int getOtpAttempts() { return otpAttempts; }
    public void setOtpAttempts(int otpAttempts) { this.otpAttempts = otpAttempts; }
    public boolean isOtpUsed() { return otpUsed; }
    public void setOtpUsed(boolean otpUsed) { this.otpUsed = otpUsed; }
    public Instant getCreatedAt() { return createdAt; }
}
