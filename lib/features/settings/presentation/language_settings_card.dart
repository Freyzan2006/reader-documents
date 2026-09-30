import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

/// Language picker built from the same selectable cards as the theme picker,
/// so the two single-choice groups on this page read as one family.
class LanguageSettingsCard extends StatelessWidget {
  const LanguageSettingsCard({
    required this.language,
    required this.onChanged,
    super.key,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  String _label(AppLocalizations l10n, AppLanguage option) =>
      option == AppLanguage.system ? l10n.systemLanguage : option.nativeName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          AppText(l10n.languageSectionTitle, variant: AppTextVariant.subtitle),
          AppGrid(
            children: [
              for (final option in AppLanguage.values)
                _LanguageOption(
                  label: _label(l10n, option),
                  // "System" has no language code, so it gets an icon instead.
                  icon: option.code.isEmpty ? AppIcons.languages : null,
                  code: option.code,
                  selected: option == language,
                  onPressed: () => onChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.code,
    required this.selected,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final String? code;
  final IconData? icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AppSelectableCard(
      selected: selected,
      onPressed: onPressed,
      child: Column(
        spacing: AppSpacing.xs,
        children: [
          if (icon != null)
            Icon(icon, size: 20, color: colors.mutedForeground)
          else
            AppText(
              code!,
              variant: AppTextVariant.label,
              color: colors.mutedForeground,
            ),
          AppText(
            label,
            variant: AppTextVariant.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}