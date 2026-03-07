package com.ximplicity.iam.controller;

import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.ximplicity.iam.service.UserService;

/**
 * Controller for the public home page.
 *
 * <p>The home page is accessible without authentication. When the user
 * is already logged in, it displays a personalised greeting and a link
 * to the dashboard.
 */
@Controller
public class HomeController {

    private final UserService userService;

    /**
     * Creates a new {@code HomeController}.
     *
     * @param userService the user information service
     */
    public HomeController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Renders the home page.
     *
     * @param token the OAuth2 authentication token (may be {@code null}
     *              for anonymous users)
     * @param model the Thymeleaf model
     * @return the template name
     */
    @GetMapping("/")
    public String home(OAuth2AuthenticationToken token, Model model) {
        if (token != null) {
            model.addAttribute("userName", userService.getDisplayName(token));
            model.addAttribute("authenticated", true);
        } else {
            model.addAttribute("authenticated", false);
        }
        return "home";
    }
}
