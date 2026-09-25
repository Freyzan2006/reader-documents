import 'package:flutter/widgets.dart';

enum AppLanguage {
  system,
  ru,
  en,
  uz;

  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.ru => const Locale('ru'),
    AppLanguage.en => const Locale('en'),
    AppLanguage.uz => const Locale('uz'),
  };

  String get nativeName => switch (this) {
    AppLanguage.system => '',
    AppLanguage.ru => 'Русский',
    AppLanguage.en => 'English',
    AppLanguage.uz => 'Oʻzbekcha',
  };
}
