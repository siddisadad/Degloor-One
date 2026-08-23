package com.degloor.one.cart.service;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.cart.dto.CartDtos.AddItemRequest;
import com.degloor.one.cart.entity.Cart;
import com.degloor.one.cart.repository.CartItemRepository;
import com.degloor.one.cart.repository.CartRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.product.entity.Product;
import com.degloor.one.product.repository.ProductRepository;
import com.degloor.one.user.entity.UserAccount;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CartServiceTest {
    @Mock CartRepository carts;
    @Mock CartItemRepository items;
    @Mock ProductRepository products;
    @Mock BusinessRepository businesses;
    CartService service;
    UserAccount user;
    Product product;
    Business shop;

    @BeforeEach
    void setUp() {
        service = new CartService(carts, items, products, businesses);
        user = new UserAccount();
        user.setId(UUID.randomUUID());
        shop = new Business();
        shop.setId(UUID.randomUUID());
        shop.setVerified(true);
        shop.setName("Patil Kirana");
        product = new Product();
        product.setId(UUID.randomUUID());
        product.setBusinessId(shop.getId());
        product.setName("Milk");
        product.setPrice(60);
        product.setAvailable(true);
        product.setTrackInventory(true);
        product.setStockQuantity(5);
    }

    @Test
    void rejectsUnavailableProduct() {
        product.setAvailable(false);
        when(products.findById(product.getId())).thenReturn(Optional.of(product));
        BusinessException ex = assertThrows(BusinessException.class, () ->
                service.add(user, new AddItemRequest(product.getId(), 1, false)));
        assertEquals("PRODUCT_UNAVAILABLE", ex.getCode());
    }

    @Test
    void rejectsUnverifiedShop() {
        shop.setVerified(false);
        when(products.findById(product.getId())).thenReturn(Optional.of(product));
        when(businesses.findById(shop.getId())).thenReturn(Optional.of(shop));
        BusinessException ex = assertThrows(BusinessException.class, () ->
                service.add(user, new AddItemRequest(product.getId(), 1, false)));
        assertEquals("BUSINESS_NOT_VERIFIED", ex.getCode());
    }

    @Test
    void rejectsOverstock() {
        when(products.findById(product.getId())).thenReturn(Optional.of(product));
        when(businesses.findById(shop.getId())).thenReturn(Optional.of(shop));
        BusinessException ex = assertThrows(BusinessException.class, () ->
                service.add(user, new AddItemRequest(product.getId(), 9, false)));
        assertEquals("CART_OUT_OF_STOCK", ex.getCode());
    }

    @Test
    void requiresReplacementForSecondShop() {
        Cart existing = new Cart();
        existing.setId(UUID.randomUUID());
        existing.setUserId(user.getId());
        existing.setBusinessId(UUID.randomUUID());
        when(products.findById(product.getId())).thenReturn(Optional.of(product));
        when(businesses.findById(shop.getId())).thenReturn(Optional.of(shop));
        when(carts.findByUserId(user.getId())).thenReturn(Optional.of(existing));
        BusinessException ex = assertThrows(BusinessException.class, () ->
                service.add(user, new AddItemRequest(product.getId(), 1, false)));
        assertEquals("CART_NEEDS_REPLACEMENT", ex.getCode());
    }
}
