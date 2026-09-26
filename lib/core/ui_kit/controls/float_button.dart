import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppFloatButton extends StatelessWidget {
  const AppFloatButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  static const _size = 56.0;

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTappable(
      onPress: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.foreground.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: _size,
          height: _size,
          child: Icon(icon, color: colors.primaryForeground, size: 24),
        ),
      ),
    );
  }
}
