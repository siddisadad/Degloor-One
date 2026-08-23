package com.degloor.one.common.security;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "degloor.otp")
public class OtpProperties {
    private int length = 4;
    private int ttlHours = 24;
    private int maxAttempts = 5;

    public int getLength() { return length; }
    public void setLength(int length) { this.length = length; }
    public int getTtlHours() { return ttlHours; }
    public void setTtlHours(int ttlHours) { this.ttlHours = ttlHours; }
    public int getMaxAttempts() { return maxAttempts; }
    public void setMaxAttempts(int maxAttempts) { this.maxAttempts = maxAttempts; }
}
