import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_spacing.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.enabled,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Overrides the icon's own color (e.g. to show an active/toggled state).
  /// The circular background color is unaffected.
  final Color? color;

  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final disabled = !(enabled ?? onPressed != null);
    final iconColor = color ?? colors.secondaryForeground;

    return FTappable(
      onPress: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: disabled
              ? colors.secondary.withValues(alpha: 0.5)
              : colors.secondary,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            size: 20,
            color: disabled ? iconColor.withValues(alpha: 0.5) : iconColor,
          ),
        ),
      ),
    );
  }
}
