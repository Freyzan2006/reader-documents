import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class ThemeSettingsSection extends StatelessWidget {
  const ThemeSettingsSection({
    required this.themeMode,
    required this.onChanged,
    super.key,
  });

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onChanged;

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
    final resolved = context.tokens.brightness == Brightness.dark
        ? l10n.darkThemeShort
        : l10n.lightThemeShort;

    return Semantics(
      container: true,
      label: l10n.themeSectionTitle,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            for (final mode in AppThemeMode.values)
              Expanded(
                child: AppPreviewChoiceCard(
                  label: _label(l10n, mode),
                  sub: mode == AppThemeMode.system
                      ? l10n.nowValue(resolved.toLowerCase())
                      : null,
                  preview: AppThemePreview(
                    brightnesses: _previewBrightnesses(mode),
                  ),
                  selected: mode == themeMode,
                  onPressed: () => onChanged(mode),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
