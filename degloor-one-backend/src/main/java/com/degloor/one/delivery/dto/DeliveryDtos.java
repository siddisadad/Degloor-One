package com.degloor.one.delivery.dto;

import com.degloor.one.delivery.entity.DeliveryAssignment;
import com.degloor.one.delivery.entity.DeliveryPartner;
import com.degloor.one.order.dto.OrderDtos.OrderResponse;
import jakarta.validation.constraints.NotBlank;
import java.util.List;

public final class DeliveryDtos {
    private DeliveryDtos() {}

    public record PartnerResponse(
            String id,
            String userId,
            String vehicleType,
            String vehicleNumber,
            boolean available,
            boolean verified,
            Double currentLatitude,
            Double currentLongitude
    ) {
        public static PartnerResponse from(DeliveryPartner p) {
            return new PartnerResponse(
                    p.getId().toString(),
                    p.getUserId().toString(),
                    p.getVehicleType(),
                    p.getVehicleNumber(),
                    p.isAvailable(),
                    p.isVerified(),
                    p.getCurrentLatitude(),
                    p.getCurrentLongitude()
            );
        }
    }

    public record RegisterRequest(String vehicleType, String vehicleNumber) {}

    public record AvailabilityRequest(boolean available) {}

    public record LocationRequest(double latitude, double longitude) {}

    public record OtpVerifyRequest(@NotBlank String otp) {}

    public record AssignmentResponse(String id, String orderId, String partnerId, String status) {
        public static AssignmentResponse from(DeliveryAssignment a) {
            return new AssignmentResponse(
                    a.getId().toString(),
                    a.getOrderId().toString(),
                    a.getDeliveryPartnerId().toString(),
                    a.getStatus()
            );
        }
    }

    public record MyOrdersResponse(PartnerResponse partner, List<OrderResponse> assigned, List<OrderResponse> ready) {}
}
