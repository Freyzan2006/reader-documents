import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import '../actions/document_commands.dart';
import 'document_filter_bar.dart';
import 'document_list.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  static const _fabClearance = 56.0 + AppSpacing.lg;

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? _summary(AppLocalizations l10n, DocumentStats? stats) => stats == null
      ? null
      : '${l10n.menuDocumentsCount(stats.count)} · '
            '${DocumentFile.formatBytes(stats.totalBytes)}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(documentFilterProvider);
    final documents = ref.watch(filteredDocumentsProvider);
    final stats = ref.watch(documentStatsProvider).value;
    final scrolled = AppScrollScope.of(context);
    final layout =
        ref.watch(settingsProvider).value?.documentsLayout ??
        DocumentsLayout.list;
    final grid = layout == DocumentsLayout.grid;

    return Stack(
      children: [
        AppPullToRefresh(
          onRefresh: () => ref.read(documentsProvider.notifier).refresh(),
          indicatorOffset: AppHeader.topInset(context),
          child: AppScrollArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: AppHeader.topInset(context),
                bottom:
                    AppBottomNav.bottomInset(context) +
                    DocumentsScreen._fabClearance +
                    AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppLargeTitle(
                    title: l10n.documentsTitle,
                    summary: _summary(l10n, stats),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: AppSearchField(
                      controller: _searchController,
                      hint: l10n.documentsSearchHint,
                      clearLabel: l10n.clear,
                      trailing: AppIconButton(
                        icon: grid ? AppIcons.list : AppIcons.layoutGrid,
                        semanticsLabel: grid
                            ? l10n.viewAsList
                            : l10n.viewAsGrid,
                        color: context.tokens.palette.ink2,
                        onPressed: () => ref
                            .read(settingsProvider.notifier)
                            .setDocumentsLayout(
                              grid
                                  ? DocumentsLayout.list
                                  : DocumentsLayout.grid,
                            ),
                      ),
                      onChanged: (value) =>
                          ref.read(documentFilterProvider.notifier).state =
                              filter.withQuery(value),
                    ),
                  ),
                  const AppGap.md(),
                  DocumentFilterBar(
                    filter: filter,
                    onChanged: (next) =>
                        ref.read(documentFilterProvider.notifier).state = next,
                  ),
                  const AppGap.lg(),
                  DocumentList(
                    key: ValueKey(filter),
                    documents: documents,
                    emptyMessage: l10n.documentsEmpty,
                    layout: layout,
                    onOpen: (file) => DocumentCommands.open(context, ref, file),
                    confirmDelete: (file) =>
                        DocumentCommands.confirmDelete(context, file),
                    onDelete: (file) =>
                        ref.read(documentsProvider.notifier).delete(file.path),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppBottomNav.bottomInset(context) + AppSpacing.lg,
          child: AppFloatButton(
            icon: AppIcons.plus,
            label: l10n.homeQuickActionImport,
            semanticsLabel: l10n.importDocument,
            extended: !scrolled,
            onPressed: () => DocumentCommands.importDocument(ref),
          ),
        ),
      ],
    );
  }
}
