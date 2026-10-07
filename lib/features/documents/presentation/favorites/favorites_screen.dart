import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import '../actions/document_commands.dart';
import '../list/document_list.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      header: AppHeader(
        title: l10n.homeFavoritesTitle,
        onBackTap: () => Navigator.of(context).maybePop(),
      ),
      child: AppPullToRefresh(
        onRefresh: () => ref.read(documentsProvider.notifier).refresh(),
        indicatorOffset: AppHeader.topInset(context),
        child: AppScrollArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppHeader.topInset(context) + AppSpacing.lg,
              AppSpacing.lg,
              MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
            ),
            child: DocumentList(
              documents: ref.watch(favoriteDocumentsProvider),
              emptyMessage: l10n.favoritesEmpty,
              onOpen: (file) => DocumentCommands.open(context, ref, file),
              confirmDelete: (file) =>
                  DocumentCommands.confirmDelete(context, file),
              onDelete: (file) =>
                  ref.read(documentsProvider.notifier).delete(file.path),
            ),
          ),
        ),
      ),
    );
  }
}
