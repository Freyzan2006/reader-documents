import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_language.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class LanguageSettingsCard extends StatelessWidget {
  const LanguageSettingsCard({
    required this.language,
    required this.onChanged,
    super.key,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          AppText(l10n.languageSectionTitle, variant: AppTextVariant.body),
          Wrap(
            spacing: 3,
            runSpacing: 3,
            children: [
              for (final option in AppLanguage.values)
                AppButton(
                  variant: option == language
                      ? AppButtonVariant.primary
                      : AppButtonVariant.outline,
                  size: AppButtonSize.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPressed: () => onChanged(option),
                  child: Text(
                    option == AppLanguage.system
                        ? l10n.systemLanguage
                        : option.nativeName,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
