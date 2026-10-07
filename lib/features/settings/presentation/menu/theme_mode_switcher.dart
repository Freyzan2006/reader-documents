import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';

class ThemeModeSwitcher extends ConsumerWidget {
  const ThemeModeSwitcher({super.key});

  static IconData _icon(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => AppIcons.monitor,
    AppThemeMode.light => AppIcons.sun,
    AppThemeMode.dark => AppIcons.moon,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(settingsProvider).value?.themeMode;
    final colors = AppColors.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        for (final mode in AppThemeMode.values)
          AppIconButton(
            icon: _icon(mode),
            color: mode == current
                ? AppColors.accent(context)
                : colors.mutedForeground,
            onPressed: () =>
                ref.read(settingsProvider.notifier).setThemeMode(mode),
          ),
      ],
    );
  }
}
