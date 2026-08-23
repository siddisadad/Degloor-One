package com.degloor.one.common.security;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "degloor.jwt")
public class JwtProperties {
    private String secret;
    private long accessMinutes = 30;
    private long refreshDays = 14;

    public String getSecret() { return secret; }
    public void setSecret(String secret) { this.secret = secret; }
    public long getAccessMinutes() { return accessMinutes; }
    public void setAccessMinutes(long accessMinutes) { this.accessMinutes = accessMinutes; }
    public long getRefreshDays() { return refreshDays; }
    public void setRefreshDays(long refreshDays) { this.refreshDays = refreshDays; }
}
