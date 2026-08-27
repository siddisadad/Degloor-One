package com.degloor.one.common.exception;

public class BusinessException extends RuntimeException {
    private final String code;
    private final int status;

    public BusinessException(String code, String message, int status) {
        super(message);
        this.code = code;
        this.status = status;
    }

    public String getCode() { return code; }
    public int getStatus() { return status; }

    public static BusinessException notFound(String code, String message) {
        return new BusinessException(code, message, 404);
    }

    public static BusinessException forbidden(String code, String message) {
        return new BusinessException(code, message, 403);
    }

    public static BusinessException unauthorized(String code, String message) {
        return new BusinessException(code, message, 401);
    }

    public static BusinessException conflict(String code, String message) {
        return new BusinessException(code, message, 409);
    }

    public static BusinessException badRequest(String code, String message) {
        return new BusinessException(code, message, 400);
    }
}
