import 'package:flutter/widgets.dart';

import '../controls/checkbox.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// One option of a single-choice row of visual previews — e.g. the theme or
/// document layout pickers on the appearance screen.
///
/// Shows a 3:4 [preview] above a centered [label] and optional [sub] line;
/// selection is carried by a thick ink border plus a check badge.
class AppPreviewChoiceCard extends StatelessWidget {
  const AppPreviewChoiceCard({
    required this.label,
    required this.preview,
    required this.selected,
    required this.onPressed,
    this.sub,
    this.semanticsLabel,
    super.key,
  });

  final String label;
  final String? sub;
  final Widget preview;
  final bool selected;
  final VoidCallback onPressed;

  /// Replaces [label] for screen readers, e.g. when [label] is abbreviated
  /// to fit the card.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final sub = this.sub;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: AppTappable(
        onPressed: onPressed,
        selected: selected,
        semanticsLabel: [semanticsLabel ?? label, ?sub].join(', '),
        excludeChildSemantics: true,
        pressedOpacity: 0.85,
        child: AnimatedContainer(
          duration: tokens.motion.quick,
          padding: const EdgeInsets.fromLTRB(6, 6, 6, AppSpacing.sm),
          foregroundDecoration: BoxDecoration(
            borderRadius: AppRadii.md,
            border: Border.all(
              color: selected ? palette.ink : palette.rule,
              width: selected ? 2 : 1,
            ),
          ),
          decoration: BoxDecoration(
            color: palette.sheet,
            borderRadius: AppRadii.md,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.sm,
                children: [
                  AspectRatio(aspectRatio: 3 / 4, child: preview),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? palette.ink : palette.ink2,
                    ),
                  ),
                  if (sub != null)
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: Text(
                        sub,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.meta.copyWith(
                          fontSize: 11,
                          height: 14 / 11,
                          color: palette.ink3,
                        ),
                      ),
                    ),
                ],
              ),
              if (selected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.sheet,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: const AppCheckMark(
                      checked: true,
                      round: true,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
