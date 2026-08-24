package com.degloor.one.api;

import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class CheckoutSecurityTest {
    @Autowired MockMvc mvc;
    @Autowired ObjectMapper mapper;
    @Autowired UserRepository users;

    @Test
    void registerLoginCartCheckoutCancelAndOwnership() throws Exception {
        String customerToken = token(register("cust-" + id() + "@degloor.test", "password1", "Customer One"));
        String otherToken = token(register("other-" + id() + "@degloor.test", "password1", "Customer Two"));
        String ownerEmail = "owner-" + id() + "@degloor.test";
        String ownerToken = token(register(ownerEmail, "password1", "Shop Owner"));
        promote(ownerEmail, "business_owner");

        String adminEmail = "admin-" + id() + "@degloor.test";
        String adminToken = token(register(adminEmail, "password1", "Admin"));
        promote(adminEmail, "admin");

        String businessId = dataId(postAuth(ownerToken, "/api/v1/businesses", Map.of(
                "name", "Patil Test Kirana",
                "addressText", "Main Market, Degloor",
                "latitude", 18.5522,
                "longitude", 77.5844,
                "open", true
        )));
        postAuth(adminToken, "/api/v1/admin/businesses/" + businessId + "/verify", Map.of("verified", true));
        mvc.perform(get("/api/v1/businesses/" + businessId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.source").value("owner"))
                .andExpect(jsonPath("$.data.photos").isArray())
                .andExpect(jsonPath("$.data.updatedAt").exists())
                .andExpect(jsonPath("$.data.verified").value(true));

        String productId = dataId(postAuth(ownerToken, "/api/v1/products", Map.of(
                "businessId", businessId,
                "name", "Fresh Milk",
                "price", 60,
                "available", true,
                "stockQuantity", 20,
                "trackInventory", true
        )));

        String addressId = dataId(postAuth(customerToken, "/api/v1/users/me/addresses", Map.of(
                "title", "Home",
                "addressText", "Lane 2, Degloor",
                "latitude", 18.5522,
                "longitude", 77.5844,
                "isDefault", true
        )));

        postAuth(customerToken, "/api/v1/cart/items", Map.of(
                "productId", productId,
                "quantity", 2,
                "replaceOtherBusiness", false
        )).andExpect(status().isOk())
                .andExpect(jsonPath("$.data.subtotal").value(120.0));

        String orderJson = postAuth(customerToken, "/api/v1/orders", Map.of(
                "addressId", addressId,
                "paymentMethod", "COD"
        )).andExpect(status().isOk())
                .andExpect(jsonPath("$.data.subtotal").value(120.0))
                .andExpect(jsonPath("$.data.status").value("pending"))
                .andReturn().getResponse().getContentAsString();
        JsonNode order = mapper.readTree(orderJson).path("data");
        String orderId = order.path("id").asText();
        assertEquals(20.0, order.path("deliveryFee").asDouble());
        assertEquals(140.0, order.path("totalAmount").asDouble());

        mvc.perform(get("/api/v1/orders/" + orderId).header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isForbidden());
        mvc.perform(get("/api/v1/admin/users").header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isForbidden());
        mvc.perform(get("/api/v1/orders/" + orderId).header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk());

        postAuth(customerToken, "/api/v1/orders/" + orderId + "/cancel", Map.of("reason", "changed mind"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("cancelled"));

        mvc.perform(get("/actuator/health")).andExpect(status().isOk());
        assertTrue(users.findByEmailIgnoreCase(ownerEmail).isPresent());
        assertNotEquals(customerToken, otherToken);
    }

    @Test
    void customerCanOpenAShopAndBecomeOwner() throws Exception {
        String email = "shop-" + id() + "@degloor.test";
        String token = token(register(email, "password1", "Priya Kale"));
        assertEquals("customer", users.findByEmailIgnoreCase(email).orElseThrow().getRole());

        String businessId = dataId(postAuth(token, "/api/v1/businesses", Map.of(
                "name", "Kale Kirana",
                "ownerName", "Priya Kale",
                "addressText", "Lane 2, Degloor",
                "latitude", 18.5522,
                "longitude", 77.5844,
                "open", true
        )));

        assertEquals("business_owner", users.findByEmailIgnoreCase(email).orElseThrow().getRole());
        mvc.perform(get("/api/v1/auth/me").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.role").value("business_owner"));
        mvc.perform(get("/api/v1/businesses/mine").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].id").value(businessId));

        String riderEmail = "rider-" + id() + "@degloor.test";
        String riderToken = token(register(riderEmail, "password1", "Rider"));
        promote(riderEmail, "delivery_partner");
        postAuth(riderToken, "/api/v1/businesses", Map.of(
                "name", "Rider Mart",
                "addressText", "Stand, Degloor",
                "latitude", 18.5522,
                "longitude", 77.5844
        )).andExpect(status().isForbidden());
        assertEquals("delivery_partner", users.findByEmailIgnoreCase(riderEmail).orElseThrow().getRole());
    }

    @Test
    void invalidLoginFails() throws Exception {
        mvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(mapper.writeValueAsString(Map.of("email", "missing@degloor.test", "password", "nope"))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
    }

    @Test
    void anonymousOwnerRoutesRequireSignIn() throws Exception {
        mvc.perform(get("/api/v1/businesses/mine"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
        mvc.perform(get("/api/v1/jobs/11111111-1111-4111-8111-111111111111/applications"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
        mvc.perform(get("/api/v1/admin/users"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
        mvc.perform(get("/api/v1/jobs")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/businesses")).andExpect(status().isOk());
    }

    @Test
    void registerIgnoresClientSuppliedRole() throws Exception {
        String body = mvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"email":"role-%s@degloor.test","password":"password1","fullName":"Ravi","role":"admin"}
                                """.formatted(id())))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        assertEquals("customer", mapper.readTree(body).path("data").path("user").path("role").asText());
    }

    private String register(String email, String password, String name) throws Exception {
        return mvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(mapper.writeValueAsString(Map.of(
                                "email", email,
                                "password", password,
                                "fullName", name
                        ))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
    }

    private String token(String body) throws Exception {
        return mapper.readTree(body).path("data").path("accessToken").asText();
    }

    private void promote(String email, String role) {
        UserAccount user = users.findByEmailIgnoreCase(email).orElseThrow();
        user.setRole(role);
        users.save(user);
    }

    private org.springframework.test.web.servlet.ResultActions postAuth(String token, String path, Object body) throws Exception {
        return mvc.perform(post(path)
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(mapper.writeValueAsString(body)));
    }

    private String dataId(org.springframework.test.web.servlet.ResultActions actions) throws Exception {
        MvcResult result = actions.andExpect(status().isOk()).andReturn();
        return mapper.readTree(result.getResponse().getContentAsString()).path("data").path("id").asText();
    }

    private static String id() {
        return UUID.randomUUID().toString().substring(0, 8);
    }
}
