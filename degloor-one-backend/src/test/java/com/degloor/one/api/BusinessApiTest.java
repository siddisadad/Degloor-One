package com.degloor.one.api;

import com.degloor.one.business.entity.BusinessCategory;
import com.degloor.one.business.entity.City;
import com.degloor.one.business.repository.BusinessCategoryRepository;
import com.degloor.one.business.repository.CityRepository;
import com.degloor.one.user.entity.UserAccount;
import com.degloor.one.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.ResultActions;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class BusinessApiTest {
    @Autowired MockMvc mvc;
    @Autowired ObjectMapper mapper;
    @Autowired UserRepository users;
    @Autowired CityRepository cities;
    @Autowired BusinessCategoryRepository categories;

    @Test
    void listSearchNearbyAndCategoryPages() throws Exception {
        String ownerEmail = "owner-" + id() + "@degloor.test";
        String ownerToken = token(register(ownerEmail, "password1", "Shop Owner"));
        promote(ownerEmail, "business_owner");

        City city = new City();
        city.setName("Degloor");
        city.setState("Maharashtra");
        cities.save(city);

        BusinessCategory category = new BusinessCategory();
        category.setName("Electronics");
        category.setIconName("phone_android");
        category.setDisplayOrder(3);
        categories.save(category);

        String businessId = dataId(postAuth(ownerToken, "/api/v1/businesses", Map.of(
                "name", "Sangmeshwar Mobile Shop",
                "addressText", "Tail Gali, Degloor",
                "phoneNumber", "+918149976123",
                "categoryId", category.getId().toString(),
                "subCategory", "Mobile Phones & Repair",
                "cityId", city.getId().toString(),
                "latitude", 18.5522,
                "longitude", 77.5844,
                "discoveryRadius", 10,
                "open", true
        )));

        mvc.perform(get("/api/v1/businesses").param("page", "0").param("size", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.items[0].id").value(businessId))
                .andExpect(jsonPath("$.data.items[0].businessId").value(businessId))
                .andExpect(jsonPath("$.data.items[0].businessName").value("Sangmeshwar Mobile Shop"))
                .andExpect(jsonPath("$.data.items[0].category").value("Electronics"))
                .andExpect(jsonPath("$.data.items[0].subCategory").value("Mobile Phones & Repair"))
                .andExpect(jsonPath("$.data.items[0].address").value("Tail Gali, Degloor"))
                .andExpect(jsonPath("$.data.items[0].phone").value("+918149976123"))
                .andExpect(jsonPath("$.data.items[0].verified").value(false))
                .andExpect(jsonPath("$.data.items[0].verificationStatus").value("PENDING_VERIFICATION"))
                .andExpect(jsonPath("$.data.items[0].discoveryRadius").value(10.0))
                .andExpect(jsonPath("$.data.page").value(0))
                .andExpect(jsonPath("$.data.size").value(20));

        mvc.perform(get("/api/v1/businesses/search").param("q", "mobile").param("city", "Degloor"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.items[0].id").value(businessId))
                .andExpect(jsonPath("$.data.total").value(1));

        mvc.perform(get("/api/v1/businesses/search").param("q", "electronics"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.items[0].id").value(businessId));

        mvc.perform(get("/api/v1/businesses/nearby")
                        .param("latitude", "18.5522")
                        .param("longitude", "77.5844")
                        .param("radius", "5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.items[0].id").value(businessId))
                .andExpect(jsonPath("$.data.items[0].distanceKm").isNumber());

        mvc.perform(get("/api/v1/businesses/nearby"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_LOCATION"));

        mvc.perform(get("/api/v1/businesses/category/" + category.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.items[0].id").value(businessId));

        mvc.perform(get("/api/v1/businesses/" + businessId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.businessId").value(businessId))
                .andExpect(jsonPath("$.data.source").value("owner"));
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

    private ResultActions postAuth(String token, String path, Object body) throws Exception {
        return mvc.perform(post(path)
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(mapper.writeValueAsString(body)));
    }

    private String dataId(ResultActions actions) throws Exception {
        MvcResult result = actions.andExpect(status().isOk()).andReturn();
        return mapper.readTree(result.getResponse().getContentAsString()).path("data").path("id").asText();
    }

    private static String id() {
        return UUID.randomUUID().toString().substring(0, 8);
    }
}
