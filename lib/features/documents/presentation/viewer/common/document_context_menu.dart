import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class DocumentContextMenu extends StatelessWidget {
  const DocumentContextMenu({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.sheet,
        borderRadius: AppRadii.lg,
        border: AppBorders.all(context),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    child: SizedBox(
                      height: 1,
                      child: ColoredBox(color: palette.rule),
                    ),
                  ),
                row,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DocumentContextMenuRow extends StatelessWidget {
  const DocumentContextMenuRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class DocumentContextMenuButton extends StatelessWidget {
  const DocumentContextMenuButton({
    required this.icon,
    required this.onPressed,
    this.label,
    this.semanticsLabel,
    this.onLongPress,
    this.external = false,
    super.key,
  }) : assert(label != null || semanticsLabel != null);

  static const minSize = 44.0;

  final Widget icon;
  final String? label;
  final String? semanticsLabel;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool external;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final label = this.label;
    final onLongPress = this.onLongPress;

    return AppTappable(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed!();
            },
      onLongPress: onLongPress == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onLongPress();
            },
      semanticsLabel: semanticsLabel ?? label,
      excludeChildSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 2,
            children: [
              SizedBox(
                height: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    icon,
                    if (external)
                      Positioned(
                        right: -9,
                        top: 0,
                        child: Icon(
                          AppIcons.arrowUpRight,
                          size: 10,
                          color: palette.ink3,
                        ),
                      ),
                  ],
                ),
              ),
              if (label != null)
                Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyles.meta.copyWith(
                    fontSize: 11,
                    height: 14 / 11,
                    color: palette.ink2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DocumentHighlightSwatch extends StatelessWidget {
  const DocumentHighlightSwatch({
    required this.color,
    this.selected = false,
    this.size = 22,
    super.key,
  });

  final Color color;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? palette.ink : palette.rule,
            width: selected ? 2 : 1,
          ),
        ),
        child: selected
            ? Icon(
                AppIcons.check,
                size: size * 0.6,
                color: AppContrast.on(color),
              )
            : null,
      ),
    );
  }
}
