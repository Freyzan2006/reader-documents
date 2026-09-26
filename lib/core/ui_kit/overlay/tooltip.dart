import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// A tooltip shown on hover/long-press over [child]. Wraps Forui's
/// [FTooltip].
class AppTooltip extends StatelessWidget {
  const AppTooltip({this.message, this.tip, required this.child, super.key})
    : assert(
        message != null || tip != null,
        'Either message or tip must be provided.',
      );

  final String? message;
  final Widget? tip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTooltip(
      style: FTooltipStyleDelta.delta(
        decoration: DecorationDelta.value(
          ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              side: BorderSide(color: colors.border),
              borderRadius: AppRadius.of(context).md,
            ),
            color: colors.card,
            shadows: [
              BoxShadow(
                color: colors.foreground.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        textStyle: TextStyleDelta.value(
          AppTypography.of(context).body.sm.copyWith(color: colors.foreground),
        ),
        padding: EdgeInsetsDelta.value(
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        longPressExitDuration: const Duration(milliseconds: 3000),
      ),
      tipBuilder: (context, controller) => tip ?? Text(message!),
      child: child,
    );
  }
}
