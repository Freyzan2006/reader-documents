import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../primitives/tappable.dart';
import '../tokens/app_borders.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// A tappable card that represents one option in a single-choice group.
///
/// Selection is carried by the border (primary + [AppBorderWidth.thick]) plus
/// a check badge in the corner. A filled card would fight whatever preview or
/// content it wraps, so the accent stays on the edges.
///
/// The whole card is the tap target, so options are comfortably larger than
/// the ~44dp minimum, and [Semantics] announces them as buttons carrying a
/// `selected` state for screen readers.
class AppSelectableCard extends StatelessWidget {
  const AppSelectableCard({
    required this.selected,
    required this.onPressed,
    required this.child,
    super.key,
  });

  final bool selected;
  final VoidCallback onPressed;

  /// The card's content — typically a preview plus a label.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Semantics(
      button: true,
      selected: selected,
      child: AppTappable(
        onPressed: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: AppRadius.of(context).md,
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? AppBorderWidth.thick : AppBorderWidth.thin,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Stack(
              children: [
                // Behind the content rather than beside it, so the badge
                // never steals width from a preview.
                Positioned(top: 0, right: 0, child: _CheckBadge(selected: selected)),
                // Padded away from the badge so content stays legible where
                // they overlap.
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge({required this.selected});

  final bool selected;

  static const _size = 18.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return SizedBox(
      width: _size,
      height: _size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? colors.primary : colors.card,
          border: selected ? null : AppBorders.all(context),
        ),
        child: selected
            ? Icon(
                AppIcons.check,
                size: _size * 0.6,
                color: colors.primaryForeground,
              )
            : null,
      ),
    );
  }
}