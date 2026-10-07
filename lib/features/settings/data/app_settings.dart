import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';
import 'package:reader_documents/features/settings/data/user_profile.dart';

enum AppThemeMode { system, light, dark }

enum AppEffectsMode { system, quality, performance }

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.language,
    required this.profile,
    required this.warmReadingFilter,
    required this.effectsMode,
  });

  static const defaults = AppSettings(
    themeMode: AppThemeMode.system,
    language: AppLanguage.system,
    profile: UserProfile.empty,
    warmReadingFilter: false,
    effectsMode: AppEffectsMode.system,
  );

  final AppThemeMode themeMode;
  final AppLanguage language;
  final UserProfile profile;

  /// A warm, sepia-like color filter over document pages, independent of
  /// [themeMode] — for reading comfort in low light, not app chrome.
  final bool warmReadingFilter;

  final AppEffectsMode effectsMode;

  bool resolveBlur({required bool platformReducesMotion}) =>
      switch (effectsMode) {
        AppEffectsMode.quality => true,
        AppEffectsMode.performance => false,
        AppEffectsMode.system => !platformReducesMotion,
      };

  Brightness resolveBrightness(Brightness platformBrightness) =>
      switch (themeMode) {
        AppThemeMode.light => Brightness.light,
        AppThemeMode.dark => Brightness.dark,
        AppThemeMode.system => platformBrightness,
      };

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    UserProfile? profile,
    bool? warmReadingFilter,
    AppEffectsMode? effectsMode,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    profile: profile ?? this.profile,
    warmReadingFilter: warmReadingFilter ?? this.warmReadingFilter,
    effectsMode: effectsMode ?? this.effectsMode,
  );
}
