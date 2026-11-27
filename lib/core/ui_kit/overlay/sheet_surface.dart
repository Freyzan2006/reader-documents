import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_shadows.dart';
import 'edge.dart';

class SheetSurface extends StatelessWidget {
  const SheetSurface({
    required this.side,
    required this.child,
    this.expand = true,
    this.onHandleDismiss,
    super.key,
  });

  final AppEdge side;
  final Widget child;
  final bool expand;
  final VoidCallback? onHandleDismiss;

  BorderRadius? get _radius => switch (side) {
    AppEdge.bottom => BorderRadius.only(
      topLeft: AppRadii.lg.topLeft,
      topRight: AppRadii.lg.topRight,
    ),
    AppEdge.top => BorderRadius.only(
      bottomLeft: AppRadii.lg.bottomLeft,
      bottomRight: AppRadii.lg.bottomRight,
    ),
    AppEdge.left || AppEdge.right => null,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.sheet,
        borderRadius: _radius,
        border: switch (side) {
          AppEdge.left => Border(right: BorderSide(color: palette.rule)),
          AppEdge.right => Border(left: BorderSide(color: palette.rule)),
          AppEdge.top || AppEdge.bottom => null,
        },
        boxShadow: side == AppEdge.bottom
            ? tokens.elevation.sheet
            : AppShadows.towards(side.freeEdgeDirection),
      ),
      child: SafeArea(
        child: side.vertical
            ? Column(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  _Handle(onDismiss: onHandleDismiss),
                  if (expand)
                    Expanded(child: child)
                  else
                    Flexible(child: child),
                ],
              )
            : child,
      ),
    );

    return expand ? SizedBox.expand(child: surface) : surface;
  }
}

class _Handle extends StatelessWidget {
  const _Handle({this.onDismiss});

  static const _dismissVelocity = 400.0;

  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final onDismiss = this.onDismiss;
    final handle = Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.tokens.palette.ruleStrong,
          borderRadius: AppRadii.pill,
        ),
        child: const SizedBox(width: 36, height: 4),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: onDismiss == null
          ? handle
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > _dismissVelocity) {
                  onDismiss();
                }
              },
              child: handle,
            ),
    );
  }
}
