package com.ximplicity.iam.config;

import java.util.Locale;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor;
import org.springframework.web.servlet.i18n.SessionLocaleResolver;

/**
 * Web MVC configuration for internationalisation (i18n).
 *
 * <p>Registers a {@link SessionLocaleResolver} that defaults to English
 * and a {@link LocaleChangeInterceptor} that switches locale when a
 * {@code ?lang=} query parameter is present on any request.
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    /**
     * Creates a session-based locale resolver with English as the
     * default locale.
     *
     * @return the configured {@link LocaleResolver}
     */
    @Bean
    public LocaleResolver localeResolver() {
        SessionLocaleResolver resolver = new SessionLocaleResolver();
        resolver.setDefaultLocale(Locale.ENGLISH);
        return resolver;
    }

    /**
     * Creates a locale change interceptor that reads the {@code lang}
     * query parameter.
     *
     * @return the configured {@link LocaleChangeInterceptor}
     */
    @Bean
    public LocaleChangeInterceptor localeChangeInterceptor() {
        LocaleChangeInterceptor interceptor = new LocaleChangeInterceptor();
        interceptor.setParamName("lang");
        return interceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(localeChangeInterceptor());
    }
}
