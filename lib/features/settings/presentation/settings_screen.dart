import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/cache_commands.dart';
import '../application/hint_commands.dart';
import '../application/settings_providers.dart';
import '../data/app_settings.dart';
import 'about_screen.dart';
import 'appearance_screen.dart';
import 'language_picker.dart';
import 'palette_settings_section.dart';
import 'theme_mode_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AppScrollArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: AppHeader.topInset(context),
          bottom: AppBottomNav.bottomInset(context) + AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppLargeTitle(title: l10n.settingsTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ref
                  .watch(settingsProvider)
                  .when(
                    data: (settings) => _SettingsGroups(settings: settings),
                    loading: () => const _SettingsSkeleton(),
                    error: (error, _) => _SettingsError(
                      onRetry: () => ref.invalidate(settingsProvider),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroups extends ConsumerWidget {
  const _SettingsGroups({required this.settings});

  final AppSettings settings;

  Future<void> _pickThemeMode(BuildContext context, WidgetRef ref) async {
    final mode = await ThemeModePicker.show(
      context,
      selected: settings.themeMode,
    );
    if (mode != null) {
      await ref.read(settingsProvider.notifier).setThemeMode(mode);
    }
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final language = await LanguagePicker.show(
      context,
      selected: settings.language,
    );
    if (language != null) {
      await ref.read(settingsProvider.notifier).setLanguage(language);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.xl,
      children: [
        AppListGroup(
          label: l10n.generalSectionTitle,
          children: [
            AppListRow(
              title: l10n.languageSectionTitle,
              leading: AppIcons.languages,
              value: LanguagePicker(l10n).label(settings.language),
              chevron: true,
              onTap: () => _pickLanguage(context, ref),
            ),
          ],
        ),
        AppListGroup(
          label: l10n.appearanceTitle,
          children: [
            AppListRow(
              title: l10n.themeTitle,
              leading: AppIcons.palette,
              value: PaletteSettingsSection.label(l10n, settings.palette),
              chevron: true,
              onTap: () => Navigator.of(context).push(
                AppPageRoute<void>(builder: (_) => const AppearanceScreen()),
              ),
            ),
            AppListRow(
              title: l10n.darkModeTitle,
              subtitle: ThemeModePicker(l10n).label(settings.themeMode),
              leading: AppIcons.moon,
              chevron: true,
              onTap: () => _pickThemeMode(context, ref),
            ),
            AppListRow(
              title: l10n.warmFilterTitle,
              subtitle: l10n.warmFilterHint,
              leading: AppIcons.lamp,
              onTap: notifier.toggleWarmReadingFilter,
              trailing: AppSwitch(
                value: settings.warmReadingFilter,
                onChanged: (_) => notifier.toggleWarmReadingFilter(),
              ),
            ),
          ],
        ),
        AppListGroup(
          label: l10n.accessibilitySectionTitle,
          children: [
            AppListRow(
              title: l10n.clearCacheTitle,
              subtitle: [
                l10n.clearCacheHint,
                ?ref
                    .watch(cacheSizeProvider)
                    .whenData(DocumentFile.formatBytes)
                    .value,
              ].join(' · '),
              leading: AppIcons.trash2,
              onTap: () => CacheCommands.clear(context, ref),
              trailing: _RowAction(
                label: l10n.clearCacheAction,
                onPressed: () => CacheCommands.clear(context, ref),
              ),
            ),
            AppListRow(
              title: l10n.resetHintsTitle,
              subtitle: l10n.resetHintsHint,
              leading: AppIcons.rotateCw,
              onTap: () => HintCommands.resetAll(context, ref),
              trailing: _RowAction(
                label: l10n.resetHintsAction,
                onPressed: () => HintCommands.resetAll(context, ref),
              ),
            ),
          ],
        ),
        AppListGroup(
          children: [
            AppListRow(
              title: l10n.aboutSectionTitle,
              leading: AppIcons.info,
              value: AboutScreen.version(),
              chevron: true,
              onTap: () => Navigator.of(
                context,
              ).push(AppPageRoute<void>(builder: (_) => const AboutScreen())),
            ),
          ],
        ),
      ],
    );
  }
}

class _RowAction extends StatelessWidget {
  const _RowAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppButton(
    variant: AppButtonVariant.secondary,
    size: AppButtonSize.sm,
    mainAxisSize: MainAxisSize.min,
    onPressed: onPressed,
    child: Text(label),
  );
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.xl,
    children: const [
      AppSkeletonText(lines: 3, lineHeight: 16),
      AppSkeletonText(lines: 3, lineHeight: 16),
      AppSkeletonText(lines: 3, lineHeight: 16),
      AppSkeletonText(lines: 3, lineHeight: 16),
      AppSkeletonText(lines: 2, lineHeight: 16),
    ],
  );
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        AppAlert(
          title: Text(l10n.settingsLoadError),
          variant: AppAlertVariant.destructive,
        ),
        AppButton(
          mainAxisSize: MainAxisSize.min,
          onPressed: onRetry,
          child: Text(l10n.retry),
        ),
      ],
    );
  }
}
