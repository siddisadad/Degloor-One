package com.degloor.one.business.service;

import com.degloor.one.business.dto.BusinessDtos.BusinessQuery;
import com.degloor.one.business.dto.BusinessDtos.BusinessResponse;
import com.degloor.one.business.dto.BusinessDtos.CategoryResponse;
import com.degloor.one.business.dto.BusinessDtos.HoursRequest;
import com.degloor.one.business.dto.BusinessDtos.HoursResponse;
import com.degloor.one.business.dto.BusinessDtos.UpsertBusinessRequest;
import com.degloor.one.business.entity.Business;
import com.degloor.one.business.entity.BusinessCategory;
import com.degloor.one.business.entity.BusinessHours;
import com.degloor.one.business.entity.City;
import com.degloor.one.business.repository.BusinessCategoryRepository;
import com.degloor.one.business.repository.BusinessHoursRepository;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.business.repository.BusinessSpecifications;
import com.degloor.one.business.repository.CityRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.response.PageResponse;
import com.degloor.one.common.security.Roles;
import com.degloor.one.common.util.Geo;
import com.degloor.one.review.repository.ReviewRepository;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
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
    private final CityRepository cities;
    private final ReviewRepository reviews;
    private final UserRepository users;

    public BusinessService(
            BusinessRepository businesses,
            BusinessCategoryRepository categories,
            BusinessHoursRepository hours,
            CityRepository cities,
            ReviewRepository reviews,
            UserRepository users
    ) {
        this.businesses = businesses;
        this.categories = categories;
        this.hours = hours;
        this.cities = cities;
        this.reviews = reviews;
        this.users = users;
    }

    public List<CategoryResponse> categories() {
        return categories.findAllByOrderByDisplayOrderAsc().stream().map(CategoryResponse::from).toList();
    }

    public PageResponse<BusinessResponse> search(BusinessQuery query) {
        int page = query.page() == null ? 0 : Math.max(query.page(), 0);
        int size = Math.min(Math.max(
                query.size() == null || query.size() <= 0 ? BusinessQuery.DEFAULT_SIZE : query.size(),
                1), 50);
        Specification<Business> spec = BusinessSpecifications.search(query.q(), query.categoryId(), query.verified());
        spec = spec.and(BusinessSpecifications.inCity(query.city()));
        if (query.lat() != null && query.lng() != null && query.radiusKm() != null) {
            spec = spec.and(BusinessSpecifications.withinBoundingBox(query.lat(), query.lng(), query.radiusKm()));
        }
        List<Business> rows = businesses.findAll(spec);
        Map<UUID, List<HoursResponse>> hoursByShop =
                hoursByBusiness(rows.stream().map(Business::getId).toList());
        Map<UUID, String> categoryNames = categoryNames();
        Map<UUID, String> cityNames = cityNames();
        Map<UUID, Long> reviewCounts = reviewCounts(rows.stream().map(Business::getId).toList());
        List<BusinessResponse> mapped = new ArrayList<>();
        for (Business b : rows) {
            Double distance = null;
            if (query.lat() != null && query.lng() != null && b.getLatitude() != null && b.getLongitude() != null) {
                distance = Geo.haversineKm(query.lat(), query.lng(), b.getLatitude(), b.getLongitude());
            }
            if (query.radiusKm() != null && distance != null && distance > query.radiusKm()) {
                continue;
            }
            BusinessResponse row = BusinessResponse.from(
                    b,
                    hoursByShop.getOrDefault(b.getId(), List.of()),
                    distance,
                    b.getCategoryId() == null ? null : categoryNames.get(b.getCategoryId()),
                    b.getCityId() == null ? null : cityNames.get(b.getCityId()),
                    reviewCounts.getOrDefault(b.getId(), 0L)
            );
            if (query.openNow() != null && query.openNow() && !row.currentlyOpen()) {
                continue;
            }
            if (query.minRating() != null && query.minRating() > 0 && row.rating() < query.minRating()) {
                continue;
            }
            mapped.add(row);
        }
        mapped.sort(Comparator.comparing(BusinessResponse::distanceKm, Comparator.nullsLast(Double::compareTo)));
        int from = page * size;
        if (from >= mapped.size()) {
            return PageResponse.of(List.of(), page, size, mapped.size());
        }
        return PageResponse.of(mapped.subList(from, Math.min(from + size, mapped.size())), page, size, mapped.size());
    }

    public BusinessResponse get(UUID id, Double lat, Double lng) {
        Business b = require(id);
        Double distance = null;
        if (lat != null && lng != null && b.getLatitude() != null && b.getLongitude() != null) {
            distance = Geo.haversineKm(lat, lng, b.getLatitude(), b.getLongitude());
        }
        return toResponse(b, hoursFor(id), distance);
    }

    public List<BusinessResponse> mine(UserAccount user) {
        return businesses.findByOwnerId(user.getId()).stream()
                .map(b -> toResponse(b, hoursFor(b.getId()), null))
                .toList();
    }

    @Transactional
    public BusinessResponse create(UserAccount user, UpsertBusinessRequest req) {
        promoteCustomerToOwner(user);
        Roles.requireBusinessOwner(user);
        if (req.latitude() != null || req.longitude() != null) {
            Geo.requireCoordinates(req.latitude(), req.longitude());
        }
        if (businesses.existsByOwnerIdAndNameIgnoreCase(user.getId(), req.name().trim())) {
            throw BusinessException.conflict("BUSINESS_EXISTS", "You already have a shop with that name");
        }
        Business b = new Business();
        b.setOwnerId(user.getId());
        b.setSource("owner");
        apply(b, req, user);
        businesses.save(b);
        replaceHours(b.getId(), req.hours());
        return toResponse(b, hoursFor(b.getId()), null);
    }

    @Transactional
    public BusinessResponse update(UserAccount user, UUID id, UpsertBusinessRequest req) {
        Business b = requireOwned(user, id);
        apply(b, req, user);
        businesses.save(b);
        if (req.hours() != null) {
            replaceHours(id, req.hours());
        }
        return toResponse(b, hoursFor(id), null);
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

    private BusinessResponse toResponse(Business b, List<HoursResponse> hours, Double distanceKm) {
        return BusinessResponse.from(
                b,
                hours,
                distanceKm,
                categoryName(b.getCategoryId()),
                cityName(b.getCityId()),
                reviews.countByBusinessId(b.getId())
        );
    }

    private void promoteCustomerToOwner(UserAccount user) {
        if (!Roles.CUSTOMER.equals(user.getRole())) {
            return;
        }
        user.setRole(Roles.BUSINESS_OWNER);
        users.save(user);
    }

    private void apply(Business b, UpsertBusinessRequest req, UserAccount user) {
        b.setName(req.name().trim());
        b.setOwnerName(req.ownerName() == null || req.ownerName().isBlank() ? user.getFullName() : req.ownerName());
        b.setDescription(req.description());
        b.setCategoryId(req.categoryId());
        if (req.subCategory() != null) {
            String sub = req.subCategory().trim();
            b.setSubCategory(sub.isEmpty() ? null : sub);
        }
        b.setCityId(req.cityId());
        b.setAddressText(req.addressText());
        b.setWhatsappNumber(req.whatsappNumber());
        b.setPhoneNumber(req.phoneNumber());
        b.setLatitude(req.latitude());
        b.setLongitude(req.longitude());
        if (req.discoveryRadius() != null) {
            if (req.discoveryRadius() <= 0) {
                throw BusinessException.badRequest("INVALID_RADIUS", "Discovery radius must be greater than 0");
            }
            b.setDiscoveryRadius(req.discoveryRadius());
        }
        if (req.open() != null) {
            b.setOpen(req.open());
        }
        b.setImageUrl(req.imageUrl());
        if (req.photos() != null) {
            b.setPhotos(new ArrayList<>(req.photos()));
            if ((req.imageUrl() == null || req.imageUrl().isBlank()) && !req.photos().isEmpty()) {
                b.setImageUrl(req.photos().get(0));
            }
        } else if (req.imageUrl() != null && !req.imageUrl().isBlank()
                && (b.getPhotos() == null || b.getPhotos().isEmpty())) {
            b.setPhotos(new ArrayList<>(List.of(req.imageUrl())));
        }
    }

    private String categoryName(UUID categoryId) {
        if (categoryId == null) return null;
        return categories.findById(categoryId).map(BusinessCategory::getName).orElse(null);
    }

    private String cityName(UUID cityId) {
        if (cityId == null) return null;
        return cities.findById(cityId).map(City::getName).orElse(null);
    }

    private Map<UUID, String> categoryNames() {
        Map<UUID, String> map = new HashMap<>();
        for (BusinessCategory row : categories.findAll()) {
            map.put(row.getId(), row.getName());
        }
        return map;
    }

    private Map<UUID, String> cityNames() {
        Map<UUID, String> map = new HashMap<>();
        for (City row : cities.findAll()) {
            map.put(row.getId(), row.getName());
        }
        return map;
    }

    private Map<UUID, Long> reviewCounts(Collection<UUID> businessIds) {
        if (businessIds.isEmpty()) {
            return Map.of();
        }
        Map<UUID, Long> map = new HashMap<>();
        for (Object[] row : reviews.countGroupedByBusinessId(businessIds)) {
            map.put((UUID) row[0], (Long) row[1]);
        }
        return map;
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
