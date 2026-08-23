package com.degloor.one.delivery.service;

import com.degloor.one.common.exception.BusinessException;
import com.degloor.one.common.security.JwtProperties;
import com.degloor.one.common.security.OtpProperties;
import com.degloor.one.order.entity.ShopOrder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.Base64;
import java.util.HexFormat;
import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.stereotype.Service;

@Service
public class OtpService {
    private final OtpProperties properties;
    private final byte[] aesKey;
    private final SecureRandom random = new SecureRandom();

    public OtpService(OtpProperties properties, JwtProperties jwtProperties) {
        this.properties = properties;
        this.aesKey = Arrays.copyOf(sha256(jwtProperties.getSecret()), 32);
    }

    public String generateAndStore(ShopOrder order) {
        int bound = (int) Math.pow(10, properties.getLength());
        String otp = String.format("%0" + properties.getLength() + "d", random.nextInt(bound));
        order.setDeliveryOtpHash(hash(order.getId().toString(), otp));
        order.setDeliveryOtpCipher(encrypt(otp));
        order.setOtpExpiresAt(Instant.now().plus(properties.getTtlHours(), ChronoUnit.HOURS));
        order.setOtpAttempts(0);
        order.setOtpUsed(false);
        return otp;
    }

    public void verify(ShopOrder order, String rawOtp) {
        if (order.isOtpUsed()) {
            throw BusinessException.conflict("OTP_USED", "This delivery code has already been used");
        }
        if (order.getOtpExpiresAt() == null || Instant.now().isAfter(order.getOtpExpiresAt())) {
            throw BusinessException.badRequest("OTP_EXPIRED", "The delivery code has expired");
        }
        if (order.getOtpAttempts() >= properties.getMaxAttempts()) {
            throw BusinessException.conflict("OTP_LOCKED", "Too many incorrect delivery codes");
        }
        if (rawOtp == null || rawOtp.isBlank()
                || !hash(order.getId().toString(), rawOtp.trim()).equals(order.getDeliveryOtpHash())) {
            order.setOtpAttempts(order.getOtpAttempts() + 1);
            throw BusinessException.badRequest("OTP_INVALID", "The delivery code is invalid");
        }
        order.setOtpUsed(true);
        order.setDeliveryOtpCipher(null);
    }

    public String revealForCustomer(ShopOrder order) {
        if (order.isOtpUsed() || order.getDeliveryOtpCipher() == null) {
            return null;
        }
        if (order.getOtpExpiresAt() != null && Instant.now().isAfter(order.getOtpExpiresAt())) {
            return null;
        }
        return decrypt(order.getDeliveryOtpCipher());
    }

    static String hash(String orderId, String otp) {
        return HexFormat.of().formatHex(sha256(orderId + ':' + otp));
    }

    private String encrypt(String otp) {
        try {
            byte[] iv = new byte[12];
            random.nextBytes(iv);
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(aesKey, "AES"), new GCMParameterSpec(128, iv));
            byte[] ct = cipher.doFinal(otp.getBytes(StandardCharsets.UTF_8));
            byte[] packed = new byte[iv.length + ct.length];
            System.arraycopy(iv, 0, packed, 0, iv.length);
            System.arraycopy(ct, 0, packed, iv.length, ct.length);
            return Base64.getEncoder().encodeToString(packed);
        } catch (Exception e) {
            throw new IllegalStateException("Unable to protect OTP");
        }
    }

    private String decrypt(String cipherText) {
        try {
            byte[] packed = Base64.getDecoder().decode(cipherText);
            byte[] iv = Arrays.copyOfRange(packed, 0, 12);
            byte[] ct = Arrays.copyOfRange(packed, 12, packed.length);
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(aesKey, "AES"), new GCMParameterSpec(128, iv));
            return new String(cipher.doFinal(ct), StandardCharsets.UTF_8);
        } catch (Exception e) {
            return null;
        }
    }

    private static byte[] sha256(String value) {
        try {
            return MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new IllegalStateException("Unable to hash");
        }
    }
}
