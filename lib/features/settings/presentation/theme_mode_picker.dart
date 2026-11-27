import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class ThemeModePicker {
  const ThemeModePicker(this._l10n);

  static const _order = [
    AppThemeMode.system,
    AppThemeMode.light,
    AppThemeMode.dark,
  ];

  final AppLocalizations _l10n;

  static Future<AppThemeMode?> show(
    BuildContext context, {
    required AppThemeMode selected,
  }) {
    final picker = ThemeModePicker(AppLocalizations.of(context)!);
    return AppChoiceSheet.show<AppThemeMode>(
      context: context,
      title: picker._l10n.themePickerTitle,
      selected: selected,
      choices: [
        for (final mode in _order)
          AppChoice(value: mode, title: picker.label(mode)),
      ],
    );
  }

  String label(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => _l10n.systemThemeShort,
    AppThemeMode.light => _l10n.lightThemeShort,
    AppThemeMode.dark => _l10n.darkThemeShort,
  };
}
