import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_spacing.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({required this.icon, required this.onPressed, super.key});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FTappable(
    onPress: onPressed,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.secondary,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(
          icon,
          size: 20,
          color: context.theme.colors.secondaryForeground,
        ),
      ),
    ),
  );
}
