import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/navigation/app_nav_tab.dart';
import 'package:reader_documents/core/navigation/navigation_providers.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/documents_providers.dart';
import 'document_card.dart';
import 'document_commands.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recent = ref.watch(recentDocumentsProvider);

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
          children: [
            AppText(l10n.homeTitle, variant: AppTextVariant.title),
            const AppGap.lg(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.xs,
                  children: [
                    Icon(
                      AppIcons.history,
                      size: 18,
                      color: AppColors.of(context).mutedForeground,
                    ),
                    AppText(l10n.homeRecentTitle, variant: AppTextVariant.body),
                  ],
                ),
                AppButton(
                  variant: AppButtonVariant.ghost,
                  size: AppButtonSize.sm,
                  onPressed: () =>
                      ref.read(currentNavDestinationProvider.notifier).state =
                          AppNavDestination.documents,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.xs,
                    children: [
                      Text(l10n.homeSeeAllDocuments),
                      const Icon(AppIcons.arrowRight, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const AppGap.sm(),
            recent.when(
              data: (files) => files.isEmpty
                  ? AppEmptyState(
                      icon: AppIcons.fileText,
                      message: l10n.homeRecentEmpty,
                    )
                  : Column(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final file in files)
                          DocumentCard(
                            file: file,
                            onTap: () =>
                                DocumentCommands.open(context, ref, file),
                            confirmDelete: (file) =>
                                DocumentCommands.confirmDelete(context, file),
                            onDelete: (file) => ref
                                .read(documentsProvider.notifier)
                                .delete(file.path),
                          ),
                      ],
                    ),
              loading: () => Column(
                spacing: AppSpacing.sm,
                children: List.generate(3, (_) => const DocumentCardSkeleton()),
              ),
              error: (error, _) => AppAlert(
                title: Text(l10n.documentsLoadError),
                subtitle: Text('$error'),
                variant: AppAlertVariant.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
