import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

/// Lets the user pick a theme by looking at it rather than reading its name —
/// a grid of miniature renderings of the app's own chrome.
class ThemeSettingsCard extends StatelessWidget {
  const ThemeSettingsCard({
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          AppText(l10n.themeSectionTitle, variant: AppTextVariant.subtitle),
          // One card per row on a phone, where a three-across preview would be
          // too small to read; three across on a desktop, as VS Code does.
          AppGrid(
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
                        aspectRatio: 1.7,
                        child: AppThemePreview(
                          brightnesses: _previewBrightnesses(mode),
                        ),
                      ),
                      AppText(
                        _label(l10n, mode),
                        variant: AppTextVariant.caption,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}