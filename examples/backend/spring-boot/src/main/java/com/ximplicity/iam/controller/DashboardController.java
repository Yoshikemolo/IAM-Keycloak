package com.ximplicity.iam.controller;

import java.util.List;

import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.ximplicity.iam.service.UserService;

/**
 * Controller for the authenticated dashboard page.
 *
 * <p>Displays user information, realm roles, and token details
 * extracted from the OIDC identity token.
 */
@Controller
public class DashboardController {

    private final UserService userService;

    /**
     * Creates a new {@code DashboardController}.
     *
     * @param userService the user information service
     */
    public DashboardController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Renders the dashboard page with user information.
     *
     * @param token the OAuth2 authentication token
     * @param model the Thymeleaf model
     * @return the template name
     */
    @GetMapping("/dashboard")
    public String dashboard(OAuth2AuthenticationToken token, Model model) {
        String displayName = userService.getDisplayName(token);
        String email = userService.getEmail(token);
        List<String> roles = userService.getRealmRoles(token);
        boolean isAdmin = userService.hasRole(token, "admin");

        model.addAttribute("userName", displayName);
        model.addAttribute("userEmail", email);
        model.addAttribute("roles", roles);
        model.addAttribute("isAdmin", isAdmin);

        return "dashboard";
    }
}
