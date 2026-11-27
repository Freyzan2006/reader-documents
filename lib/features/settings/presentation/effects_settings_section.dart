import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class EffectsSettingsSection extends StatelessWidget {
  const EffectsSettingsSection({
    required this.effectsMode,
    required this.onChanged,
    super.key,
  });

  final AppEffectsMode effectsMode;
  final ValueChanged<AppEffectsMode> onChanged;

  static String _label(AppLocalizations l10n, AppEffectsMode mode) =>
      switch (mode) {
        AppEffectsMode.system => l10n.graphicsAuto,
        AppEffectsMode.quality => l10n.effectsQuality,
        AppEffectsMode.performance => l10n.graphicsPerformanceShort,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.tokens.palette;
    final resolved = context.tokens.graphics == GraphicsMode.quality
        ? l10n.effectsQuality
        : l10n.effectsPerformance;

    return AppListGroup(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            14,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.graphicsModeTitle,
                    style: AppTextStyles.body.copyWith(color: palette.ink),
                  ),
                  if (effectsMode == AppEffectsMode.system)
                    Text(
                      l10n.graphicsAutoNow(resolved),
                      style: AppTextStyles.caption.copyWith(
                        color: palette.ink3,
                      ),
                    ),
                ],
              ),
              AppSegmented<AppEffectsMode>(
                expand: true,
                value: effectsMode,
                onChanged: onChanged,
                segments: [
                  for (final mode in AppEffectsMode.values)
                    AppSegment(
                      value: mode,
                      label: _label(l10n, mode),
                      semanticsLabel: mode == AppEffectsMode.performance
                          ? l10n.effectsPerformance
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
