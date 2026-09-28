import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/controllers/document_bookmarks_controller.dart';
import 'package:reader_documents/features/documents/data/models/document_bookmark.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../contract/document_viewer_controller.dart';

abstract final class DocumentBookmarksSheet {
  static Future<void> show({
    required BuildContext context,
    required DocumentBookmarksController bookmarks,
    required DocumentViewerController viewerController,
  }) => AppSheet.show(
    context: context,
    initialSize: 0.5,
    builder: (context, scrollController) => DocumentBookmarksView(
      bookmarks: bookmarks,
      viewerController: viewerController,
      scrollController: scrollController,
    ),
  );
}

class DocumentBookmarksView extends StatelessWidget {
  const DocumentBookmarksView({
    required this.bookmarks,
    required this.viewerController,
    required this.scrollController,
    super.key,
  });

  final DocumentBookmarksController bookmarks;
  final DocumentViewerController viewerController;
  final ScrollController scrollController;

  void _goTo(BuildContext context, DocumentBookmark bookmark) {
    viewerController.goToPage(bookmark.pageNumber);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: bookmarks,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context)!;
      final items = bookmarks.value;

      if (items.isEmpty) {
        return Center(child: AppText(l10n.bookmarksEmpty));
      }

      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppList(
            items: [
              for (final bookmark in items)
                AppListItem(
                  title: bookmark.note.isEmpty
                      ? l10n.bookmarkPageLabel(bookmark.pageNumber)
                      : bookmark.note,
                  subtitle: bookmark.note.isEmpty
                      ? null
                      : l10n.bookmarkPageLabel(bookmark.pageNumber),
                  leading: AppIcons.bookmark,
                  trailing: AppIcons.trash2,
                  onTap: () => _goTo(context, bookmark),
                  onTrailingTap: () => bookmarks.remove(bookmark.id),
                ),
            ],
          ),
        ],
      );
    },
  );
}
