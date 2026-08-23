package com.degloor.one.user.dto;

import com.degloor.one.user.entity.Address;
import com.degloor.one.user.entity.UserAccount;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;

public final class UserDtos {
    private UserDtos() {}

    public record ProfileResponse(
            String id,
            String email,
            String phoneNumber,
            String fullName,
            String avatarUrl,
            String role
    ) {
        public static ProfileResponse from(UserAccount u) {
            return new ProfileResponse(
                    u.getId().toString(),
                    u.getEmail(),
                    u.getPhoneNumber(),
                    u.getFullName(),
                    u.getAvatarUrl(),
                    u.getRole()
            );
        }
    }

    public record UpdateProfileRequest(
            @Size(max = 120) String fullName,
            @Size(max = 32) String phoneNumber,
            String avatarUrl
    ) {}

    public record AddressRequest(
            @NotBlank String title,
            @NotBlank String addressText,
            double latitude,
            double longitude,
            boolean isDefault
    ) {}

    public record AddressResponse(
            String id,
            String title,
            String addressText,
            double latitude,
            double longitude,
            boolean isDefault
    ) {
        public static AddressResponse from(Address a) {
            return new AddressResponse(
                    a.getId().toString(),
                    a.getTitle(),
                    a.getAddressText(),
                    a.getLatitude(),
                    a.getLongitude(),
                    a.isDefault()
            );
        }

        public static List<AddressResponse> list(List<Address> rows) {
            return rows.stream().map(AddressResponse::from).toList();
        }
    }
}
