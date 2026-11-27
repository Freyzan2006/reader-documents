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
                child: _ThemeCard(
                  label: _label(l10n, mode),
                  sub: mode == AppThemeMode.system
                      ? l10n.nowValue(resolved.toLowerCase())
                      : null,
                  brightnesses: _previewBrightnesses(mode),
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

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.label,
    required this.brightnesses,
    required this.selected,
    required this.onPressed,
    this.sub,
  });

  final String label;
  final String? sub;
  final List<Brightness> brightnesses;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final sub = this.sub;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: AppTappable(
        onPressed: onPressed,
        selected: selected,
        semanticsLabel: label,
        excludeChildSemantics: true,
        pressedOpacity: 0.85,
        child: AnimatedContainer(
          duration: tokens.motion.quick,
          padding: const EdgeInsets.fromLTRB(6, 6, 6, AppSpacing.sm),
          foregroundDecoration: BoxDecoration(
            borderRadius: AppRadii.md,
            border: Border.all(
              color: selected ? palette.ink : palette.rule,
              width: selected ? 2 : 1,
            ),
          ),
          decoration: BoxDecoration(
            color: palette.sheet,
            borderRadius: AppRadii.md,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.sm,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: AppThemePreview(brightnesses: brightnesses),
                  ),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? palette.ink : palette.ink2,
                    ),
                  ),
                  if (sub != null)
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: Text(
                        sub,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.meta.copyWith(
                          fontSize: 11,
                          height: 14 / 11,
                          color: palette.ink3,
                        ),
                      ),
                    ),
                ],
              ),
              if (selected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.sheet,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: const AppCheckMark(
                      checked: true,
                      round: true,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
