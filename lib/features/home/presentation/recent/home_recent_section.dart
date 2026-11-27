import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/navigation/app_nav_tab.dart';
import 'package:reader_documents/core/navigation/navigation_providers.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/features/documents/presentation/list/document_compact_card.dart';
import 'package:reader_documents/features/home/application/providers/home_recent_documents_provider.dart';
import 'package:reader_documents/features/home/presentation/home_shelf_skeleton.dart';
import 'package:reader_documents/features/home/presentation/home_section_error_banner.dart';
import 'package:reader_documents/features/home/presentation/home_shelf_section.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class HomeRecentSection extends ConsumerWidget {
  const HomeRecentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mostRecent = ref.watch(mostRecentDocumentProvider).value;
    final older = ref.watch(homeOlderDocumentsProvider);
    if (mostRecent != null && (older.value?.isEmpty ?? false)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return HomeShelfSection(
      title: l10n.homeRecentTitle,
      linkLabel: l10n.seeAll,
      onLink: () => ref.read(currentNavDestinationProvider.notifier).state =
          AppNavDestination.documents,
      child: older.when(
        data: (files) => files.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AppText(
                  l10n.homeRecentEmpty,
                  variant: AppTextVariant.caption,
                ),
              )
            : HomeDocumentShelf(
                children: [
                  for (final (index, file) in files.indexed)
                    AppEntrance(
                      index: index,
                      child: DocumentCompactCard(
                        file: file,
                        onTap: () => DocumentCommands.open(context, ref, file),
                      ),
                    ),
                ],
              ),
        loading: () => const HomeShelfSkeleton(),
        error: (error, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: HomeSectionErrorBanner(
            message: l10n.documentsLoadError,
            error: error,
          ),
        ),
      ),
    );
  }
}
