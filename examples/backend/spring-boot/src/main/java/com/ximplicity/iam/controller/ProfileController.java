package com.ximplicity.iam.controller;

import java.util.List;
import java.util.Map;

import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.ximplicity.iam.service.UserService;

/**
 * Controller for the authenticated profile page.
 *
 * <p>Displays the full set of OIDC token claims as well as the user's
 * realm roles and basic identity information.
 */
@Controller
public class ProfileController {

    private final UserService userService;

    /**
     * Creates a new {@code ProfileController}.
     *
     * @param userService the user information service
     */
    public ProfileController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Renders the profile page with token claims.
     *
     * @param token the OAuth2 authentication token
     * @param model the Thymeleaf model
     * @return the template name
     */
    @GetMapping("/profile")
    public String profile(OAuth2AuthenticationToken token, Model model) {
        String displayName = userService.getDisplayName(token);
        String email = userService.getEmail(token);
        List<String> roles = userService.getRealmRoles(token);
        Map<String, Object> claims = userService.getClaims(token);

        model.addAttribute("userName", displayName);
        model.addAttribute("userEmail", email);
        model.addAttribute("roles", roles);
        model.addAttribute("claims", claims);

        return "profile";
    }
}
