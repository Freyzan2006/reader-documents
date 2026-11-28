import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/tokens/app_breakpoints.dart';
import 'package:reader_documents/core/ui_kit/tokens/app_palette.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';

enum AppThemeMode { system, light, dark }

enum AppEffectsMode { system, quality, performance }

/// How document lists are laid out.
///
/// [DocumentsLayout.auto] follows the screen size: one card per row on
/// phones, several cards per row on tablets and desktops.
enum DocumentsLayout { auto, card, cardrow }

extension DocumentsLayoutX on DocumentsLayout {
  /// Whether documents are shown as a row of cards for the given [screenSize].
  bool useCardRow(ScreenSize screenSize) => switch (this) {
    DocumentsLayout.auto => screenSize != ScreenSize.mobile,
    DocumentsLayout.cardrow => true,
    DocumentsLayout.card => false,
  };
}

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.language,
    required this.warmReadingFilter,
    required this.effectsMode,
    this.documentsLayout = DocumentsLayout.auto,
    this.palette = AppPaletteFamily.monochrome,
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
  final AppPaletteFamily palette;

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
    AppPaletteFamily? palette,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    warmReadingFilter: warmReadingFilter ?? this.warmReadingFilter,
    effectsMode: effectsMode ?? this.effectsMode,
    documentsLayout: documentsLayout ?? this.documentsLayout,
    palette: palette ?? this.palette,
  );
}
