import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/user_profile.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class ProfileMenuHeader extends ConsumerWidget {
  const ProfileMenuHeader({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile =
        ref.watch(settingsProvider).value?.profile ?? UserProfile.empty;
    final count = ref.watch(documentStatsProvider).value?.count;
    final name = profile.name.trim();

    return AppTappable(
      onPressed: onTap,
      child: Row(
        spacing: AppSpacing.md,
        children: [
          AppAvatar(
            initials: profile.initialsOrNull,
            fallbackIcon: AppIcons.lamp,
            size: 48,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                AppText(
                  name.isEmpty ? l10n.homeWelcome : name,
                  variant: AppTextVariant.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (count != null)
                  AppText(
                    l10n.menuDocumentsCount(count),
                    variant: AppTextVariant.caption,
                  ),
              ],
            ),
          ),
          Icon(
            AppIcons.settings,
            size: 18,
            color: AppColors.of(context).mutedForeground,
          ),
        ],
      ),
    );
  }
}
