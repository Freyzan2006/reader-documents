import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

sealed class PdfContextMenuEntry {
  const PdfContextMenuEntry({required this.label, required this.icon});

  final String label;
  final Widget icon;
}

class PdfContextMenuAction extends PdfContextMenuEntry {
  const PdfContextMenuAction({
    required super.label,
    required super.icon,
    required this.onPressed,
  });

  final VoidCallback? onPressed;
}

class PdfContextMenuGroup extends PdfContextMenuEntry {
  const PdfContextMenuGroup({
    required super.label,
    required super.icon,
    required this.children,
  });

  final List<PdfContextMenuAction> children;
}

class PdfContextMenu extends StatefulWidget {
  const PdfContextMenu({required this.entries, super.key});

  final List<PdfContextMenuEntry> entries;

  @override
  State<PdfContextMenu> createState() => _PdfContextMenuState();
}

class _PdfContextMenuState extends State<PdfContextMenu> {
  PdfContextMenuGroup? _expandedGroup;

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

  Widget _buildEntry(BuildContext context, PdfContextMenuEntry entry) =>
      switch (entry) {
        PdfContextMenuAction() => _iconButton(
          label: entry.label,
          icon: entry.icon,
          onPressed: entry.onPressed,
        ),
        PdfContextMenuGroup() => _iconButton(
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
