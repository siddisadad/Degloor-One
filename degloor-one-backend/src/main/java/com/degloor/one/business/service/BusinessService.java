package com.degloor.one.business.service;

import com.degloor.one.business.dto.BusinessDtos.BusinessResponse;
import com.degloor.one.business.dto.BusinessDtos.CategoryResponse;
import com.degloor.one.business.dto.BusinessDtos.HoursRequest;
import com.degloor.one.business.dto.BusinessDtos.HoursResponse;
import com.degloor.one.business.dto.BusinessDtos.UpsertBusinessRequest;
import com.degloor.one.business.entity.Business;
import com.degloor.one.business.entity.BusinessHours;
import com.degloor.one.business.repository.BusinessCategoryRepository;
import com.degloor.one.business.repository.BusinessHoursRepository;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.business.repository.BusinessSpecifications;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.security.Roles;
import com.degloor.one.common.util.Geo;
import com.degloor.one.user.entity.UserAccount;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BusinessService {
    private final BusinessRepository businesses;
    private final BusinessCategoryRepository categories;
    private final BusinessHoursRepository hours;

    public BusinessService(
            BusinessRepository businesses,
            BusinessCategoryRepository categories,
            BusinessHoursRepository hours
    ) {
        this.businesses = businesses;
        this.categories = categories;
        this.hours = hours;
    }

    public List<CategoryResponse> categories() {
        return categories.findAllByOrderByDisplayOrderAsc().stream().map(CategoryResponse::from).toList();
    }

    public List<BusinessResponse> search(String q, UUID categoryId, Double lat, Double lng, Double radiusKm, Boolean verifiedOnly) {
        Specification<Business> spec = BusinessSpecifications.search(q, categoryId, verifiedOnly);
        if (lat != null && lng != null && radiusKm != null) {
            spec = spec.and(BusinessSpecifications.withinBoundingBox(lat, lng, radiusKm));
        }
        List<Business> rows = businesses.findAll(spec);
        Map<UUID, List<HoursResponse>> hoursByShop = hoursByBusiness(rows.stream().map(Business::getId).toList());
        return rows.stream()
                .map(b -> {
                    Double distance = null;
                    if (lat != null && lng != null && b.getLatitude() != null && b.getLongitude() != null) {
                        distance = Geo.haversineKm(lat, lng, b.getLatitude(), b.getLongitude());
                    }
                    return BusinessResponse.from(b, hoursByShop.getOrDefault(b.getId(), List.of()), distance);
                })
                .filter(b -> radiusKm == null || b.distanceKm() == null || b.distanceKm() <= radiusKm)
                .sorted(Comparator.comparing(BusinessResponse::distanceKm, Comparator.nullsLast(Double::compareTo)))
                .toList();
    }

    public BusinessResponse get(UUID id, Double lat, Double lng) {
        Business b = require(id);
        Double distance = null;
        if (lat != null && lng != null && b.getLatitude() != null && b.getLongitude() != null) {
            distance = Geo.haversineKm(lat, lng, b.getLatitude(), b.getLongitude());
        }
        return BusinessResponse.from(b, hoursFor(id), distance);
    }

    public List<BusinessResponse> mine(UserAccount user) {
        return businesses.findByOwnerId(user.getId()).stream()
                .map(b -> BusinessResponse.from(b, hoursFor(b.getId()), null))
                .toList();
    }

    @Transactional
    public BusinessResponse create(UserAccount user, UpsertBusinessRequest req) {
        Roles.requireBusinessOwner(user);
        if (req.latitude() != null || req.longitude() != null) {
            Geo.requireCoordinates(req.latitude(), req.longitude());
        }
        if (businesses.existsByOwnerIdAndNameIgnoreCase(user.getId(), req.name().trim())) {
            throw BusinessException.conflict("BUSINESS_EXISTS", "You already have a shop with that name");
        }
        Business b = new Business();
        b.setOwnerId(user.getId());
        apply(b, req, user);
        businesses.save(b);
        replaceHours(b.getId(), req.hours());
        return BusinessResponse.from(b, hoursFor(b.getId()), null);
    }

    @Transactional
    public BusinessResponse update(UserAccount user, UUID id, UpsertBusinessRequest req) {
        Business b = requireOwned(user, id);
        apply(b, req, user);
        businesses.save(b);
        if (req.hours() != null) {
            replaceHours(id, req.hours());
        }
        return BusinessResponse.from(b, hoursFor(id), null);
    }

    @Transactional
    public void delete(UserAccount user, UUID id) {
        businesses.delete(requireOwned(user, id));
    }

    public Business require(UUID id) {
        return businesses.findById(id)
                .orElseThrow(() -> BusinessException.notFound("BUSINESS_NOT_FOUND", "Business not found"));
    }

    public Business requireOwned(UserAccount user, UUID id) {
        Business b = require(id);
        if (!Roles.isAdmin(user) && !b.getOwnerId().equals(user.getId())) {
            throw BusinessException.forbidden("FORBIDDEN", "Not your business");
        }
        return b;
    }

    private void apply(Business b, UpsertBusinessRequest req, UserAccount user) {
        b.setName(req.name().trim());
        b.setOwnerName(req.ownerName() == null || req.ownerName().isBlank() ? user.getFullName() : req.ownerName());
        b.setDescription(req.description());
        b.setCategoryId(req.categoryId());
        b.setCityId(req.cityId());
        b.setAddressText(req.addressText());
        b.setWhatsappNumber(req.whatsappNumber());
        b.setPhoneNumber(req.phoneNumber());
        b.setLatitude(req.latitude());
        b.setLongitude(req.longitude());
        if (req.open() != null) {
            b.setOpen(req.open());
        }
        b.setImageUrl(req.imageUrl());
    }

    private List<HoursResponse> hoursFor(UUID businessId) {
        return hours.findByBusinessIdOrderByDayOfWeekAsc(businessId).stream().map(HoursResponse::from).toList();
    }

    private Map<UUID, List<HoursResponse>> hoursByBusiness(Collection<UUID> businessIds) {
        if (businessIds.isEmpty()) {
            return Map.of();
        }
        Map<UUID, List<HoursResponse>> map = new HashMap<>();
        for (BusinessHours row : hours.findByBusinessIdInOrderByDayOfWeekAsc(businessIds)) {
            map.computeIfAbsent(row.getBusinessId(), ignored -> new ArrayList<>()).add(HoursResponse.from(row));
        }
        return map;
    }

    private void replaceHours(UUID businessId, List<HoursRequest> rows) {
        if (rows == null) {
            return;
        }
        hours.deleteByBusinessId(businessId);
        for (HoursRequest row : rows) {
            if (row.dayOfWeek() < 0 || row.dayOfWeek() > 6) {
                throw BusinessException.badRequest("INVALID_HOURS", "Day of week must be 0-6");
            }
            BusinessHours h = new BusinessHours();
            h.setBusinessId(businessId);
            h.setDayOfWeek(row.dayOfWeek());
            h.setOpenTime(row.openTime());
            h.setCloseTime(row.closeTime());
            h.setClosed(row.closed());
            hours.save(h);
        }
    }
}
