import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

/// Lets the user pick a theme by looking at it rather than reading its name —
/// a grid of miniature renderings of the app's own chrome.
class ThemeSettingsSection extends StatelessWidget {
  const ThemeSettingsSection({
    required this.themeMode,
    required this.onChanged,
    super.key,
  });

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onChanged;

  /// "System" gets a split preview, since it means *both* light and dark —
  /// the one thing a single pane couldn't convey.
  static List<Brightness> _previewBrightnesses(AppThemeMode mode) =>
      switch (mode) {
        AppThemeMode.system => const [Brightness.light, Brightness.dark],
        AppThemeMode.light => const [Brightness.light],
        AppThemeMode.dark => const [Brightness.dark],
      };

  static String _label(AppLocalizations l10n, AppThemeMode mode) =>
      switch (mode) {
        AppThemeMode.system => l10n.systemThemeShort,
        AppThemeMode.light => l10n.lightThemeShort,
        AppThemeMode.dark => l10n.darkThemeShort,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppSection(
      title: l10n.themeSectionTitle,
      icon: AppIcons.palette,
      child: AppGrid(
        columns: AppThemeMode.values.length,
        spacing: AppSpacing.sm,
        children: [
          for (final mode in AppThemeMode.values)
            AppSelectableCard(
              selected: mode == themeMode,
              onPressed: () => onChanged(mode),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.xs,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: AppThemePreview(
                      brightnesses: _previewBrightnesses(mode),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AppText(
                      _label(l10n, mode),
                      variant: AppTextVariant.caption,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
