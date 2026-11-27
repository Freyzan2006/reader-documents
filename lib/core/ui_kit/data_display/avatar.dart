import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_typography.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    this.image,
    this.initials,
    this.fallbackIcon,
    this.size = 40,
    super.key,
  });

  final ImageProvider? image;
  final String? initials;
  final IconData? fallbackIcon;
  final double size;

  Widget? _fallback(Color color) {
    final text = initials?.trim();
    final icon = fallbackIcon;
    if (text != null && text.isNotEmpty) {
      return Text(
        text.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          fontSize: size * 0.38,
          height: 1,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      );
    }
    if (icon != null) return Icon(icon, size: size * 0.5, color: color);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final fallback = _fallback(palette.ink2);
    final image = this.image;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.shade,
          shape: BoxShape.circle,
          border: Border.all(color: palette.rule),
        ),
        child: ClipOval(
          child: image == null
              ? Center(child: fallback)
              : Image(
                  image: image,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(child: fallback),
                ),
        ),
      ),
    );
  }
}
