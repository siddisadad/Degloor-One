package com.degloor.one.common.security;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "degloor.swagger")
public class SwaggerProperties {
    /** When false, OpenAPI docs and Swagger UI are not exposed. */
    private boolean enabled = true;

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }
}
