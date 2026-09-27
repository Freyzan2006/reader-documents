import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'document_outline_node.dart';
import 'document_viewer_controller.dart';

abstract final class DocumentOutlineSheet {
  static Future<void> show({
    required BuildContext context,
    required DocumentViewerController controller,
  }) => AppSheet.show(
    context: context,
    initialSize: 0.6,
    builder: (context, scrollController) => DocumentOutlineView(
      controller: controller,
      scrollController: scrollController,
    ),
  );
}

class DocumentOutlineView extends StatelessWidget {
  const DocumentOutlineView({
    required this.controller,
    required this.scrollController,
    super.key,
  });

  final DocumentViewerController controller;
  final ScrollController scrollController;

  void _select(BuildContext context, DocumentOutlineNode node) {
    final pageNumber = node.pageNumber;
    if (pageNumber == null) return;
    controller.goToPage(pageNumber);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final outline = controller.outline;
    if (outline.isEmpty) {
      return Center(
        child: AppText(AppLocalizations.of(context)!.pdfOutlineEmpty),
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final node in outline)
          _DocumentOutlineTile(
            node: node,
            depth: 0,
            onSelect: (selected) => _select(context, selected),
          ),
      ],
    );
  }
}

class _DocumentOutlineTile extends StatefulWidget {
  const _DocumentOutlineTile({
    required this.node,
    required this.depth,
    required this.onSelect,
  });

  final DocumentOutlineNode node;
  final int depth;
  final ValueChanged<DocumentOutlineNode> onSelect;

  @override
  State<_DocumentOutlineTile> createState() => _DocumentOutlineTileState();
}

class _DocumentOutlineTileState extends State<_DocumentOutlineTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.children.isNotEmpty;
    final hasDest = widget.node.pageNumber != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.depth * AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: AppTappable(
                  onPressed: hasDest
                      ? () => widget.onSelect(widget.node)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: AppText(
                      widget.node.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              if (hasChildren)
                AppIconButton(
                  icon: _expanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                  onPressed: () => setState(() => _expanded = !_expanded),
                )
              else
                const SizedBox(width: 20),
            ],
          ),
        ),
        if (hasChildren && _expanded)
          for (final child in widget.node.children)
            _DocumentOutlineTile(
              node: child,
              depth: widget.depth + 1,
              onSelect: widget.onSelect,
            ),
        if (widget.depth == 0) const AppDivider(),
      ],
    );
  }
}
