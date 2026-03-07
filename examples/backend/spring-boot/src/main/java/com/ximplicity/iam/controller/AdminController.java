package com.ximplicity.iam.controller;

import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.ximplicity.iam.service.UserService;

/**
 * Controller for the admin-only page.
 *
 * <p>This page is restricted to users with the {@code admin} realm
 * role. The role check is enforced by Spring Security in
 * {@link com.ximplicity.iam.config.SecurityConfig}.
 */
@Controller
public class AdminController {

    private final UserService userService;

    /**
     * Creates a new {@code AdminController}.
     *
     * @param userService the user information service
     */
    public AdminController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Renders the administration page.
     *
     * @param token the OAuth2 authentication token
     * @param model the Thymeleaf model
     * @return the template name
     */
    @GetMapping("/admin")
    public String admin(OAuth2AuthenticationToken token, Model model) {
        String displayName = userService.getDisplayName(token);
        model.addAttribute("userName", displayName);
        return "admin";
    }
}
