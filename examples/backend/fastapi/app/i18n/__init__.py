"""
Internationalisation (i18n) support for the FastAPI example.

Translations are stored as JSON files alongside this module.  The
:func:`get_translations` helper loads all available locales at startup, and
:func:`t` provides a dot-notated key lookup with optional interpolation.
"""

import json
from pathlib import Path
from typing import Any

# Directory containing the locale JSON files.
_LOCALE_DIR = Path(__file__).resolve().parent

# In-memory cache: ``{"en": {...}, "es": {...}}``.
_translations: dict[str, dict[str, Any]] = {}

# Supported locale codes.
SUPPORTED_LOCALES: list[str] = ["en", "es"]

# Fallback locale when the requested one is not available.
DEFAULT_LOCALE: str = "en"


def get_translations() -> dict[str, dict[str, Any]]:
    """Load and cache all locale JSON files.

    On the first call the files are read from disk; subsequent calls
    return the cached dictionaries.

    Returns:
        A mapping from locale code to its translation dictionary.
    """
    if _translations:
        return _translations

    for locale in SUPPORTED_LOCALES:
        path = _LOCALE_DIR / f"{locale}.json"
        if path.exists():
            with open(path, encoding="utf-8") as fh:
                _translations[locale] = json.load(fh)

    return _translations


def t(key: str, locale: str = DEFAULT_LOCALE, **kwargs: str) -> str:
    """Look up a translation by dot-notated *key*.

    Args:
        key: Dot-separated path into the translation dict (e.g.
            ``"home.title"``).
        locale: The locale code to look up (falls back to
            :data:`DEFAULT_LOCALE`).
        **kwargs: Placeholder values for ``{{name}}``-style interpolation.

    Returns:
        The translated string with placeholders replaced, or the raw
        *key* if no translation was found.
    """
    translations = get_translations()
    data = translations.get(locale, translations.get(DEFAULT_LOCALE, {}))

    value: Any = data
    for part in key.split("."):
        if isinstance(value, dict):
            value = value.get(part)
        else:
            return key

    if not isinstance(value, str):
        return key

    # Replace {{placeholder}} tokens.
    for placeholder, replacement in kwargs.items():
        value = value.replace("{{" + placeholder + "}}", replacement)

    return value
