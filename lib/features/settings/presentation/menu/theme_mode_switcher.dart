import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class ThemeModeSwitcher extends ConsumerWidget {
  const ThemeModeSwitcher({super.key});

  static const _order = [
    AppThemeMode.light,
    AppThemeMode.dark,
    AppThemeMode.system,
  ];

  static IconData _icon(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => AppIcons.monitor,
    AppThemeMode.light => AppIcons.sun,
    AppThemeMode.dark => AppIcons.moon,
  };

  static String _label(AppLocalizations l10n, AppThemeMode mode) =>
      switch (mode) {
        AppThemeMode.system => l10n.systemThemeShort,
        AppThemeMode.light => l10n.lightThemeShort,
        AppThemeMode.dark => l10n.darkThemeShort,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current =
        ref.watch(settingsProvider).value?.themeMode ??
        AppSettings.defaults.themeMode;

    return AppSegmented<AppThemeMode>(
      value: current,
      onChanged: ref.read(settingsProvider.notifier).setThemeMode,
      segments: [
        for (final mode in _order)
          AppSegment(
            value: mode,
            icon: _icon(mode),
            semanticsLabel: _label(l10n, mode),
          ),
      ],
    );
  }
}
