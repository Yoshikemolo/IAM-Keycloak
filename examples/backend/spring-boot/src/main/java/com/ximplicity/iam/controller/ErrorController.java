package com.ximplicity.iam.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Controller for error and access-denied pages.
 */
@Controller
public class ErrorController {

    /**
     * Renders the "access denied" / unauthorized page.
     *
     * @return the template name
     */
    @GetMapping("/unauthorized")
    public String unauthorized() {
        return "unauthorized";
    }
}
