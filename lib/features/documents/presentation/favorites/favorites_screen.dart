import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/navigation/app_nav_tab.dart';
import 'package:reader_documents/core/navigation/navigation_providers.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import '../actions/document_commands.dart';
import '../list/document_list.dart';
import '../list/document_selection_aware_header.dart';
import '../list/document_selection_header.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  DocumentFilter _filter = const DocumentFilter();
  late final DocumentSelectionNotifier _selection = ref.read(
    documentSelectionProvider.notifier,
  );

  @override
  void initState() {
    super.initState();
    _selection;
  }

  @override
  void dispose() {
    final selection = _selection;
    WidgetsBinding.instance.addPostFrameCallback((_) => selection.clear());
    super.dispose();
  }

  void _openDocuments() {
    ref.read(currentNavDestinationProvider.notifier).state =
        AppNavDestination.documents;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = ref.watch(favoriteDocumentsProvider);
    final stats = favorites.whenData(DocumentStats.from).value;
    final layout =
        ref.watch(settingsProvider).value?.documentsLayout ??
        DocumentsLayout.grid;
    final grid = layout == DocumentsLayout.grid;
    final hasFavorites = (stats?.count ?? 0) > 0;
    final visible = favorites.whenData(
      (files) => files.where((file) => _filter.matches(file.type)).toList(),
    );

    return AppScaffold(
      header: DocumentSelectionAwareHeader(
        normal: AppHeader(
          title: l10n.homeFavoritesTitle,
          collapsible: true,
          backLabel: l10n.goBack,
          onBackTap: () => Navigator.of(context).maybePop(),
          actions: [
            if (hasFavorites)
              AppIconButton(
                icon: grid ? AppIcons.list : AppIcons.layoutGrid,
                semanticsLabel: grid ? l10n.viewAsList : l10n.viewAsGrid,
                onPressed: () => ref
                    .read(settingsProvider.notifier)
                    .setDocumentsLayout(
                      grid ? DocumentsLayout.list : DocumentsLayout.grid,
                    ),
              ),
          ],
        ),
      ),
      footer: const DocumentSelectionAwareFooter(normal: SizedBox.shrink()),
      child: AppPullToRefresh(
        onRefresh: () => ref.read(documentsProvider.notifier).refresh(),
        indicatorOffset: AppHeader.topInset(context),
        child: AppScrollArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: AppHeader.topInset(context),
              bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppLargeTitle(
                  title: l10n.homeFavoritesTitle,
                  summary: hasFavorites ? _summary(l10n, stats!) : null,
                ),
                if (hasFavorites) ...[
                  _FavoritesFilterBar(
                    filter: _filter,
                    stats: stats!,
                    onChanged: (next) => setState(() => _filter = next),
                  ),
                  const AppGap.lg(),
                ],
                DocumentList(
                  key: ValueKey(_filter),
                  documents: visible,
                  emptyMessage: l10n.favoritesEmpty,
                  layout: layout,
                  empty: hasFavorites
                      ? null
                      : AppEmptyState(
                          icon: AppIcons.star,
                          message: l10n.favoritesEmpty,
                          description: l10n.favoritesEmptyHint,
                          action: AppButton(
                            variant: AppButtonVariant.outline,
                            mainAxisSize: MainAxisSize.min,
                            prefix: const Icon(AppIcons.fileText),
                            onPressed: _openDocuments,
                            child: Text(l10n.openDocuments),
                          ),
                        ),
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
    );
  }

  String _summary(AppLocalizations l10n, DocumentStats stats) =>
      '${l10n.menuDocumentsCount(stats.count)} · '
      '${DocumentFile.formatBytes(stats.totalBytes)}';
}

class _FavoritesFilterBar extends StatelessWidget {
  const _FavoritesFilterBar({
    required this.filter,
    required this.stats,
    required this.onChanged,
  });

  final DocumentFilter filter;
  final DocumentStats stats;
  final ValueChanged<DocumentFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final types = [
      for (final type in DocumentFilter.selectable)
        if ((stats.countByType[type] ?? 0) > 0) type,
    ];

    return AppChipBar(
      children: [
        AppChip(
          label: AppLocalizations.of(context)!.filterAll,
          count: stats.count,
          selected: filter.isEmpty,
          onPressed: () => onChanged(filter.clear()),
        ),
        for (final type in types)
          AppChip(
            label: type.label,
            count: stats.countByType[type],
            selected: filter.selects(type),
            onPressed: () => onChanged(filter.toggle(type)),
          ),
      ],
    );
  }
}
