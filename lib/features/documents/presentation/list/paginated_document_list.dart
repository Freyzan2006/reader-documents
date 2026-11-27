import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import '../../application/documents_providers.dart';
import '../actions/document_commands.dart';
import 'document_card.dart';
import 'document_gesture_hint_banner.dart';

import 'package:reader_documents/features/settings/data/app_settings.dart';

class PaginatedDocumentList extends ConsumerStatefulWidget {
  const PaginatedDocumentList({
    required this.files,
    required this.onOpen,
    required this.confirmDelete,
    required this.onDelete,
    this.layout = DocumentsLayout.list,
    super.key,
  });

  static const pageSize = 10;

  final List<DocumentFile> files;
  final ValueChanged<DocumentFile> onOpen;
  final Future<bool> Function(DocumentFile file) confirmDelete;
  final ValueChanged<DocumentFile> onDelete;
  final DocumentsLayout layout;

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!selecting)
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: DocumentGestureHintBanner(),
          ),
        if (widget.layout == DocumentsLayout.grid)
          _DocumentGrid(
            files: pageFiles,
            builder: (file) => DocumentCard(
              file: file,
              tile: true,
              onTap: () =>
                  selecting ? _toggleSelection(file) : widget.onOpen(file),
              onLongPress: () =>
                  selecting ? _toggleSelection(file) : _startSelection(file),
              selectionMode: selecting,
              selected: selection.contains(file.path),
            ),
          )
        else
          for (final (index, file) in pageFiles.indexed) ...[
            if (index > 0)
              const AppDivider(indent: AppSpacing.lg + 42 + AppSpacing.md),
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
                color: context.tokens.palette.ink,
                foregroundColor: context.tokens.palette.onInk,
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
          ],
        if (pageCount > 1) ...[
          const AppGap.sm(),
          Center(
            child: AppPagination(
              pageCount: pageCount,
              initial: page,
              onChanged: (next) => setState(() => _page = next),
            ),
          ),
        ],
      ],
    );
  }
}

class _DocumentGrid extends StatelessWidget {
  const _DocumentGrid({required this.files, required this.builder});

  static const _minTileWidth = 140.0;

  final List<DocumentFile> files;
  final Widget Function(DocumentFile file) builder;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / _minTileWidth).floor().clamp(
          2,
          6,
        );
        return Column(
          spacing: AppSpacing.lg,
          children: [
            for (var start = 0; start < files.length; start += columns)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.md,
                children: [
                  for (var i = start; i < start + columns; i++)
                    Expanded(
                      child: i < files.length
                          ? builder(files[i])
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
          ],
        );
      },
    ),
  );
}
