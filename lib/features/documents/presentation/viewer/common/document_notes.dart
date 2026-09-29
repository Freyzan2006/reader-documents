import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/controllers/document_bookmarks_controller.dart';
import 'package:reader_documents/features/documents/application/controllers/document_highlights_controller.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../contract/document_viewer_controller.dart';
import 'document_bookmarks.dart';
import 'document_outline.dart';

abstract final class DocumentNotesSheet {
  static void show({
    required BuildContext context,
    required DocumentViewerController controller,
    required DocumentBookmarksController bookmarks,
    required DocumentHighlightsController highlights,
  }) => AppRotatedSheet.show(
    context: context,
    initialSize: 0.6,
    builder: (context, _, dismiss) => _DocumentNotesTabs(
      controller: controller,
      bookmarks: bookmarks,
      highlights: highlights,
      onDismiss: dismiss,
    ),
  );
}

class _DocumentNotesTabs extends StatelessWidget {
  const _DocumentNotesTabs({
    required this.controller,
    required this.bookmarks,
    required this.highlights,
    required this.onDismiss,
  });

  final DocumentViewerController controller;
  final DocumentBookmarksController bookmarks;
  final DocumentHighlightsController highlights;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTabs(
      expands: true,
      scrollable: true,
      tabs: [
        AppTab(
          label: l10n.pdfMenuOutline,
          child: DocumentOutlineView(
            controller: controller,
            onDismiss: onDismiss,
          ),
        ),
        AppTab(
          label: l10n.pdfMenuBookmarks,
          child: DocumentBookmarksView(
            bookmarks: bookmarks,
            viewerController: controller,
            onDismiss: onDismiss,
          ),
        ),
        AppTab(
          label: l10n.exportNotesHighlightsSection,
          child: DocumentHighlightsView(
            highlights: highlights,
            viewerController: controller,
            onDismiss: onDismiss,
          ),
        ),
      ],
    );
  }
}

class DocumentHighlightsView extends StatelessWidget {
  const DocumentHighlightsView({
    required this.highlights,
    required this.viewerController,
    required this.onDismiss,
    super.key,
  });

  final DocumentHighlightsController highlights;
  final DocumentViewerController viewerController;
  final VoidCallback onDismiss;

  void _goTo(DocumentHighlight highlight) {
    viewerController.goToPage(highlight.pageNumber);
    onDismiss();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: highlights,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context)!;
      final items = [...highlights.value]
        ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

      if (items.isEmpty) {
        return Center(child: AppText(l10n.highlightsEmpty));
      }

      return ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppList(
            items: [
              for (final highlight in items)
                AppListItem(
                  title: highlight.text,
                  subtitle: l10n.bookmarkPageLabel(highlight.pageNumber),
                  leading: AppIcons.highlighter,
                  trailing: AppIcons.trash2,
                  onTap: () => _goTo(highlight),
                  onTrailingTap: () => highlights.remove(highlight),
                ),
            ],
          ),
        ],
      );
    },
  );
}
