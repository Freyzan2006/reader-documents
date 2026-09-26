import 'package:flutter/widgets.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

abstract final class PdfOutlineSheet {
  static Future<void> show({
    required BuildContext context,
    required PdfViewerController controller,
    required List<PdfOutlineNode> outline,
  }) => AppSheet.show(
    context: context,
    initialSize: 0.6,
    builder: (context, scrollController) => PdfOutlineView(
      controller: controller,
      outline: outline,
      scrollController: scrollController,
    ),
  );
}

class PdfOutlineView extends StatelessWidget {
  const PdfOutlineView({
    required this.controller,
    required this.outline,
    required this.scrollController,
    super.key,
  });

  final PdfViewerController controller;
  final List<PdfOutlineNode> outline;
  final ScrollController scrollController;

  void _select(BuildContext context, PdfOutlineNode node) {
    final dest = node.dest;
    if (dest == null) return;
    controller.goToPage(pageNumber: dest.pageNumber);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
          _PdfOutlineTile(
            node: node,
            depth: 0,
            onSelect: (selected) => _select(context, selected),
          ),
      ],
    );
  }
}

class _PdfOutlineTile extends StatefulWidget {
  const _PdfOutlineTile({
    required this.node,
    required this.depth,
    required this.onSelect,
  });

  final PdfOutlineNode node;
  final int depth;
  final ValueChanged<PdfOutlineNode> onSelect;

  @override
  State<_PdfOutlineTile> createState() => _PdfOutlineTileState();
}

class _PdfOutlineTileState extends State<_PdfOutlineTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.children.isNotEmpty;
    final hasDest = widget.node.dest != null;

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
            _PdfOutlineTile(
              node: child,
              depth: widget.depth + 1,
              onSelect: widget.onSelect,
            ),
        if (widget.depth == 0) const AppDivider(),
      ],
    );
  }
}
