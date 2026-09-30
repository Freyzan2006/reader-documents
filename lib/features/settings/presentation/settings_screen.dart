import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/settings_providers.dart';
import 'about_settings_card.dart';
import 'language_settings_card.dart';
import 'profile_settings_card.dart';
import 'theme_settings_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AppScrollArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppHeader.topInset(context) + AppSpacing.lg,
          AppSpacing.lg,
          AppBottomNav.bottomInset(context) + AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xl,
          children: [
            AppText(l10n.settingsTitle, variant: AppTextVariant.title),
            ref
                .watch(settingsProvider)
                .when(
                  data: (value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xl,
                    children: [
                      ProfileSettingsCard(
                        profile: value.profile,
                        onSave: (profile) => ref
                            .read(settingsProvider.notifier)
                            .updateProfile(profile),
                      ),
                      ThemeSettingsCard(
                        themeMode: value.themeMode,
                        onChanged: (mode) => ref
                            .read(settingsProvider.notifier)
                            .setThemeMode(mode),
                      ),
                      LanguageSettingsCard(
                        language: value.language,
                        onChanged: (language) => ref
                            .read(settingsProvider.notifier)
                            .setLanguage(language),
                      ),
                      const AboutSettingsCard(),
                    ],
                  ),
                  loading: () => const _SettingsSkeleton(),
                  error: (error, _) => _SettingsError(
                    onRetry: () => ref.invalidate(settingsProvider),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors the real cards' heights so the layout doesn't jump when the
/// settings finish loading.
class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.xl,
    children: const [
      AppCard(child: AppSkeletonText(lines: 3, lineHeight: 16)),
      AppCard(child: AppSkeletonText(lines: 3, lineHeight: 16)),
      AppCard(child: AppSkeletonText(lines: 3, lineHeight: 16)),
      AppCard(child: AppSkeletonText(lines: 2, lineHeight: 16)),
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
        // The underlying exception is deliberately not shown: it is either
        // noise to the reader or, for a corrupt settings file, a file path.
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