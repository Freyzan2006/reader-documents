import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

abstract final class ThemeCommands {
  /// Mirrors the order of the theme cards on the Settings page, so the same
  /// option isn't in a different place depending on how you got there.
  static List<AppCommandItem> items(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return [
      AppCommandItem(
        label: l10n.systemTheme,
        icon: AppIcons.monitor,
        onSelect: () => ref
            .read(settingsProvider.notifier)
            .setThemeMode(AppThemeMode.system),
      ),
      AppCommandItem(
        label: l10n.lightTheme,
        icon: AppIcons.sun,
        onSelect: () => ref
            .read(settingsProvider.notifier)
            .setThemeMode(AppThemeMode.light),
      ),
      AppCommandItem(
        label: l10n.darkTheme,
        icon: AppIcons.moon,
        onSelect: () =>
            ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark),
      ),
    ];
  }
}