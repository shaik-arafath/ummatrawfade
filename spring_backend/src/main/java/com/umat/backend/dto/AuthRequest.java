package com.umat.backend.dto;

import lombok.Data;

@Data
public class AuthRequest {
    private String email;
    private String password;
    private String name; // optional for signup
}
