import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';

import 'document_card.dart';

class PaginatedDocumentList extends StatefulWidget {
  const PaginatedDocumentList({
    required this.files,
    required this.onOpen,
    required this.confirmDelete,
    required this.onDelete,
    super.key,
  });

  static const pageSize = 10;

  final List<DocumentFile> files;
  final ValueChanged<DocumentFile> onOpen;
  final Future<bool> Function(DocumentFile file) confirmDelete;
  final ValueChanged<DocumentFile> onDelete;

  @override
  State<PaginatedDocumentList> createState() => _PaginatedDocumentListState();
}

class _PaginatedDocumentListState extends State<PaginatedDocumentList> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final pageCount = (widget.files.length / PaginatedDocumentList.pageSize)
        .ceil();
    final page = _page.clamp(0, pageCount - 1);
    final pageFiles = widget.files
        .skip(page * PaginatedDocumentList.pageSize)
        .take(PaginatedDocumentList.pageSize)
        .toList();

    return Column(
      spacing: AppSpacing.sm,
      children: [
        for (final file in pageFiles)
          AppDismissible(
            itemKey: ValueKey(file.path),
            confirmDismiss: () => widget.confirmDelete(file),
            onDismissed: () => widget.onDelete(file),
            child: DocumentCard(file: file, onTap: () => widget.onOpen(file)),
          ),
        if (pageCount > 1) ...[
          const AppGap.sm(),
          AppPagination(
            pageCount: pageCount,
            initial: page,
            onChanged: (next) => setState(() => _page = next),
          ),
        ],
      ],
    );
  }
}
