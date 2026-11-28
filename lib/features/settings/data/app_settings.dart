import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/tokens/app_breakpoints.dart';
import 'package:reader_documents/core/ui_kit/theme/graphics_mode.dart';
import 'package:reader_documents/core/ui_kit/tokens/app_palette.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';

enum AppThemeMode { system, light, dark }

enum AppEffectsMode { system, quality, performance }

enum DocumentsLayout { auto, card, cardrow }

extension DocumentsLayoutX on DocumentsLayout {
  bool useCardRow(ScreenSize screenSize) => switch (this) {
    DocumentsLayout.auto => screenSize != ScreenSize.mobile,
    DocumentsLayout.cardrow => true,
    DocumentsLayout.card => false,
  };
}

enum DocumentPreviews { auto, show, hide }

extension DocumentPreviewsX on DocumentPreviews {
  bool enabled(GraphicsMode graphics) => switch (this) {
    DocumentPreviews.auto => graphics == GraphicsMode.quality,
    DocumentPreviews.show => true,
    DocumentPreviews.hide => false,
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
    this.documentPreviews = DocumentPreviews.auto,
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
  final DocumentPreviews documentPreviews;

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
    DocumentPreviews? documentPreviews,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    warmReadingFilter: warmReadingFilter ?? this.warmReadingFilter,
    effectsMode: effectsMode ?? this.effectsMode,
    documentsLayout: documentsLayout ?? this.documentsLayout,
    palette: palette ?? this.palette,
    documentPreviews: documentPreviews ?? this.documentPreviews,
  );
}
