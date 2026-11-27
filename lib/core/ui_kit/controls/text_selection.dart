import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppTextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  static const _handleSize = 22.0;

  @override
  Size getHandleSize(double textLineHeight) =>
      const Size(_handleSize, _handleSize);

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      switch (type) {
        TextSelectionHandleType.left => const Offset(_handleSize, 0),
        TextSelectionHandleType.right => Offset.zero,
        TextSelectionHandleType.collapsed => const Offset(_handleSize / 2, -4),
      };

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) => SizedBox.square(
    dimension: _handleSize,
    child: CustomPaint(
      painter: _HandlePainter(color: context.tokens.palette.ink, type: type),
    ),
  );
}

class _HandlePainter extends CustomPainter {
  const _HandlePainter({required this.color, required this.type});

  final Color color;
  final TextSelectionHandleType type;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final radius = size.width / 2;
    final circle = Rect.fromCircle(
      center: Offset(radius, radius),
      radius: radius,
    );
    final corner = switch (type) {
      TextSelectionHandleType.left => Rect.fromLTWH(radius, 0, radius, radius),
      TextSelectionHandleType.right => Rect.fromLTWH(0, 0, radius, radius),
      TextSelectionHandleType.collapsed => null,
    };
    if (corner == null) {
      canvas
        ..save()
        ..translate(radius, radius)
        ..rotate(math.pi / 4)
        ..drawRect(
          Rect.fromCenter(
            center: Offset(-radius * 0.5, -radius * 0.5),
            width: radius,
            height: radius,
          ),
          paint,
        )
        ..restore();
    } else {
      canvas.drawRect(corner, paint);
    }
    canvas.drawOval(circle, paint);
  }

  @override
  bool shouldRepaint(_HandlePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.type != type;
}

class AppTextContextMenu extends StatelessWidget {
  const AppTextContextMenu({
    required this.anchors,
    required this.items,
    super.key,
  });

  static Widget builder(BuildContext context, EditableTextState state) =>
      AppTextContextMenu(
        anchors: state.contextMenuAnchors,
        items: state.contextMenuButtonItems,
      );

  static const _gap = 8.0;

  final TextSelectionToolbarAnchors anchors;
  final List<ContextMenuButtonItem> items;

  static String _label(WidgetsLocalizations l10n, ContextMenuButtonItem item) =>
      item.label ??
      switch (item.type) {
        ContextMenuButtonType.cut => l10n.cutButtonLabel,
        ContextMenuButtonType.copy => l10n.copyButtonLabel,
        ContextMenuButtonType.paste => l10n.pasteButtonLabel,
        ContextMenuButtonType.selectAll => l10n.selectAllButtonLabel,
        ContextMenuButtonType.lookUp => l10n.lookUpButtonLabel,
        ContextMenuButtonType.searchWeb => l10n.searchWebButtonLabel,
        ContextMenuButtonType.share => l10n.shareButtonLabel,
        ContextMenuButtonType.delete ||
        ContextMenuButtonType.liveTextInput ||
        ContextMenuButtonType.custom => '',
      };

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final item in items)
        if (_label(WidgetsLocalizations.of(context), item).isNotEmpty) item,
    ];
    if (visible.isEmpty) return const SizedBox.shrink();

    final tokens = context.tokens;
    final palette = tokens.palette;
    final l10n = WidgetsLocalizations.of(context);
    final padding = MediaQuery.paddingOf(context);
    final above = anchors.primaryAnchor;
    final below = anchors.secondaryAnchor ?? anchors.primaryAnchor;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm,
        padding.top + AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: CustomSingleChildLayout(
        delegate: TextSelectionToolbarLayoutDelegate(
          anchorAbove:
              above - Offset(AppSpacing.sm, padding.top + AppSpacing.sm + _gap),
          anchorBelow:
              below - Offset(AppSpacing.sm, padding.top + AppSpacing.sm - _gap),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: palette.ink,
            borderRadius: AppRadii.sm,
            boxShadow: tokens.elevation.pop,
          ),
          child: ClipRRect(
            borderRadius: AppRadii.sm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in visible)
                  AppTappable(
                    onPressed: item.onPressed,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      child: Text(
                        _label(l10n, item),
                        style: AppTextStyles.label.copyWith(
                          fontSize: 13,
                          color: palette.onInk,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
