package com.degloor.one.user.service;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.util.Geo;
import com.degloor.one.user.dto.UserDtos.AddressRequest;
import com.degloor.one.user.dto.UserDtos.AddressResponse;
import com.degloor.one.user.dto.UserDtos.DeliveryFeeResponse;
import com.degloor.one.user.dto.UserDtos.ProfileResponse;
import com.degloor.one.user.dto.UserDtos.UpdateProfileRequest;
import com.degloor.one.user.entity.Address;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.AddressRepository;
import com.degloor.one.user.repository.UserRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {
    private final UserRepository users;
    private final AddressRepository addresses;
    private final BusinessRepository businesses;

    public UserService(
            UserRepository users, AddressRepository addresses, BusinessRepository businesses) {
        this.users = users;
        this.addresses = addresses;
        this.businesses = businesses;
    }

    public ProfileResponse me(UUID userId) {
        return ProfileResponse.from(requireUser(userId));
    }

    @Transactional
    public ProfileResponse updateMe(UUID userId, UpdateProfileRequest req) {
        UserAccount u = requireUser(userId);
        if (req.fullName() != null && !req.fullName().isBlank()) {
            u.setFullName(req.fullName().trim());
        }
        if (req.phoneNumber() != null) {
            u.setPhoneNumber(req.phoneNumber().isBlank() ? null : req.phoneNumber().trim());
        }
        if (req.avatarUrl() != null) {
            u.setAvatarUrl(req.avatarUrl().isBlank() ? null : req.avatarUrl().trim());
        }
        return ProfileResponse.from(users.save(u));
    }

    public List<AddressResponse> myAddresses(UUID userId) {
        return AddressResponse.list(addresses.findByUserIdOrderByCreatedAtDesc(userId));
    }

    @Transactional
    public AddressResponse addAddress(UUID userId, AddressRequest req) {
        requireUser(userId);
        Geo.requireCoordinates(req.latitude(), req.longitude());
        Address a = new Address();
        a.setUserId(userId);
        apply(a, req);
        if (req.isDefault()) {
            clearDefaults(userId);
            a.setDefault(true);
        }
        return AddressResponse.from(addresses.save(a));
    }

    @Transactional
    public AddressResponse updateAddress(UUID userId, UUID addressId, AddressRequest req) {
        Address a = ownedAddress(userId, addressId);
        Geo.requireCoordinates(req.latitude(), req.longitude());
        apply(a, req);
        if (req.isDefault()) {
            clearDefaults(userId);
            a.setDefault(true);
        }
        return AddressResponse.from(addresses.save(a));
    }

    @Transactional
    public void deleteAddress(UUID userId, UUID addressId) {
        addresses.delete(ownedAddress(userId, addressId));
    }

    public DeliveryFeeResponse deliveryFee(UUID userId, UUID addressId, UUID businessId) {
        Address address = ownedAddress(userId, addressId);
        Business shop = businesses.findById(businessId)
                .orElseThrow(() -> BusinessException.notFound("BUSINESS_NOT_FOUND", "Shop not found"));
        if (shop.getLatitude() == null || shop.getLongitude() == null) {
            return new DeliveryFeeResponse(Geo.deliveryFee(0));
        }
        double km = Geo.haversineKm(
                address.getLatitude(),
                address.getLongitude(),
                shop.getLatitude(),
                shop.getLongitude());
        return new DeliveryFeeResponse(Geo.deliveryFee(km));
    }

    public UserAccount requireUser(UUID userId) {
        return users.findById(userId)
                .orElseThrow(() -> BusinessException.notFound("USER_NOT_FOUND", "User not found"));
    }

    public Address requireOwnedAddress(UUID userId, UUID addressId) {
        return ownedAddress(userId, addressId);
    }

    private Address ownedAddress(UUID userId, UUID addressId) {
        Address a = addresses.findById(addressId)
                .orElseThrow(() -> BusinessException.notFound("ADDRESS_NOT_FOUND", "Address not found"));
        if (!a.getUserId().equals(userId)) {
            throw BusinessException.forbidden("FORBIDDEN", "Not your address");
        }
        return a;
    }

    private void apply(Address a, AddressRequest req) {
        a.setTitle(req.title().trim());
        a.setAddressText(req.addressText().trim());
        a.setLatitude(req.latitude());
        a.setLongitude(req.longitude());
        a.setDefault(req.isDefault());
    }

    private void clearDefaults(UUID userId) {
        for (Address existing : addresses.findByUserIdOrderByCreatedAtDesc(userId)) {
            if (existing.isDefault()) {
                existing.setDefault(false);
                addresses.save(existing);
            }
        }
    }
}
