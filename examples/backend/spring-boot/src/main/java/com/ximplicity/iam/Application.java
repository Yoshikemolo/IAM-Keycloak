package com.ximplicity.iam;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Entry point for the IAM Spring Boot Example application.
 *
 * <p>This application demonstrates OpenID Connect authentication with
 * Keycloak using Spring Security OAuth2 Client. It serves Thymeleaf
 * templates with the same Catppuccin-themed UI as the React frontend
 * example.
 */
@SpringBootApplication
public class Application {

    /**
     * Starts the Spring Boot application.
     *
     * @param args command-line arguments
     */
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
