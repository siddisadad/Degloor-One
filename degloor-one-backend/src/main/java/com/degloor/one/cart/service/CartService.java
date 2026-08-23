package com.degloor.one.cart.service;

import com.degloor.one.business.entity.Business;
import com.degloor.one.business.repository.BusinessRepository;
import com.degloor.one.cart.dto.CartDtos.AddItemRequest;
import com.degloor.one.cart.dto.CartDtos.CartItemResponse;
import com.degloor.one.cart.dto.CartDtos.CartResponse;
import com.degloor.one.cart.entity.Cart;
import com.degloor.one.cart.entity.CartItem;
import com.degloor.one.cart.repository.CartItemRepository;
import com.degloor.one.cart.repository.CartRepository;
import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.product.entity.Product;
import com.degloor.one.product.repository.ProductRepository;
import com.degloor.one.user.entity.UserAccount;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CartService {
    private final CartRepository carts;
    private final CartItemRepository items;
    private final ProductRepository products;
    private final BusinessRepository businesses;

    public CartService(
            CartRepository carts,
            CartItemRepository items,
            ProductRepository products,
            BusinessRepository businesses
    ) {
        this.carts = carts;
        this.items = items;
        this.products = products;
        this.businesses = businesses;
    }

    public CartResponse get(UserAccount user) {
        return carts.findByUserId(user.getId()).map(this::toResponse).orElse(CartResponse.empty());
    }

    @Transactional
    public CartResponse add(UserAccount user, AddItemRequest req) {
        Product product = requireSellable(req.productId(), req.quantity());
        Cart cart = carts.findByUserId(user.getId()).orElse(null);
        if (cart != null && !cart.getBusinessId().equals(product.getBusinessId())) {
            if (!req.replaceOtherBusiness()) {
                throw BusinessException.conflict("CART_NEEDS_REPLACEMENT",
                        "Your cart has items from another shop. Clear it to add this item.");
            }
            items.deleteByCartId(cart.getId());
            carts.delete(cart);
            cart = null;
        }
        if (cart == null) {
            cart = new Cart();
            cart.setUserId(user.getId());
            cart.setBusinessId(product.getBusinessId());
            carts.save(cart);
        }
        CartItem item = items.findByCartIdAndProductId(cart.getId(), product.getId()).orElse(null);
        int nextQty = req.quantity() + (item == null ? 0 : item.getQuantity());
        if (nextQty > 99) {
            throw BusinessException.badRequest("CART_INVALID_QTY", "Quantity must be between 1 and 99");
        }
        assertStock(product, nextQty);
        if (item == null) {
            item = new CartItem();
            item.setCartId(cart.getId());
            item.setProductId(product.getId());
        }
        item.setQuantity(nextQty);
        items.save(item);
        return toResponse(cart);
    }

    @Transactional
    public CartResponse update(UserAccount user, UUID productId, int quantity) {
        Cart cart = carts.findByUserId(user.getId())
                .orElseThrow(() -> BusinessException.notFound("CART_EMPTY", "Cart is empty"));
        CartItem item = items.findByCartIdAndProductId(cart.getId(), productId)
                .orElseThrow(() -> BusinessException.notFound("CART_ITEM_NOT_FOUND", "Item is not in your cart"));
        if (quantity <= 0) {
            items.delete(item);
            if (items.findByCartId(cart.getId()).isEmpty()) {
                carts.delete(cart);
                return CartResponse.empty();
            }
            return toResponse(cart);
        }
        Product product = requireSellable(productId, quantity);
        if (!product.getBusinessId().equals(cart.getBusinessId())) {
            throw BusinessException.badRequest("CART_PRODUCT", "Product does not belong to this cart");
        }
        item.setQuantity(quantity);
        items.save(item);
        return toResponse(cart);
    }

    @Transactional
    public void clear(UserAccount user) {
        carts.findByUserId(user.getId()).ifPresent(cart -> {
            items.deleteByCartId(cart.getId());
            carts.delete(cart);
        });
    }

    public Cart requireCart(UUID userId) {
        return carts.findByUserId(userId)
                .orElseThrow(() -> BusinessException.badRequest("CART_EMPTY", "Cart is empty"));
    }

    public List<CartItem> itemsOf(UUID cartId) {
        return items.findByCartId(cartId);
    }

    public void clearCart(UUID userId) {
        carts.findByUserId(userId).ifPresent(cart -> {
            items.deleteByCartId(cart.getId());
            carts.delete(cart);
        });
    }

    private Product requireSellable(UUID productId, int quantity) {
        if (quantity < 1 || quantity > 99) {
            throw BusinessException.badRequest("CART_INVALID_QTY", "Quantity must be between 1 and 99");
        }
        Product product = products.findById(productId)
                .orElseThrow(() -> BusinessException.notFound("PRODUCT_NOT_FOUND", "Product not found"));
        if (!product.isAvailable()) {
            throw BusinessException.badRequest("PRODUCT_UNAVAILABLE", "This product is not available");
        }
        Business shop = businesses.findById(product.getBusinessId())
                .orElseThrow(() -> BusinessException.notFound("BUSINESS_NOT_FOUND", "Business not found"));
        if (!shop.isVerified()) {
            throw BusinessException.badRequest("BUSINESS_NOT_VERIFIED", "This shop is not accepting orders yet");
        }
        assertStock(product, quantity);
        return product;
    }

    private void assertStock(Product product, int quantity) {
        if (product.isTrackInventory() && quantity > product.getStockQuantity()) {
            throw BusinessException.conflict("CART_OUT_OF_STOCK", "Not enough stock for " + product.getName());
        }
    }

    private CartResponse toResponse(Cart cart) {
        Business shop = businesses.findById(cart.getBusinessId()).orElse(null);
        List<CartItemResponse> rows = new ArrayList<>();
        double subtotal = 0;
        for (CartItem item : items.findByCartId(cart.getId())) {
            Product product = products.findById(item.getProductId()).orElse(null);
            if (product == null) {
                continue;
            }
            double line = product.getPrice() * item.getQuantity();
            subtotal += line;
            rows.add(new CartItemResponse(
                    item.getId().toString(),
                    product.getId().toString(),
                    product.getName(),
                    product.getPrice(),
                    item.getQuantity(),
                    line,
                    product.isAvailable(),
                    product.isTrackInventory() ? product.getStockQuantity() : null
            ));
        }
        return new CartResponse(
                cart.getId().toString(),
                cart.getBusinessId().toString(),
                shop == null ? null : shop.getName(),
                rows,
                subtotal
        );
    }
}
