import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

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
  }) => showFDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context, style, animation) => FDialog(
      style: style,
      animation: animation,
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle.merge(style: style.titleTextStyle, child: title),
            if (body != null) ...[const SizedBox(height: AppSpacing.sm), body],
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: AppSpacing.sm,
              children: actions,
            ),
          ],
        ),
      ),
    ),
  );
}
