package com.degloor.one.product.service;

import com.degloor.one.business.service.BusinessService;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.response.PageResponse;
import com.degloor.one.product.dto.ProductDtos.CategoryResponse;
import com.degloor.one.product.dto.ProductDtos.ProductResponse;
import com.degloor.one.product.dto.ProductDtos.UpsertProductRequest;
import com.degloor.one.product.entity.Product;
import com.degloor.one.product.entity.ProductCategory;
import com.degloor.one.product.repository.ProductCategoryRepository;
import com.degloor.one.product.repository.ProductRepository;
import com.degloor.one.product.repository.ProductSpecifications;
import com.degloor.one.user.entity.UserAccount;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ProductService {
    private final ProductRepository products;
    private final ProductCategoryRepository categories;
    private final BusinessService businesses;

    public ProductService(
            ProductRepository products,
            ProductCategoryRepository categories,
            BusinessService businesses
    ) {
        this.products = products;
        this.categories = categories;
        this.businesses = businesses;
    }

    public PageResponse<ProductResponse> search(
            String q,
            UUID businessId,
            UUID categoryId,
            Double minPrice,
            Double maxPrice,
            Boolean available,
            int page,
            int size,
            String sort
    ) {
        Sort sortSpec = "price".equalsIgnoreCase(sort)
                ? Sort.by("price").ascending()
                : "priceDesc".equalsIgnoreCase(sort)
                ? Sort.by("price").descending()
                : Sort.by("name").ascending();
        Page<Product> result = products.findAll(
                ProductSpecifications.search(q, businessId, categoryId, minPrice, maxPrice, available),
                PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100), sortSpec));
        return PageResponse.from(result.map(ProductResponse::from));
    }

    public ProductResponse get(UUID id) {
        return ProductResponse.from(require(id));
    }

    public List<ProductResponse> forBusiness(UUID businessId, boolean availableOnly) {
        businesses.require(businessId);
        List<Product> rows = availableOnly
                ? products.findByBusinessIdAndAvailableTrueOrderByNameAsc(businessId)
                : products.findByBusinessIdOrderByNameAsc(businessId);
        return rows.stream().map(ProductResponse::from).toList();
    }

    public List<CategoryResponse> categoriesFor(UUID businessId) {
        businesses.require(businessId);
        return categories.findByBusinessIdOrderByNameAsc(businessId).stream().map(CategoryResponse::from).toList();
    }

    @Transactional
    public ProductResponse create(UserAccount user, UpsertProductRequest req) {
        businesses.requireOwned(user, req.businessId());
        Product p = new Product();
        apply(p, req);
        return ProductResponse.from(products.save(p));
    }

    @Transactional
    public ProductResponse update(UserAccount user, UUID id, UpsertProductRequest req) {
        Product p = require(id);
        businesses.requireOwned(user, p.getBusinessId());
        apply(p, req);
        return ProductResponse.from(products.save(p));
    }

    @Transactional
    public void delete(UserAccount user, UUID id) {
        Product p = require(id);
        businesses.requireOwned(user, p.getBusinessId());
        products.delete(p);
    }

    @Transactional
    public CategoryResponse createCategory(UserAccount user, UUID businessId, String name) {
        businesses.requireOwned(user, businessId);
        ProductCategory c = new ProductCategory();
        c.setBusinessId(businessId);
        c.setName(name.trim());
        return CategoryResponse.from(categories.save(c));
    }

    public Product require(UUID id) {
        return products.findById(id)
                .orElseThrow(() -> BusinessException.notFound("PRODUCT_NOT_FOUND", "Product not found"));
    }

    private void apply(Product p, UpsertProductRequest req) {
        p.setBusinessId(req.businessId());
        p.setCategoryId(req.categoryId());
        p.setName(req.name().trim());
        p.setDescription(req.description());
        p.setPrice(req.price());
        p.setImageUrl(req.imageUrl());
        if (req.available() != null) {
            p.setAvailable(req.available());
        }
        if (req.stockQuantity() != null) {
            p.setStockQuantity(req.stockQuantity());
        }
        if (req.trackInventory() != null) {
            p.setTrackInventory(req.trackInventory());
        }
    }
}
