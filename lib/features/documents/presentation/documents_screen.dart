import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/documents_providers.dart';
import 'document_card.dart';
import 'document_commands.dart';
import 'document_filter_bar.dart';
import 'paginated_document_list.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _headerKey = GlobalKey();
  final _searchController = TextEditingController();
  double _indicatorOffset = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _measureIndicatorOffset() {
    final headerBox =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final screenBox = context.findRenderObject() as RenderBox?;
    if (headerBox == null || screenBox == null) return;

    final offset = headerBox
        .localToGlobal(Offset(0, headerBox.size.height), ancestor: screenBox)
        .dy;
    if ((offset - _indicatorOffset).abs() > 0.5) {
      setState(() => _indicatorOffset = offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(documentFilterProvider);
    final documents = ref.watch(filteredDocumentsProvider);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => mounted ? _measureIndicatorOffset() : null,
    );

    return Stack(
      children: [
        AppPullToRefresh(
          onRefresh: () => ref.read(documentsProvider.notifier).refresh(),
          indicatorOffset: _indicatorOffset,
          child: AppScrollArea(
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
                  Column(
                    key: _headerKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.documentsTitle,
                        variant: AppTextVariant.title,
                      ),
                      const AppGap.sm(),
                      AppInput(
                        controller: _searchController,
                        hint: l10n.documentsSearchHint,
                        onChanged: (value) =>
                            ref.read(documentFilterProvider.notifier).state =
                                filter.withQuery(value),
                      ),
                      const AppGap.sm(),
                      DocumentFilterBar(
                        filter: filter,
                        onChanged: (next) =>
                            ref.read(documentFilterProvider.notifier).state =
                                next,
                      ),
                    ],
                  ),
                  const AppGap.lg(),
                  documents.when(
                    data: (files) => files.isEmpty
                        ? AppEmptyState(
                            icon: AppIcons.fileText,
                            message: l10n.documentsEmpty,
                          )
                        : PaginatedDocumentList(
                            key: ValueKey(filter),
                            files: files,
                            onOpen: (file) =>
                                DocumentCommands.open(context, ref, file),
                            confirmDelete: (file) =>
                                DocumentCommands.confirmDelete(context, file),
                            onDelete: (file) => ref
                                .read(documentsProvider.notifier)
                                .delete(file.path),
                          ),
                    loading: () => Column(
                      spacing: AppSpacing.sm,
                      children: List.generate(
                        6,
                        (_) => const DocumentCardSkeleton(),
                      ),
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
          ),
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppBottomNav.bottomInset(context) + AppSpacing.lg,
          child: AppFloatButton(
            icon: AppIcons.plus,
            onPressed: () => DocumentCommands.importDocument(ref),
          ),
        ),
      ],
    );
  }
}
