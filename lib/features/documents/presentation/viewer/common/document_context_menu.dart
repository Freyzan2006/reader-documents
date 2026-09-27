import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

sealed class DocumentContextMenuEntry {
  const DocumentContextMenuEntry({required this.label, required this.icon});

  final String label;
  final Widget icon;
}

class DocumentContextMenuAction extends DocumentContextMenuEntry {
  const DocumentContextMenuAction({
    required super.label,
    required super.icon,
    required this.onPressed,
  });

  final VoidCallback? onPressed;
}

class DocumentContextMenuGroup extends DocumentContextMenuEntry {
  const DocumentContextMenuGroup({
    required super.label,
    required super.icon,
    required this.children,
  });

  final List<DocumentContextMenuAction> children;
}

class DocumentContextMenu extends StatefulWidget {
  const DocumentContextMenu({required this.entries, super.key});

  final List<DocumentContextMenuEntry> entries;

  @override
  State<DocumentContextMenu> createState() => _DocumentContextMenuState();
}

class _DocumentContextMenuState extends State<DocumentContextMenu> {
  DocumentContextMenuGroup? _expandedGroup;

  Widget _iconButton({
    required String label,
    required Widget icon,
    required VoidCallback? onPressed,
  }) => AppTappable(
    onPressed: onPressed,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Semantics(label: label, child: icon),
    ),
  );

  Widget _buildEntry(BuildContext context, DocumentContextMenuEntry entry) =>
      switch (entry) {
        DocumentContextMenuAction() => _iconButton(
          label: entry.label,
          icon: entry.icon,
          onPressed: entry.onPressed,
        ),
        DocumentContextMenuGroup() => _iconButton(
          label: entry.label,
          icon: entry.icon,
          onPressed: () => setState(() => _expandedGroup = entry),
        ),
      };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final expanded = _expandedGroup;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.of(context).lg,
        border: AppBorders.all(context),
        boxShadow: [
          BoxShadow(
            color: colors.foreground.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs,
          children: expanded == null
              ? [
                  for (final entry in widget.entries)
                    _buildEntry(context, entry),
                ]
              : [
                  _iconButton(
                    label: AppLocalizations.of(context)!.goBack,
                    icon: Icon(AppIcons.arrowLeft, color: colors.foreground),
                    onPressed: () => setState(() => _expandedGroup = null),
                  ),
                  for (final action in expanded.children)
                    _buildEntry(context, action),
                ],
        ),
      ),
    );
  }
}
