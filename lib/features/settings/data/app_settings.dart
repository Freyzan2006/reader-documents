import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';

enum AppThemeMode { system, light, dark }

enum AppEffectsMode { system, quality, performance }

enum DocumentsLayout { list, grid }

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.language,
    required this.warmReadingFilter,
    required this.effectsMode,
    this.documentsLayout = DocumentsLayout.list,
  });

  static const defaults = AppSettings(
    themeMode: AppThemeMode.system,
    language: AppLanguage.system,
    warmReadingFilter: false,
    effectsMode: AppEffectsMode.system,
  );

  final AppThemeMode themeMode;
  final AppLanguage language;

  /// A warm, sepia-like color filter over document pages, independent of
  /// [themeMode] — for reading comfort in low light, not app chrome.
  final bool warmReadingFilter;

  final AppEffectsMode effectsMode;
  final DocumentsLayout documentsLayout;

  Brightness resolveBrightness(Brightness platformBrightness) =>
      switch (themeMode) {
        AppThemeMode.light => Brightness.light,
        AppThemeMode.dark => Brightness.dark,
        AppThemeMode.system => platformBrightness,
      };

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? warmReadingFilter,
    AppEffectsMode? effectsMode,
    DocumentsLayout? documentsLayout,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    warmReadingFilter: warmReadingFilter ?? this.warmReadingFilter,
    effectsMode: effectsMode ?? this.effectsMode,
    documentsLayout: documentsLayout ?? this.documentsLayout,
  );
}
