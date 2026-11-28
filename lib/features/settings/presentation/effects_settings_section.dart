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

  static List<GraphicsMode> _previewModes(AppEffectsMode mode) =>
      switch (mode) {
        // Quality takes the lower half, where its motion trail is drawn.
        AppEffectsMode.system => const [
          GraphicsMode.performance,
          GraphicsMode.quality,
        ],
        AppEffectsMode.quality => const [GraphicsMode.quality],
        AppEffectsMode.performance => const [GraphicsMode.performance],
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolved = context.tokens.graphics == GraphicsMode.quality
        ? l10n.effectsQuality
        : l10n.graphicsPerformanceShort;

    return Semantics(
      container: true,
      label: l10n.graphicsModeTitle,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            for (final mode in AppEffectsMode.values)
              Expanded(
                child: AppPreviewChoiceCard(
                  label: _label(l10n, mode),
                  semanticsLabel: mode == AppEffectsMode.performance
                      ? l10n.effectsPerformance
                      : null,
                  sub: mode == AppEffectsMode.system
                      ? l10n.nowValue(resolved.toLowerCase())
                      : null,
                  preview: AppEffectsPreview(modes: _previewModes(mode)),
                  selected: mode == effectsMode,
                  onPressed: () => onChanged(mode),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
