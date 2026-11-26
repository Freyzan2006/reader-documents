import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import '../../application/documents_providers.dart';
import '../actions/document_commands.dart';
import 'document_card.dart';
import 'document_gesture_hint_banner.dart';

class PaginatedDocumentList extends ConsumerStatefulWidget {
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
  ConsumerState<PaginatedDocumentList> createState() =>
      _PaginatedDocumentListState();
}

class _PaginatedDocumentListState extends ConsumerState<PaginatedDocumentList> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _syncSelection();
  }

  void _syncSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(documentSelectionProvider.notifier).sync(widget.files);
      }
    });
  }

  @override
  void didUpdateWidget(covariant PaginatedDocumentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.files, widget.files)) _syncSelection();
  }

  void _startSelection(DocumentFile file) =>
      ref.read(documentSelectionProvider.notifier).start(file, widget.files);

  void _toggleSelection(DocumentFile file) =>
      ref.read(documentSelectionProvider.notifier).toggle(file);

  Future<bool> _confirmDismiss(
    DocumentFile file,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      HapticFeedback.mediumImpact();
      await DocumentCommands.toggleFavorite(context, ref, file);
      return false;
    }
    return widget.confirmDelete(file);
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(documentSelectionProvider);
    final selecting = selection.isNotEmpty;

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
        if (!selecting) const DocumentGestureHintBanner(),
        for (final file in pageFiles)
          AppDismissible(
            itemKey: ValueKey(file.path),
            direction: selecting
                ? DismissDirection.none
                : DismissDirection.horizontal,
            confirmDismiss: selecting
                ? null
                : (direction) => _confirmDismiss(file, direction),
            onDismissed: () => widget.onDelete(file),
            background: AppDismissibleAction(
              icon: AppIcons.star,
              color: AppColors.warning(context),
              foregroundColor: AppColors.warningForeground(context),
              alignment: Alignment.centerLeft,
            ),
            child: DocumentCard(
              file: file,
              onTap: () =>
                  selecting ? _toggleSelection(file) : widget.onOpen(file),
              onLongPress: () =>
                  selecting ? _toggleSelection(file) : _startSelection(file),
              selectionMode: selecting,
              selected: selection.contains(file.path),
            ),
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
