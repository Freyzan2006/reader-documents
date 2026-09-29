import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_shadows.dart';
import '../tokens/app_spacing.dart';

/// A centered modal dialog. Wraps Forui's [FDialog]/[showFDialog].
///
/// Exposes only a `show` function — like Flutter's own `showDialog`, a
/// dialog isn't embedded in a tree, it's presented imperatively.
abstract final class AppDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    Widget? body,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
    bool actionsWrap = true,
    int quarterTurns = 0,
  }) => showFDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    routeStyle: FDialogRouteStyleDelta.delta(
      barrierFilter: () => _dimBarrierFilter,
    ),
    style: FDialogStyleDelta.delta(
      insetPadding: EdgeInsetsGeometryDelta.value(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      ),
    ),
    builder: (context, style, animation) => DecoratedBox(
      decoration: const BoxDecoration(boxShadow: AppShadows.floating),
      child: FDialog(
        style: style,
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
        builder: (context, style) => RotatedBox(
          quarterTurns: quarterTurns,
          child: _buildDialogContent(
            context,
            style,
            title,
            body,
            actions,
            actionsWrap,
            quarterTurns != 0,
          ),
        ),
      ),
    ),
  );

  static Widget _buildDialogContent(
    BuildContext context,
    FDialogStyle style,
    Widget title,
    Widget? body,
    List<Widget> actions,
    bool actionsWrap,
    bool isRotated,
  ) {
    final horizontalPadding = isRotated ? AppSpacing.sm : AppSpacing.md;
    final verticalPadding = isRotated ? AppSpacing.sm : AppSpacing.md;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle.merge(style: style.titleTextStyle, child: title),
          if (body != null) ...[
            SizedBox(height: isRotated ? AppSpacing.xs : AppSpacing.sm),
            body,
          ],
          SizedBox(height: isRotated ? AppSpacing.sm : AppSpacing.md),
          if (actionsWrap)
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actions,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: AppSpacing.sm,
              children: actions,
            ),
        ],
      ),
    );
  }

  static ImageFilter _dimBarrierFilter(
    BuildContext context,
    double animation,
  ) => ColorFilter.mode(
    Color.lerp(
      const Color(0x00000000),
      context.theme.colors.barrier,
      animation,
    )!,
    BlendMode.srcOver,
  );
}
