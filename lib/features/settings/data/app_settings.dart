import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';
import 'package:reader_documents/features/settings/data/user_profile.dart';

enum AppThemeMode { system, light, dark }

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.language,
    required this.profile,
  });

  static const defaults = AppSettings(
    themeMode: AppThemeMode.system,
    language: AppLanguage.system,
    profile: UserProfile.empty,
  );

  final AppThemeMode themeMode;
  final AppLanguage language;
  final UserProfile profile;

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
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    profile: profile ?? this.profile,
  );
}
