package com.degloor.one.marketplace.service;

import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.security.Roles;
import com.degloor.one.marketplace.dto.MarketplaceDtos.CategoryResponse;
import com.degloor.one.marketplace.dto.MarketplaceDtos.CreateRequestDto;
import com.degloor.one.marketplace.dto.MarketplaceDtos.ProviderResponse;
import com.degloor.one.marketplace.dto.MarketplaceDtos.RegisterProviderRequest;
import com.degloor.one.marketplace.dto.MarketplaceDtos.RequestResponse;
import com.degloor.one.marketplace.entity.ServiceProvider;
import com.degloor.one.marketplace.entity.ServiceRequest;
import com.degloor.one.marketplace.repository.ServiceCategoryRepository;
import com.degloor.one.marketplace.repository.ServiceProviderRepository;
import com.degloor.one.marketplace.repository.ServiceRequestRepository;
import com.degloor.one.notification.service.NotificationService;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MarketplaceService {
    private static final Set<String> PROVIDER_NEXT = Set.of("accepted", "declined");

    private final ServiceCategoryRepository categories;
    private final ServiceProviderRepository providers;
    private final ServiceRequestRepository requests;
    private final UserRepository users;
    private final NotificationService notifications;

    public MarketplaceService(
            ServiceCategoryRepository categories,
            ServiceProviderRepository providers,
            ServiceRequestRepository requests,
            UserRepository users,
            NotificationService notifications
    ) {
        this.categories = categories;
        this.providers = providers;
        this.requests = requests;
        this.users = users;
        this.notifications = notifications;
    }

    public List<CategoryResponse> categories() {
        return categories.findAllByOrderByNameAsc().stream().map(CategoryResponse::from).toList();
    }

    public List<ProviderResponse> providers(UUID categoryId) {
        List<ServiceProvider> rows = categoryId == null
                ? providers.findAllByOrderByIdAsc()
                : providers.findByCategoryIdOrderByIdAsc(categoryId);
        return rows.stream().map(ProviderResponse::from).toList();
    }

    public ProviderResponse provider(UUID id) {
        return ProviderResponse.from(providers.findById(id)
                .orElseThrow(() -> BusinessException.notFound("PROVIDER_NOT_FOUND", "Service provider not found")));
    }

    @Transactional
    public ProviderResponse register(UserAccount user, RegisterProviderRequest req) {
        return providers.findByUserId(user.getId()).map(ProviderResponse::from).orElseGet(() -> {
            ServiceProvider p = new ServiceProvider();
            p.setUserId(user.getId());
            p.setCategoryId(req.categoryId());
            p.setBio(req.bio());
            p.setHourlyRate(req.hourlyRate());
            p.setExperienceYears(req.experienceYears());
            p.setVerified(false);
            if (Roles.CUSTOMER.equals(user.getRole())) {
                user.setRole(Roles.SERVICE_PROVIDER);
                users.save(user);
            }
            return ProviderResponse.from(providers.save(p));
        });
    }

    @Transactional
    public RequestResponse create(UserAccount user, CreateRequestDto req) {
        ServiceProvider provider = providers.findById(req.providerId())
                .orElseThrow(() -> BusinessException.notFound("PROVIDER_NOT_FOUND", "Service provider not found"));
        ServiceRequest row = new ServiceRequest();
        row.setUserId(user.getId());
        row.setProviderId(provider.getId());
        row.setDescription(req.description().trim());
        row.setScheduledAt(req.scheduledAt());
        row.setStatus("pending");
        requests.save(row);
        notifications.notifyQuietly(provider.getUserId(), "New service request", "A customer requested your service.", "service");
        return RequestResponse.from(row);
    }

    public List<RequestResponse> mine(UserAccount user) {
        return requests.findByUserIdOrderByCreatedAtDesc(user.getId()).stream().map(RequestResponse::from).toList();
    }

    public List<RequestResponse> forProvider(UserAccount user) {
        ServiceProvider provider = providers.findByUserId(user.getId())
                .orElseThrow(() -> BusinessException.notFound("PROVIDER_NOT_FOUND", "Service provider not found"));
        return requests.findByProviderIdOrderByCreatedAtDesc(provider.getId()).stream().map(RequestResponse::from).toList();
    }

    @Transactional
    public RequestResponse transition(UserAccount user, UUID id, String next) {
        ServiceRequest row = requests.findById(id)
                .orElseThrow(() -> BusinessException.notFound("REQUEST_NOT_FOUND", "Service request not found"));
        String status = next.toLowerCase();
        ServiceProvider provider = providers.findById(row.getProviderId()).orElseThrow();
        boolean providerActor = provider.getUserId().equals(user.getId()) || Roles.isAdmin(user);
        boolean customerActor = row.getUserId().equals(user.getId());
        if ("cancelled".equals(status)) {
            if (!customerActor) {
                throw BusinessException.forbidden("FORBIDDEN", "Only the customer can cancel this request");
            }
            if (!"pending".equals(row.getStatus())) {
                throw BusinessException.conflict("INVALID_REQUEST_TRANSITION", "Only pending requests can be cancelled");
            }
            row.setStatus("declined");
            return RequestResponse.from(requests.save(row));
        }
        if (!providerActor) {
            throw BusinessException.forbidden("FORBIDDEN", "Only the assigned provider can update this request");
        }
        if (PROVIDER_NEXT.contains(status)) {
            if (!"pending".equals(row.getStatus())) {
                throw BusinessException.conflict("INVALID_REQUEST_TRANSITION", "Request is no longer pending");
            }
            row.setStatus(status);
        } else if ("completed".equals(status)) {
            if (!"accepted".equals(row.getStatus())) {
                throw BusinessException.conflict("INVALID_REQUEST_TRANSITION", "Only accepted requests can be completed");
            }
            row.setStatus("completed");
        } else {
            throw BusinessException.badRequest("INVALID_REQUEST_TRANSITION", "Unknown request status");
        }
        requests.save(row);
        notifications.notifyQuietly(row.getUserId(), "Service update", "Your service request is now " + row.getStatus() + ".", "service");
        return RequestResponse.from(row);
    }
}
