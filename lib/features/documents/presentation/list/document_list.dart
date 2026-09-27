import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';

import 'document_list_empty_state.dart';
import 'document_list_error_banner.dart';
import 'document_list_skeleton.dart';
import 'paginated_document_list.dart';

class DocumentList extends StatelessWidget {
  const DocumentList({
    required this.documents,
    required this.emptyMessage,
    required this.onOpen,
    required this.confirmDelete,
    required this.onDelete,
    this.skeletonCount = 6,
    super.key,
  });

  final AsyncValue<List<DocumentFile>> documents;
  final String emptyMessage;
  final ValueChanged<DocumentFile> onOpen;
  final Future<bool> Function(DocumentFile file) confirmDelete;
  final ValueChanged<DocumentFile> onDelete;
  final int skeletonCount;

  @override
  Widget build(BuildContext context) => documents.when(
    data: (files) => files.isEmpty
        ? DocumentListEmptyState(message: emptyMessage)
        : PaginatedDocumentList(
            files: files,
            onOpen: onOpen,
            confirmDelete: confirmDelete,
            onDelete: onDelete,
          ),
    loading: () => DocumentListSkeleton(count: skeletonCount),
    error: (error, _) => DocumentListErrorBanner(error: error),
  );
}
