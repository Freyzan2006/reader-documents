import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

class AppFloatButton extends StatelessWidget {
  const AppFloatButton({
    required this.icon,
    required this.onPressed,
    this.label,
    this.extended = true,
    this.semanticsLabel,
    super.key,
  });

  static const _size = 56.0;
  static const _iconSize = 22.0;

  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final bool extended;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final text = label;
    final showLabel = extended && text != null;

    return AppTappable.builder(
      onPressed: onPressed,
      semanticsLabel: semanticsLabel ?? text,
      excludeChildSemantics: true,
      builder: (context, state) => AppFocusRing(
        visible: state.focused,
        borderRadius: AppRadii.lg,
        child: AnimatedContainer(
          duration: tokens.motion.quick,
          height: _size,
          constraints: const BoxConstraints(minWidth: _size),
          padding: EdgeInsets.only(
            left: showLabel ? 16 : 0,
            right: showLabel ? 20 : 0,
          ),
          decoration: BoxDecoration(
            color: state.pressed
                ? Color.lerp(palette.ink, palette.ink3, 0.25)
                : palette.ink,
            borderRadius: AppRadii.lg,
            boxShadow: tokens.elevation.fab,
          ),
          child: AnimatedSize(
            duration: tokens.motion.quick,
            curve: Curves.easeOut,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Icon(icon, size: _iconSize, color: palette.onInk),
                if (showLabel)
                  Text(
                    text,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: palette.onInk,
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
