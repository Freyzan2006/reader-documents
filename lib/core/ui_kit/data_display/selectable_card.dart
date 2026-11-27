import 'package:flutter/widgets.dart';

import '../controls/checkbox.dart';
import '../primitives/tappable.dart';
import '../tokens/app_borders.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../theme/app_tokens.dart';

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
    final palette = context.tokens.palette;

    return Semantics(
      button: true,
      selected: selected,
      child: AppTappable(
        onPressed: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.sheet,
            borderRadius: AppRadii.md,
            border: Border.all(
              color: selected ? palette.ink : palette.rule,
              width: selected ? AppBorderWidth.thick : AppBorderWidth.thin,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Stack(
              children: [
                // Behind the content rather than beside it, so the badge
                // never steals width from a preview.
                Positioned(
                  top: 0,
                  right: 0,
                  child: AppSelectionBadge(selected: selected),
                ),
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

class AppSelectionBadge extends StatelessWidget {
  const AppSelectionBadge({required this.selected, super.key});

  final bool selected;

  @override
  Widget build(BuildContext context) =>
      AppCheckMark(checked: selected, round: true, size: 20);
}
