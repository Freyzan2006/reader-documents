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

  static IconData _icon(AppEffectsMode mode) => switch (mode) {
    AppEffectsMode.system => AppIcons.monitor,
    AppEffectsMode.quality => AppIcons.sparkles,
    AppEffectsMode.performance => AppIcons.zap,
  };

  static String _label(AppLocalizations l10n, AppEffectsMode mode) =>
      switch (mode) {
        AppEffectsMode.system => l10n.effectsSystem,
        AppEffectsMode.quality => l10n.effectsQuality,
        AppEffectsMode.performance => l10n.effectsPerformance,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);

    return AppSection(
      title: l10n.effectsSectionTitle,
      icon: AppIcons.sparkles,
      hint: l10n.effectsSectionHint,
      child: AppGrid(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final mode in AppEffectsMode.values)
            AppSelectableCard(
              selected: mode == effectsMode,
              onPressed: () => onChanged(mode),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  Icon(_icon(mode), size: 20, color: colors.mutedForeground),
                  Expanded(
                    child: AppText(
                      _label(l10n, mode),
                      variant: AppTextVariant.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
