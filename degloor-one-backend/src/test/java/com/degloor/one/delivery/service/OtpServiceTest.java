package com.degloor.one.delivery.service;

import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.security.JwtProperties;
import com.degloor.one.common.security.OtpProperties;
import com.degloor.one.order.entity.ShopOrder;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class OtpServiceTest {
    private OtpService otp;
    private ShopOrder order;

    @BeforeEach
    void setUp() {
        OtpProperties props = new OtpProperties();
        props.setLength(4);
        props.setTtlHours(24);
        props.setMaxAttempts(5);
        JwtProperties jwt = new JwtProperties();
        jwt.setSecret("test-secret-test-secret-test-secret-test");
        otp = new OtpService(props, jwt);
        order = new ShopOrder();
        order.setId(UUID.randomUUID());
    }

    @Test
    void generateRevealAndVerify() {
        String code = otp.generateAndStore(order);
        assertEquals(4, code.length());
        assertEquals(code, otp.revealForCustomer(order));
        otp.verify(order, code);
        assertTrue(order.isOtpUsed());
        assertNull(otp.revealForCustomer(order));
    }

    @Test
    void wrongCodeIncrementsAttempts() {
        otp.generateAndStore(order);
        BusinessException ex = assertThrows(BusinessException.class, () -> otp.verify(order, "0000"));
        assertEquals("OTP_INVALID", ex.getCode());
        assertEquals(1, order.getOtpAttempts());
    }

    @Test
    void expiredCodeFails() {
        otp.generateAndStore(order);
        order.setOtpExpiresAt(Instant.now().minus(1, ChronoUnit.MINUTES));
        BusinessException ex = assertThrows(BusinessException.class, () -> otp.verify(order, "1234"));
        assertEquals("OTP_EXPIRED", ex.getCode());
    }

    @Test
    void usedCodeFails() {
        String code = otp.generateAndStore(order);
        otp.verify(order, code);
        BusinessException ex = assertThrows(BusinessException.class, () -> otp.verify(order, code));
        assertEquals("OTP_USED", ex.getCode());
    }

    @Test
    void lockAfterMaxAttempts() {
        otp.generateAndStore(order);
        for (int i = 0; i < 5; i++) {
            try {
                otp.verify(order, "0000");
            } catch (BusinessException ignored) {
            }
        }
        BusinessException ex = assertThrows(BusinessException.class, () -> otp.verify(order, "0000"));
        assertEquals("OTP_LOCKED", ex.getCode());
    }

    @Test
    void hashIsDeterministic() {
        assertNotNull(OtpService.hash(order.getId().toString(), "1234"));
        assertEquals(
                OtpService.hash(order.getId().toString(), "1234"),
                OtpService.hash(order.getId().toString(), "1234")
        );
    }
}
