import 'package:flutter/widgets.dart';

abstract final class AppLocaleResolver {
  static const fallback = Locale('ru');

  static Locale resolve(
    Locale? deviceLocale,
    Iterable<Locale> supportedLocales,
  ) {
    if (deviceLocale == null) return fallback;
    for (final locale in supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode) return locale;
    }
    return fallback;
  }
}
