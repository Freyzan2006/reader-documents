import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' show FLucideIcons;
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class ThemeSettingsCard extends StatelessWidget {
  const ThemeSettingsCard({
    required this.themeMode,
    required this.onChanged,
    super.key,
  });

  static const _icons = {
    AppThemeMode.system: FLucideIcons.monitor,
    AppThemeMode.light: FLucideIcons.sun,
    AppThemeMode.dark: FLucideIcons.moon,
  };

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        AppText(
          AppLocalizations.of(context)!.themeSectionTitle,
          variant: AppTextVariant.body,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            for (final mode in AppThemeMode.values)
              AppButton(
                variant: mode == themeMode
                    ? AppButtonVariant.primary
                    : AppButtonVariant.outline,
                size: AppButtonSize.sm,
                mainAxisSize: MainAxisSize.min,
                onPressed: () => onChanged(mode),
                child: Icon(_icons[mode]),
              ),
          ],
        ),
      ],
    ),
  );
}
