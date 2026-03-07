package com.ximplicity.iam.service;

import jakarta.enterprise.context.ApplicationScoped;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Internationalisation service that loads message bundles from the
 * classpath and provides key-based lookups.
 *
 * <p>Message files follow the standard Java {@link Properties} naming
 * convention:</p>
 * <ul>
 *   <li>{@code messages/messages.properties} &mdash; English (default)</li>
 *   <li>{@code messages/messages_es.properties} &mdash; Spanish</li>
 * </ul>
 *
 * <p>Bundles are cached in memory after the first load for each locale.</p>
 */
@ApplicationScoped
public class I18nService {

    private static final String BUNDLE_PREFIX = "messages/messages";
    private static final String BUNDLE_SUFFIX = ".properties";

    /** Locale-keyed cache of loaded bundles. */
    private final Map<String, Map<String, String>> cache = new ConcurrentHashMap<>();

    /**
     * Returns all messages for the given language tag.
     *
     * @param lang a BCP-47 language tag such as {@code "en"} or {@code "es"}
     * @return an unmodifiable map of message keys to values
     */
    public Map<String, String> getMessages(String lang) {
        return cache.computeIfAbsent(normalise(lang), this::loadBundle);
    }

    /**
     * Returns a single message by key for the given language.
     *
     * @param lang the language tag
     * @param key  the message key (e.g. {@code "home.title"})
     * @return the translated value, or the key itself if not found
     */
    public String getMessage(String lang, String key) {
        return getMessages(lang).getOrDefault(key, key);
    }

    /**
     * Returns a message with simple placeholder replacement.
     * Placeholders use the format {@code {0}}, {@code {1}}, etc.
     *
     * @param lang   the language tag
     * @param key    the message key
     * @param params replacement values
     * @return the formatted message
     */
    public String getMessage(String lang, String key, Object... params) {
        String template = getMessage(lang, key);
        String result = template;
        for (int i = 0; i < params.length; i++) {
            result = result.replace("{" + i + "}", String.valueOf(params[i]));
        }
        return result;
    }

    // ------------------------------------------------------------------
    // Internal helpers
    // ------------------------------------------------------------------

    private String normalise(String lang) {
        if (lang == null || lang.isBlank()) {
            return "en";
        }
        // Take only the language portion (e.g. "es-MX" -> "es")
        return lang.split("[_-]")[0].toLowerCase(Locale.ROOT);
    }

    private Map<String, String> loadBundle(String lang) {
        String path = "en".equals(lang)
                ? BUNDLE_PREFIX + BUNDLE_SUFFIX
                : BUNDLE_PREFIX + "_" + lang + BUNDLE_SUFFIX;

        Properties props = new Properties();
        try (InputStream is = Thread.currentThread()
                .getContextClassLoader()
                .getResourceAsStream(path)) {
            if (is != null) {
                props.load(new InputStreamReader(is, StandardCharsets.UTF_8));
            } else if (!"en".equals(lang)) {
                // Fall back to English if the requested locale is missing
                return getMessages("en");
            }
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load i18n bundle: " + path, e);
        }

        return props.entrySet().stream()
                .collect(Collectors.toUnmodifiableMap(
                        e -> String.valueOf(e.getKey()),
                        e -> String.valueOf(e.getValue())));
    }
}
