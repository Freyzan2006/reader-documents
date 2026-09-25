import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/documents_providers.dart';
import 'document_card.dart';
import 'document_filter_bar.dart';
import 'paginated_document_list.dart';
import 'pdf_viewer_screen.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  void _openDocument(BuildContext context, DocumentFile file) {
    if (file.type == DocumentType.pdf) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PdfViewerScreen(file: file)),
      );
      return;
    }

    AppToast.show(
      context: context,
      title: Text(AppLocalizations.of(context)!.viewerComingSoon),
      description: Text(file.name),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, DocumentFile file) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: Text(l10n.deleteDocumentTitle),
      body: Text(l10n.deleteDocumentBody(file.name)),
      actions: [
        AppButton(
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        AppButton(
          variant: AppButtonVariant.destructive,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(documentFilterProvider);
    final documents = ref.watch(filteredDocumentsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppHeader.topInset(context) + AppSpacing.lg,
        AppSpacing.lg,
        AppBottomNav.bottomInset(context) + AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(l10n.documentsTitle, variant: AppTextVariant.title),
          const AppGap.sm(),
          DocumentFilterBar(
            filter: filter,
            onChanged: (next) =>
                ref.read(documentFilterProvider.notifier).state = next,
          ),
          const AppGap.lg(),
          Expanded(
            child: AppPullToRefresh(
              onRefresh: () => ref.read(documentsProvider.notifier).refresh(),
              child: AppScrollArea(
                child: documents.when(
                  data: (files) => files.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xl,
                          ),
                          child: AppCenter(
                            child: AppText(
                              l10n.documentsEmpty,
                              variant: AppTextVariant.caption,
                            ),
                          ),
                        )
                      : PaginatedDocumentList(
                          key: ValueKey(filter),
                          files: files,
                          onOpen: (file) => _openDocument(context, file),
                          confirmDelete: (file) =>
                              _confirmDelete(context, file),
                          onDelete: (file) => ref
                              .read(documentsProvider.notifier)
                              .delete(file.path),
                        ),
                  loading: () => const Column(
                    spacing: AppSpacing.sm,
                    children: [
                      DocumentCardSkeleton(),
                      DocumentCardSkeleton(),
                      DocumentCardSkeleton(),
                    ],
                  ),
                  error: (error, _) => AppAlert(
                    title: Text(l10n.documentsLoadError),
                    subtitle: Text('$error'),
                    variant: AppAlertVariant.destructive,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
